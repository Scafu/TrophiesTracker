import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:trophies_app_tracker/core/models/game/game.dart';
import 'package:trophies_app_tracker/core/models/game/game_summary.dart';
import 'package:trophies_app_tracker/core/models/trophy/trophy.dart';

class JsonService {
  final Dio _dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 5)));
  Future<List<GameSummary>> fetchFromLocalDatabase() async {
    try {
      final jsonString = await rootBundle.loadString(
        'lib/resources/steam_database/download.json',
      );
      final data = jsonDecode(jsonString);

      final apps = data['response']['apps'] as List;

      return apps
          .map<GameSummary>((game) => GameSummary.fromJson(game))
          .toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> loadRawJson() async {
    return await rootBundle.loadString(
      'lib/resources/steam_database/download.json',
    );
  }

  Future<Game> fetchDataGameSteam(int appId) async {
    try {
      final response = await _dio.get(
        "https://store.steampowered.com/api/appdetails?",
        queryParameters: {'appids': appId},
      );

      final data = response.data['$appId']['data'];
      final libraryImage =
          "https://cdn.akamai.steamstatic.com/steam/apps/$appId/library_600x900.jpg";

      final jsonString2 = await _dio.get(
        "https://trophiestracker.alessandro-mazzariol04.workers.dev",
        queryParameters: {"appid": appId},
      );

      final trophyList =
          (jsonString2.data['game']?['availableGameStats']?['achievements'] ??
                  [])
              as List;
      final localJson = await rootBundle.loadString(
        'lib/resources/local_database/trophy_100.json',
      );

      final localData = jsonDecode(localJson);
      final publishers =
          (data['publishers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Unknown'];

      final customTrophy = Trophy.fromJson(localData);

      final trophies = [
        customTrophy,
        ...trophyList.map<Trophy>(
          (trophy) => Trophy.fromJson({
            'displayName': trophy['displayName'] ?? '',
            'description': trophy['description'],
            'coloredIcon': trophy['icon'],
            'uncoloredIcon': trophy['icongray'],
            'isAchieved': 0,
          }),
        ),
      ];

      return Game(
        appId: appId,
        name: data['name'] ?? 'Unknown',
        publisher: publishers,
        description: data['short_description'] ?? '',
        headerImage: data['header_image'],
        libraryImage: libraryImage,
        trophies: trophies,
      );
    } catch (e) {
      throw Exception('Impossibile caricare dati per appId $appId');
    }
  }
}
