import { test, beforeEach, afterEach } from "node:test";
import assert from "node:assert/strict";
import { readFileSync, readdirSync } from "node:fs";
import worker from "../src/index.js";

const ORIGIN = "https://w.test";
// Valori finti che non devono mai finire in un log né in un indirizzo.
const CODE = "SENTINEL-code-123";
const ACCESS = "eyJ-ACCESS-SENTINEL-0000000000";
const REFRESH = "eyJ-REFRESH-SENTINEL-000000000";
const ONLINE_ID = "SentinelPlayer";
const ACCOUNT = "1234567890123456789";
const NEW_ACCESS = "eyJ-NEW-ACCESS-SENTINEL-00000";
const NEW_REFRESH = "eyJ-NEW-REFRESH-SENTINEL-0000";

const realFetch = globalThis.fetch;
const consoleMethods = ["log", "info", "warn", "error", "debug"];
const realConsole = {};
let sony;
let logged;
let requests;

beforeEach(() => {
  logged = [];
  requests = [];
  for (const method of consoleMethods) {
    realConsole[method] = console[method];
    console[method] = (...args) => logged.push(args.map(String).join(" "));
  }
  sony = () => new Response("unexpected", { status: 500 });
  globalThis.fetch = async (url, init) => {
    requests.push({ url: String(url), init });
    return sony(new URL(String(url)), init);
  };
});

afterEach(() => {
  globalThis.fetch = realFetch;
  for (const method of consoleMethods) console[method] = realConsole[method];
});

function call(path, body, { method = "POST", raw } = {}) {
  const request = new Request(ORIGIN + path, {
    method,
    headers: { "Content-Type": "application/json" },
    body: method === "GET" ? undefined : (raw ?? JSON.stringify(body)),
  });
  return worker.fetch(request, { KV: {}, STEAM_API_KEY: "key" });
}

const tokens = (access = NEW_ACCESS, refresh = NEW_REFRESH) =>
  Response.json({
    access_token: access,
    refresh_token: refresh,
    expires_in: 3599,
    refresh_token_expires_in: 5183999,
  });

const title = (id, platform, extra = {}) => ({
  npServiceName: platform.includes("PS5") ? "trophy2" : "trophy",
  npCommunicationId: id,
  trophySetVersion: "01.00",
  trophyTitleName: `Game ${id}`,
  trophyTitleIconUrl: `https://image.api.playstation.com/${id}.png`,
  trophyTitlePlatform: platform,
  definedTrophies: { bronze: 10, silver: 3, gold: 1, platinum: 1 },
  progress: 40,
  earnedTrophies: { bronze: 5, silver: 1, gold: 0, platinum: 0 },
  lastUpdatedDateTime: "2025-01-02T03:04:05Z",
  ...extra,
});

/** Sony com'è fatto: token, riepilogo dei trofei e profilo dell'account. */
const profileApi = (url) => {
  if (url.pathname.endsWith("/token")) return tokens();
  if (url.pathname.endsWith("/trophySummary")) {
    return Response.json({ accountId: ACCOUNT, trophyLevel: 12 });
  }
  if (url.pathname === `/api/userProfile/v1/internal/users/${ACCOUNT}/profiles`) {
    return Response.json({ profile: { onlineId: ONLINE_ID } });
  }
  return new Response("no", { status: 404 });
};

// ------------------------------------------------------------ authorize

test("/psn/authorize gives the login page and the scheme Sony returns to, without calling Sony", async () => {
  const response = await call("/psn/authorize", {});
  const data = await response.json();

  assert.equal(response.status, 200);
  assert.equal(data.callbackScheme, "com.scee.psxandroid.scecompcall");
  const url = new URL(data.url);
  assert.equal(url.origin + url.pathname, "https://ca.account.sony.com/api/authz/v3/oauth/authorize");
  assert.equal(url.searchParams.get("response_type"), "code");
  assert.equal(url.searchParams.get("access_type"), "offline");
  assert.equal(url.searchParams.get("redirect_uri"), "com.scee.psxandroid.scecompcall://redirect");
  assert.equal(url.searchParams.get("scope"), "psn:mobile.v2.core psn:clientapp");
  assert.match(url.searchParams.get("client_id"), /^[0-9a-f-]{36}$/);
  assert.equal(requests.length, 0);
});

// ---------------------------------------------------------------- login

