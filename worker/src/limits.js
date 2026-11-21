// Limite delle richieste per client (vedi docs/features/rate-limiting.md).
//
// Usa i binding `ratelimits` di Cloudflare, dichiarati in wrangler.jsonc. Sono
// una protezione di sicurezza, non una misura fine: i valori stanno sopra a
// quello che un utente vero fa (la sincronizzazione di Steam arriva a più di
// mille richieste al minuto). I contatori sono per sede di Cloudflare e
// approssimati.
//
// Niente console e niente di salvato: la chiave è l'IP o l'hash del token, e
// vive solo il tempo della chiamata a `limit()`.

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

/** Secondi da aspettare, quanto la finestra dei binding (60 s in wrangler.jsonc). */
const RETRY_AFTER = 60;

/**
 * I gruppi di rotte. `byToken`: la chiave è l'hash del token di sessione, se
 * c'è, perché più utenti possono stare dietro lo stesso IP; senza token,
 * l'IP. Ogni rotta del Worker è qui o in `UNLIMITED`: un test lo controlla.
 */
export const TIERS = [
  {
    binding: "RL_IDENTITY",
    paths: [
      "/auth/steam",
      "/auth/steam/callback",
      "/auth/token",
      "/logout",
      "/psn/authorize",
      "/psn/login",
      "/psn/refresh",
    ],
  },
  { binding: "RL_USER", byToken: true, paths: ["/user", "/library"] },
  {
    binding: "RL_GAME",
    paths: ["/game", "/achievements"],
  },
  { binding: "RL_GAME", byToken: true, paths: ["/playerAchievements"] },
  {
    binding: "RL_LIGHT",
    paths: ["/covers", "/rarity", "/category", "/catalog"],
  },
  {
    binding: "RL_PSN",
    paths: ["/psn/titles", "/psn/trophies", "/psn/profile"],
  },
];

/** Pagine fisse che non chiamano nessuno: non hanno limite. */
export const UNLIMITED = ["/", "/policy", "/open", "/.well-known/assetlinks.json"];

const BY_PATH = new Map(
  TIERS.flatMap((tier) => tier.paths.map((path) => [path, tier]))
);

/** I primi 32 caratteri esadecimali dello SHA-256 di [text]. */
async function hash(text) {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(text)
  );
  return [...new Uint8Array(digest)]
    .slice(0, 16)
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

/** Il token di sessione della richiesta (`Authorization: Bearer`, poi `?token=`), o null. */
function sessionToken(request, url) {
  const auth = request.headers.get("Authorization") || "";
  const token = auth.startsWith("Bearer ")
    ? auth.slice(7)
    : url.searchParams.get("token");
  return UUID.test(token || "") ? token : null;
}

/**
 * Se la richiesta ha superato il limite del suo gruppo, i secondi da
 * aspettare; altrimenti null. Se il binding manca o fallisce la richiesta
 * passa: un guasto del limitatore non deve fermare l'app.
 */
export async function retryAfterSeconds(request, env, url) {
  const tier = BY_PATH.get(url.pathname);
  const limiter = tier && env?.[tier.binding];
  if (!limiter) return null;

  try {
    const token = tier.byToken ? sessionToken(request, url) : null;
    const key = token
      ? `t:${await hash(token)}`
      : `ip:${request.headers.get("CF-Connecting-IP") ?? "unknown"}`;
    const { success } = await limiter.limit({ key });
    return success === false ? RETRY_AFTER : null;
  } catch {
    return null;
  }
}
