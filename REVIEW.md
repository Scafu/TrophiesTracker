# REVIEW.md — Tracciamento problemi

Documento vivo: elenco dei problemi trovati nel codice, da usare come checklist nelle revisioni future.

**Come si usa**
- Stato: `[ ]` aperto · `[x]` risolto (aggiungi data/commit) · `[~]` risolto in parte (scrivi cosa resta) · `[?]` da verificare · `[-]` scartato (spiega perché).
- Quando risolvi un punto, spunta la casella e scrivi accanto il commit. Non cancellare le righe: servono come storico.
- Nuovi problemi: nuovo ID in fondo alla sezione di gravità giusta, poi una riga nel [Registro revisioni](#registro-revisioni).
- Gravità: **Alta** = perdita/corruzione dati o app inutilizzabile in casi realistici · **Media** = bug visibili, sicurezza, prestazioni · **Bassa** = pulizia/manutenzione.

**Limiti della prima revisione (2026-11-19):** solo lettura statica di `lib/`, `android/`, `codemagic.yaml`, `pubspec.yaml`. `flutter` non è installato nell'ambiente, quindi **`flutter analyze` e i test non sono stati eseguiti**. I file generati (`*.g.dart`, `*.freezed.dart`) e alcune pagine UI secondarie (`credits_page`, `app_appbar`, `themes`, parte di `stats_widgets`) non sono stati letti riga per riga. I percorsi sono relativi a `lib/` salvo indicazione.

---

## Gravità alta

- [x] **A1 · La sync Steam può azzerare i progressi se la risposta `playerAchievements` non è 200** — risolto 2026-11-19 (commit `986e98d`). `getGameByIdRemote` ora lancia se con token `playerAchievements` non è 200, e `_parseAndMergeGameData` lancia se la risposta 200 non contiene `achievements`. Test: `test/game_remote_data_source_test.dart`. Resta il caso "profilo privato" che non ha un messaggio dedicato (vedi M5/M9).
  - Dove: `features/game/data/datasource/game_remote_data_source.dart:147-156` (il body diventa `null` se lo status ≠ 200), `features/game/presentation/details/cubit/game_details_cubit.dart:77-102`, `features/game/data/repositories/game_repositories_impl.dart:191-204`.
  - Problema: con un token, se `playerAchievements` risponde 403 (profilo privato), 429 o 5xx, i trofei restano tutti `isAchieved: false` e vengono salvati con upsert sopra quelli esistenti. Il sync del dettaglio chiama anche `removeActivity` per ogni trofeo "perso".
  - Fix: con `token != null`, trattare un `playerAchievements` non-200 come errore (throw) e non salvare nulla. Valutare se distinguere profilo privato (messaggio dedicato).

- [x] **A2 · Foreign key SQLite non attive: `onDelete: cascade` non funziona** — risolto 2026-11-19 (commit `986e98d`). `beforeOpen` attiva `PRAGMA foreign_keys = ON`. Nessuna migrazione, per scelta (fase di sviluppo, `schemaVersion` resta 3): gli orfani già presenti in un DB esistente non vengono ripuliti, basta cancellare i dati dell'app/reinstallare. **Prima di una release con utenti reali** serve una migrazione che elimini gli orfani (`DELETE FROM trophies WHERE game_id NOT IN (SELECT app_id FROM games)`, idem `activities.game_app_id`). Test: `test/app_database_test.dart`. Resta aperto il punto sui trofei rimossi da Steam (B11).
  - Dove: `core/database/app_database.dart:72-89` (nessun `beforeOpen`), `features/game/data/datasource/game_local_data_source.dart:117-135`.
  - Problema: Drift non abilita `PRAGMA foreign_keys` di default. Cancellare un gioco lascia righe orfane in `Trophies` e `Activities`; se lo si riaggiunge, ricompaiono trofei e stato vecchi. Inoltre `saveGamesToDb` non rimuove mai i trofei che Steam ha tolto dallo schema.
  - Fix: `beforeOpen: (d) async => customStatement('PRAGMA foreign_keys = ON')` più una migrazione (schema 4) che ripulisce gli orfani. In alternativa cancellare esplicitamente trofei e attività nella stessa transazione di `deleteGameFromDb`. Confidenza alta, ma verificare con un test sul DB in-memory.

- [x] **A3 · Dopo una sync fallita la tab Libreria resta sullo stato di errore** — risolto 2026-11-19 (commit `986e98d`). `GameCubit._fail` emette l'errore e richiama `watchGames()`, quindi lo stato torna alla libreria; usato in tutti e tre i punti di errore di `fetchGamesFromSteamAccount`. Test: `test/game_cubit_test.dart`. Resta il testo grezzo dell'errore mostrato all'utente (M5).
  - Dove: `features/game/presentation/gamelibrary/cubit/game_cubit.dart:58-63`, `features/game/presentation/gamelibrary/ui/game_page.dart:50-63`.
  - Problema: `fetchGamesFromSteamAccount` fa `emit(loading)` e, in caso di eccezione, `emit(error(...))`. La sottoscrizione a `watchLibrary` resta attiva ma emette solo quando il DB cambia, quindi la libreria non torna visibile finché non c'è una scrittura. Solo il 429 è gestito (con un controllo sul testo, `contains('429')`, che mostra comunque la libreria precedente); tutti gli altri errori no.
  - Fix: separare lo stato della sync da quello della libreria (es. `isSyncing`/`syncError` dentro `loaded`), oppure nel `catch` richiamare `watchGames()`.

- [x] **A4 · Lo splash può restare bloccato per sempre** — risolto 2026-11-19 (commit `986e98d`). Timeout di 30 s su ogni richiesta del catalogo e di 15 s sull'attesa dello splash: oltre, l'app si apre e il download prosegue in background. Nessun test automatico (sono due `.timeout`). Su rete lenta al primo avvio Explore parte con il catalogo ancora incompleto.
  - Dove: `core/utils/splash/splash_screen.dart:19-27`, `features/game/data/datasource/game_remote_data_source.dart:88-108` (`client.get(url)` senza timeout).
  - Problema: la navigazione a `/games` aspetta `syncSteamCatalog()`, che al primo avvio scarica 8 chunk. Con rete lenta o che non risponde la richiesta non scade mai e l'app resta su "Preparing catalog...".
  - Fix: `.timeout(...)` sulle richieste del catalogo, e non bloccare lo splash sul download (navigare subito, sincronizzare in background).

- [x] **A5 · Il catalogo Steam può restare parziale per sempre e non si aggiorna mai** — risolto 2026-11-19 (commit `986e98d`). `syncSteamCatalog` riparte a ogni avvio dall'appId più alto salvato (`getLastCatalogAppId`, nessuna nuova tabella né migration): completa un download interrotto e aggiunge le app nuove con una richiesta quando è già tutto aggiornato. Test: `test/steam_catalog_sync_test.dart`, `test/app_database_test.dart`. Limiti: i nomi già salvati non vengono aggiornati; ogni avvio fa almeno una richiesta al Worker; il download resta in memoria fino alla fine (M8).
  - Dove: `features/game/data/repositories/game_repositories_impl.dart:42-75`.
  - Problema: dopo i primi 8 chunk il resto viene scaricato fire-and-forget (`_syncRemainingCatalog`). Se l'app viene chiusa o la richiesta fallisce (viene solo loggata), al prossimo avvio `isCatalogEmpty()` è `false` e il download non riprende. Non esiste nessun refresh: i giochi nuovi di Steam non compaiono mai in Explore.
  - Fix: salvare `lastAppId`/timestamp della sync (es. in SharedPreferences o tabella) e riprendere da lì; refresh periodico.

- [x] **A6 · L'app non compilava con Flutter 3.47.7** (trovato eseguendo i test, 2026-11-19) — `material_symbols_icons` 4.2906.0 estende `IconData`, diventata `final`. Risolto con `flutter pub upgrade material_symbols_icons` (4.2960.0, dentro il vincolo `^4.2906.0`, cambia solo `pubspec.lock`; commit `a2a4c47`). **Attenzione:** `codemagic.yaml` usa `flutter: stable`, quindi finché il lock aggiornato non è su `main` la CI su stable fallisce. Valutare di fissare la versione di Flutter in CI.

---

## Gravità media

- [x] **M1 · Token di sessione in chiaro in SharedPreferences, `flutter_secure_storage` mai usato** — risolto 2026-11-19 (commit `2abc7ec`). Il token è ora in `FlutterSecureStorage` (registrato in `injection_container.dart`). Scoperto durante il fix: il token finiva in chiaro **anche** dentro il JSON del profilo in cache (`cached_steam_user`); `saveUser` ora lo toglie. Test: `test/account_local_data_source_test.dart`. **Nessuna migrazione, per scelta:** chi ha già fatto login deve rifare il login, e il vecchio valore in chiaro resta nelle SharedPreferences finché non si cancellano i dati dell'app.
  - Dove: `features/account/data/datasource/account_local_data_source.dart:17-18, 43-45`; `pubspec.yaml:26`; `README.md` dichiara "Secure storage for your credentials".
  - Fix: spostare il token su `FlutterSecureStorage` (con migrazione dal valore vecchio), oppure togliere la dipendenza e correggere il README.

- [~] **M2 · Token nell'URL, non codificato, e logging del router sempre attivo** — codice pronto 2026-11-19 (commit `2abc7ec` e `668fed0`, non ancora pubblicato). App: il token viaggia in `Authorization: Bearer` (mai nell'URL, test in `test/game_remote_data_source_test.dart`), nel deep link arriva solo un codice monouso, `debugLogDiagnostics: kDebugMode`, il redirect del router non porta nulla. Worker: legge l'header (la query `?token=` resta solo per le app vecchie, vedi W9). **Resta:** pubblicare il Worker e poi l'app (vedi checklist di deploy).
  - Dove: `features/account/data/datasource/account_remote_data_source.dart:41`, `game_remote_data_source.dart:127, 161` (`?token=$token` concatenato), `core/router/app_router.dart:26-35, 37` (`debugLogDiagnostics: true`).
  - Problema: un token con `+`, `/`, `=` rompe la richiesta; i token finiscono nei log del Worker/CDN. Il redirect `/accounts?sync=true&token=...` viene stampato dal router.
  - Fix: costruire gli URL con `Uri(queryParameters: ...)`; idealmente header `Authorization: Bearer` (richiede modifica al Worker); `debugLogDiagnostics: kDebugMode`.