test("/psn/login exchanges the code and returns the tokens with the online id", async () => {
  sony = profileApi;

  const response = await call("/psn/login", { code: CODE });
  const data = await response.json();

  assert.equal(response.status, 200);
  assert.deepEqual(data, {
    accessToken: NEW_ACCESS,
    refreshToken: NEW_REFRESH,
    expiresIn: 3599,
    refreshTokenExpiresIn: 5183999,
    onlineId: ONLINE_ID,
  });
  assert.equal(response.headers.get("Cache-Control"), "no-store");

  const exchange = requests.find((r) => r.url.endsWith("/oauth/token"));
  const form = new URLSearchParams(exchange.init.body);
  assert.equal(form.get("code"), CODE);
  assert.equal(form.get("grant_type"), "authorization_code");
  assert.equal(form.get("redirect_uri"), "com.scee.psxandroid.scecompcall://redirect");
  assert.match(exchange.init.headers.Authorization, /^Basic /);
});

test("/psn/login still works when the profile cannot be read", async () => {
  sony = (url) =>
    url.pathname.endsWith("/token") ? tokens() : new Response("no", { status: 500 });

  const data = await (await call("/psn/login", { code: CODE })).json();

  assert.equal(data.accessToken, NEW_ACCESS);
  assert.equal(data.onlineId, null);
});

test("/psn/login refuses a missing or malformed code without asking Sony", async () => {
  for (const body of [{}, { code: "" }, { code: 12345 }, { code: "a b" }, { code: "x".repeat(300) }]) {
    assert.equal((await call("/psn/login", body)).status, 400, JSON.stringify(body));
  }
  assert.equal(requests.length, 0);
});

test("/psn/login reports a code Sony rejects as 401 and an outage as 502", async () => {
  sony = () => new Response(JSON.stringify({ error: "invalid_grant" }), { status: 400 });
  const rejected = await call("/psn/login", { code: CODE });
  assert.equal(rejected.status, 401);
  assert.deepEqual(await rejected.json(), { error: "psn_rejected" });

  sony = () => new Response("down", { status: 503 });
  assert.equal((await call("/psn/login", { code: CODE })).status, 502);

  globalThis.fetch = async () => {
    throw new Error("network");
  };
  assert.equal((await call("/psn/login", { code: CODE })).status, 502);

  sony = () => Response.json({ access_token: NEW_ACCESS });
  globalThis.fetch = async () => sony();
  assert.equal((await call("/psn/login", { code: CODE })).status, 502);
});

// -------------------------------------------------------------- refresh

test("/psn/refresh renews the tokens", async () => {
  sony = () => tokens();

  const response = await call("/psn/refresh", { refreshToken: REFRESH });
  const data = await response.json();

  assert.equal(response.status, 200);
  assert.equal(data.accessToken, NEW_ACCESS);
  assert.equal(data.refreshToken, NEW_REFRESH);
  const form = new URLSearchParams(requests[0].init.body);
  assert.equal(form.get("grant_type"), "refresh_token");
  assert.equal(form.get("refresh_token"), REFRESH);
});

test("/psn/refresh refuses a bad token and reports an expired one as 401", async () => {
  assert.equal((await call("/psn/refresh", { refreshToken: "short" })).status, 400);
  assert.equal((await call("/psn/refresh", {})).status, 400);
  assert.equal(requests.length, 0);

  sony = () => new Response("{}", { status: 400 });
  assert.equal((await call("/psn/refresh", { refreshToken: REFRESH })).status, 401);
});

// --------------------------------------------------------------- titles

test("/psn/titles keeps the PS4 and PS5 games and leaves PS3 and Vita out", async () => {
  sony = () =>
    Response.json({
      totalItemCount: 4,
      trophyTitles: [
        title("NPWR20001_00", "PS5"),
        title("NPWR10002_00", "PS4"),
        title("NPWR10003_00", "PS4,PSVITA"),
        title("NPWR10004_00", "PS3"),
        title("NPWR10005_00", "PSVITA"),
        title("NPWR10006_00", "PS3,PSVITA"),
      ],
    });

  const { titles } = await (await call("/psn/titles", { accessToken: ACCESS })).json();

  assert.deepEqual(
    titles.map((t) => [t.id, t.consoles, t.service]),
    [
      ["NPWR20001_00", ["PS5"], "trophy2"],
      ["NPWR10002_00", ["PS4"], "trophy"],
      ["NPWR10003_00", ["PS4"], "trophy"],
    ]
  );
});

test("/psn/titles shapes each game with its counts", async () => {
  sony = () => Response.json({ trophyTitles: [title("NPWR20001_00", "PS5")] });

  const { titles } = await (await call("/psn/titles", { accessToken: ACCESS })).json();

  assert.deepEqual(titles[0], {
    id: "NPWR20001_00",
    service: "trophy2",
    name: "Game NPWR20001_00",
    iconUrl: "https://image.api.playstation.com/NPWR20001_00.png",
    consoles: ["PS5"],
    defined: { bronze: 10, silver: 3, gold: 1, platinum: 1 },
    earned: { bronze: 5, silver: 1, gold: 0, platinum: 0 },
    total: 15,
    earnedCount: 6,
    progress: 40,
    lastUpdated: "2025-01-02T03:04:05Z",
  });
});

