# Chat bot sui videogiochi

**Stato: rimosso il 2026-11-21 su richiesta dell'utente** ("il codice assistant puoi anche rimuoverlo"). Era sospeso dal 2026-11-20. Il codice (`lib/features/chat`, 11 file e circa 1.560 righe, 7 file di test e 2 helper, 95 test) **non era mai stato committato, quindi è stato cancellato senza possibilità di recuperarlo da git**; non c'è più nessun riferimento nell'app. Questo file resta come registro delle decisioni e del piano, utile se si volesse rifare da capo. Ultimo aggiornamento 2026-11-21.

## Obiettivo

Una chat dentro l'app a cui chiedere cose come "che gioco mi consigli?", "qualcosa di simile a Hades", "quale gioco della mia libreria conviene finire?". Deve funzionare anche offline, essere leggera da installare e **non inventare mai giochi o fatti**.

## Decisioni confermate

- **2026-11-20, l'Assistant è sospeso.** L'utente: "per ora lasciamo stare questa possibilità di integrare un assistant". Il codice delle fasi 1 e 2 resta nel repo (`lib/features/chat`, `test/chat_*`, `test/helpers/chat_fixtures.dart`, `test/helpers/fake_chat_repository.dart`) ma **non è collegato all'app**: tolti il pulsante accanto alla ricerca di Explore, la rotta `/assistant` e le registrazioni nel DI, e il campo di ricerca di Explore è tornato com'era. Non va nei commit del resto del lavoro finché non si riprende. Resta in tutto il repo anche la correzione dell'overflow di `ExploreGameTile`, che non dipende dall'Assistant.

- **2026-11-20, funziona anche offline.** L'utente: "secondo me dovrebbe funzionare anche offline".
- **2026-11-20, la versione 1 dà solo consigli.** L'utente: "solo consigli". Il bot consiglia giochi dalla libreria dell'utente e dai più popolari per genere salvati in locale. **Non risponde a domande aperte sui giochi** ("come si sblocca il platino?", "è bello X?"): dice che fa solo consigli e propone dei suggerimenti. Il motivo: il catalogo offline ha solo id e nome, quindi non può verificare niente su trama, difficoltà o modalità di gioco.
- **2026-11-20, punto d'ingresso: una quarta scheda nella barra in basso. Superata** dalla decisione seguente sul pulsante in Explore. L'utente: "beh potremmo come quarta scelta". Accanto a Library, Explore e Stats. Nome proposto: "Assistant". La barra a capsula (`AppNavigationBar`) lavora già su una lista di destinazioni e si nasconde con la tastiera; resta da verificare che quattro voci con etichette ci stiano bene sui telefoni stretti.
- **2026-11-20, il punto d'ingresso cambia: un pulsante accanto alla barra di ricerca di Explore, non più una quarta scheda.** L'utente: "non si potrebbe mettere l'assistant come icon button nella barra di ricerca di explore?". **Sostituisce** la decisione sulla quarta scheda (presa lo stesso giorno): la barra in basso torna a tre voci e l'Assistant si apre a schermo intero da Explore, con il tasto indietro. Conseguenza: la conversazione dura finché la schermata è aperta, non più finché l'app è aperta.
- **2026-11-20, niente modello da 1 GB.** L'utente: "non vorrei far scaricare un 1GB di modello". Quindi la versione 1 **non usa un modello di linguaggio**: capisce le richieste con regole e sceglie i giochi dai dati locali. Nessun download, nessun server, nessuna quota, e niente può essere inventato perché il bot non scrive nulla di suo.
- **2026-11-20, nessun modello sul telefono né sul server** (conseguenza della precedente). Questo **sostituisce** la decisione "il modello gira solo sul telefono", presa lo stesso giorno prima di quantificare il download.
- **2026-11-20, il bot parla italiano e inglese.** L'utente: "per me entrambe le lingue". Capisce le frasi in tutte e due le lingue e risponde in tutte e due. Nota: oggi l'app non ha un selettore di lingua (nessuna schermata usa `setLocale`) e tutte le scritte sono in inglese, quindi la lingua da usare non si può leggere dalle impostazioni. Regola proposta, da confermare: risponde nella lingua in cui l'utente ha scritto; se tocca un pulsante o saluta, nella lingua del telefono (italiano se il telefono è in italiano, altrimenti inglese).
- **2026-11-20, le scelte della versione 1 proposte e accettate ("si").** Nome della scheda: "Assistant". Richieste: cosa gioco dopo, quasi finiti, un gioco nuovo (per genere), simile a X, sorprendimi, più un "consigliami un gioco" generico. Riconoscimento delle frasi con regole (livello A), sostituibile. Lingua: quella in cui scrive l'utente, altrimenti quella del telefono (italiano se il telefono è in italiano, altrimenti inglese).
- **2026-11-20, la conversazione non si salva.** L'utente: "la cronologia non serve tenerla". La chat vive solo finché l'app è aperta sulla scheda; non si scrive niente su disco, e non serve nemmeno un pulsante per cancellarla.

