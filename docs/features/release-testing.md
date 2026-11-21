# Test interno dell'app (TestFlight e Play Console)

**Stato: in corso (2026-11-21).** Scelte fatte, lavoro tecnico finito; restano passi che richiedono i tuoi account e i pannelli di Apple e Google. Questo file è la lista da seguire.

## Obiettivo

Mettere l'app in test interno e poter dire che il necessario è fatto. L'utente: "cosa manca da decidere prima di poter mettere la app in testing e poter dire di aver completato il necessario".

## Decisioni confermate

- **2026-11-21, si parte con un test interno su tutte e due le piattaforme.** L'utente ha scelto "Test interno": TestFlight interno su iOS e Play Console "internal testing" su Android. *Perché:* non passano dalla revisione degli store, pochi tester, sono i più veloci da far partire. *Scartati per ora:* solo Android; test esterno o pubblico (TestFlight esterno, closed e open testing), che passano dalla revisione e rendono subito rilevanti i rischi sui marchi, sull'API non ufficiale di Sony e sul pulsante Ko-fi (vedi sotto).
- **2026-11-21, il bundle id iOS è `com.alessandromazzariol.trophiestracker`, lo stesso dell'`applicationId` Android.** *Perché:* un solo identificatore per le due piattaforme, e coerente con gli App Link; prima era `com.example.trophiesTracker` (B12). *Conseguenza:* l'app con il nuovo id è **un'altra app** per iOS: chi ha installato quella vecchia (per esempio il telefono dell'utente) se la ritrova accanto e deve disinstallarla; i dati e gli accessi salvati (archivio sicuro e database) non si trasferiscono, si rifà il login. Cambiati i sei `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj/project.pbxproj` (anche quelli di `RunnerTests`); l'app iOS per il simulatore compila.
- **Già deciso prima e collegato:** il database non ha migrazioni (lo schema 3 è quello iniziale, chi ha un'installazione vecchia disinstalla: REVIEW.md V4); la release `v1.0.0` è stata cancellata da GitHub; i percorsi per le app vecchie sono tolti dal Worker (W9); il rischio sulla quota Free di Cloudflare è accettato per ora (`docs/features/rate-limiting.md`); la versione è `1.1.0+5` e la CI esegue `flutter test`.

## Già fatto, con le prove

- Worker pubblicato e controllato dall'esterno: rotte, limite (20 risposte poi 429), cache (`X-Cache` MISS poi HIT), login e logout; poi pubblicato di nuovo senza i percorsi vecchi e controllato (`/auth/steam` senza challenge 400, `/open?token=` 400, `?token=` 401).
- L'app nuova installata sul telefono dell'utente con login Steam e PlayStation che funzionano ("ho reinstallato l'app e fatto login e vanno").
- `flutter analyze` pulito e 318 test verdi; build iOS (simulatore) e Android (debug, con Java 21 e un `key.properties` finto: REVIEW.md M11) riuscite.
- Privacy policy riscritta in `worker/policy.html` (bozza, vedi sotto).

## Da fare

### Tuo (account, pannelli, dispositivi)

1. **Rileggere e pubblicare la privacy policy.** Il testo è in `worker/policy.html`; si carica con `cd worker && npx wrangler kv key put privacy-policy --binding=KV --path=policy.html --remote`. Prima rileggila: è una bozza mia su cosa fa davvero l'app. Non ho messo i link alle policy di Sony e di Ko-fi perché non ho potuto verificarli.
2. **Account Apple Developer** (a pagamento) e creare l'app in App Store Connect con il bundle id sopra.
3. **Account Google Play Console** e creare l'app con `com.alessandromazzariol.trophiestracker`.
4. **Android: la prima release in test interno** si carica a mano dal pannello con l'`app-release.aab` che Codemagic già costruisce firmato (`CM_KEYSTORE`). Dopo il primo caricamento Play firma l'app con la **sua** chiave (Play App Signing): l'impronta SHA-256 di quella chiave (Play Console, Configurazione, Firma dell'app) va **aggiunta** a `sha256_cert_fingerprints` in `assetlinks.json` (nel Worker, `index.js`; oggi c'è una sola impronta) e il Worker ripubblicato. Non blocca il login (se l'App Link non si verifica funziona lo stesso il passaggio dallo scheme `trophiestracker://`), ma l'App Link è il percorso pulito.
5. **Una prova su un telefono Android vero:** login Steam, login PlayStation (il ritorno da Sony e la sessione "pulita" del browser, che non ho potuto verificare) e `adb shell pm get-app-links com.alessandromazzariol.trophiestracker`.
6. **Moduli degli store**, da compilare nei pannelli: su Google Play "Data safety" e classificazione dei contenuti; su Apple "App Privacy" e l'età. Per un test interno non so quali siano obbligatori già adesso: va visto nei pannelli.

### Mio, quando mi dai i dati o gli accessi

7. **Firma iOS e caricamento su TestFlight in Codemagic.** Oggi `codemagic.yaml` costruisce iOS con `--no-codesign` e non produce nulla di distribuibile (B9): quando c'è l'account Apple scrivo la parte di firma (chiave API di App Store Connect, certificato e profilo) e l'invio a TestFlight.
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

Nessuna per ora.