test("/psn/titles follows the pages until they end", async () => {
  sony = (url) => {
    const offset = Number(url.searchParams.get("offset"));
    return offset === 0
      ? Response.json({ trophyTitles: [title("NPWR20001_00", "PS5")], nextOffset: 100 })
      : Response.json({ trophyTitles: [title("NPWR20002_00", "PS5")] });
  };

  const { titles } = await (await call("/psn/titles", { accessToken: ACCESS })).json();

  assert.deepEqual(titles.map((t) => t.id), ["NPWR20001_00", "NPWR20002_00"]);
  assert.equal(requests.length, 2);
});

test("/psn/titles stops when the pages do not advance", async () => {
  sony = () => Response.json({ trophyTitles: [title("NPWR20001_00", "PS5")], nextOffset: 0 });

  const response = await call("/psn/titles", { accessToken: ACCESS });

  assert.equal(response.status, 200);
  assert.equal(requests.length, 1);
});

test("/psn/titles ignores entries that are not valid games and bad icon addresses", async () => {
  sony = () =>
    Response.json({
      trophyTitles: [
        title("not-an-id", "PS5"),
        title("NPWR20001_00", "PS5", { trophyTitleIconUrl: "javascript:alert(1)" }),
      ],
    });

  const { titles } = await (await call("/psn/titles", { accessToken: ACCESS })).json();

  assert.equal(titles.length, 1);
  assert.equal(titles[0].iconUrl, null);
});

test("/psn/titles reports an expired access as 401 and other failures as 502", async () => {
  sony = () => new Response("{}", { status: 401 });
  const expired = await call("/psn/titles", { accessToken: ACCESS });
  assert.equal(expired.status, 401);
  assert.deepEqual(await expired.json(), { error: "token_expired" });

  sony = () => new Response("{}", { status: 500 });
  assert.equal((await call("/psn/titles", { accessToken: ACCESS })).status, 502);

  sony = () => Response.json({ error: { message: "x" } });
  assert.equal((await call("/psn/titles", { accessToken: ACCESS })).status, 502);

  assert.equal((await call("/psn/titles", { accessToken: "x" })).status, 400);
});

// ------------------------------------------------------------- trophies

const definition = (id, extra = {}) => ({
  trophyId: id,
  trophyHidden: false,
  trophyType: "bronze",
  trophyName: `Trophy ${id}`,
  trophyDetail: `Do ${id}`,
  trophyIconUrl: `https://image.api.playstation.com/t${id}.png`,
  trophyGroupId: "default",
  ...extra,
});

function trophiesSony({ definitions, mine }) {
  return (url) => {
    const own = url.pathname.includes("/users/me/");
    return Response.json({ trophies: own ? mine : definitions });
  };
}

test("/psn/trophies joins the definitions with what the user earned", async () => {
  sony = trophiesSony({
    definitions: [
      definition(0, { trophyType: "platinum" }),
      definition(1, { trophyHidden: true }),
      definition(2, { trophyType: "weird" }),
    ],
    mine: [
      {
        trophyId: 0,
        earned: true,
        earnedDateTime: "2025-03-04T05:06:07Z",
        trophyEarnedRate: "1.9",
      },
      { trophyId: 1, earned: false, trophyEarnedRate: "37.25" },
    ],
  });

  const response = await call("/psn/trophies", {
    accessToken: ACCESS,
    id: "NPWR20001_00",
    service: "trophy2",
  });
  const { trophies } = await response.json();

  assert.equal(response.status, 200);
  assert.deepEqual(trophies[0], {
    id: "0",
    name: "Trophy 0",
    detail: "Do 0",
    iconUrl: "https://image.api.playstation.com/t0.png",
    type: "platinum",
    hidden: false,
    rarity: 1.9,
    group: "default",
    earned: true,
    earnedAt: "2025-03-04T05:06:07Z",
  });
  assert.equal(trophies[1].rarity, 37.25, "the rate comes from the user's list");
  assert.equal(trophies[1].hidden, true);
  assert.equal(trophies[1].earned, false);
  assert.equal(trophies[1].earnedAt, null);
  assert.equal(trophies[2].type, null, "an unknown type is not guessed");
  assert.equal(trophies[2].rarity, null, "a missing rate is not zero");
  assert.equal(trophies[2].earned, false, "a trophy Sony does not list for the user is not earned");
});

