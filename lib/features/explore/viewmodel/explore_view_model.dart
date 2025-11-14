import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trophies_app_tracker/core/models/game/game_summary.dart';
import 'package:trophies_app_tracker/core/services/app_database.dart';
import 'package:trophies_app_tracker/core/services/json_service.dart';

List<GameSummary> parseGamesFromString(String jsonString) {
  final data = jsonDecode(jsonString);
  final apps = data['response']['apps'] as List;
  return apps.map((game) => GameSummary.fromJson(game)).toList();
}

class JsonDataProvider extends AsyncNotifier<List<GameSummary>> {
  @override
  Future<List<GameSummary>> build() async {
    // Leggo il JSON dal bundle sul main isolate
    final jsonString = await JsonService().loadRawJson();

    // Parsing pesante in un isolate
    return compute(parseGamesFromString, jsonString);
  }

  List<GameSummary> get gamesList => state.value!;
}

final jsonDataProvider =
    AsyncNotifierProvider<JsonDataProvider, List<GameSummary>>(
      JsonDataProvider.new,
    );

class SuggestionBuilderProvider extends Notifier<List<GameSummary>> {
  @override
  List<GameSummary> build() {
    return [];
  }

  void searchByValue(String value, List<GameSummary> gameList) {
    List<GameSummary> results = [];
    if (value.isEmpty) {
      state = gameList;
      return;
    }
    if (int.tryParse(value) != null) {
      results = gameList
          .where((game) => game.appid.toString().contains(value))
          .toList();
    } else {
      results = gameList
          .where(
            (game) => game.name.toLowerCase().contains(value.toLowerCase()),
          )
          .toList();
    }
    state = results;
  }

  Future<bool> checkIfAlreadyExist(int appId) async {
    final db = await AppDatabase().database;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM games WHERE appId = ?', [appId]),
    );
    return (result ?? 0) > 0;
  }
}

final suggestionBuilderProvider =
    NotifierProvider<SuggestionBuilderProvider, List<GameSummary>>(
      SuggestionBuilderProvider.new,
    );
