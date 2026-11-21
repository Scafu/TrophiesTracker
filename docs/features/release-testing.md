# Test interno dell'app (TestFlight e Play Console)

**Stato: in corso (2026-11-21).** Scelte fatte, lavoro tecnico finito; restano passi che richiedono i tuoi account e i pannelli di Apple e Google. Questo file è la lista da seguire.

## Obiettivo

Mettere l'app in test interno e poter dire che il necessario è fatto. L'utente: "cosa manca da decidere prima di poter mettere la app in testing e poter dire di aver completato il necessario".

## Decisioni confermate

- **2026-11-21, si parte con un test interno su tutte e due le piattaforme.** L'utente ha scelto "Test interno": TestFlight interno su iOS e Play Console "internal testing" su Android. *Perché:* non passano dalla revisione degli store, pochi tester, sono i più veloci da far partire. *Scartati per ora:* solo Android; test esterno o pubblico (TestFlight esterno, closed e open testing), che passano dalla revisione e rendono subito rilevanti i rischi sui marchi, sull'API non ufficiale di Sony e sul pulsante Ko-fi (vedi sotto).
- **2026-11-21, il bundle id iOS è `com.alessandromazzariol.trophiestracker`, lo stesso dell'`applicationId` Android.** *Perché:* un solo identificatore per le due piattaforme, e coerente con gli App Link; prima era `com.example.trophiesTracker` (B12). *Conseguenza:* l'app con il nuovo id è **un'altra app** per iOS: chi ha installato quella vecchia (per esempio il telefono dell'utente) se la ritrova accanto e deve disinstallarla; i dati e gli accessi salvati (archivio sicuro e database) non si trasferiscono, si rifà il login. Cambiati i sei `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj/project.pbxproj` (anche quelli di `RunnerTests`); l'app iOS per il simulatore compila.
- **2026-11-21, per ora solo Android.** L'utente: "ho solo l'account google play". Si fa il test interno su Google Play; iOS (firma in Codemagic, TestFlight) aspetta l'account Apple Developer. Il bundle id iOS resta allineato, così non c'è altro da cambiare dopo. *Conseguenza in CI:* il passo "Build iOS" di `codemagic.yaml` è ora `ignore_failure: true`, perché senza firma non produce nulla di distribuibile e un suo errore non deve impedire la release Android (la creazione di tag e release viene dopo); da togliere quando si firma iOS.
- **2026-11-21, due rami: `main` è ciò che si rilascia, `develop` è il lavoro in corso.** L'utente: "possiamo dividere lo sviluppo in due branch per proteggere il codice pubblico da quello in fase di sviluppo?" (dopo aver scelto la Pull Request). *Come:* il lavoro nuovo sta su `develop` (o su rami brevi che partono da lì); si rilascia con una PR da `develop` a `main`, dopo aver alzato la versione; nessuno spinge a mano su `main`. Un ramo `origin/develop` esiste già ma è vecchio (9 commit in meno di `main`, nessuno in più): si porta in avanti al ramo di oggi con un fast-forward. Il modello è scritto in CLAUDE.md ("Branches and releases"). *Limite da dire chiaro:* il repository è pubblico, quindi anche `develop` è visibile a tutti; il modello protegge **ciò che viene rilasciato**, non tiene **segreto** il lavoro in corso (per quello servirebbe un repository privato, con le conseguenze descritte sotto). *In CI:* `codemagic.yaml` ha un secondo workflow `checks` (analisi e test, senza build né release) che parte sulle PR verso `main` o `develop` e sui push a `develop`; un push a `main` lo fa partire anche lui, accanto a `app_build`. **Da verificare alla prima PR** che Codemagic lo avvii davvero (non ho potuto provarlo).
- **2026-11-21, `main` è protetto su GitHub, e si procede con push di `develop` e PR.** L'utente ha risposto sì a entrambe le domande ("Sì, proteggi main", "Sì, push e PR"). *Regola applicata a `main` (con `gh api`):* serve una Pull Request per cambiare il ramo (nessun push diretto, **anche per gli amministratori**, cioè anche per l'utente), nessun obbligo di approvazioni (sei solo: la PR si può fare e unire da soli), force-push e cancellazione vietati. *Non* è obbligatorio il controllo `checks`: non so se Codemagic riporta lo stato a GitHub, da vedere alla prima PR. I tag non sono interessati (Codemagic crea `v<versione>` con un push di tag). Per toglierla: GitHub, Settings, Branches. *Scartato:* lasciare solo la convenzione scritta in CLAUDE.md.
- **Già deciso prima e collegato:** il database non ha migrazioni (lo schema 3 è quello iniziale, chi ha un'installazione vecchia disinstalla: REVIEW.md V4); la release `v1.0.0` è stata cancellata da GitHub; i percorsi per le app vecchie sono tolti dal Worker (W9); il rischio sulla quota Free di Cloudflare è accettato per ora (`docs/features/rate-limiting.md`); la versione è `1.1.0+5` e la CI esegue `flutter test`.

## Già fatto, con le prove

- Worker pubblicato e controllato dall'esterno: rotte, limite (20 risposte poi 429), cache (`X-Cache` MISS poi HIT), login e logout; poi pubblicato di nuovo senza i percorsi vecchi e controllato (`/auth/steam` senza challenge 400, `/open?token=` 400, `?token=` 401).
- L'app nuova installata sul telefono dell'utente con login Steam e PlayStation che funzionano ("ho reinstallato l'app e fatto login e vanno").
- `flutter analyze` pulito e 318 test verdi; build iOS (simulatore) e Android (debug, con Java 21 e un `key.properties` finto: REVIEW.md M11) riuscite.
- Privacy policy riscritta in `worker/policy.html` (bozza, vedi sotto).

## Android adesso (il percorso scelto)

1. **PR da `develop` a `main`** (vedi "Rami e rilasci" in CLAUDE.md; `develop` è il ramo di lavoro, `main` è ciò che si rilascia; il merge è fast-forward perché `main` non ha commit in più). Il merge su `main` fa partire Codemagic: analizza, esegue i test, costruisce APK e AAB firmati con `CM_KEYSTORE`, poi crea tag e release `v1.1.0` con `trophies-tracker-1.1.0.apk` e `.aab`. **Il repository è pubblico, quindi chiunque potrà scaricare quei file** (com'era per la vecchia `v1.0.0`).
2. **Play Console, prima volta** (i nomi dei menu li ricordo, non li ho verificati): creare l'app (nome, lingua, app o gioco, gratis), con package `com.alessandromazzariol.trophiestracker`. Testing, Internal testing, Create new release: lasciare attiva la firma di Play (Play App Signing), caricare l'`.aab` della release, note di versione, Review e poi Roll out. Scheda Testers: una lista di e-mail (account Google dei tester) e il link di adesione da mandare loro.
3. **Moduli:** Play può chiedere già adesso alcune dichiarazioni (privacy policy, annunci, pubblico, Data safety): l'indirizzo della policy è `https://trophiestracker.alessandro-mazzariol04.workers.dev/policy` (dopo averla ricaricata). Va compilato ciò che il pannello chiede per il test interno.
4. **Ogni nuovo caricamento deve avere un numero di build più alto** (il `+5` di `pubspec.yaml`, oggi `1.1.0+5`): alza il numero prima di ogni release, oppure dimmelo e lo faccio io.
5. **Dopo il primo caricamento:** l'impronta SHA-256 della chiave di firma di Play (Play Console, Configurazione, Firma dell'app) va aggiunta in `assetlinks.json` e il Worker ripubblicato (vedi sotto).
6. **Provare** su un telefono Android installando dal link di test: login Steam, login PlayStation, `adb shell pm get-app-links com.alessandromazzariol.trophiestracker`.

## Da fare

### Tuo (account, pannelli, dispositivi; iOS solo quando c'è l'account Apple)

1. **Rileggere e pubblicare la privacy policy.** Il testo è in `worker/policy.html`; si carica con `cd worker && npx wrangler kv key put privacy-policy --binding=KV --path=policy.html --remote`. Prima rileggila: è una bozza mia su cosa fa davvero l'app. Non ho messo i link alle policy di Sony e di Ko-fi perché non ho potuto verificarli.
2. **(Rimandato, serve l'account)** Account Apple Developer (a pagamento) e creare l'app in App Store Connect con il bundle id sopra.
3. **Account Google Play Console**: già aperto (2026-11-21); creare l'app con `com.alessandromazzariol.trophiestracker` (vedi "Android adesso").
4. **Android: la prima release in test interno** si carica a mano dal pannello con l'`app-release.aab` che Codemagic già costruisce firmato (`CM_KEYSTORE`). Dopo il primo caricamento Play firma l'app con la **sua** chiave (Play App Signing): l'impronta SHA-256 di quella chiave (Play Console, Configurazione, Firma dell'app) va **aggiunta** a `sha256_cert_fingerprints` in `assetlinks.json` (nel Worker, `index.js`; oggi c'è una sola impronta) e il Worker ripubblicato. Non blocca il login (se l'App Link non si verifica funziona lo stesso il passaggio dallo scheme `trophiestracker://`), ma l'App Link è il percorso pulito.
5. **Una prova su un telefono Android vero:** login Steam, login PlayStation (il ritorno da Sony e la sessione "pulita" del browser, che non ho potuto verificare) e `adb shell pm get-app-links com.alessandromazzariol.trophiestracker`.
6. **Moduli degli store**, da compilare nei pannelli: su Google Play "Data safety" e classificazione dei contenuti; su Apple "App Privacy" e l'età. Per un test interno non so quali siano obbligatori già adesso: va visto nei pannelli.

### Mio, quando mi dai i dati o gli accessi

7. **(Rimandato)** **Firma iOS e caricamento su TestFlight in Codemagic.** Oggi `codemagic.yaml` costruisce iOS con `--no-codesign` e non produce nulla di distribuibile (B9): quando c'è l'account Apple scrivo la parte di firma (chiave API di App Store Connect, certificato e profilo) e l'invio a TestFlight.
8. **Android: invio automatico a Play** (con un account di servizio) dopo il primo caricamento a mano, se lo vuoi.
9. **Pulizia di B9** (a ogni push su `main` con la stessa versione tag e release vengono ricreati) se vuoi evitarlo.
10. **L'impronta di Play App Signing** nell'`assetlinks.json` appena me la dai.

### Solo se il test diventa esterno o pubblico

- **Marchi e API non ufficiale di Sony:** l'app dice "PlayStation" e usa il login e i servizi delle app Sony senza permesso; Sony può bloccarli e uno store può respingere l'app. Il Legal disclaimer e l'avviso nella scheda PlayStation ci sono; la decisione di rischiare è tua.
- **Valve:** condizioni d'uso dell'API di Steam (la chiave sta nel Worker).
- **Pulsante Ko-fi:** Apple ha regole sui pagamenti per contenuti digitali; da controllare se un link a una raccolta di donazioni va bene (non l'ho verificato).
- **Età consigliata** e moduli completi degli store.

### Può aspettare (non blocca un test interno)

La sincronizzazione che scarta giochi in silenzio (M9), il feed delle attività (M10), i trofei rimossi che restano nel database (B11), il nome del profilo PlayStation (se non compare, la scheda mostra "PlayStation account"), un messaggio dell'app per il 429, il filtro per piattaforma e i platini nelle statistiche (fase 5 di `docs/features/psn.md`), la pulizia del codice della prova PlayStation, l'aggiornamento di Gradle, del plugin Android e di Kotlin (B5).

## Decisioni da confermare

1. **Repository privato?** Se vuoi che nemmeno `develop` si veda, il repository deve essere privato. Conseguenze: la release su GitHub (APK e AAB) non sarebbe più scaricabile da chiunque, Codemagic deve poter accedere al repository (token) e non si potrebbe più mostrare il codice come portfolio. Non è necessario per proteggere ciò che viene rilasciato.