test("/psn/trophies still reads a rate that Sony puts in the definitions, and prefers the user's", async () => {
  sony = trophiesSony({
    definitions: [
      definition(0, { trophyEarnedRate: "5.5" }),
      definition(1, { trophyEarnedRate: "5.5" }),
    ],
    mine: [{ trophyId: 1, earned: false, trophyEarnedRate: "8.0" }],
  });

  const { trophies } = await (
    await call("/psn/trophies", { accessToken: ACCESS, id: "NPWR20001_00", service: "trophy" })
  ).json();

  assert.equal(trophies[0].rarity, 5.5);
  assert.equal(trophies[1].rarity, 8);
});

test("/psn/trophies asks Sony for the right title, service and every group", async () => {
  sony = trophiesSony({ definitions: [], mine: [] });

  await call("/psn/trophies", { accessToken: ACCESS, id: "NPWR20001_00", service: "trophy2" });

  assert.equal(requests.length, 2);
  for (const request of requests) {
    const url = new URL(request.url);
    assert.match(url.pathname, /npCommunicationIds\/NPWR20001_00\/trophyGroups\/all\/trophies$/);
    assert.equal(url.searchParams.get("npServiceName"), "trophy2");
    assert.equal(request.init.headers.Authorization, `Bearer ${ACCESS}`);
  }
});

test("/psn/trophies refuses a bad id, service or token without asking Sony", async () => {
  const good = { accessToken: ACCESS, id: "NPWR20001_00", service: "trophy" };
  for (const bad of [
    { ...good, id: "NPWR1_0" },
    { ...good, id: "../../etc" },
    { ...good, service: "other" },
    { ...good, accessToken: "short" },
    { id: good.id, service: good.service },
  ]) {
    assert.equal((await call("/psn/trophies", bad)).status, 400, JSON.stringify(bad));
  }
  assert.equal(requests.length, 0);
});

// -------------------------------------------------- the request itself

test("only POST is accepted, and a token in the address is never read", async () => {
  const get = await call(`/psn/titles?accessToken=${ACCESS}`, undefined, { method: "GET" });

  assert.equal(get.status, 405);
  assert.equal(requests.length, 0);
});

test("an unknown PlayStation route is a 404", async () => {
  assert.equal((await call("/psn/nothing", {})).status, 404);
});

test("a body that is missing, not JSON, not an object or too large is refused", async () => {
  for (const raw of ["", "nope", "[1,2]", "null", JSON.stringify({ code: "x".repeat(9000) })]) {
    const response = await call("/psn/login", undefined, { raw });
    assert.equal(response.status, 400, raw.slice(0, 20));
  }
  assert.equal(requests.length, 0);
});

// -------------------------------------------------------------- profile

test("/psn/login finds the name through the trophy summary and the profile of that account", async () => {
  sony = profileApi;

  const data = await (await call("/psn/login", { code: CODE })).json();

  assert.equal(data.onlineId, ONLINE_ID);
  const asked = requests.filter((r) => !r.url.endsWith("/oauth/token"));
  assert.deepEqual(
    asked.map((r) => new URL(r.url).pathname),
    [
      "/api/trophy/v1/users/me/trophySummary",
      `/api/userProfile/v1/internal/users/${ACCOUNT}/profiles`,
    ]
  );
  for (const request of asked) {
    assert.equal(request.init.headers.Authorization, `Bearer ${NEW_ACCESS}`);
    assert.ok(!request.url.includes(NEW_ACCESS), "the token is never in an address");
  }
});

test("/psn/profile gives the name and the steps that found it, with no data in them", async () => {
  sony = profileApi;

  const response = await call("/psn/profile", { accessToken: ACCESS });
  const data = await response.json();

  assert.equal(response.status, 200);
  assert.equal(response.headers.get("Cache-Control"), "no-store");
  assert.deepEqual(data, { onlineId: ONLINE_ID, attempts: ["summary 200", "profile 200"] });
});

test("the name falls back to the old profile address when the account profile fails", async () => {
  sony = (url) =>
    url.pathname.endsWith("/trophySummary")
      ? Response.json({ accountId: ACCOUNT })
      : url.pathname.includes("profile2")
        ? Response.json({ profile: { onlineId: ONLINE_ID } })
        : new Response("no", { status: 404 });

  const data = await (await call("/psn/profile", { accessToken: ACCESS })).json();

  assert.deepEqual(data, {
    onlineId: ONLINE_ID,
    attempts: ["summary 200", "profile 404", "legacy 200"],
  });
  const legacy = requests.find((r) => r.url.includes("profile2"));
  assert.equal(new URL(legacy.url).hostname, "us-prof.np.community.playstation.net");
});

