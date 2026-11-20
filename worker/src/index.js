const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
const CHALLENGE = /^[A-Za-z0-9_-]{43}$/;
const VERIFIER = /^[A-Za-z0-9_-]{43,128}$/;
const NUMERIC = /^\d+$/;
const LANGUAGE = /^[a-z]{2,20}$/;
const CLAIMED_ID = /^https:\/\/steamcommunity\.com\/openid\/id\/(\d+)$/;
const STEAM_OPENID = "https://steamcommunity.com/openid/login";
const STORE_ASSETS = "https://shared.akamai.steamstatic.com/store_item_assets/";
const SESSION_TTL = 60 * 60 * 24 * 30; // 30 giorni
const CODE_TTL = 60; // minimo consentito da KV

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, HEAD, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    // ==========================================
    // HELPERS
    // ==========================================

    /**
     * Legge il token di sessione: prima `Authorization: Bearer`, poi `?token=`
     * (solo per le versioni dell'app precedenti all'header).
     * Restituisce null se non ha forma di UUID, così nessun token può mai
     * puntare a chiavi KV che non siano sessioni (es. `privacy-policy`).
     */
    function getToken() {
      const auth = request.headers.get("Authorization") || "";
      const token = auth.startsWith("Bearer ")
        ? auth.slice(7)
        : url.searchParams.get("token");
      return UUID.test(token || "") ? token : null;
    }

    /** Risolve un token di sessione nello SteamID, o null se non esiste. */
    async function getSteamId(token) {
      if (!token) return null;
      return await env.KV.get(token);
    }

    function jsonResponse(data, status = 200, extra = {}) {
      return new Response(JSON.stringify(data), {
        status,
        headers: { "Content-Type": "application/json", ...corsHeaders, ...extra },
      });
    }

    /** Legge il JSON di una risposta, o null se il corpo non è JSON. */
    async function readJson(response) {
      try {
        return await response.json();
      } catch {
        return null;
      }
    }

    /**
     * Inoltra la risposta di Steam mantenendo il suo status, così l'app non
     * scambia un errore per un successo. Un corpo non JSON diventa un 502.
     */
    async function relaySteam(response, extra = {}) {
      const data = await readJson(response);
      if (data === null) {
        return jsonResponse({ error: "Risposta non valida da Steam" }, 502);
      }
      return jsonResponse(data, response.status, extra);
    }

    async function checkRateLimit(token) {
      if (!token) return false;
      const cacheKey = `ratelimit:${token}`;
      const existing = await env.KV.get(cacheKey);
      if (existing) return true;
      await env.KV.put(cacheKey, "1", { expirationTtl: 60 });
      return false;
    }

    /** SHA-256 di [text] in base64url senza padding (il `code_challenge` PKCE). */
    async function sha256Base64Url(text) {
      const digest = await crypto.subtle.digest(
        "SHA-256",
        new TextEncoder().encode(text)
      );
      return btoa(String.fromCharCode(...new Uint8Array(digest)))
        .replace(/\+/g, "-")
        .replace(/\//g, "_")
        .replace(/=+$/, "");
    }

    /**
     * Valida il callback OpenID di Steam e restituisce `{ steamId, challenge }`,
     * oppure null.
     *
     * Oltre alla verifica della firma fatta da Steam, richiede che il
     * `return_to` firmato sia proprio questo callback: un'asserzione ottenuta
     * per un altro sito non può essere riusata qui. La `challenge` si legge dal
     * `return_to` firmato, non dalla query del callback, che non è firmata.
     */
    async function verifySteamLogin() {
      const query = url.searchParams;
      const claimed = CLAIMED_ID.exec(query.get("openid.claimed_id") || "");

      let returnTo;
      try {
        returnTo = new URL(query.get("openid.return_to") || "");
      } catch {
        return null;
      }

      const signed = (query.get("openid.signed") || "").split(",");
      const challenge = returnTo.searchParams.get("c");
      if (
        !claimed ||
        query.get("openid.mode") !== "id_res" ||
        query.get("openid.op_endpoint") !== STEAM_OPENID ||
        returnTo.origin + returnTo.pathname !== `${url.origin}/auth/steam/callback` ||
        !signed.includes("return_to") ||
        !signed.includes("claimed_id") ||
        (challenge !== null && !CHALLENGE.test(challenge))
      ) {
        return null;
      }

      const params = new URLSearchParams(url.search);
      params.set("openid.mode", "check_authentication");
      const checkResponse = await fetch(STEAM_OPENID, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: params.toString(),
      });
      if (!(await checkResponse.text()).includes("is_valid:true")) return null;

      return { steamId: claimed[1], challenge };
    }

    // ==========================================
    // 1. ASSET LINKS — verifica App Link Android
    // ==========================================

    if (url.pathname === "/.well-known/assetlinks.json") {
      const assetLinks = [{
        relation: ["delegate_permission/common.handle_all_urls"],
        target: {
          namespace: "android_app",
          package_name: "com.alessandromazzariol.trophiestracker",
          sha256_cert_fingerprints: [
            "A1:FD:47:97:A2:01:9C:B3:66:A0:39:4A:A4:64:96:2E:B4:15:85:C4:86:F2:32:83:92:4D:F6:4C:E6:2B:25:2F"
          ],
        },
      }];
      return new Response(JSON.stringify(assetLinks), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders,
          "Cache-Control": "max-age=3600",
        },
      });
    }

    // ==========================================
    // 2. APP LINK — apre l'app direttamente
    // ==========================================

    if (url.pathname === "/open") {
      const code = url.searchParams.get("code");
      const token = url.searchParams.get("token");
      // Se l'App Link è verificato Android consegna questo URL https all'app;
      // altrimenti il browser segue il redirect verso il custom scheme.
      if (UUID.test(code || "")) {
        return Response.redirect(`trophiestracker://stats?code=${code}`, 302);
      }
      // Solo per le versioni dell'app precedenti al codice monouso.
      if (UUID.test(token || "")) {
        return Response.redirect(`trophiestracker://stats?token=${token}`, 302);
      }
      return new Response("Missing code", { status: 400, headers: corsHeaders });
    }

    // ==========================================
    // 3. AUTENTICAZIONE STEAM (OpenID + PKCE)
    // ==========================================

    if (url.pathname === "/auth/steam") {
      const challenge = url.searchParams.get("challenge");
      if (challenge !== null && !CHALLENGE.test(challenge)) {
        return new Response("Invalid challenge", { status: 400, headers: corsHeaders });
      }

      // La challenge passa dentro il return_to, che Steam firma.
      const returnTo = new URL(`${url.origin}/auth/steam/callback`);
      if (challenge) returnTo.searchParams.set("c", challenge);

      const params = new URLSearchParams({
        "openid.ns": "http://specs.openid.net/auth/2.0",
        "openid.mode": "checkid_setup",
        "openid.return_to": returnTo.toString(),
        "openid.realm": `${url.origin}/`,
        "openid.identity": "http://specs.openid.net/auth/2.0/identifier_select",
        "openid.claimed_id": "http://specs.openid.net/auth/2.0/identifier_select",
      });
      return Response.redirect(`${STEAM_OPENID}?${params}`, 302);
    }

    if (url.pathname === "/auth/steam/callback") {
      const login = await verifySteamLogin();
      if (!login) {
        return new Response("Autenticazione Fallita", {
          status: 401,
          headers: corsHeaders,
        });
      }

      // Con challenge: all'app va solo un codice monouso, inutile senza il
      // verifier che l'app non ha mai mandato in giro.
      if (login.challenge) {
        const code = crypto.randomUUID();
        await env.KV.put(`code:${code}`, JSON.stringify(login), {
          expirationTtl: CODE_TTL,
        });
        return Response.redirect(`${url.origin}/open?code=${code}`, 302);
      }

      // Senza challenge (app precedente): token opaco direttamente nel redirect.
      const token = crypto.randomUUID();
      await env.KV.put(token, login.steamId, { expirationTtl: SESSION_TTL });
      return Response.redirect(`${url.origin}/open?token=${token}`, 302);
    }

    // Scambia il codice monouso con il token di sessione.
    if (url.pathname === "/auth/token" && request.method === "POST") {
      const body = await readJson(request);
      const code = body?.code;
      const verifier = body?.verifier;
      if (!UUID.test(code || "") || !VERIFIER.test(verifier || "")) {
        return jsonResponse({ error: "invalid_request" }, 400);
      }

      const key = `code:${code}`;
      const stored = await env.KV.get(key);
      if (!stored) return jsonResponse({ error: "invalid_grant" }, 400);

      // Il codice si brucia al primo tentativo, giusto o sbagliato.
      await env.KV.delete(key);
      const { steamId, challenge } = JSON.parse(stored);
      if ((await sha256Base64Url(verifier)) !== challenge) {
        return jsonResponse({ error: "invalid_grant" }, 400);
      }

      const token = crypto.randomUUID();
      await env.KV.put(token, steamId, { expirationTtl: SESSION_TTL });
      return jsonResponse({ token });
    }

    // Revoca il token di sessione (logout).
    if (url.pathname === "/logout" && request.method === "POST") {
      const token = getToken();
      if (token) await env.KV.delete(token);
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    // ==========================================
    // 4. PROFILO UTENTE
    // ==========================================

    if (url.pathname === "/user") {
      const steamId = await getSteamId(getToken());

      if (!steamId) {
        return jsonResponse({ error: "Token non valido o scaduto" }, 401);
      }

      const apiUrl = `https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=${env.STEAM_API_KEY}&steamids=${steamId}`;
      const steamResponse = await fetch(apiUrl);
      const steamData = await readJson(steamResponse);
      const players = steamData?.response?.players;

      if (players && players.length > 0) {
        return jsonResponse(players[0], 200, { "Cache-Control": "max-age=300" });
      } else {
        return jsonResponse({ error: "Utente non trovato" }, 404);
      }
    }

    // ==========================================
    // 5. LIBRERIA GIOCHI
    // ==========================================

    if (url.pathname === "/library") {
      const token = getToken();
      const steamId = await getSteamId(token);

      if (!steamId) {
        return jsonResponse({ error: "Token non valido o scaduto" }, 401);
      }

      if (await checkRateLimit(token)) {
        return jsonResponse({ error: "Troppe richieste. Aspetta 1 minuto." }, 429);
      }

      const apiUrl = `https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=${env.STEAM_API_KEY}&steamid=${steamId}&format=json&include_appinfo=true&include_played_free_games=true`;
      const steamResponse = await fetch(apiUrl);
      const steamData = await readJson(steamResponse);
      if (!steamResponse.ok || steamData === null) {
        return jsonResponse({ error: "Risposta non valida da Steam" }, 502);
      }

      return jsonResponse(steamData.response?.games || []);
    }

    // ==========================================
    // 6. ACHIEVEMENTS GIOCATORE
    // ==========================================

    if (url.pathname === "/playerAchievements") {
      const appid = url.searchParams.get("appid");
      const steamId = await getSteamId(getToken());

      if (!steamId) {
        return jsonResponse({ error: "Token non valido o scaduto" }, 401);
      }
      if (!NUMERIC.test(appid || "")) {
        return jsonResponse({ error: "appid non valido" }, 400);
      }

      const apiUrl = `https://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001/?appid=${appid}&key=${env.STEAM_API_KEY}&steamid=${steamId}`;
      return relaySteam(await fetch(apiUrl));
    }

    // ==========================================
    // 7. DETTAGLI GIOCO (pubblico, no token)
    // ==========================================

    if (url.pathname === "/game") {
      const appid = url.searchParams.get("appid");
      if (!NUMERIC.test(appid || "")) {
        return new Response("Missing appid", { status: 400, headers: corsHeaders });
      }

      const apiUrl = `https://store.steampowered.com/api/appdetails?appids=${appid}`;
      return relaySteam(await fetch(apiUrl));
    }

    // ==========================================
    // 8. SCHEMA ACHIEVEMENTS (pubblico, no token)
    // ==========================================

    if (url.pathname === "/achievements") {
      const appid = url.searchParams.get("appid");
      const lang = url.searchParams.get("l") || "english";

      if (!NUMERIC.test(appid || "")) {
        return new Response("Missing appid", { status: 400, headers: corsHeaders });
      }
      if (!LANGUAGE.test(lang)) {
        return new Response("Invalid language", { status: 400, headers: corsHeaders });
      }

      const apiUrl = `https://api.steampowered.com/ISteamUserStats/GetSchemaForGame/v2/?key=${env.STEAM_API_KEY}&appid=${appid}&l=${lang}`;
      return relaySteam(await fetch(apiUrl));
    }

    // ==========================================
    // 8b. COPERTINE (pubblico, no token)
    // ==========================================

    /**
     * Restituisce, per ogni gioco richiesto (`?ids=1,2,3`, al massimo 100),
     * l'URL reale della copertina verticale. Per molti giochi recenti Steam
     * tiene l'immagine in un percorso con hash; quello senza hash risponde 200
     * con un segnaposto grigio, quindi l'app non può indovinarlo. Il percorso
     * si legge dallo store di Steam, che non richiede la chiave API.
     */
    if (url.pathname === "/covers") {
      const ids = (url.searchParams.get("ids") || "").split(",");
      if (ids.length > 100 || !ids.every((id) => NUMERIC.test(id))) {
        return jsonResponse({ error: "ids non validi" }, 400);
      }

      const input = {
        ids: ids.map((appid) => ({ appid: Number(appid) })),
        context: { language: "english", country_code: "US" },
        data_request: { include_assets: true },
      };
      const response = await fetch(
        `https://api.steampowered.com/IStoreBrowseService/GetItems/v1?input_json=${encodeURIComponent(JSON.stringify(input))}`
      );
      const data = await readJson(response);
      if (!response.ok || data === null) {
        return jsonResponse({ error: "Risposta non valida da Steam" }, 502);
      }

      const covers = {};
      for (const item of data.response?.store_items ?? []) {
        const assets = item.assets;
        const asset = (name) =>
          assets?.asset_url_format && assets[name]
            ? STORE_ASSETS + assets.asset_url_format.replace("${FILENAME}", assets[name])
            : null;
        const library = asset("library_capsule_2x") ?? asset("library_capsule");
        if (library) covers[item.appid] = { library };
      }
      return jsonResponse(covers, 200, { "Cache-Control": "max-age=86400" });
    }

    // ==========================================
    // 8c. RARITÀ DEI TROFEI (pubblico, no token)
    // ==========================================

    /**
     * Percentuale globale di giocatori che ha sbloccato ogni achievement di un
     * gioco (`?appid=`), come mappa `{ nomeApi: percentuale }`. Steam a volte
     * restituisce le percentuali come stringhe: qui diventano numeri.
     */
    if (url.pathname === "/rarity") {
      const appid = url.searchParams.get("appid");
      if (!NUMERIC.test(appid || "")) {
        return jsonResponse({ error: "appid non valido" }, 400);
      }

      const response = await fetch(
        `https://api.steampowered.com/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v2/?gameid=${appid}`
      );
      const data = await readJson(response);
      if (!response.ok || data === null) {
        return jsonResponse({ error: "Risposta non valida da Steam" }, 502);
      }

      const rarity = {};
      for (const item of data.achievementpercentages?.achievements ?? []) {
        const percent = Number(item.percent);
        if (item.name && Number.isFinite(percent)) rarity[item.name] = percent;
      }
      return jsonResponse(rarity, 200, { "Cache-Control": "max-age=86400" });
    }

    // ==========================================
    // 9. CATALOGO GIOCHI (pubblico, no token)
    // ==========================================

    if (url.pathname === "/catalog") {
      const lastAppId = url.searchParams.get("last_appid") || "0";
      if (!NUMERIC.test(lastAppId)) {
        return new Response("Invalid last_appid", { status: 400, headers: corsHeaders });
      }

      try {
        const apiUrl = `https://api.steampowered.com/IStoreService/GetAppList/v1/?key=${env.STEAM_API_KEY}&include_games=true&include_dlc=false&include_software=false&include_videos=false&include_hardware=false&last_appid=${lastAppId}`;

        return await relaySteam(await fetch(apiUrl), {
          "Cache-Control": "max-age=86400",
        });
      } catch {
        return jsonResponse({ error: "Failed to fetch applist from Steam" }, 500);
      }
    }

    // ==========================================
    // 10. PRIVACY POLICY
    // ==========================================

    if (url.pathname === "/policy") {
      try {
        // Legge la privacy policy dal KV store
        const policyHtml = await env.KV.get("privacy-policy");

        if (policyHtml) {
          return new Response(policyHtml, {
            status: 200,
            headers: {
              "Content-Type": "text/html; charset=utf-8",
              ...corsHeaders,
              "Cache-Control": "max-age=3600", // Cache per 1 ora
            },
          });
        } else {
          // Fallback se la policy non è stata ancora caricata
          return new Response("Privacy Policy non disponibile. Contatta l'amministratore.", {
            status: 503,
            headers: corsHeaders,
          });
        }
      } catch (error) {
        return new Response("Errore nel caricamento della Privacy Policy", {
          status: 500,
          headers: corsHeaders,
        });
      }
    }

    // ==========================================
    // 11. HEALTH CHECK
    // ==========================================

    if (url.pathname === "/") {
      return new Response("TrophiesTracker Worker Active", {
        status: 200,
        headers: corsHeaders,
      });
    }

    return new Response("Not found", { status: 404, headers: corsHeaders });
  },
};
