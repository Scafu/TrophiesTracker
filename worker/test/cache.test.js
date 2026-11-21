import { test, beforeEach, afterEach } from "node:test";
import assert from "node:assert/strict";
import { readFileSync, readdirSync } from "node:fs";
import worker from "../src/index.js";
import { TTL, shared } from "../src/cache.js";

const ORIGIN = "https://w.test";
const SESSION = "123e4567-e89b-42d3-a456-426614174000";
const ACCESS = "eyJ-ACCESS-SENTINEL-0000000000";
const STEAM_ID = "76561198000000000";

const realFetch = globalThis.fetch;
let upstream;
let answer;

beforeEach(() => {
  upstream = [];
  answer = () => Response.json({});
  globalThis.fetch = async (url, init) => {
    upstream.push({ url: String(url), init });
    return answer(String(url));
  };
});

afterEach(() => {
  globalThis.fetch = realFetch;
});

const kv = {
  get: async (key) => (key.startsWith("ratelimit:") ? null : STEAM_ID),
  put: async () => {},
  delete: async () => {},
};
const env = { KV: kv, STEAM_API_KEY: "key" };

function call(path, { method = "GET", headers = {}, body } = {}) {
  return worker.fetch(new Request(ORIGIN + path, { method, headers, body }), env);
}

// Le durate sono scritte a mano: se cambiano, il test se ne accorge.
const CACHED = [
  { path: "/game?appid=620", host: "store.steampowered.com", ttl: 21600 },
  { path: "/achievements?appid=620", host: "api.steampowered.com", ttl: 86400 },
  { path: "/covers?ids=620", host: "api.steampowered.com", ttl: 86400 },
  { path: "/rarity?appid=620", host: "api.steampowered.com", ttl: 86400 },
  { path: "/category?tag=19", host: "api.steampowered.com", ttl: 3600 },
  { path: "/catalog", host: "api.steampowered.com", ttl: 86400 },
];

test("each shared route asks Cloudflare to keep Steam's answer, but only a successful one", async () => {
  for (const { path, host, ttl } of CACHED) {
    upstream.length = 0;
    await call(path);

    assert.equal(upstream.length, 1, path);
    assert.equal(new URL(upstream[0].url).hostname, host, path);
    assert.deepEqual(
      upstream[0].init.cf,
      { cacheEverything: true, cacheTtlByStatus: { "200-299": ttl, "300-599": -1 } },
      path
    );
  }
});

test("the durations are never longer than a day and never shorter than a minute", () => {
  for (const [name, seconds] of Object.entries(TTL)) {
    assert.ok(seconds >= 60 && seconds <= 86400, name);
  }
  assert.deepEqual(shared(100).cf.cacheTtlByStatus, { "200-299": 100, "300-599": -1 });
});

// ------------------------------------------------------------ dati personali

test("nothing that belongs to a user is ever kept in the shared cache", async () => {
  const personal = [
    { path: "/library", headers: { Authorization: `Bearer ${SESSION}` } },
    { path: "/user", headers: { Authorization: `Bearer ${SESSION}` } },
    { path: "/playerAchievements?appid=620", headers: { Authorization: `Bearer ${SESSION}` } },
  ];
  for (const { path, headers } of personal) {
    upstream.length = 0;
    await call(path, { headers });

    assert.ok(upstream.length >= 1, `${path} asked Steam`);
    for (const request of upstream) {
      assert.equal(request.init?.cf, undefined, `${path} must not be cached`);
    }
  }
});

test("a PlayStation call, which carries tokens, is never cached", async () => {
  const psn = [
    ["/psn/authorize", {}],
    ["/psn/login", { code: "SENTINEL-code-123" }],
    ["/psn/refresh", { refreshToken: ACCESS }],
    ["/psn/profile", { accessToken: ACCESS }],
    ["/psn/titles", { accessToken: ACCESS }],
    ["/psn/trophies", { accessToken: ACCESS, id: "NPWR20001_00", service: "trophy" }],
  ];
  for (const [path, body] of psn) {
    upstream.length = 0;
    await call(path, { method: "POST", body: JSON.stringify(body) });

    for (const request of upstream) {
      assert.equal(request.init?.cf, undefined, `${path} must not be cached`);
    }
  }
});

test("only the cache module knows how to cache, and the PlayStation code never mentions it", () => {
  const dir = new URL("../src/", import.meta.url);
  for (const file of readdirSync(dir).filter((name) => name.endsWith(".js"))) {
    const source = readFileSync(new URL(file, dir), "utf8");
    if (file === "cache.js") continue;
    assert.doesNotMatch(source, /cacheEverything|cacheTtl/, `${file} sets a cache by hand`);
  }
  const psn = readFileSync(new URL("psn.js", dir), "utf8");
  assert.doesNotMatch(psn, /\bcf\s*:|shared\(|from "\.\/cache\.js"/);
});

// ------------------------------------------------------------ verifica

test("the answer says if Steam's reply came from the cache, with only that word", async () => {
  answer = () =>
    new Response(JSON.stringify({}), {
      headers: { "cf-cache-status": "HIT", "set-cookie": "secret=1" },
    });

  for (const { path } of CACHED) {
    const response = await call(path);

    assert.equal(response.headers.get("X-Cache"), "HIT", path);
    assert.equal(response.headers.get("set-cookie"), null, path);
  }
});

test("without the status from Cloudflare there is no X-Cache header", async () => {
  for (const { path } of CACHED) {
    const response = await call(path);

    assert.equal(response.headers.get("X-Cache"), null, path);
  }
});

test("a Steam error is relayed as it is and is not kept", async () => {
  answer = () => new Response("{}", { status: 429 });

  const response = await call("/game?appid=620");

  assert.equal(response.status, 429);
  assert.equal(upstream[0].init.cf.cacheTtlByStatus["300-599"], -1);
});