test("with no name anywhere the answer is null with the statuses, not an error", async () => {
  sony = (url) =>
    url.pathname.endsWith("/trophySummary")
      ? new Response("no", { status: 403 })
      : new Response("no", { status: 404 });

  const response = await call("/psn/profile", { accessToken: ACCESS });
  const data = await response.json();

  assert.equal(response.status, 200);
  assert.deepEqual(data, { onlineId: null, attempts: ["summary 403", "legacy 404"] });
});

test("an account id that is not a number never goes into an address", async () => {
  sony = (url) =>
    url.pathname.endsWith("/trophySummary")
      ? Response.json({ accountId: "../../evil" })
      : new Response("no", { status: 404 });

  const data = await (await call("/psn/profile", { accessToken: ACCESS })).json();

  assert.equal(data.onlineId, null);
  assert.ok(!requests.some((r) => r.url.includes("evil")));
  assert.deepEqual(data.attempts, ["summary 200", "legacy 404"]);
});

test("Sony not answering at all is told as 'down', and the name is still null", async () => {
  globalThis.fetch = async () => {
    throw new Error(`boom ${ACCESS}`);
  };

  const data = await (await call("/psn/profile", { accessToken: ACCESS })).json();

  assert.deepEqual(data, { onlineId: null, attempts: ["summary down", "legacy down"] });
});

test("/psn/profile refuses a missing or malformed token without asking Sony", async () => {
  for (const body of [{}, { accessToken: "" }, { accessToken: 5 }, { accessToken: "short" }]) {
    assert.equal((await call("/psn/profile", body)).status, 400, JSON.stringify(body));
  }
  assert.equal(requests.length, 0);
});

test("the steps of the name lookup are only a step and a status, whatever Sony says", async () => {
  sony = () => new Response(JSON.stringify({ error: `${ACCESS} ${ONLINE_ID}` }), { status: 500 });

  const data = await (await call("/psn/profile", { accessToken: ACCESS })).json();

  for (const attempt of data.attempts) assert.match(attempt, /^(summary|profile|legacy) (\d{3}|down)$/);
});

// ------------------------------------------------------------ logs

test("nothing sensitive reaches the logs or an error answer, whatever happens", async () => {
  const secrets = [CODE, ACCESS, REFRESH, ONLINE_ID, NEW_ACCESS, NEW_REFRESH, ACCOUNT];
  const answers = [];

  sony = profileApi;
  await call("/psn/login", { code: CODE });
  await call("/psn/profile", { accessToken: ACCESS });

  for (const status of [400, 401, 500]) {
    sony = () => new Response(JSON.stringify({ error: { message: `${ACCESS} ${CODE}` } }), { status });
    answers.push(await (await call("/psn/login", { code: CODE })).text());
    answers.push(await (await call("/psn/refresh", { refreshToken: REFRESH })).text());
    answers.push(await (await call("/psn/titles", { accessToken: ACCESS })).text());
    answers.push(await (await call("/psn/profile", { accessToken: ACCESS })).text());
    answers.push(
      await (await call("/psn/trophies", { accessToken: ACCESS, id: "NPWR20001_00", service: "trophy" })).text()
    );
  }
  globalThis.fetch = async () => {
    throw new Error(`boom ${ACCESS} ${CODE}`);
  };
  answers.push(await (await call("/psn/login", { code: CODE })).text());
  answers.push(await (await call("/psn/titles", { accessToken: ACCESS })).text());

  for (const secret of secrets) {
    assert.ok(!logged.some((line) => line.includes(secret)), `${secret} in a log`);
    assert.ok(!answers.some((text) => text.includes(secret)), `${secret} in an error answer`);
  }
  assert.deepEqual(logged, [], "the PlayStation routes write nothing to the console");
});

test("the Worker source has no console calls at all", () => {
  const dir = new URL("../src/", import.meta.url);
  for (const file of readdirSync(dir).filter((name) => name.endsWith(".js"))) {
    const source = readFileSync(new URL(file, dir), "utf8");
    assert.doesNotMatch(source, /\bconsole\s*\./, `${file} calls console`);
  }
});

test("the invocation logs, which keep paths, headers and IPs, stay off", () => {
  const text = readFileSync(new URL("../wrangler.jsonc", import.meta.url), "utf8");
  const config = JSON.parse(text.replace(/^\s*\/\/.*$/gm, ""));

  assert.equal(config.observability.logs.invocation_logs, false);
});
