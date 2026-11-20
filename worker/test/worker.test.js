import { test, beforeEach, afterEach } from "node:test";
import assert from "node:assert/strict";
import worker from "../src/index.js";

const ORIGIN = "https://w.test";
const STEAM_ID = "76561190000000001";
const VERIFIER = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk";
const CHALLENGE = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"; // RFC 7636, appendix B
const SIGNED = "signed,op_endpoint,claimed_id,identity,return_to,response_nonce,assoc_handle";

class FakeKV {
  store = new Map();
  reads = [];
  async get(key) {
    this.reads.push(key);
    return this.store.get(key) ?? null;
  }
  async put(key, value) {
    this.store.set(key, value);
  }
  async delete(key) {
    this.store.delete(key);
  }
}

const realFetch = globalThis.fetch;
let kv;
let steam;

/** Stubs every outgoing call to Steam; `steam` can be replaced per test. */
beforeEach(() => {
  kv = new FakeKV();
  steam = (url) =>
    url.includes("openid/login")
      ? new Response("ns:http://specs.openid.net/auth/2.0\nis_valid:true\n")
      : Response.json({ response: { players: [{ steamid: STEAM_ID }] } });
  globalThis.fetch = async (url, init) => steam(String(url), init);
});

afterEach(() => {
  globalThis.fetch = realFetch;
});

function call(path, { method = "GET", headers = {}, body } = {}) {
  const request = new Request(ORIGIN + path, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
    redirect: "manual",
  });
  return worker.fetch(request, { KV: kv, STEAM_API_KEY: "key" });
}

function callbackPath({ returnTo, claimed, signed } = {}) {
  const query = new URLSearchParams({
    "openid.mode": "id_res",
    "openid.op_endpoint": "https://steamcommunity.com/openid/login",
    "openid.claimed_id": claimed ?? `https://steamcommunity.com/openid/id/${STEAM_ID}`,
    "openid.return_to": returnTo ?? `${ORIGIN}/auth/steam/callback?c=${CHALLENGE}`,
    "openid.signed": signed ?? SIGNED,
  });
  return `/auth/steam/callback?${query}`;
}

/** Runs the login up to the one-time code and returns it. */
async function loginForCode() {
  const response = await call(callbackPath());
  assert.equal(response.status, 302);
  return new URL(response.headers.get("location")).searchParams.get("code");
}

async function loginForToken() {
  const code = await loginForCode();
  const response = await call("/auth/token", {
    method: "POST",
    body: { code, verifier: VERIFIER },
  });
  return (await response.json()).token;
}

test("login: the challenge goes inside the return_to signed by Steam", async () => {
  const response = await call(`/auth/steam?challenge=${CHALLENGE}`);

  assert.equal(response.status, 302);
  const location = new URL(response.headers.get("location"));
  assert.equal(location.origin, "https://steamcommunity.com");
  assert.equal(
    location.searchParams.get("openid.return_to"),
    `${ORIGIN}/auth/steam/callback?c=${CHALLENGE}`
  );
});

test("login: a malformed challenge is refused", async () => {
  assert.equal((await call("/auth/steam?challenge=short")).status, 400);
});

test("callback: an assertion made for another site is refused", async () => {
  const response = await call(
    callbackPath({ returnTo: `https://evil.test/auth/steam/callback?c=${CHALLENGE}` })
  );

  assert.equal(response.status, 401);
  assert.equal(kv.store.size, 0);
});

test("callback: unsigned return_to or a forged claimed_id are refused", async () => {
  assert.equal((await call(callbackPath({ signed: "signed,claimed_id" }))).status, 401);
  assert.equal(
    (await call(callbackPath({ claimed: "https://evil.test/openid/id/1" }))).status,
    401
  );
});

test("callback: Steam saying the assertion is invalid is refused", async () => {
  steam = () => new Response("is_valid:false");

  assert.equal((await call(callbackPath())).status, 401);
});

test("callback: a valid login hands the app a one-time code, never the token", async () => {
  const response = await call(callbackPath());

  const location = new URL(response.headers.get("location"));
  assert.equal(location.pathname, "/open");
  assert.equal(location.searchParams.has("token"), false);
  assert.ok(kv.store.has(`code:${location.searchParams.get("code")}`));
});

test("/open forwards the code to the app scheme", async () => {
  const code = await loginForCode();

  const response = await call(`/open?code=${code}`);

  assert.equal(response.headers.get("location"), `trophiestracker://stats?code=${code}`);
});

test("token exchange: the right verifier gives a session token, only once", async () => {
  const code = await loginForCode();
  const exchange = () =>
    call("/auth/token", { method: "POST", body: { code, verifier: VERIFIER } });

  const first = await exchange();
  assert.equal(first.status, 200);
  assert.equal(kv.store.get((await first.json()).token), STEAM_ID);
  assert.equal((await exchange()).status, 400);
});

test("token exchange: a wrong verifier fails and burns the code", async () => {
  const code = await loginForCode();
  const exchange = (verifier) =>
    call("/auth/token", { method: "POST", body: { code, verifier } });

  assert.equal((await exchange("x".repeat(43))).status, 400);
  assert.equal((await exchange(VERIFIER)).status, 400);
});

