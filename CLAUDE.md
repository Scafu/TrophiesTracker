# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

`flutter`/`dart` are **not on PATH** here; Flutter is managed by fvm. Prefix commands with `export PATH="$HOME/fvm/default/bin:$PATH" &&`.

```bash
flutter pub get
flutter run
flutter analyze                      # also run by CI before building
dart run build_runner build --delete-conflicting-outputs   # regenerate drift/freezed/json code
flutter test                         # single file: flutter test test/foo_test.dart
(cd worker && npm test)              # Cloudflare Worker tests (node:test, no dependencies)
```

- Generated files (`*.g.dart`, `*.freezed.dart`) are **committed**. After editing a drift table, a `@freezed` class or a `@JsonSerializable` model, re-run `build_runner` and commit the output.
- `test/widget_test.dart` is the untouched Flutter counter template and fails against the real app (see REVIEW.md B2). The real tests are `test/game_remote_data_source_test.dart` (`MockClient`) and `test/app_database_test.dart` (in-memory Drift); run them by path.
- CI is Codemagic ([codemagic.yaml](codemagic.yaml)): every push to `main` analyzes, builds APK/AAB/iOS, then tags `v<pubspec version>` and publishes a GitHub release (deleting and recreating the tag if it already exists). Bump `version:` in `pubspec.yaml` to cut a new release.

## Known issues

[REVIEW.md](REVIEW.md) tracks reviewed problems (A = high, M = medium, B = low, V = to verify). Read it before changing the sync, database or login code; when you fix an item, tick it there with the commit, and add new findings under a new ID.

## Architecture

Feature-first Clean Architecture under `lib/features/<feature>/{data,domain,presentation}` (account, game, settings, stats), plus `lib/core` for shared code. State management is `flutter_bloc` Cubits; navigation is `go_router`; DI is `get_it`.

**Dependency wiring is manual** in [lib/core/di/injection_container.dart](lib/core/di/injection_container.dart) (`sl`). Data sources and repositories are lazy singletons registered by interface; Cubits are `registerFactory` and take dependencies positionally via `sl()`. Adding a constructor parameter to a Cubit/repository means updating this file too. `main()` awaits `di.init()` before `runApp`.

**Global Cubits** (`GameCubit`, `AccountCubit`, `SettingsCubit`) are provided once in [lib/main.dart](lib/main.dart); `ExploreCubit`, `StatsCubit` and `GameDetailsCubit` are provided per-route in [lib/core/router/app_router.dart](lib/core/router/app_router.dart). Routes use a `StatefulShellRoute.indexedStack` for the three bottom-nav tabs (`/games`, `/explore`, `/stats`); `/accounts`, `/credits` and `/gamesDetails/:appId/:fromExplorer` sit outside the shell.

**Local-first data.** Drift/SQLite ([lib/core/database/app_database.dart](lib/core/database/app_database.dart): `Games`, `Trophies`, `Activities`, `SteamCatalog`) is the source of truth; the UI reacts to `GameRepository.watchLibrary()` streams. Changing a table requires bumping `schemaVersion` and adding a migration step in the same file. `Game.platformSource` (`'local'` vs `'steam'`) and `isSynced` distinguish manually-added games from ones imported from a Steam account — logout deletes only `steam` + `isSynced` rows.

**Backend proxy.** Its source is in [worker/](worker/) (deployed by hand with `cd worker && npx wrangler deploy`; `wrangler.jsonc` declares the `KV` binding and `STEAM_API_KEY` is a secret configured on Cloudflare, not in the repo). A change to the token/login protocol must ship app and Worker together. Cover art: Steam's default `library_600x900_2x.jpg` is a grey placeholder (HTTP 200) for many recent games, so the real URL comes from the Worker's `/covers` route and `GameCover` falls back through the other Steam images. The trophy rarity shown on the game page comes from the Worker's `/rarity` route. All remote calls (catalog, game details, user info, Steam login) go through a Cloudflare Worker whose base URL is hardcoded twice in `injection_container.dart`. The app never talks to Steam directly and holds no Steam API key. The Steam catalog is bulk-downloaded once into `SteamCatalog` (first 8 chunks synchronously, the rest in a fire-and-forget background task in `GameRepositoriesImpl`) and searched offline.

**Steam login / deep links (PKCE).** `AccountRepositoryImpl.startLogin()` generates a `Pkce` pair (`core/utils/pkce`), stores the verifier in secure storage and `AccountCubit.login()` opens `<proxy>/auth/steam?challenge=...` in the external browser. After Steam, the Worker redirects to `https://<worker>/open?code=...`, which reaches the app as that App Link or as `trophiestracker://stats?code=...`. `AccountCubit._handleDeepLink` hands the one-time code to `finishLogin`, which exchanges it with the saved verifier (`POST /auth/token`) for the session token; a link with no login in progress is ignored. The token is kept only in `FlutterSecureStorage` (never in SharedPreferences, nor in the cached profile) and sent as `Authorization: Bearer`; logout also calls `POST /logout`. `AppRouter.redirect` just rewrites the callback to `/accounts?sync=true`, which triggers the library sync once the cubit is authenticated. Never put the token in a route, URL or log line.

`GameRepositoriesImpl` caches un-authenticated remote game details in memory (`_cachedGames`); token-authenticated fetches (which include the user's achieved state) bypass the cache.