## Per riattivarlo (storico: il codice non c'è più)

I passi sotto descrivevano come collegare il codice che c'era. Ora non servono più: per riavere un assistente si riparte dal piano qui sotto (le regole, la cache dei più popolari per genere dalla rotta `/category` del Worker, che esiste ancora, e le decisioni confermate).

1. **DI** (`injection_container.dart`, con `import 'dart:ui' show PlatformDispatcher;`): `CandidateCache(sl(), sl(), tagIds: [for (final category in gameCategories) category.tagId])` e `ChatEngine(sl())` come `registerLazySingleton`; `ChatCubit(sl(), sl(), sl(), ChatLanguage.fromCode(PlatformDispatcher.instance.locale.languageCode))` come `registerFactory`.
2. **Rotta** (`app_router.dart`, fuori dalla `StatefulShellRoute`): `GoRoute(name: 'assistant', path: '/assistant', builder: ... BlocProvider<ChatCubit>(create: (_) => sl<ChatCubit>()..start(), child: const ChatPage()))`.
3. **Punto d'ingresso** (ultima scelta: pulsante accanto alla ricerca di Explore): una riga con `CapsuleSearchField(dense: true, hint: 'Search Steam games')` e un `RoundIconButton` da 48 punti con `Symbols.chat_bubble_rounded` e `context.push('/assistant')`. `RoundIconButton` va esteso con `size` e `iconColor`. Il suo test: aprire `/assistant` toccando il pulsante, e il pulsante accanto al campo.
4. Hot restart, perché cambiano DI e router.

## Storico (opzioni scartate, con i fatti verificati)

Per non rifare la ricerca se un giorno si riconsidera un modello:

- **Modello sul server (Workers AI o Claude Haiku)** dietro una rotta `/chat`: scartato perché non funziona offline. Workers AI ha 10.000 Neuron al giorno gratis, condivisi tra tutti i modelli; oltre, solo con il piano Workers Paid (0,011 $ ogni 1.000 Neuron). [Prezzi](https://developers.cloudflare.com/workers-ai/platform/pricing/)
- **Modello sul telefono con `flutter_gemma`** (Android e iOS, file `.task` o `.litertlm`): scartato per il download. Gemma 3 1B circa 0,5 GB ma è protetto su Hugging Face (serve un token che non si può mettere nell'app) e, ospitandolo noi, valgono le condizioni d'uso di Gemma (avviso, copia dell'accordo, restrizioni da trasmettere). Qwen2.5 1.5B ha licenza Apache 2.0 ma pesa circa 1-1,6 GB (dato terzo, non verificato); Qwen2.5 3B è non commerciale. Su iOS il simulatore gira solo su CPU, la prova vera va fatta su telefono reale. [flutter_gemma](https://pub.dev/packages/flutter_gemma), [Gemma](https://ai.google.dev/gemma/terms), [Qwen2.5 1.5B](https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct)
- **Modelli di sistema** (Apple Foundation Models da iOS 26 con Apple Intelligence attivo, nessun plugin Flutter trovato; Gemini Nano su Android, in alpha e su pochi dispositivi): non coprono tutti i telefoni. [Apple](https://developer.apple.com/documentation/foundationmodels/detecting-available-apple-foundation-models.md), [Android](https://android-developers.googleblog.com/2025/10/ml-kit-genai-prompt-api-alpha-release.html)
- **Dove ospitare un file grande, se servisse:** Cloudflare R2, 10 GB gratis e uscita dati gratis. [Prezzi R2](https://developers.cloudflare.com/r2/pricing)

## Cosa c'è nei dati (controllato il 2026-11-20)

Il catalogo scaricato (`SteamCatalog`) ha 201.516 righe, ognuna con solo `app_id` e `name`: niente genere, descrizione, popolarità, anno o trofei. Serve a sapere se un titolo esiste e a trovarne l'id, non a scegliere cosa consigliare. Per scegliere servono due fonti:

- **La libreria** (Drift): giochi, trofei sbloccati, ultimo sblocco. Già disponibili le funzioni `almostThere` e `librarySummary` in `library_view.dart` e i calcoli di `stats_view.dart`.
- **La cache dei candidati**: quando c'è rete, l'app salva in locale i giochi popolari con trofei per ognuno dei 12 generi, dalla rotta `/category` del Worker (già in produzione). Circa 40 giochi per genere, poche decine di KB: si salva come JSON nelle SharedPreferences (nessuna tabella nuova; se servisse, vale la preferenza già presa: niente migrazioni in sviluppo). Si rinfresca in background se ha più di 7 giorni. Si mostra "Consigli aggiornati il …".

Senza mai essere stata online l'app consiglia solo dalla libreria. Le copertine di giochi mai caricati restano un segnaposto.

## Come funziona senza modello

Tre pezzi, tutti codice normale in Dart, come già facciamo in `library_view.dart` e `stats_view.dart` (funzioni pure, facili da testare):

1. **Capire la richiesta** (`IntentParser`): normalizza il testo (minuscole, niente accenti né punteggiatura), cerca parole e frasi chiave per ogni intento e per ogni genere, in italiano e in inglese. Per "simile a X" cerca il nome del gioco nel catalogo (`searchLocalCatalog`); se i candidati sono più di uno, li propone come scelte.
2. **Scegliere i giochi** (`Recommender`): regole fisse sui dati locali, sempre gli stessi risultati per gli stessi dati.
3. **Scrivere la risposta** (`ReplyComposer`): frasi a modello con i dati veri dentro ("Ti mancano 4 trofei per completare Balatro: 27 su 31").

L'interfaccia è **guidata**: la chat parte con dei pulsanti-risposta (chip) e scrivere è facoltativo. Se la frase non si capisce, il bot lo dice e rimostra i pulsanti.

### Come riconoscere le frasi: tre livelli (da scegliere)

Riconoscere cosa vuole l'utente si può fare in tre modi, dal più semplice al più pesante. `IntentParser` è un'interfaccia piccola, quindi si può partire dal primo e passare a un altro senza toccare il resto. Un riconoscitore **non è un modello di linguaggio**: non scrive niente, associa la frase a una delle richieste che conosciamo, quindi non rompe la decisione "niente modello da scaricare".

| Livello | Cos'è | Peso | Pro | Contro |
|---|---|---|---|---|
| **A. Regole** | Parole e frasi chiave per ogni richiesta e genere, in italiano e inglese | Zero | Semplice, prevedibile, già nel piano | Ogni sinonimo e variante va scritto a mano |
| **B. Piccolo classificatore nostro** | Qualche centinaio di frasi d'esempio (italiano e inglese) scritte da noi per ogni richiesta; uno script le trasforma in un file di pesi (sequenze di lettere, non solo parole) che l'app legge in Dart puro | Pochi KB, dentro l'app | Regge errori di battitura e varianti ("consigliami", "consigli", "consiglia"); nessun plugin, nessun download, testabile | Riconosce solo frasi che somigliano agli esempi; serve scrivere gli esempi e mantenerli |
| **C. Modello pre-addestrato che capisce il significato** | Un modello di "embedding": trasforma ogni frase in numeri, e si sceglie la richiesta con l'esempio più vicino | **Circa 118 MB** in int8 per `multilingual-e5-small` (versioni della comunità, non verificato su tutte: un'altra copia dichiara 470 MB) | Capisce parafrasi e sinonimi senza elencarli, anche tra lingue | Download di 100+ MB (circa un decimo del modello di linguaggio); serve un plugin con ONNX Runtime (`flutter_gemma_onnx` dichiara Android, iOS e desktop; `flutter_embedder` è pensato soprattutto per Android); ogni frase costa tempo e memoria |

Fatti verificati il 2026-11-20: MediaPipe ha un Text Embedder con un modello piccolo (Universal Sentence Encoder, circa 10 ms per frase) e uno più capace (EmbeddingGemma 300m, circa 200 ms); un thread del forum di Google segnala qualità scarsa con il piccolo. Non ho trovato le dimensioni in MB dei modelli MediaPipe e non ho verificato che coprano l'italiano. [MediaPipe](https://developers.google.com/edge/mediapipe/solutions/text/text_embedder), [multilingual-e5-small ONNX](https://huggingface.co/intfloat/multilingual-e5-small/tree/main/onnx), [int8 della comunità](https://huggingface.co/deepfile/multilingual-e5-small-onnx-qint8), [flutter_gemma_onnx](https://pub.dev/documentation/flutter_gemma_onnx/0.3.0/), [flutter_embedder](https://pub.dev/documentation/flutter_embedder/latest/). Che E5 multilingue copra bene l'italiano è conoscenza generale, da verificare con una prova.

**Attenzione: riconoscere la frase non basta.** "Qualcosa di rilassante" si può riconoscere benissimo, ma il bot può rispondere solo con i dati che ha, e la cache dei candidati non ha l'etichetta "rilassante". Un modello migliore capisce meglio la richiesta, non crea i dati: per richieste nuove (rilassante, cooperativo, breve) servono comunque nuove etichette nella cache (si allarga `CATEGORY_TAGS` del Worker).

### Cosa sa fare nella versione 1

| Richiesta | Come sceglie | Offline |
|---|---|---|
| "Cosa gioco dopo?" | Dalla libreria: prima i quasi finiti (`almostThere`), poi quelli in corso per ultimo sblocco, poi i non iniziati | Sì |
| "Quali sto per finire?" | `almostThere`, con i trofei che mancano | Sì |
| "Un gioco nuovo di [genere]" | Dalla cache di quel genere, senza i giochi già in libreria | Sì, dopo la prima volta online |
| "Simile a X" | I giochi che stanno nelle stesse categorie di X nella cache (più categorie in comune, più è simile) | Sì, se X è nella cache |
| "Sorprendimi" | Uno a caso dalla cache, non in libreria | Sì, dopo la prima volta online |

Limiti da dire chiaramente: "simile" vuol dire **stessi generi**, non stesso stile (con 12 categorie larghe, Hades risulta vicino ad altri giochi Action, RPG e Indie); funziona solo per i circa 480 giochi della cache. Più avanti si possono aggiungere etichette alla cache senza nuove schede (per esempio roguelike, metroidvania, cooperativo): basta allargare l'elenco `CATEGORY_TAGS` del Worker.

## Struttura nel codice

Seguendo l'architettura già in uso (feature-first, Cubit, `get_it` manuale):

```
lib/features/chat/
  domain/        ChatMessage, ChatIntent, IntentParser, Recommender, ReplyComposer
  data/          CandidateCache (SharedPreferences, rinfresco con getCategoryGames)
  presentation/  ChatCubit, ChatPage, bolle, pulsanti-risposta, scheda gioco
```

- `ChatCubit` è un `registerFactory` in `injection_container.dart`, dipendenze posizionali.
- Punto d'ingresso: un pulsante con l'icona della nuvoletta accanto al campo di ricerca di Explore (`explore_page.dart`), che apre `/assistant` a schermo intero, fuori dalla `StatefulShellRoute`, come `/category/:tagId`. Il `ChatCubit` si crea a ogni apertura e si chiude con la schermata. La barra in basso resta a tre voci.
- Le schede dei giochi riusano `ExploreGameTile` e `withCovers`; toccandole si apre la pagina del gioco come dai risultati di ricerca.

## Test

- Unit: tabelle di frasi in italiano e inglese per `IntentParser` (anche frasi non capite e maiuscole/accenti), `Recommender` con librerie e cache finte, `ReplyComposer`, cache (salva, carica, età, JSON rotto).
- Cubit con repository finti, come per Explore.
- Widget: pagina iniziale con i pulsanti, risposta con schede, frase non capita, nessuna rete e nessuna cache, il tasto indietro, il pulsante accanto alla ricerca di Explore (che apre `/assistant` e sta a fianco del campo) e la pagina su un telefono stretto con testo grande (nessun overflow).

## Fasi

1. **Dati e logica** (fatta il 2026-11-20, non ancora committata): `CandidateCache` (`data/candidate_cache.dart`), `parseIntent` (`domain/intent_parser.dart`), `Recommender` (`domain/recommender.dart`), `ReplyComposer` (`domain/reply_composer.dart`) e `ChatEngine` (`domain/chat_engine.dart`), che li mette insieme e non ha bisogno di rete. Tutto con test, in italiano e inglese. Scelte fatte lungo la strada: le richieste si controllano nell'ordine "simile a", quasi finiti, sorprendimi, genere, qualcosa di nuovo, cosa gioco dopo, consiglio generico, aiuto; "simile" è il rapporto tra generi in comune e generi totali dei due giochi; ogni risposta mostra 3 giochi e "Mostrane altri" continua da dove si era fermata; se un genere non ha giochi salvati il bot dice di collegarsi a internet una volta, non che li hai già tutti.
2. **Interfaccia** (fatta il 2026-11-20, non ancora committata): pagina della chat con pulsanti e schede (`presentation/ui/chat_page.dart`), `ChatCubit` che tiene la conversazione solo in memoria e rinfresca la cache all'apertura, rotta `/assistant` fuori dalla barra, pulsante accanto alla ricerca di Explore, `CandidateCache`, `ChatEngine` e `ChatCubit` nel DI. La lingua di partenza è quella del telefono. Provata su un secondo simulatore: Explore con il pulsante, apertura a schermo intero con il tasto indietro, saluto in italiano, risposta con scheda e copertina vera, scelta del genere.
3. **Dopo, solo se serve:** generi dei giochi della libreria per personalizzare "un gioco nuovo" (rotta del Worker con le etichette), più etichette per la somiglianza, "trofei facili" con `/rarity`, e se le frasi libere non bastano un modello **molto più piccolo** del giga (soglia da concordare, vedi sotto).

## Rischi

- **Frasi non capite:** il bot riconosce solo ciò che gli abbiamo insegnato; ogni sinonimo si aggiunge a mano. Si mitiga con i pulsanti-risposta e con un messaggio chiaro quando non capisce.
- **"Simile" grossolano:** sono i generi, non lo stile. Va detto nella risposta.
- **Cache vecchia o assente:** all'inizio il bot consiglia solo dalla libreria; mostrare la data dell'ultimo aggiornamento.
- **Sensazione di chatbot meno "umano":** le frasi sono a modello; si usano più varianti per non ripetersi.
- **Lingue:** ogni frase va mantenuta in ogni lingua supportata.

## Possibili risposte in più (proposta, 2026-11-20)

Per un'esperienza più completa, in ordine di quanto costano e di quanto sono affidabili. Le stime di lavoro sono mie.

1. **Domande sui propri dati.** "Quanti trofei ho?", "cosa ho sbloccato di recente?", "quanti trofei questo mese?", "a che punto sono con Terraria?", "quali ho completato?", "quali non ho mai iniziato?", "a cosa ho giocato per ultimo?". Si calcolano dalla libreria (esistono già `libraryTotals`, `recentUnlocks`, `unlocksPerDay`, `topGames`, `arrangeLibrary`), quindi funzionano offline e non possono inventare nulla. Lavoro: piccolo. **Attenzione:** non sono consigli, quindi vanno oltre la decisione "solo consigli": serve il tuo ok.
2. **Convenevoli.** "Grazie", "ripeti", "ricomincia", "cosa sai fare?" con esempi. Lavoro: minimo, e fanno sembrare la chat più viva.
3. **Consigli per umore e modalità.** Stesso meccanismo dei generi con nuove etichette di Steam: rilassante (1654), cooperativo (1685), con una bella storia (1742), roguelike (1716), difficile (4026), metroidvania (1628), multigiocatore (3859). Verificate il 2026-11-20: le etichette esistono e per rilassante, cooperativo, storia, roguelike, difficile e metroidvania le liste sono sensate (It Takes Two, Stardew Valley, Hollow Knight, Elden Ring). "Breve" (4234) e "cozy" (97376) danno soprattutto titoli sconosciuti: meglio lasciarli. Richiede: aggiungere gli id a `CATEGORY_TAGS` del Worker (nuovo deploy), una lista di etichette solo per la chat distinta dai 12 riquadri di Explore, e nuove parole chiave. Migliora anche "simile a X" (più generi in comune).
4. **Trofei facili.** "Quale gioco della libreria è più facile da completare?", "qual è il trofeo più facile che mi manca in X?". Serve la rarità dei trofei (`/rarity`, una richiesta per gioco, solo online): si salva per i giochi della libreria quando c'è rete. Per i giochi nuovi non è fattibile (troppe richieste). Lavoro: medio.
5. **Consigli sui tuoi gusti.** "Consigliami in base a quello che gioco". Servono i generi dei giochi della libreria, che ora non abbiamo (il catalogo ha solo id e nome): una rotta del Worker che li restituisce, salvati in locale. Lavoro: medio, e funziona solo dopo essere stati online.
6. **Azioni sulle schede.** "Aggiungi alla libreria" senza aprire il gioco, "non mi interessa" per non rivedere un gioco. Il secondo salva una piccola lista sul telefono. Lavoro: piccolo o medio.

**Non fattibili con i dati che abbiamo:** trama, durata, difficoltà soggettiva, recensioni, prezzi e sconti, "è bello X?". Il catalogo offline non li contiene e senza un modello l'app non può rispondere in modo affidabile.

Ordine che consiglio: 1 e 2 (poco lavoro, tutto verificabile), poi 3 (più varietà nei consigli), poi 4 e 5.

## Decisioni da confermare

1. **Quali risposte aggiungere**, tra quelle di "Possibili risposte in più" (in particolare se includere le domande sui propri dati, che vanno oltre "solo consigli").
2. **Come riconoscere le frasi** se le regole non bastano: B piccolo classificatore nostro (pochi KB, consigliato come passo successivo) oppure C modello pre-addestrato (circa 118 MB, con una soglia di download da fissare). Non serve deciderlo finché le regole bastano: `parseIntent` si sostituisce.

## Fonti

Vedi i link nello "Storico".