test("login without a challenge still works for older app versions", async () => {
  const response = await call(callbackPath({ returnTo: `${ORIGIN}/auth/steam/callback` }));

  const location = new URL(response.headers.get("location"));
  assert.equal(location.pathname, "/open");
  assert.equal(kv.store.get(location.searchParams.get("token")), STEAM_ID);
});

test("the session token is accepted from the Authorization header", async () => {
  const token = await loginForToken();

  const response = await call("/user", { headers: { Authorization: `Bearer ${token}` } });

  assert.equal(response.status, 200);
  assert.equal((await response.json()).steamid, STEAM_ID);
});

test("a token that is not a UUID never reaches the KV store", async () => {
  const response = await call("/user?token=privacy-policy");

  assert.equal(response.status, 401);
  assert.deepEqual(kv.reads, []);
});

test("logout revokes the token", async () => {
  const token = await loginForToken();
  const auth = { Authorization: `Bearer ${token}` };

  assert.equal((await call("/logout", { method: "POST", headers: auth })).status, 204);
  assert.equal((await call("/user", { headers: auth })).status, 401);
});

test("appid and last_appid cannot inject parameters into Steam URLs", async () => {
  const token = await loginForToken();
  const auth = { Authorization: `Bearer ${token}` };
  const injected = encodeURIComponent("440&steamid=1");

  assert.equal((await call(`/playerAchievements?appid=${injected}`, { headers: auth })).status, 400);
  assert.equal((await call(`/game?appid=${injected}`)).status, 400);
  assert.equal((await call(`/achievements?appid=1&l=${injected}`)).status, 400);
  assert.equal((await call(`/catalog?last_appid=${injected}`)).status, 400);
});

test("a Steam error is relayed with its status instead of a 200", async () => {
  const token = await loginForToken();
  steam = () => Response.json({ playerstats: { success: false } }, { status: 403 });

  const response = await call("/playerAchievements?appid=1", {
    headers: { Authorization: `Bearer ${token}` },
  });

  assert.equal(response.status, 403);
});

test("a non-JSON Steam answer becomes a 502", async () => {
  steam = () => new Response("<html>oops</html>", { status: 500 });

  assert.equal((await call("/game?appid=1")).status, 502);
});

test("assetlinks names the Android applicationId", async () => {
  const [link] = await (await call("/.well-known/assetlinks.json")).json();

  assert.equal(link.target.package_name, "com.alessandromazzariol.trophiestracker");
});

test("/covers returns the real vertical art, skipping games that have none", async () => {
  let requested;
  steam = (url) => {
    requested = url;
    return Response.json({
      response: {
        store_items: [
          {
            appid: 1,
            assets: {
              asset_url_format: "steam/apps/1/${FILENAME}?t=9",
              library_capsule_2x: "abc123/library_capsule_2x.jpg",
            },
          },
          { appid: 2, assets: { asset_url_format: "steam/apps/2/${FILENAME}?t=9" } },
          {
            appid: 3,
            assets: {
              asset_url_format: "steam/apps/3/${FILENAME}?t=9",
              library_capsule: "def456/library_capsule.jpg",
            },
          },
        ],
      },
    });
  };

  const response = await call("/covers?ids=1,2,3");

  assert.deepEqual(await response.json(), {
    1: { library: "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1/abc123/library_capsule_2x.jpg?t=9" },
    3: { library: "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3/def456/library_capsule.jpg?t=9" },
  });
  assert.match(decodeURIComponent(requested), /"appid":1.*"appid":2.*"appid":3/);
  assert.doesNotMatch(requested, /key=/);
});

test("/covers refuses ids that are not numbers or are too many", async () => {
  const many = Array.from({ length: 101 }, (_, i) => i + 1).join(",");

  assert.equal((await call("/covers")).status, 400);
  assert.equal((await call("/covers?ids=1,x")).status, 400);
  assert.equal((await call(`/covers?ids=${many}`)).status, 400);
});

test("/covers reports a Steam failure as 502", async () => {
  steam = () => new Response("down", { status: 500 });

  assert.equal((await call("/covers?ids=1")).status, 502);
});

test("/rarity returns the unlock percentage of every achievement as numbers", async () => {
  let requested;
  steam = (url) => {
    requested = url;
    return Response.json({
      achievementpercentages: {
        achievements: [
          { name: "ACH_A", percent: "12.5" },
          { name: "ACH_B", percent: 0.4 },
          { name: "ACH_C", percent: "n/a" },
        ],
      },
    });
  };

  const response = await call("/rarity?appid=105600");

  assert.deepEqual(await response.json(), { ACH_A: 12.5, ACH_B: 0.4 });
  assert.match(requested, /gameid=105600/);
  assert.doesNotMatch(requested, /key=/);
});

test("/rarity refuses a bad appid and reports a Steam failure as 502", async () => {
  assert.equal((await call("/rarity?appid=abc")).status, 400);
  assert.equal((await call("/rarity")).status, 400);

  steam = () => new Response("down", { status: 500 });
  assert.equal((await call("/rarity?appid=1")).status, 502);
});