- [~] **M3 · Deep link di login: scheme custom intercettabile, e su iOS non è nemmeno registrato** — codice pronto 2026-11-19 (commit `2abc7ec` e `668fed0`, non ancora pubblicato). Login in stile PKCE (RFC 7636): l'app manda solo il `code_challenge`, il deep link porta un `code` monouso (60 s) e lo scambia con `POST /auth/token` insieme al `code_verifier` salvato nel secure storage; un'altra app che intercetta il link non può usarlo. Registrato lo scheme `trophiestracker` su iOS (`Info.plist`, non provato su dispositivo). L'app accetta anche il link `https://…/open?code=` (necessario per W1) e ignora link ripetuti o non richiesti. Test: `test/pkce_test.dart` (vettore RFC), `test/account_repository_test.dart`, `worker/test/worker.test.js`. **Resta:** pubblicare e provare il login su un dispositivo reale.
  - Dove: `android/app/src/main/AndroidManifest.xml` (intent-filter `trophiestracker://`), `ios/Runner/Info.plist` (nessun `CFBundleURLTypes`, nessuna entitlement per Universal Links).
  - Problema: su Android qualsiasi app può registrare lo stesso scheme e leggere il token. Su iOS il callback `trophiestracker://` non può riaprire l'app, quindi il login Steam non si completa (la CI compila iOS, ma pubblica solo APK/AAB).
  - Fix: far usare al Worker solo l'App Link https (`/open`) con `assetlinks.json` valido (vedi V2); aggiungere URL scheme/Associated Domains su iOS se iOS è un target.

