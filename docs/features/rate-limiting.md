# Limite delle richieste del Worker

**Stato: in corso (2026-11-21).** Codice e test pronti nel Worker; **da pubblicare** (`cd worker && npx wrangler deploy`) e da guardare in uso. Non tocca l'app. Verificato: 17 test nuovi nel Worker (74 in tutto) con 5 rotture volute scoperte; `wrangler deploy --dry-run` accetta la configurazione (i cinque binding elencati con i loro limiti); in locale con `wrangler dev` e il binding vero, 25 chiamate di fila a `/psn/authorize` danno 20 volte 200 e poi 429 con `Retry-After: 60` e `{"error":"rate_limited"}`. **Non verificato:** il comportamento dopo la pubblicazione, con più sedi di Cloudflare. **Cache (stesso giorno):** `worker/src/cache.js` (`TTL`, `shared()`, `cacheStatus()`) e le sei rotte che la usano; 8 test nuovi (82 nel Worker) con 5 rotture volute scoperte (rotta senza cache, libreria di un utente in cache, errori in cache, chiamate a Sony in cache, `X-Cache` mancante); in locale con `wrangler dev` le rotte rispondono 200 con dati veri di Steam, senza `X-Cache` perché in locale non c'è la cache di Cloudflare. **Non provato che la cache funzioni davvero:** serve la pubblicazione e vedere `X-Cache: MISS` e poi `HIT` (per esempio `curl -i "<worker>/category?tag=19"` due volte).

## Obiettivo

L'utente: "voglio evitare che ci possano essere attacchi informatici che intasino e blocchino il sistema". Oggi solo `/library` ha un limite (una richiesta al minuto per token, su KV, non atomico). Le altre rotte, `/psn/*` comprese, no, e l'indirizzo del Worker è pubblico nel repo. Era già W7 in REVIEW.md.

## Decisioni confermate

- **2026-11-21, si mette un limite alle richieste dentro il Worker.** Conferma dell'utente alla proposta. Si usa il binding di Cloudflare `ratelimits` (Wrangler 4.36 o più recente; l'installato è 4.166), con un limite per gruppo di rotte, e si risponde `429 { "error": "rate_limited" }` con `Retry-After`.
- **Se il limite non funziona, non si blocca nessuno ("fail open").** Se il binding manca (test, sviluppo) o `limit()` lancia un errore, la richiesta passa: un guasto del limitatore non deve fermare l'app.
- **Nessun dato personale salvato o scritto nei log.** La chiave del limite è l'indirizzo IP (`CF-Connecting-IP`) o, per le rotte con sessione, un **hash** del token (SHA-256, 32 caratteri esadecimali): il token non esce mai com'è. Il Worker continua a non chiamare `console` e a tenere spenti i log delle invocazioni.
- **2026-11-21, per ora si accetta il rischio sulla quota: nessun dominio proprio e nessun piano Paid; resta il Worker su `workers.dev` con il solo limite per client.** L'utente: "no lasciamo il worker magari non succede nulla dato che è ancora in sviluppo anche per i primi utenti non dovrebbe essere un problema". *Perché:* l'app è in sviluppo e i primi utenti saranno pochi, quindi la probabilità di un abuso è bassa e il passaggio al dominio proprio costa (dominio, nuova versione dell'app, App Link, ritorno di Steam). *Alternative scartate per ora:* dominio proprio su Cloudflare con `workers_dev: false` e regole WAF (l'unico modo per non far contare le richieste scartate nella quota: vedi sotto cosa serve); piano Paid con limite di spesa. **Cosa si rischia:** un attacco o anche un errore dell'app che mandi molte richieste può esaurire le 100.000 richieste al giorno del piano Free; l'app smette per tutti fino a mezzanotte UTC (errore 1027). **Quando rivederla:** prima di aprire a più utenti, o se il contatore delle richieste del Worker (pannello di Cloudflare) si avvicina al tetto, o se l'app smette di funzionare in modo strano a metà giornata.
- **2026-11-21, si mette in cache la risposta di Steam per le rotte con dati uguali per tutti.** L'utente: "ok vai", dopo la spiegazione ("a cosa serve la cache"). *A cosa serve:* non rifare a Steam la stessa domanda per ogni utente e per ogni apertura (la sincronizzazione fa 3 richieste per gioco e due sono uguali per tutti), quindi sincronizzazione più veloce, meno consumo della chiave di Steam, meno rischio che Steam rallenti il Worker e meno effetto di un'ondata di richieste uguali su Steam. **Non serve** per la quota Free: il Worker gira prima della cache e una richiesta servita dalla cache conta lo stesso (documentazione di Cloudflare). *Come:* `cf: { cacheEverything: true, cacheTtlByStatus: { "200-299": TTL, "300-599": -1 } }` sulla `fetch` verso Steam (`worker/src/cache.js`): si tiene solo una risposta riuscita, gli errori di Steam (429, 5xx) mai (il valore negativo vuol dire "non salvare", lo 0 vorrebbe dire "scade subito"). *Rotte e durate:* `/game` 6 ore (se Steam desse una risposta vuota per un guasto, dura meno), `/achievements`, `/rarity`, `/covers`, `/catalog` 1 giorno, `/category` 1 ora (come il suo `Cache-Control`). **Mai** per dati di un utente: `/library`, `/user`, `/playerAchievements`, né per `/psn/*` (hanno token e dati personali); due test lo impongono. *Alternative scartate:* la Cache API (`caches.default`: la documentazione non dice con certezza che funzioni su `workers.dev`, e conta per sede senza cache a livelli); chiavi di cache personalizzate (solo Enterprise). **Verifica dopo la pubblicazione:** la risposta del Worker porta `X-Cache` con il valore di `cf-cache-status` di Cloudflare (`MISS` la prima volta, `HIT` la seconda); la documentazione **non dice espressamente** che `cf.cacheTtl` funzioni verso un host non tuo come Steam (dice solo che la `fetch` passa per la cache della propria zone anche per siti non Cloudflare), quindi finché non si vede `HIT` non è provato. Le chiavi di cache includono la query, quindi `appid` e `l` diversi sono voci diverse; `/covers` mette in cache per l'elenco esatto di id.

