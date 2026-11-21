import { test, beforeEach, afterEach } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import worker from "../src/index.js";
import { TIERS, UNLIMITED, retryAfterSeconds } from "../src/limits.js";

const ORIGIN = "https://w.test";
const SESSION = "123e4567-e89b-42d3-a456-426614174000";
const ACCESS = "eyJ-ACCESS-SENTINEL-0000000000";

const realFetch = globalThis.fetch;
let upstream;

beforeEach(() => {
  upstream = [];
  globalThis.fetch = async (url) => {
    upstream.push(String(url));
    return Response.json({});
  };
});

afterEach(() => {
  globalThis.fetch = realFetch;
});

/** Un binding finto: ricorda le chiavi e risponde come gli si dice. */
function binding(answer = () => ({ success: true })) {
  const keys = [];
  return {
    keys,
    async limit({ key }) {
      keys.push(key);
      return answer(key);
    },
  };
}

const bindings = (answer) => ({
  RL_IDENTITY: binding(answer),
  RL_USER: binding(answer),
  RL_GAME: binding(answer),
  RL_LIGHT: binding(answer),
  RL_PSN: binding(answer),
});

const kv = { get: async () => null, put: async () => {}, delete: async () => {} };
const environment = (limiters = {}) => ({ KV: kv, STEAM_API_KEY: "key", ...limiters });

function call(path, { method = "GET", headers = {}, body, env = environment() } = {}) {
  return worker.fetch(
    new Request(ORIGIN + path, { method, headers, body }),
    env
  );
}

/** I binding chiamati, con le loro chiavi. */
function asked(limiters) {
  return Object.fromEntries(
    Object.entries(limiters)
      .filter(([, limiter]) => limiter.keys.length > 0)
      .map(([name, limiter]) => [name, limiter.keys])
  );
}

// ------------------------------------------------------------ gruppi

const EXPECTED = {
  "/auth/steam": "RL_IDENTITY",
  "/auth/steam/callback": "RL_IDENTITY",
  "/auth/token": "RL_IDENTITY",
  "/logout": "RL_IDENTITY",
  "/psn/authorize": "RL_IDENTITY",
  "/psn/login": "RL_IDENTITY",
  "/psn/refresh": "RL_IDENTITY",
  "/user": "RL_USER",
  "/library": "RL_USER",
  "/game": "RL_GAME",
  "/achievements": "RL_GAME",
  "/playerAchievements": "RL_GAME",
  "/covers": "RL_LIGHT",
  "/rarity": "RL_LIGHT",
  "/category": "RL_LIGHT",
  "/catalog": "RL_LIGHT",
  "/psn/titles": "RL_PSN",
  "/psn/trophies": "RL_PSN",
  "/psn/profile": "RL_PSN",
};

test("each route is guarded by the limiter of its group", async () => {
  for (const [path, name] of Object.entries(EXPECTED)) {
    const limiters = bindings();
    await call(path, { env: environment(limiters) });
    assert.deepEqual(Object.keys(asked(limiters)), [name], path);
  }
});

test("every route of the Worker is in a group or is deliberately left out", () => {
  const index = readFileSync(new URL("../src/index.js", import.meta.url), "utf8");
  const psn = readFileSync(new URL("../src/psn.js", import.meta.url), "utf8");
  const routes = [
    ...[...index.matchAll(/url\.pathname === "([^"]+)"/g)].map((m) => m[1]),
    ...[...psn.matchAll(/^\s*"(\/psn\/[a-z]+)":/gm)].map((m) => m[1]),
  ];
  const known = new Set([...TIERS.flatMap((tier) => tier.paths), ...UNLIMITED]);

  assert.ok(routes.length >= 20, "the routes were found");
  for (const route of routes) assert.ok(known.has(route), `${route} has no limit and is not listed as unlimited`);
  for (const path of known) assert.ok(routes.includes(path), `${path} is listed but is not a route`);
});

test("the pages that call nobody are not limited, and neither is an unknown path", async () => {
  for (const path of [...UNLIMITED, "/nothing-here"]) {
    const limiters = bindings();
    assert.equal(await retryAfterSeconds(new Request(ORIGIN + path), limiters, new URL(ORIGIN + path)), null);
    assert.deepEqual(asked(limiters), {}, path);
  }
});

test("a preflight request is not counted", async () => {
  const limiters = bindings(() => ({ success: false }));

  const response = await call("/covers", { method: "OPTIONS", env: environment(limiters) });

  assert.equal(response.status, 200);
  assert.deepEqual(asked(limiters), {});
});

// ------------------------------------------------------------ risposta

test("over the limit the answer is a 429 with the wait, and nothing is asked upstream", async () => {
  const limiters = bindings(() => ({ success: false }));

  for (const path of ["/covers?ids=1", "/game?appid=1", "/catalog"]) {
    const response = await call(path, { env: environment(limiters) });

    assert.equal(response.status, 429, path);
    assert.deepEqual(await response.json(), { error: "rate_limited" });
    assert.equal(response.headers.get("Retry-After"), "60");
    assert.equal(response.headers.get("Access-Control-Allow-Origin"), "*");
  }
  assert.deepEqual(upstream, []);
});

test("a refused PlayStation call is stopped before its body is read or Sony is asked", async () => {
  const limiters = bindings(() => ({ success: false }));

  const response = await call("/psn/titles", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ accessToken: ACCESS }),
    env: environment(limiters),
  });

  assert.equal(response.status, 429);
  assert.deepEqual(upstream, []);
});

test("within the limit the request goes on as it always did", async () => {
  const limiters = bindings();

  const response = await call("/psn/authorize", { method: "POST", body: "{}", env: environment(limiters) });

  assert.equal(response.status, 200);
  assert.equal(asked(limiters).RL_IDENTITY.length, 1);
});