- [x] **M4 · Il rate limiter si "consuma" anche quando l'operazione fallisce** — risolto 2026-11-19 (commit `986e98d`). `RateRequestLimiter.clear(key)` viene chiamato quando la sync fallisce (libreria e dettaglio), quindi si può riprovare subito; il blocco resta contro il doppio avvio. In `syncAchievements` il controllo `state is! GameDetailsLoaded` ora precede il limiter; dopo un 429 lo stato torna a `GameDetailsLoaded` (prima restava su errore e la sync non partiva più). La stringa magica `'429'` è sostituita da `rateLimitedMessage`. Test: `test/game_cubit_test.dart`, `test/game_details_cubit_test.dart`.
  - Dove: `features/game/presentation/gamelibrary/cubit/game_cubit.dart:55`, `features/game/presentation/details/cubit/game_details_cubit.dart:48-49`.
  - Problema: `markRequest` viene chiamato prima della richiesta. Dopo un errore di rete l'utente è bloccato 5 minuti con un "429" locale. In `syncAchievements` viene marcato anche se `state is! GameDetailsLoaded` (return subito dopo).
  - Fix: marcare solo dopo il successo. Sostituire la stringa magica `'429'` con uno stato/enum dedicato (vedi M5).

- [x] **M5 · Messaggi d'errore UI incoerenti** — risolto 2026-11-19 per la sync della libreria e il login (commit `986e98d`). Gli snackbar della sync sono mostrati in un solo punto, `GamePage` (resta montata sotto la pagina Account, quindi copre anche le sync avviate da lì), senza più il duplicato in `AccountPage`; `GameCubit` emette `syncSuccess` solo se ha salvato giochi, altrimenti segnala "No games with trophies found…" (rende visibile il profilo privato); gli errori tecnici sono loggati e all'utente arriva un testo leggibile; `AccountPage` ora mostra gli errori di `AccountCubit` (prima il login fallito era silenzioso). `fetchGamesFromSteamAccount` del repository ora restituisce il numero di giochi salvati. **Resta aperto:** `GameDetailsCubit` mostra ancora `"Sync error: $e"` con l'eccezione grezza, e `AccountCubit` emette `e.toString()` negli errori del deep link e di `checkStatus`. Nessun test sulle pagine (solo sui cubit).
  - Dove: `features/account/presentation/ui/account_page.dart:93` (gestisce `'429'` su `AccountCubit`, che non lo emette mai), `:108` (`syncSuccess` non viene mai emesso da nessun cubit → lo snackbar "synced successfully" non appare), `:113-115` (mostra il `message` grezzo, quindi l'utente vede letteralmente "429" o `Exception: Network error: ...`).
  - Fix: stati tipizzati per gli errori (rate limit, rete, profilo privato) e testi in un punto solo; emettere `syncSuccess` a fine sync (o rimuoverlo).

- [x] **M6 · Ricerca nel catalogo senza LIMIT né indice, wildcard non escapate** — risolto 2026-11-19 (commit `986e98d`). `searchInLocalCatalog` restituisce al massimo 50 giochi (`limit`), prima i nomi che iniziano con la query e poi l'ordine alfabetico; `%`, `_` e `\` digitati dall'utente valgono come caratteri normali. Nessun indice né migration: con il `%` iniziale un indice non serve, resta una scansione della tabella, che su qualche decina di migliaia di righe è rapida. Se un giorno pesa, il passo successivo è FTS5. Test: `test/app_database_test.dart`.
  - Dove: `features/game/data/datasource/game_local_data_source.dart:181-197`.
  - Problema: `lower(name) LIKE '%q%'` fa full scan su decine di migliaia di righe e restituisce tutti i match (una sola lettera = migliaia di `GameModel` e tile). `%` e `_` digitati dall'utente funzionano da wildcard.
  - Fix: `limit(50)`, escape dei wildcard (`ESCAPE`), valutare FTS5 o un indice sul nome normalizzato.

- [~] **M7 · Ogni modifica al DB rilegge e rimappa tutti i trofei di tutti i giochi** — parziale 2026-11-19 (commit `986e98d`). Fatto: `watchLibrary` ora è un solo stream di invalidazione su `games` e `trophies` (`customSelect(...).watch()` + `switchMap`), quindi un salvataggio che tocca entrambe le tabelle produce una sola emissione coerente (prima ne arrivavano due, la prima con il gioco nuovo e i trofei vecchi) e una modifica più recente annulla la lettura ancora in corso; `GameRepositoriesImpl.watchLibrary` condivide una sola query tra `GameCubit` e `StatsCubit` (`shareValue`), e il mapping riga → modello duplicato è stato eliminato. Test: `test/library_stream_test.dart` (falliscono sul codice vecchio). **Resta:** ogni modifica rilegge comunque tutti i trofei (la griglia ne userebbe solo i conteggi). Non l'ho cambiato senza misure: servirebbe un campo `achievedCount`/`totalCount` in `Game` e nelle query. Misurare prima su una libreria grande (centinaia di giochi).
  - Dove: `game_local_data_source.dart:30-66, 137-179`; `features/stats/presentation/cubit/stats_cubit.dart:20-23` (seconda sottoscrizione a `watchLibrary`).
  - Problema: anche un solo toggle di trofeo rilegge due tabelle intere; `GameCubit` e `StatsCubit` lo fanno entrambi. Cresce con la libreria (centinaia di giochi × decine di trofei).
  - Fix: query con join/aggregati per la griglia (serve solo `achieved/total`), trofei completi solo nel dettaglio; condividere un unico stream.

- [x] **M8 · `compute` vanificato nel download del catalogo, e tutto in memoria** — risolto 2026-11-19 (commit `986e98d`). L'isolate restituisce anche `have_more_results` e `last_appid`, quindi la risposta non viene più decodificata una seconda volta sul thread principale (e una pagina senza `response` non manda più in errore); il resto del catalogo si scarica e si salva a fette di 2 pagine (`_syncRemainingCatalog`), con memoria limitata e ripartenza dall'appId più alto salvato; una pagina che dichiara altri risultati senza avanzare interrompe il ciclo invece di ripeterlo all'infinito. Test: `test/game_remote_data_source_test.dart`, `test/steam_catalog_sync_test.dart`.
  - Dove: `game_remote_data_source.dart:97-104` (`json.decode(response.body)` rifatto sul main isolate dopo il `compute`), `:85-110` e `game_repositories_impl.dart:63-75` (accumula tutti i chunk prima di salvare, un unico `insertAll`).
  - Fix: far restituire `last_appid`/`have_more_results` dall'isolate; salvare chunk per chunk.

- [ ] **M9 · La sync della libreria scarta giochi in silenzio ed è lenta**
  - Dove: `game_remote_data_source.dart:179-223`.
  - Problema: se i dettagli di un gioco falliscono, il `catch` costruisce un `GameModel` con `trophies: []` che subito dopo viene filtrato da `.where((g) => g.trophies.isNotEmpty)`: il fallback è codice morto e il gioco sparisce senza avviso né retry. 5 giochi × 3 richieste in parallelo + 500 ms di pausa a batch: per librerie grandi sono minuti, senza progresso (solo uno spinner).
  - Fix: contare/segnalare i falliti, ritentare; mostrare progresso; valutare un endpoint batch lato Worker.

- [ ] **M10 · Feed attività incoerente**
  - Dove: `features/game/presentation/details/cubit/game_details_cubit.dart:91-100`, `core/data/repositories/activity_repository_impl.dart:33-44`, `features/stats/presentation/ui/stats_widgets.dart:75`.
  - Problema: l'attività usa `DateTime.now()` invece di `achievedAt` di Steam; la sync iniziale della libreria non crea attività; il tipo "game added" (`isGameAdded`) non viene mai creato da nessuno (`addActivity` è chiamato solo con un nome trofeo), quindi quel ramo UI è morto.
  - Fix: usare `achievedAt`; decidere se "game added" serve (crearlo in `saveGameToLibrary`) o eliminarlo.

- [ ] **M11 · Build Android locale impossibile senza `android/key.properties`**
  - Dove: `android/app/build.gradle.kts` (`signingConfigs.release`, ramo non-CI: `keystoreProperties["keyAlias"] as String`).
  - Problema: `create("release")` viene eseguito sempre in fase di configurazione, quindi con `key.properties` assente Gradle lancia un cast a `null` anche per `flutter run` in debug. Il file non esiste in questo checkout (è correttamente in `.gitignore`).
  - Fix: usare `?.toString()` e creare/assegnare la config `release` solo se `key.properties` esiste.

---

## Gravità bassa

- [ ] **B1 · Versione hardcoded**: `features/account/presentation/ui/account_page.dart:159` mostra `'1.0.1'`, ma `pubspec.yaml` è `1.0.0+4`. Leggerla con `package_info_plus` o allinearla a mano.
- [ ] **B2 · Test e CI**: `test/widget_test.dart` è il template del contatore e fallisce (verificato: `SettingsCubit` non registrato in GetIt, l'app non viene inizializzata); `codemagic.yaml` non esegue `flutter test`. Da quando esistono `test/game_remote_data_source_test.dart` e `test/app_database_test.dart` la suite ha test reali: eliminare o riscrivere `widget_test.dart`, poi aggiungere `flutter test` alla CI.
- [ ] **B3 · README rovinato**: la riga 1 è un residuo ("samples, guidance on mobile development…"), la sezione "Features" è vuota e la sua lista sta sotto "Used Libraries".
- [ ] **B4 · Asset e font**: `assets/` è incluso per intero nel bundle (~4 MB inutili: `page_screenshot_1-5.png`, `output-onlinepngtools.png`, `icon_foreground.png`, `steam-icon-logo.png`; a runtime si usano solo `splash.png` e `support_me_on_kofi_beige.png`). I `.ttf` in `lib/styles/fonts/` non sono dichiarati in `pubspec.yaml` e non vengono usati. I font reali (Inter, Kanit) sono scaricati a runtime da `google_fonts` → fallback al primo avvio offline. Spostare le immagini README in `docs/`, elencare solo gli asset necessari, includere i font in locale.
- [ ] **B5 · Dipendenze**: `flutter_launcher_icons` e `flutter_native_splash` sono in `dependencies` (`pubspec.yaml:38-39`), vanno in `dev_dependencies`. `freezed ^3.0.0` e `json_serializable ^6.0.0` sono range molto larghi.
- [ ] **B6 · Codice morto** (il doppio `@override` su `getSteamUserInfo` è stato tolto con M2): `initialName` letto ma mai passato in `_parseAndMergeGameData` (`game_remote_data_source.dart:260`); `searchGamesOnline` (`:41-78`) non è chiamato dal repository; `ExploreError("No games found.")` usato come stato "vuoto" (`explore_cubit.dart:27`); `SettingsCubit.setLocale` senza UI né `supportedLocales`.
- [ ] **B7 · Piccoli bug di robustezza**: `Debouncer` senza cancel e mai fermato in `dispose` (`explore_page.dart:25-28`: il timer può scattare dopo lo smontaggio e usare `context.read`); in `toggleTrophy` il rollback chiama `getGameByIdLocal` dentro il `catch` senza protezione (`game_details_cubit.dart:162-163`).
- [ ] **B8 · Duplicazioni**: il mapping riga Drift → `GameModel` è copiato 2 volte in `game_local_data_source.dart` (`fetchGamesFromDb`, `getGameByIdLocal`; quello di `watchLibrary` è stato eliminato con M7) più `_mapToModel` nel repository; l'URL del proxy è scritto 2 volte in `core/di/injection_container.dart:45-46, 66-67`.
- [ ] **B9 · Codemagic**: lo step "Set up key properties" è ridondante (in CI `build.gradle.kts` legge le variabili d'ambiente); a ogni push su `main` con versione invariata tag e release vengono cancellati e ricreati; il fallback del changelog è `HEAD~10`; la build iOS non produce un artifact distribuibile.
- [ ] **B10 · Libreria non ordinata**: `watchLibrary` non ha `ORDER BY`, quindi la griglia segue l'`appId`. Nessuna ricerca/filtro nella libreria.
- [ ] **B11 · Trofei rimossi da Steam restano nel DB**: `saveGamesToDb` fa solo upsert dei trofei (`game_local_data_source.dart:104-108`), non elimina quelli che non sono più nello schema. Residuo di A2: cancellare i trofei del gioco prima del reinserimento, nella stessa transazione.
- [ ] **B12 · Bundle id iOS ancora quello di default**: `ios/Runner.xcodeproj/project.pbxproj` ha `PRODUCT_BUNDLE_IDENTIFIER = com.example.trophiesTracker`, mentre Android usa `com.alessandromazzariol.trophiestracker`. Da allineare prima di firmare o pubblicare su iOS.

---

## Worker Cloudflare

Il sorgente è in `worker/src/index.js` (versione pubblicata il 2026-03-25 dal dashboard, poi modificata qui, vedi sotto). `worker/wrangler.jsonc` è già compilato con i dati letti dal tuo account il 2026-11-19: binding `KV` → namespace `trophies_tracker_KV` (`fe959c0d3b1a4fc8b3256f2c1d902313`), `compatibility_date` `2025-11-15` (quella oggi in produzione, così il comportamento del runtime non cambia) e le impostazioni di osservabilità. `STEAM_API_KEY` è un secret (`secret_text`) e resta al suo posto a ogni deploy. Un cambio al protocollo del token va pubblicato insieme all'app.

- [~] **W1 · `assetlinks.json` ha il package sbagliato**: `com.alessandromazzariol.trophiestracker.trophies_tracker`, mentre l'`applicationId` Android è `com.alessandromazzariol.trophiestracker`. La verifica dell'App Link fallisce; il login oggi funziona solo perché il browser segue il redirect `/open` → `trophiestracker://`. **Attenzione:** correggere solo il package farebbe consegnare all'app direttamente `https://…/open?token=…`, che `AccountCubit._handleDeepLink` ignora (accetta solo lo scheme `trophiestracker`), e il login si romperebbe. Controllare anche che il fingerprint sia quello della chiave di release (e di Play App Signing, se pubblichi sul Play Store). — codice pronto: package corretto in `worker/`, app che accetta il link https. Resta: deploy e verifica con `adb shell pm get-app-links com.alessandromazzariol.trophiestracker`; controllare anche che il fingerprint sia quello della chiave di release.
- [~] **W2 · Il callback OpenID non valida `openid.return_to`**: un sito malevolo può avviare il login Steam con un suo `return_to`, ottenere l'asserzione firmata e inoltrarla al Worker, che emette un token per lo SteamID della vittima. Fix: richiedere `return_to === ${origin}/auth/steam/callback`, `op_endpoint` di Steam e `claimed_id` che rispetti `^https://steamcommunity\.com/openid/id/\d+$` (oggi `claimedId.split` va anche in errore se manca). — codice pronto in `worker/` (verifica di `return_to`, `op_endpoint`, `claimed_id` e campi firmati), con test. Resta il deploy.
- [~] **W3 · Gli errori di Steam escono come HTTP 200**: `/playerAchievements`, `/game`, `/achievements`, `/library`, `/catalog` restituiscono il JSON di Steam con status 200 qualunque cosa sia successa; un token non valido su `/playerAchievements` dà 400 invece di 401; una risposta non JSON manda il Worker in errore 500. L'app oggi regge (A1 gestisce `200` con `success:false`), ma è meglio propagare lo status. — codice pronto in `worker/` (status di Steam propagato, 502 per risposte non JSON, 401 per token non valido), con test. Resta il deploy.
- [~] **W4 · Nessun logout lato server**: il token resta valido 30 giorni anche dopo il logout dell'app. Aggiungere `POST /logout` che cancella la chiave dal KV e chiamarlo da `AccountRepositoryImpl.logout`. — codice pronto: `POST /logout` nel Worker e chiamata best effort da `AccountRepositoryImpl.logout`, con test. Resta il deploy.
- [~] **W5 · Parametri non validati dentro gli URL di Steam**: `appid`, `l` e `last_appid` sono interpolati così come arrivano. Un `appid=440%26steamid%3D…` aggiunge un secondo `steamid` a `/playerAchievements`, quindi con un token valido si potrebbe interrogare un altro giocatore (nei limiti della sua privacy Steam). Fix: `^\d+$` per gli id numerici, `encodeURIComponent` per `l`. — codice pronto in `worker/` (`appid`, `last_appid` numerici, `l` solo lettere), con test. Resta il deploy.
- [~] **W6 · Chiavi KV senza prefisso**: token, `ratelimit:*` e `privacy-policy` stanno nello stesso namespace, quindi `/user?token=privacy-policy` fa restituire a `getSteamId` l'HTML della policy. Prefissare le chiavi (`token:`) e scartare formati non attesi. — codice pronto in `worker/`: un token che non ha forma di UUID non arriva mai al KV, quindi niente collisioni con `privacy-policy` o `ratelimit:*` (nessun prefisso, così le sessioni esistenti restano valide), con test. Resta il deploy.
- [ ] **W7 · Quota e abuso**: `/game`, `/achievements` e `/catalog` usano la chiave Steam senza autenticazione né limiti, e l'URL del Worker è pubblico nel repo; solo `/library` ha un limite di 60 s (su KV, non atomico). Una sync costa circa 3 richieste per gioco. Mitigazioni: regola di rate limiting nel dashboard Cloudflare e cache vera (Cache API o `cf.cacheTtl` sul `fetch` verso Steam: gli header `Cache-Control` da soli non fanno cachare nulla al Worker).
- [ ] **W8 · `Access-Control-Allow-Origin: *`** non serve a un'app mobile: toglierlo se non esiste un client web.
- [~] **W10 · I log del Worker conservano le query string**: in produzione `observability` ha `invocation_logs: true`, `persist: true` e `redact_query_string: false`, quindi ogni URL con `?token=` (app vecchie), `?code=` e `appid` finisce nei Workers Logs e ci resta. Codice pronto: `redact_query_string: true` in `worker/wrangler.jsonc`, da applicare con il deploy. I token già finiti nei log scadono entro 30 giorni; le app nuove non li mandano più in URL.
- [ ] **W9 · Compatibilità con le app vecchie**: il Worker accetta ancora il login senza `challenge` (token nell'URL del redirect) e `?token=` in query, perché l'APK già pubblicato su GitHub li usa. Questi percorsi mantengono i buchi di M2/M3 per quelle app. Toglierli (`/open?token`, ramo "senza challenge" del callback, `?token=` in `getToken`) quando nessuno usa più le versioni vecchie.

**Checklist di deploy** (ordine importante: prima il Worker, poi l'app; le app vecchie continuano a funzionare):
1. `worker/wrangler.jsonc` è già compilato (id KV, compatibility date attuale, `redact_query_string`).
2. `cd worker && npm test`, poi `npx wrangler deploy`.
3. Controllare `https://trophiestracker.alessandro-mazzariol04.workers.dev/.well-known/assetlinks.json` (package `com.alessandromazzariol.trophiestracker`).
4. Installare la nuova app, fare login: browser → Steam → l'app si riapre → sync della libreria. Poi logout e verificare che il token non funzioni più.
5. Su Android controllare lo stato dell'App Link con `adb shell pm get-app-links com.alessandromazzariol.trophiestracker`.

---

## Da verificare

- [?] **V1 · Doppia gestione del link iniziale**: `AccountCubit._initDeepLinkListener` usa sia `getInitialLink()` sia `uriLinkStream`, e `AppRouter.redirect` intercetta lo stesso URI. Con il login a codice un secondo link uguale è innocuo (`finishLogin` trova il verifier già consumato e non fa nulla), quindi non è più un rischio; resta da capire se `app_links` lo consegna due volte.
- [x] **V2 · App Link verificato** — letto il Worker (2026-11-19): serve `assetlinks.json` ma con il package sbagliato, vedi W1.
- [x] **V3 · Worker senza protezione** — letto il Worker (2026-11-19): confermato per gli endpoint pubblici, vedi W7. Il sorgente ora è in `worker/`.
- [?] **V4 · Migrazioni DB**: `onUpgrade` gestisce solo `from < 3` (aggiunge `isSynced`). Se esistono installazioni con schema 1 o 2, controllare che `Activities` e `SteamCatalog` esistessero già in quelle versioni; la storia git ha un solo commit su `app_database.dart`.
- [x] **V5 · Analyzer/test non eseguiti** — eseguiti 2026-11-19 con Flutter 3.47.7 (via fvm): `flutter analyze` pulito, i 5 test nuovi passano, `widget_test.dart` fallisce (vedi B2).

---

## Registro revisioni

| Data | Ambito | Note |
|---|---|---|
| 2026-11-19 | Prima revisione, lettura statica del codice | Creato il documento. Aperti A1–A5, M1–M11, B1–B10, V1–V5. Nessun fix applicato. |
| 2026-11-19 | Fix A1, A2 + scoperta A6 | A1 e A2 risolti con test (falliscono senza il fix, passano con). Trovato e risolto A6 (build rotta su Flutter 3.47.7). Aggiunto B11. `flutter analyze` pulito. Committato sul branch `fix/review-2026-11-19`. |
| 2026-11-19 | Fix A3, A4, A5 | Risolti con 4 test nuovi (`game_cubit_test`, `steam_catalog_sync_test`, caso aggiunto in `app_database_test`). `isCatalogEmpty` sostituito da `getLastCatalogAppId`. `flutter analyze` pulito, 9 test passano. Committato sul branch `fix/review-2026-11-19`. |
| 2026-11-19 | Fix M4, M5 | Risolti con 7 test sui cubit (falliscono senza le modifiche). `flutter analyze` pulito, 15 test passano. Committato sul branch `fix/review-2026-11-19`. |
| 2026-11-19 | Fix M1, M2, M3 (parte lato app) | M1 chiuso; M2 e M3 parziali: il resto dipende dal Worker. 2 test nuovi, `flutter analyze` pulito, 17 test passano più `widget_test.dart` che fallisce (B2). Aggiunto B12. Committato sul branch `fix/review-2026-11-19`. |
| 2026-11-19 | Revisione del Worker | Sorgente copiato in `worker/` senza modifiche. Aperti W1–W8; chiusi V2 e V3. |
| 2026-11-19 | Login PKCE (app + Worker) | Worker riscritto in `worker/src/index.js` con 17 test (`npm test`, 5 mutazioni verificate); app: `Pkce`, scambio codice, header Bearer, logout con revoca, route `/open`; 11 test Dart nuovi. W1–W6, M2, M3 in `[~]` fino al deploy. Aggiunto W9. `flutter analyze` pulito. |
| 2026-11-19 | Lettura dell'account Cloudflare | Con `cf` (sola lettura): id del namespace KV, `STEAM_API_KEY` è un secret, versione 69 pubblicata dal dashboard con compat date `2025-11-15`. `wrangler.jsonc` compilato. Trovato W10 (query string nei log). |
| 2026-11-19 | Fix M6, M7 (parziale), M8 | 8 test nuovi, verificati contro i comportamenti vecchi (stream non coerente, stream non condiviso, download tutto in memoria). `flutter analyze` pulito. Committato sul branch `fix/review-2026-11-19`. |