## Gruppi e valori (da tarare, sono in `worker/wrangler.jsonc`)

I valori sono **un'impostazione di sicurezza, non una misura fine**: devono stare sopra quello che un utente vero fa. La sincronizzazione di Steam fa 3 richieste per gioco, 5 giochi alla volta (15 insieme): per una libreria grande sono circa 1000–1800 richieste al minuto; una risposta 429 a metà farebbe perdere i trofei di quei giochi (l'app, se un gioco fallisce, lo salva senza trofei). La sincronizzazione di PlayStation fa una richiesta per gioco, tre alla volta (fino a circa 360 al minuto).

| Binding | Rotte | Chiave | Limite ogni 60 s |
|---|---|---|---|
| `RL_IDENTITY` | `/auth/steam`, `/auth/steam/callback`, `/auth/token`, `/logout`, `/psn/authorize`, `/psn/login`, `/psn/refresh` | IP | 20 |
| `RL_USER` | `/user`, `/library` | token (hash), senza token IP | 30 |
| `RL_GAME` | `/game`, `/achievements`, `/playerAchievements` | IP (token con hash per `/playerAchievements`) | 2000 |
| `RL_LIGHT` | `/covers`, `/rarity`, `/category`, `/catalog` | IP | 120 |
| `RL_PSN` | `/psn/titles`, `/psn/trophies`, `/psn/profile` | IP | 600 |

Senza limite, di proposito: `/`, `/policy`, `/open`, `/.well-known/assetlinks.json` (pagine fisse, non chiamano nessuno). Il preflight `OPTIONS` non conta. Un test controlla che **ogni rotta del Worker sia in un gruppo o nell'elenco senza limite**, così una rotta nuova non esce senza protezione per dimenticanza.

## Alternative scartate