// ------------------------------------------------------------ chiavi

test("the key is the address of the client, or 'unknown' without one", async () => {
  const limiters = bindings();
  await call("/covers?ids=1", { headers: { "CF-Connecting-IP": "203.0.113.7" }, env: environment(limiters) });
  await call("/covers?ids=1", { env: environment(limiters) });

  assert.deepEqual(limiters.RL_LIGHT.keys, ["ip:203.0.113.7", "ip:unknown"]);
});

test("with a session the key is a hash of the token, never the token", async () => {
  for (const request of [
    { path: "/user", headers: { Authorization: `Bearer ${SESSION}` } },
    { path: "/playerAchievements?appid=1", headers: { Authorization: `Bearer ${SESSION}` } },
  ]) {
    const limiters = bindings();
    await call(request.path, { headers: { ...request.headers, "CF-Connecting-IP": "203.0.113.7" }, env: environment(limiters) });

    const key = Object.values(asked(limiters))[0][0];
    assert.match(key, /^t:[0-9a-f]{32}$/, request.path);
    assert.ok(!key.includes(SESSION) && !key.includes("203.0.113.7"));
  }
});

test("the same token always gives the same key, and two tokens give two", async () => {
  const limiters = bindings();
  const other = "223e4567-e89b-42d3-a456-426614174000";
  for (const token of [SESSION, SESSION, other]) {
    await call("/user", { headers: { Authorization: `Bearer ${token}` }, env: environment(limiters) });
  }

  const [a, b, c] = limiters.RL_USER.keys;
  assert.equal(a, b);
  assert.notEqual(a, c);
});

test("a token in the address is not a session: the key is the address", async () => {
  const limiters = bindings();
  await call(`/user?token=${SESSION}`, {
    headers: { "CF-Connecting-IP": "203.0.113.7" },
    env: environment(limiters),
  });

  assert.deepEqual(limiters.RL_USER.keys, ["ip:203.0.113.7"]);
});

test("a token that is not a session falls back to the address", async () => {
  const limiters = bindings();
  await call("/user", {
    headers: { Authorization: "Bearer privacy-policy", "CF-Connecting-IP": "203.0.113.7" },
    env: environment(limiters),
  });

  assert.deepEqual(limiters.RL_USER.keys, ["ip:203.0.113.7"]);
});

test("routes that do not belong to a session ignore the token", async () => {
  const limiters = bindings();
  await call("/game?appid=1", {
    headers: { Authorization: `Bearer ${SESSION}`, "CF-Connecting-IP": "203.0.113.7" },
    env: environment(limiters),
  });

  assert.deepEqual(limiters.RL_GAME.keys, ["ip:203.0.113.7"]);
});

test("the tokens of a PlayStation call never reach the limiter", async () => {
  const limiters = bindings();
  await call("/psn/trophies", {
    method: "POST",
    headers: { "CF-Connecting-IP": "203.0.113.7" },
    body: JSON.stringify({ accessToken: ACCESS, id: "NPWR20001_00", service: "trophy" }),
    env: environment(limiters),
  });

  assert.deepEqual(limiters.RL_PSN.keys, ["ip:203.0.113.7"]);
});

// ------------------------------------------------------------ guasti

test("with no binding, or one that fails or answers something unexpected, nobody is blocked", async () => {
  const cases = [
    {},
    { RL_IDENTITY: { limit: async () => { throw new Error("down"); } } },
    { RL_IDENTITY: { limit: async () => ({}) } },
    { RL_IDENTITY: { limit: async () => undefined } },
  ];
  for (const limiters of cases) {
    const response = await call("/psn/authorize", { method: "POST", body: "{}", env: environment(limiters) });
    assert.equal(response.status, 200, JSON.stringify(Object.keys(limiters)));
  }
});

// ------------------------------------------------------------ configurazione

function config() {
  const text = readFileSync(new URL("../wrangler.jsonc", import.meta.url), "utf8");
  return JSON.parse(text.replace(/^\s*\/\/.*$/gm, ""));
}

test("wrangler.jsonc declares exactly the bindings the code asks for", () => {
  const declared = config().ratelimits.map((entry) => entry.name).sort();
  const used = [...new Set(TIERS.map((tier) => tier.binding))].sort();

  assert.deepEqual(declared, used);
});

test("the namespaces are unique and each limit is a valid window", () => {
  const { ratelimits } = config();

  assert.equal(new Set(ratelimits.map((r) => r.namespace_id)).size, ratelimits.length);
  for (const entry of ratelimits) {
    assert.match(entry.namespace_id, /^[1-9]\d*$/, entry.name);
    assert.ok([10, 60].includes(entry.simple.period), `${entry.name} period`);
    assert.ok(Number.isInteger(entry.simple.limit) && entry.simple.limit > 0, `${entry.name} limit`);
  }
});

test("no limit is below what a real sync needs", () => {
  const limits = Object.fromEntries(
    config().ratelimits.map((entry) => [entry.name, entry.simple.limit / entry.simple.period * 60])
  );

  // La sincronizzazione di Steam fa 15 richieste insieme, quella di PlayStation
  // arriva a circa 360 al minuto, il primo avvio scarica il catalogo a pezzi.
  assert.ok(limits.RL_GAME >= 1800, "Steam sync");
  assert.ok(limits.RL_PSN >= 400, "PlayStation sync");
  assert.ok(limits.RL_LIGHT >= 60, "catalog and covers");
  assert.ok(limits.RL_IDENTITY >= 10, "login");
  assert.ok(limits.RL_USER >= 10, "user and library");
});
