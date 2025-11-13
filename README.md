# TrophiesTracker

<p align="center">
  <img src= "lib/assets/output-onlinepngtools.png" width = 25%/>
</p>

# Track your trophies locally, using just your phone

<p> 
  This is a Flutter app, made for learning purpose, while using this app you could find bugs, or visual problems, if so, please create an issue and i will try to resolve it ASAP.
</p>

To contribute fork the repository by runnning this command in your terminal:

```bash
git clone https://github.com/Scafu/TrophiesTracker
```

## Features

- :video_game: Search any game from local database (Only Steam for now)
- :trophy: Add the game to your collection and start tracking you trophies
- :bar_chart: See your stats in the stats page
- :iphone: Made for mobile phones tested only on Android (I don't have an emulator for Apple)

## Installation
1. Clone the repository or download the Source Code from the release section.
2. To be able to build the app correctly you will need a *Steam API Key* that you can create at this URL *https://steamcommunity.com/dev*
2. To run the app locally write down the following code:
```bash
flutter doctor -v
flutter pub get
flutter run --dart-define=STEAM_API_KEY={YOUR_API_KEY}
```
3. To build the app in release mode, you will have to write this instead:
- For Android:
```bash
flutter build apk --release --dart-define=STEAM_API_KEY{YOUR_API_KEY}
```
- For Apple:
```bash
flutter build appbundle --release --dart-define=STEAM_API_KEY{YOUR_API_KEY}
```
4. I know It's not the best to include the API_KEY inside the APK, i don't have a server to make API call with, if you have any advice feel free, to tell me.

## Something about the APP
The codebase is made using AI, but is published after i've learned all the things, and has been refacted by myself.  
Currently i'm waiting for Serverpod cloud to permit redirection call from OpenID to the App.  
LLM used in this project are:
- ChatGPT v5
- Gemini Pro v2.5
- DeepSeek 70b

For Design and color i used **StitchIO**: https://stitch.withgoogle.com

## Technologies
- **Riverpod**: as a state manager
- **SQFlite**: for the local database
- **Serverpod**: for backend calls (currently in develop)

## Things i wanna add
- Steam authentication and retrieve user trophies stats from API and merge the local data with the online one.
- Find or create an API to call other platform, such as Ubisoft and Epic Games
- Possible add an LLM to ask advice about games (Unlikely to happened)
  