- **Contatori su KV** (come il limite attuale di `/library`): non sono atomici e ogni richiesta scrive (costo e latenza).
- **Durable Objects:** darebbero un limite esatto e globale, ma sono molto più lavoro e costo per questo caso.
- **Regole di rate limiting nel pannello Cloudflare:** valgono per un dominio proprio (zone), non per un indirizzo `*.workers.dev` (da verificare, non l'ho letto dalla documentazione). Sarebbero la difesa migliore perché girano **prima** del Worker; vedi sotto.
- **L'IP come chiave sempre:** la documentazione lo sconsiglia (più utenti dietro lo stesso IP, per esempio una rete mobile), per questo dove c'è una sessione si usa il token.

## Cosa NON risolve (da dire chiaro)

- **I contatori sono per sede di Cloudflare e approssimati** (la documentazione: "approximate and apply separately in each Cloudflare location"): il limite si può superare in una raffica. Non è un limite esatto.
- **Un attacco da molti indirizzi** non lo ferma: ogni indirizzo ha il suo limite.
- **La quota giornaliera resta esposta.** Un Worker chiamato conta una richiesta anche se risponde 429. Con il piano Free il tetto è 100.000 richieste al giorno (poi errore 1027, l'app smette per tutti fino a mezzanotte UTC); con il piano Paid non c'è tetto e un abuso diventa un costo. Il limite protegge soprattutto **la chiave di Steam e la quota di Sony** e il lavoro dietro la richiesta, e ferma gli abusi da una sola fonte.
- **Non si vede nel pannello di Cloudflare** (la documentazione: i binding di rate limiting non compaiono nella dashboard). Con i log delle invocazioni spenti non si vede nemmeno quante richieste sono state rifiutate.

## Se in futuro si vuole fermare le richieste prima del Worker

Appunti dalla documentazione di Cloudflare (letta il 2026-11-21), per quando si rivedrà la decisione sopra. La quota conta "inbound requests to your Worker" e "only requests that hit a Worker will count against your limits and your bill"; qualunque richiesta che arriva al Worker conta, anche una che finisce in 404, in 400 o nel 429 del limitatore (e il preflight `OPTIONS`). **L'unico modo per non farle contare è fermarle prima che arrivino al Worker.** La documentazione non dice espressamente che una richiesta bloccata da una regola WAF non conta (lo fa capire con "hit a Worker"): da verificare guardando il contatore dopo averlo fatto. Le regole WAF (di blocco e di rate limiting) valgono per un **dominio proprio su Cloudflare (zone)**; la documentazione non dice che valgano per `*.workers.dev` e anzi, sul controllo del browser, dice che le regole della propria zone non toccano la zone `workers.dev`. Quindi:
- **Con l'indirizzo `workers.dev` di oggi non si può** filtrare prima del Worker.
- **Con un dominio proprio:** (a) Custom Domain per il Worker (`"routes": [{ "pattern": "api.esempio.it", "custom_domain": true }]`); (b) **spegnere `workers.dev`** (`"workers_dev": false`), altrimenti chi attacca usa quell'indirizzo e aggira le regole (restano comunque gli indirizzi di versione e di anteprima); (c) regole WAF. Sul piano Free: **1 regola di rate limiting** (solo per IP, finestra di 10 s, blocco di 10 s) e **5 regole personalizzate** (tutte le azioni tranne il log; la documentazione che ho letto non dice quali campi, per esempio percorso o metodo, siano disponibili sul Free).
- **Costo del passaggio al dominio proprio:** comprare il dominio (a mio sapere circa 10 euro all'anno, non verificato), una **nuova versione dell'app** (l'indirizzo è scritto due volte in `injection_container.dart`), e tutto ciò che oggi dipende dall'indirizzo del Worker: gli App Link di Android (`assetlinks.json`, il filtro nel manifest), l'eventuale dominio associato su iOS, il ritorno di Steam (`/auth/steam/callback`, `/open`), l'indirizzo della privacy policy. Finché ci sono app vecchie in giro `workers.dev` non si può spegnere, e finché è acceso la protezione si aggira.
- **Senza dominio:** il piano Paid toglie il tetto giornaliero (la quota non si esaurisce, quindi il blocco per tutti non c'è) e la documentazione parla di un **limite di spesa** che blocca le nuove richieste a una soglia; un abuso diventa un costo, non un'interruzione fino a quella soglia. Non so quanto costi oltre la quota inclusa: da leggere sul pannello.

## Decisioni da confermare

1. **Un messaggio apposta nell'app per il 429** ("troppe richieste, riprova tra un minuto"): oggi per PlayStation diventa "could not be reached, try again" e per Steam un errore generico.

## Fasi

1. **Limitatore nel Worker** (fatto 2026-11-21, da pubblicare; `RL_GAME` e `RL_PSN` sono larghi apposta, vedi sopra): `worker/src/limits.js`, cinque binding in `wrangler.jsonc`, chiamata all'inizio di `fetch`. Test in `worker/test/limits.test.js`.
2. **Tarare** i valori dopo qualche giorno di uso vero.
3. **Cache** (fatta 2026-11-21, da pubblicare e da verificare con `X-Cache`).
4. Le decisioni da confermare qui sopra.
