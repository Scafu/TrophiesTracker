# Presentation screenshots

How `docs/screenshots/*.png` were made, to redo them when the interface changes. They are real captures of the app on an Android emulator, with a library of real games (real covers and achievement lists from the Worker's public routes, with generated progress and dates; nothing comes from a real account).

1. **Build and install** a debug APK: from `android/`, with JDK 21 and a dummy `key.properties` (see `REVIEW.md` M11), `./gradlew :app:assembleDebug`; then start an emulator (a Pixel works well), `adb install -r build/app/outputs/apk/debug/app-debug.apk`, launch the app once so it creates its database, and force-stop it.
2. **Fill the library:** `python3 make_seed.py seed.sql`, pull the database (`adb exec-out run-as com.alessandromazzariol.trophiestracker cat app_flutter/trophies_tracker.sqlite > db.sqlite`), `sqlite3 db.sqlite < seed.sql`, copy it back with `run-as ... cp` and delete the `-wal` and `-shm` files on the device.
3. **Set the scene:** dark theme (`adb shell cmd uimode night yes`) and a clean status bar with the system UI demo mode (clock 9:41, full battery, Wi-Fi only).
4. **Capture** with `adb exec-out screencap -p`, in this order, into this folder: `01_library_raw.png` (Library), `02_explore_raw.png` (Explore), `03_details_raw.png` (a game page, top), `04_stats_raw.png` (Stats), `05_settings_raw.png` (Settings).
5. **Compose:** `python3 compose.py ../../docs/screenshots` draws each capture in a phone frame on the blue gradient with its title (it uses Google Chrome in headless mode, macOS path).

`make_seed.py` reads the Worker with `curl`: Cloudflare's browser check blocks Python's own HTTP client.
