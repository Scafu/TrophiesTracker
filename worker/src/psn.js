/**
 * Collegamento a PlayStation Network.
 *
 * Sony non ha un'API pubblica per i trofei: queste sono le stesse chiamate
 * dell'app di PlayStation, come le usano le librerie non ufficiali. Possono
 * cambiare senza preavviso, e il Worker serve proprio a isolare l'app da questo:
 * parla con Sony e restituisce JSON compatti e stabili.
 *
 * Il Worker non salva nulla e non scrive nulla nei log: token e codici arrivano
 * solo nel corpo di richieste POST (mai in URL o intestazioni, che i log delle
 * richieste possono riportare), e un errore si riduce a un codice fisso, senza
 * risposta di Sony e senza quello che l'utente ha inviato.
 */

const AUTH = "https://ca.account.sony.com/api/authz/v3/oauth";
const TROPHY = "https://m.np.playstation.com/api/trophy";
const PROFILE = "https://m.np.playstation.com/api/userProfile/v1/internal/users";
const LEGACY_PROFILE =
  "https://us-prof.np.community.playstation.net/userProfile/v1/users/me/profile2?fields=onlineId";

// Credenziali pubbliche dell'app Android di PlayStation: sono le stesse per
// tutti i client non ufficiali, non sono un segreto nostro.
const CLIENT_AUTH =
  "Basic MDk1MTUxNTktNzIzNy00MzcwLTliNDAtMzgwNmU2N2MwODkxOnVjUGprYTV0bnRCMktxc1A=";
const CLIENT_ID = "09515159-7237-4370-9b40-3806e67c0891";
const REDIRECT_URI = "com.scee.psxandroid.scecompcall://redirect";
const SCOPE = "psn:mobile.v2.core psn:clientapp";

const CODE = /^[A-Za-z0-9._~-]{4,256}$/;
const TOKEN = /^[A-Za-z0-9._~+/=-]{20,4096}$/;
const TITLE_ID = /^NPWR\d{5,}_\d{2}$/;
const ACCOUNT_ID = /^\d{1,24}$/;
const SERVICES = new Set(["trophy", "trophy2"]);
const CONSOLES = ["PS5", "PS4"]; // PS3 e Vita restano fuori
const TROPHY_TYPES = new Set(["bronze", "silver", "gold", "platinum"]);
const MAX_BODY = 8192;
const PAGE_SIZE = 100;
const MAX_PAGES = 50;

/** Un errore da restituire all'app: solo un codice fisso, mai testo di Sony. */
class PsnError extends Error {
  constructor(status, code) {
    super(code);
    this.status = status;
    this.code = code;
  }
}

const invalid = () => new PsnError(400, "invalid_request");
const matches = (pattern, value) =>
  typeof value === "string" && pattern.test(value);

async function readJson(response) {
  try {
    return await response.json();
  } catch {
    return null;
  }
}

/** Il corpo JSON della richiesta, o null se manca, è troppo grande o non è un oggetto. */
async function readBody(request) {
  if (Number(request.headers.get("content-length") ?? 0) > MAX_BODY) return null;
  const text = await request.text();
  if (text.length > MAX_BODY) return null;
  try {
    const data = JSON.parse(text);
    return data && typeof data === "object" && !Array.isArray(data) ? data : null;
  } catch {
    return null;
  }
}

/** Chiama Sony; se non risponde affatto, `psn_unavailable`. */
async function sony(url, init) {
  let response;
  try {
    response = await fetch(url, init);
  } catch {
    throw new PsnError(502, "psn_unavailable");
  }
  return { response, data: await readJson(response) };
}

/** Scambia un codice di accesso, o un token di rinnovo, con dei token nuovi. */
async function exchange(params) {
  const { response, data } = await sony(`${AUTH}/token`, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      Authorization: CLIENT_AUTH,
    },
    body: new URLSearchParams(params).toString(),
  });
  if (response.status >= 400 && response.status < 500) {
    throw new PsnError(401, "psn_rejected");
  }
  if (!response.ok || !data?.access_token || !data?.refresh_token) {
    throw new PsnError(502, "psn_unavailable");
  }
  return {
    accessToken: data.access_token,
    refreshToken: data.refresh_token,
    expiresIn: Number(data.expires_in) || null,
    refreshTokenExpiresIn: Number(data.refresh_token_expires_in) || null,
  };
}

