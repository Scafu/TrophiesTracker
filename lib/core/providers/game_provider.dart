import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:trophies_app_tracker/core/services/app_database.dart';
import 'package:trophies_app_tracker/core/models/game/game.dart';
import 'package:trophies_app_tracker/core/models/trophy/trophy.dart';
import 'package:trophies_app_tracker/core/services/json_service.dart';
import 'package:trophies_app_tracker/features/shared/log.dart';
import 'package:trophies_app_tracker/features/stats/viewmodel/stats_viewmodel.dart';

final dioProvider = Provider((ref) => Dio());

final singleGameProvider = Provider.family<Game?, int>((ref, appId) {
  final gameList = ref.watch(gameProviderOffline);
  return gameList.firstWhereOrNull((g) => g.appId == appId);
});

final allTrophiesProvider = Provider<List<Trophy>>((ref) {
  final games = ref.watch(gameProviderOffline);
  return games.expand((game) => game.trophies).toList();
});

final achievedTrophiesProvider = Provider<List<Trophy>>((ref) {
  final allTrophies = ref.watch(allTrophiesProvider);
  return allTrophies.where((trophy) => trophy.isAchieved == 1).toList();
});

final gameProviderOffline = NotifierProvider<GameProviderOffline, List<Game>>(
  GameProviderOffline.new,
);
final gameProviderSingleGameOffline = FutureProvider.family<Game?, int>(
  (ref, appId) =>
      ref.read(gameProviderOffline.notifier).fetchGameByAppId(appId),
);

final gameProviderSteam = FutureProvider.family<Game, int>((ref, appId) {
  logger.i("sto cercando $appId");
  return JsonService().fetchDataGameSteam(appId);
});

class GameProviderOffline extends Notifier<List<Game>> {
  final _jsonLock = Lock();
  static final _invalidFileName = RegExp(r'[<>:"/\\|~?*]');
  @override
  List<Game> build() => [];

