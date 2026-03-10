# TrophiesTracker

<p align="center">
  <img src="../../../Desktop/assets/output-onlinepngtools.png" width=25%/>
</p>

# Track your trophies locally, using only your phone

<p align='center'>
  <a href="https://flutter.dev"><img alt="Flutter" src="https://img.shields.io/badge/flutter-3.35-blue?logo=flutter&logoColor=blue" /></a>
  &nbsp;
  <a href="https://github.com/Scafu/TrophiesTracker/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-MIT-green" /></a>
  &nbsp;
  <a href="https://codemagic.io/apps/6918531c322d670e8c8900c7"><img alt="Codemagic" src="https://api.codemagic.io/apps/6918531c322d670e8c8900c7/6918531c322d670e8c8900c6/status_badge.svg" /></a>
</p>

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

## Technologies

- **Riverpod**: as a state manager
- **SQFlite**: for the local database
- **Cloudflare**: Proxy for backend calls

## Things i want to add

- Steam authentication and retrieval of user trophy stats from the API, and merging them with local data

- API integration for other platforms such as Ubisoft and Epic Games

- Possibly adding an LLM to ask for game advice (unlikely to happen)