/** Una GET a Sony con il token; un 401 vuol dire che l'accesso è scaduto. */
async function get(url, accessToken) {
  const { response, data } = await sony(url, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (response.status === 401) throw new PsnError(401, "token_expired");
  if (!response.ok || !data || data.error) {
    throw new PsnError(502, "psn_unavailable");
  }
  return data;
}

/**
 * Il nome online dell'utente, che serve solo a mostrare "collegato come…".
 *
 * Il profilo si chiede con l'`accountId`, non con `me`: l'`accountId` lo dà il
 * riepilogo dei trofei. Se quella strada non porta al nome si prova quella
 * vecchia con `me`. Ogni risposta è `{ onlineId, attempts }`, dove `attempts`
 * ha solo il nome del passo e lo stato HTTP di Sony (`summary 200`), per capire
 * dove si ferma senza vedere nessun dato.
 */
async function lookUpName(accessToken) {
  const attempts = [];
  const ask = async (step, url) => {
    try {
      const { response, data } = await sony(url, {
        headers: { Authorization: `Bearer ${accessToken}` },
      });
      attempts.push(`${step} ${response.status}`);
      return response.ok ? data : null;
    } catch {
      attempts.push(`${step} down`);
      return null;
    }
  };
  const nameIn = (data) => {
    const id = data?.profile?.onlineId ?? data?.onlineId;
    return typeof id === "string" && id ? id : null;
  };

  const summary = await ask("summary", `${TROPHY}/v1/users/me/trophySummary`);
  const accountId = String(summary?.accountId ?? "");
  if (matches(ACCOUNT_ID, accountId)) {
    const name = nameIn(await ask("profile", `${PROFILE}/${accountId}/profiles`));
    if (name) return { onlineId: name, attempts };
  }
  return { onlineId: nameIn(await ask("legacy", LEGACY_PROFILE)), attempts };
}

/** Il nome online, o null: non è mai un motivo per far fallire un login. */
async function onlineIdOf(accessToken) {
  return (await lookUpName(accessToken)).onlineId;
}

/** Tutte le pagine di un elenco di Sony, seguendo `nextOffset`. */
async function allPages(base, query, accessToken, key) {
  const items = [];
  let offset = 0;
  for (let page = 0; page < MAX_PAGES; page++) {
    const params = new URLSearchParams({
      ...query,
      limit: String(PAGE_SIZE),
      offset: String(offset),
    });
    const data = await get(`${base}?${params}`, accessToken);
    items.push(...(data[key] ?? []));
    const next = data.nextOffset;
    if (!Number.isInteger(next) || next <= offset) break;
    offset = next;
  }
  return items;
}

const httpsUrl = (url) =>
  typeof url === "string" && url.startsWith("https://") ? url : null;

function counts(value) {
  const count = (type) => Number(value?.[type]) || 0;
  return {
    bronze: count("bronze"),
    silver: count("silver"),
    gold: count("gold"),
    platinum: count("platinum"),
  };
}

const total = (c) => c.bronze + c.silver + c.gold + c.platinum;

/** Un gioco di Sony nella forma dell'app, o null se non è per PS4 o PS5. */
function mapTitle(title) {
  const consoles = String(title.trophyTitlePlatform ?? "")
    .split(",")
    .map((name) => name.trim())
    .filter((name) => CONSOLES.includes(name));
  if (!matches(TITLE_ID, title.npCommunicationId) || consoles.length === 0) {
    return null;
  }

  const defined = counts(title.definedTrophies);
  const earned = counts(title.earnedTrophies);
  return {
    id: title.npCommunicationId,
    service: SERVICES.has(title.npServiceName)
      ? title.npServiceName
      : consoles.includes("PS5")
        ? "trophy2"
        : "trophy",
    name: String(title.trophyTitleName ?? ""),
    iconUrl: httpsUrl(title.trophyTitleIconUrl),
    consoles,
    defined,
    earned,
    total: total(defined),
    earnedCount: total(earned),
    progress: Number(title.progress) || 0,
    lastUpdated:
      typeof title.lastUpdatedDateTime === "string"
        ? title.lastUpdatedDateTime
        : null,
  };
}

/**
 * Un trofeo: la definizione di Sony unita allo stato dell'utente. La
 * percentuale di chi l'ha ottenuto (`trophyEarnedRate`) Sony la manda solo
 * nell'elenco dell'utente, non nelle definizioni (verificato con un account
 * vero); si legge da lì e, se un giorno fosse nelle definizioni, da lì.
 */
function mapTrophy(definition, mine) {
  const rate = parseFloat(mine?.trophyEarnedRate ?? definition.trophyEarnedRate);
  const earned = mine?.earned === true;
  return {
    id: String(definition.trophyId),
    name: String(definition.trophyName ?? ""),
    detail: String(definition.trophyDetail ?? ""),
    iconUrl: httpsUrl(definition.trophyIconUrl),
    type: TROPHY_TYPES.has(definition.trophyType) ? definition.trophyType : null,
    hidden: definition.trophyHidden === true,
    rarity: Number.isFinite(rate) ? rate : null,
    group: String(definition.trophyGroupId ?? "default"),
    earned,
    earnedAt:
      earned && typeof mine.earnedDateTime === "string"
        ? mine.earnedDateTime
        : null,
  };
}

/**
 * L'indirizzo della pagina di login di Sony e lo schema con cui Sony riporta
 * l'utente all'app (con il `code` nell'indirizzo). Tutto ciò che riguarda Sony
 * sta qui, così se cambia non serve aggiornare l'app.
 */
async function authorize() {
  const query = new URLSearchParams({
    access_type: "offline",
    client_id: CLIENT_ID,
    redirect_uri: REDIRECT_URI,
    response_type: "code",
    scope: SCOPE,
  });
  return {
    url: `${AUTH}/authorize?${query}`,
    callbackScheme: REDIRECT_URI.split(":")[0],
  };
}

async function login(body) {
  if (!matches(CODE, body.code)) throw invalid();
  const tokens = await exchange({
    code: body.code,
    redirect_uri: REDIRECT_URI,
    grant_type: "authorization_code",
    token_format: "jwt",
  });
  return { ...tokens, onlineId: await onlineIdOf(tokens.accessToken) };
}

async function refresh(body) {
  if (!matches(TOKEN, body.refreshToken)) throw invalid();
  return await exchange({
    refresh_token: body.refreshToken,
    grant_type: "refresh_token",
    token_format: "jwt",
    scope: SCOPE,
  });
}

async function profile(body) {
  if (!matches(TOKEN, body.accessToken)) throw invalid();
  return await lookUpName(body.accessToken);
}

async function titles(body) {
  if (!matches(TOKEN, body.accessToken)) throw invalid();
  const all = await allPages(
    `${TROPHY}/v1/users/me/trophyTitles`,
    {},
    body.accessToken,
    "trophyTitles"
  );
  return { titles: all.map(mapTitle).filter(Boolean) };
}

async function trophies(body) {
  if (
    !matches(TOKEN, body.accessToken) ||
    !matches(TITLE_ID, body.id) ||
    !SERVICES.has(body.service)
  ) {
    throw invalid();
  }

  const query = { npServiceName: body.service };
  const path = `npCommunicationIds/${body.id}/trophyGroups/all/trophies`;
  const [definitions, mine] = await Promise.all([
    allPages(`${TROPHY}/v1/${path}`, query, body.accessToken, "trophies"),
    allPages(`${TROPHY}/v1/users/me/${path}`, query, body.accessToken, "trophies"),
  ]);

  const earned = new Map(mine.map((trophy) => [trophy.trophyId, trophy]));
  return {
    trophies: definitions.map((trophy) =>
      mapTrophy(trophy, earned.get(trophy.trophyId))
    ),
  };
}

const ROUTES = {
  "/psn/authorize": authorize,
  "/psn/login": login,
  "/psn/refresh": refresh,
  "/psn/profile": profile,
  "/psn/titles": titles,
  "/psn/trophies": trophies,
};

/**
 * Risponde alle rotte `/psn/*`. Sono tutte POST con il corpo in JSON, e le
 * risposte non vanno mai tenute in cache.
 */
export async function handlePsn(request, pathname, jsonResponse) {
  const respond = (data, status = 200) =>
    jsonResponse(data, status, { "Cache-Control": "no-store" });

  const route = ROUTES[pathname];
  if (!route) return respond({ error: "not_found" }, 404);
  if (request.method !== "POST") return respond({ error: "method_not_allowed" }, 405);

  const body = await readBody(request);
  if (!body) return respond({ error: "invalid_request" }, 400);

  try {
    return respond(await route(body));
  } catch (error) {
    if (error instanceof PsnError) return respond({ error: error.code }, error.status);
    return respond({ error: "psn_unavailable" }, 502);
  }
}