  Future<String?> _downloadAndSaveImage(
    Dio dio,
    String pathOrUrl,
    String destPath,
  ) async {
    final file = File(destPath);
    await file.parent.create(recursive: true);
    if (await file.exists()) return file.path;

    try {
      if (pathOrUrl.startsWith('http')) {
        final response = await dio.get<List<int>>(
          pathOrUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        await file.writeAsBytes(response.data!);
        return file.path;
      }

      final possibleLocal = File(pathOrUrl);
      if (possibleLocal.existsSync()) {
        await possibleLocal.copy(destPath);
        return File(destPath).path;
      }

      final byteData = await rootBundle.load(pathOrUrl);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (e, st) {
      logger.e(
        "Error during download/save of $pathOrUrl -> $destPath: $e",
        stackTrace: st,
      );
      return null;
    }
  }

  Future<Trophy> _downloadTrophyAssets(
    Dio dio,
    String gameDirPath,
    Trophy trophy,
  ) async {
    final safeName = trophy.displayName.replaceAll(_invalidFileName, '_');
    final trophyDir = Directory(join(gameDirPath, safeName));
    await trophyDir.create(recursive: true);

    Future<String?>? coloredFuture;
    Future<String?>? uncoloredFuture;

    if (trophy.coloredIcon != null && trophy.coloredIcon!.isNotEmpty) {
      coloredFuture = _downloadAndSaveImage(
        dio,
        trophy.coloredIcon!,
        join(trophyDir.path, 'colored.png'),
      );
    }
    if (trophy.uncoloredIcon != null && trophy.uncoloredIcon!.isNotEmpty) {
      uncoloredFuture = _downloadAndSaveImage(
        dio,
        trophy.uncoloredIcon!,
        join(trophyDir.path, 'uncolored.png'),
      );
    }

    final coloredPath = coloredFuture != null ? await coloredFuture : null;
    final uncoloredPath = uncoloredFuture != null
        ? await uncoloredFuture
        : null;

    return trophy.copyWith(
      coloredIcon: coloredPath ?? trophy.coloredIcon,
      uncoloredIcon: uncoloredPath ?? trophy.uncoloredIcon,
    );
  }

  Future<Game> addGame(Game game) async {
    final dio = ref.read(dioProvider);
    final db = await AppDatabase().database;

    final gameResult = await _jsonLock.synchronized(() async {
      final appDir = await getApplicationDocumentsDirectory();
      final gameDir = Directory(
        join(appDir.path, 'games', game.appId.toString()),
      );
      await gameDir.create(recursive: true);

      try {
        final headerFuture = game.headerImage != null
            ? _downloadAndSaveImage(
                dio,
                game.headerImage!,
                join(gameDir.path, 'header.jpg'),
              )
            : Future.value(null);

        final libraryFuture = game.libraryImage != null
            ? _downloadAndSaveImage(
                dio,
                game.libraryImage!,
                join(gameDir.path, 'library.jpg'),
              )
            : Future.value(null);

        final trophyFutures = await Future.wait(
          game.trophies.map((t) => _downloadTrophyAssets(dio, gameDir.path, t)),
        );

        final gameWithLocalPaths = game.copyWith(
          headerImage: await headerFuture,
          libraryImage: await libraryFuture,
          trophies: trophyFutures,
          addedAt: game.addedAt ?? DateTime.now(),
        );

        final gameTimeStampInt = game.addedAt?.millisecondsSinceEpoch;
        await db.transaction((txn) async {
          await txn.insert('games', {
            'appId': gameWithLocalPaths.appId,
            'name': gameWithLocalPaths.name,
            'description': gameWithLocalPaths.description,
            'publisher': jsonEncode(gameWithLocalPaths.publisher),
            'headerImage': gameWithLocalPaths.headerImage,
            'libraryImage': gameWithLocalPaths.libraryImage,
            'addedAt': gameTimeStampInt,
          }, conflictAlgorithm: ConflictAlgorithm.replace);

          final batch = txn.batch();
          for (final trophy in trophyFutures) {
            final trophyTimeStampInt =
                trophy.achievedAt?.millisecondsSinceEpoch;
            batch.insert('trophies', {
              'gameAppId': game.appId,
              'description': trophy.description,
              'isAchieved': trophy.isAchieved,
              'displayName': trophy.displayName,
              'coloredIcon': trophy.coloredIcon,
              'uncoloredIcon': trophy.uncoloredIcon,
              'achievedAt': trophyTimeStampInt,
            });
          }
          await batch.commit(noResult: true);
        });

        state = [...state, gameWithLocalPaths];
        logger.i("${game.name} added");
        return gameWithLocalPaths;
      } catch (e, st) {
        logger.e(
          "Error during the operation with ${game.appId}: $e",
          stackTrace: st,
        );
        rethrow;
      }
    });

    return gameResult;
  }

  Future<void> removeGame(int appId) async {
    final db = await AppDatabase().database;
    try {
      await db.transaction((txn) async {
        await txn.delete(
          'trophies',
          where: 'gameAppId = ?',
          whereArgs: [appId],
        );
        await txn.delete('games', where: 'appId = ?', whereArgs: [appId]);
      });

      final appDir = await getApplicationDocumentsDirectory();
      final gameDir = Directory(join(appDir.path, "games", appId.toString()));
      if (await gameDir.exists()) await gameDir.delete(recursive: true);
      state = state.where((g) => g.appId != appId).toList();
      logger.i("$appId deleted");
    } catch (e, st) {
      logger.e("Error during operation with $appId: $e", stackTrace: st);
      rethrow;
    }
  }

  Future<void> fetchGamesFromDB() async {
    final db = await AppDatabase().database;
    final gameRows = await db.query('games');

    final games = await Future.wait(
      gameRows.map((row) async {
        final trophies = await _fetchTrophiesForGame(db, row['appId'] as int);
        return _mapGameFromDb(row, trophies);
      }),
    );

    state = games;
  }

  Future<Game?> fetchGameByAppId(int appId) async {
    final db = await AppDatabase().database;
    final result = await db.query(
      'games',
      where: 'appId = ?',
      whereArgs: [appId],
      limit: 1,
    );
    if (result.isEmpty) return null;

    final trophies = await _fetchTrophiesForGame(db, appId);
    return _mapGameFromDb(result.first, trophies);
  }

  Future<void> setTrophyAchieved(
    int appId,
    String displayName,
    int isAchieved,
  ) async {
    final db = await AppDatabase().database;
    bool shouldCompleteGame = false;

    final newState = await _jsonLock.synchronized(() async {
      try {
        final now = DateTime.now();
        final bool isUnachieving = (isAchieved == 0);
        final bool isNotMastery = (displayName != "Mastery Trophy");
        final bool needsMasteryUpdate = (isUnachieving && isNotMastery);
        final bool isAchieving = (isAchieved == 1);

        await db.update(
          'trophies',
          {
            'isAchieved': isAchieved,
            'achievedAt': isAchieved == 1 ? now.millisecondsSinceEpoch : null,
          },
          where: 'gameAppId = ? AND displayName = ?',
          whereArgs: [appId, displayName],
        );

        if (needsMasteryUpdate) {
          await db.update(
            'trophies',
            {'isAchieved': 0, 'achievedAt': null},
            where: 'gameAppId = ? AND displayName = ?',
            whereArgs: [appId, "Mastery Trophy"],
          );
        }

        final index = state.indexWhere((g) => g.appId == appId);
        if (index == -1) {
          throw Exception("Game with appId $appId not found in state");
        }
        final game = state[index];

        final trophies = game.trophies.map((t) {
          if (t.displayName == displayName) {
            return t.copyWith(
              isAchieved: isAchieved,
              achievedAt: isAchieved == 1 ? now : null,
            );
          }

          if (t.displayName == "Mastery Trophy" && needsMasteryUpdate) {
            return t.copyWith(isAchieved: 0, achievedAt: null);
          }
          return t;
        }).toList();

        bool allAchieved = false;
        if (isAchieving) {
          allAchieved = trophies
              .whereNot((t) => t.displayName == "Mastery Trophy")
              .every((t) => t.isAchieved == 1);
        }
        logger.i(allAchieved);
        if (index == -1) {
          throw Exception("Game with appId $appId not found in state");
        }
        if (allAchieved) {
          ref
              .read(recentActivityProvider.notifier)
              .addActivity(
                appId,
                trophies
                    .firstWhere((t) => t.displayName == "Mastery Trophy")
                    .displayName,
              );
          shouldCompleteGame = true;
        }
        return [
          ...state.sublist(0, index),
          game.copyWith(trophies: trophies),
          ...state.sublist(index + 1),
        ];
      } catch (e, st) {
        logger.e("Error during trophy update: $e", stackTrace: st);
        rethrow;
      }
    });
    state = newState;
    if (shouldCompleteGame) {
      await setGameCompleted(appId);
    }
  }

  Future<List<Trophy>> _fetchTrophiesForGame(Database db, int appId) async {
    final rows = await db.query(
      'trophies',
      where: 'gameAppId = ?',
      whereArgs: [appId],
    );
    return rows.map(_mapTrophyFromDb).toList();
  }

  Trophy _mapTrophyFromDb(Map<String, Object?> row) => Trophy(
    displayName: row['displayName'] as String,
    description: row['description'] as String?,
    isAchieved: row['isAchieved'] as int,
    coloredIcon: row['coloredIcon'] as String?,
    uncoloredIcon: row['uncoloredIcon'] as String?,
    achievedAt: row['achievedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(row['achievedAt'] as int)
        : null,
  );

  Game _mapGameFromDb(Map<String, Object?> row, List<Trophy> trophies) => Game(
    appId: row['appId'] as int,
    name: row['name'] as String,
    description: row['description'] as String?,
    publisher: (jsonDecode(row['publisher'] as String) as List).cast<String>(),
    headerImage: row['headerImage'] as String?,
    libraryImage: row['libraryImage'] as String?,
    addedAt: row['addedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(row['addedAt'] as int)
        : null,
    trophies: trophies,
  );

  Future<void> setGameCompleted(int appId) async {
    final db = await AppDatabase().database;

    await _jsonLock.synchronized(() async {
      final now = DateTime.now();
      final nowMs = now.millisecondsSinceEpoch;

      await db.rawUpdate(
        'UPDATE trophies SET isAchieved = 1, achievedAt = COALESCE(achievedAt, ?) WHERE gameAppId = ?',
        [nowMs, appId],
      );

      final gameIndex = state.indexWhere((g) => g.appId == appId);
      if (gameIndex != -1) {
        final game = state[gameIndex];

        final updatedGame = game.copyWith(
          trophies: game.trophies
              .map(
                (t) =>
                    t.copyWith(isAchieved: 1, achievedAt: t.achievedAt ?? now),
              )
              .toList(),
        );
        state = [
          ...state.sublist(0, gameIndex),
          updatedGame,
          ...state.sublist(gameIndex + 1),
        ];
      }
    });
  }
}
