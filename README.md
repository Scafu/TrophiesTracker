# TrophiesTracker

<p align="center">
  <img src= "lib/assets/output-onlinepngtools.png" width = 25%/>
</p>

# Track your trophies locally, using just your phone
<p align="center">
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/flutter-3.35-blue?logo=flutter&logoColor=white" alt="Flutter">
  </a>
  <a href="https://github.com/Scafu/TrophiesTracker/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  </a>
</p>
<p> 
  This is a Flutter app made for learning purposes. While using this app you might find bugs or visual issues; if so, please create an issue and I will try to resolve it ASAP.
</p>

To contribute, fork the repository by running this command in your terminal:

```bash
git clone https://github.com/Scafu/TrophiesTracker
```

## Features

- :video_game: Search any game from a local database (Steam only for now)

- :trophy: Add games to your collection and start tracking your trophies

- :bar_chart: View your stats in the stats page

- :iphone: Made for mobile phones — tested only on Android (I don't have an iOS emulator)

## Installation from Source
1. Clone the repository or download the Source Code from the Release section.
2. To build the app correctly you need a *Steam API Key* which you can create at this URL: *https://steamcommunity.com/dev*
3. To run the app locally, run:
```bash
flutter doctor -v
flutter pub get
```
4.  after creating a .json file with the Key inside
```bash
flutter run --dart-define-from-file={YOUR_FILE}.json
```
5. To build the app in release mode, use:
- Android:
```bash
flutter build apk --release --dart-define-from-file={YOUR_FILE}.json
```
- Apple:
```bash
flutter build appbundle --release --dart-define-from-file={YOUR_FILE}.json
```
5. For security reasons I will not publish the APK or IPA until I have a server handling API calls. Until then, you will need to build the app from source. Sorry for the inconvenience.

## Something about the APP
The codebase was checked using AI for bug detection but was published only after I learned everything and refactored and corrected it myself.
Currently, I'm waiting for Serverpod Cloud to allow redirect calls from OpenID to the app.  
LLM used in this project are:
- ChatGPT v5
- Gemini Pro v2.5
- DeepSeek 70b

For Design and color, I used **StitchIO**: https://stitch.withgoogle.com

## Technologies
- **Riverpod**: as a state manager
- **SQFlite**: for the local database
- **Serverpod**: for backend calls (currently in develop)

## Things i want to add
- Steam authentication and retrieval of user trophy stats from the API, and merging them with local data

- API integration for other platforms such as Ubisoft and Epic Games

- Possibly adding an LLM to ask for game advice (unlikely to happen)
  



