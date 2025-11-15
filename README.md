# TrophiesTracker

<p align="center">
  <img src="lib/assets/output-onlinepngtools.png" width=25%/>
</p>

# Track your trophies locally, using only your phone

[![Flutter](https://img.shields.io/badge/flutter-3.35-blue?logo=flutter&logoColor=blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/Scafu/TrophiesTracker/blob/main/LICENSE)
[![Build Status](https://api.codemagic.io/apps/6918531c322d670e8c8900c7/6918531c322d670e8c8900c6/status_badge.svg)](https://codemagic.io/apps/6918531c322d670e8c8900c7)


<p> 
  This is a Flutter app made for learning purposes. While using this app you might find bugs or visual issues; if so, please create an issue and I will try to resolve it ASAP.
</p>

To contribute, fork the repository by running this command in your terminal:

```bash
git clone https://github.com/Scafu/TrophiesTracker
```

## Features

- :video_game: Search for any game in a local database (currently Steam only)

- :trophy: Add games to your collection and start tracking your trophies

- :bar_chart: View your stats in the stats page

- :iphone: Designed for mobile phones — currently tested only on Android (iOS not tested)

## Installation from Source

1. Clone the repository or download the Source Code from the Release section.
2. To run the app locally, write:

```bash
flutter doctor -v
flutter pub get
flutter run
```

3. To build the app in release mode, use:

- Android:

```bash
flutter build apk --release
```

- Apple:

```bash
flutter build ipa --release
```

## Something about the APP

The codebase was checked using AI for bug detection but was published only after I learned everything and refactored and corrected it myself.
Currently, the backend proxy for searching methods are hosted on cloudflare, in the future i will try different host.

- ChatGPT v5
- Gemini Pro v2.5
- DeepSeek 70b

For Design and color, I used **StitchIO**: https://stitch.withgoogle.com

## Technologies

- **Riverpod**: as a state manager
- **SQFlite**: for the local database
- **Cloudflare**: Proxy for backend calls

## Things i want to add

- Steam authentication and retrieval of user trophy stats from the API, and merging them with local data

- API integration for other platforms such as Ubisoft and Epic Games

- Possibly adding an LLM to ask for game advice (unlikely to happen)
