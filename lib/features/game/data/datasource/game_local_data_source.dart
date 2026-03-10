import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

import 'package:trophies_tracker/core/database/app_database.dart';
import 'package:trophies_tracker/features/game/data/models/game_model.dart';
import 'package:trophies_tracker/features/game/data/models/trophy_model.dart';

abstract class GameLocalDataSource {
  Future<List<GameModel>> fetchGamesFromDb();
  Future<void> saveGameToDb(GameModel game);
  Future<void> saveGamesToDb(List<GameModel> games);
  Future<void> deleteGameFromDb(int appId);
  Future<void> deleteGamesFromDb(String source, {bool onlySynced = false});
  Future<GameModel?> getGameByIdLocal(int appId);
  Future<void> updateStateTrophy(int appId, String trophyName, bool status);
  Stream<List<GameModel>> watchLibrary();
  Future<List<GameModel>> searchInLocalCatalog(String query);
  Future<bool> isCatalogEmpty();
  Future<void> saveSteamCatalogToDb(List<Map<String, dynamic>> apps);
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  /// Concrete implementation of the local data source using Drift.

  final AppDatabase db;

  GameLocalDataSourceImpl(this.db);

  @override
  Future<List<GameModel>> fetchGamesFromDb() async {
    final gamesData = await db.select(db.games).get();
    final trophiesData = await db.select(db.trophies).get();

    final Map<int, List<TrophyModel>> trophiesMap = {};
    for (final t in trophiesData) {
      trophiesMap
          .putIfAbsent(t.gameId, () => [])
          .add(
            TrophyModel(
              apiName: t.apiName,
              displayName: t.displayName,
              description: t.description,
              icon: t.icon,
              coloredIcon: t.coloredIcon,
              isAchieved: t.isAchieved,
              achievedAt: t.achievedAt,
            ),
          );
    }

    return gamesData.map((g) {
      return GameModel(
        appId: g.appId,
        name: g.name,
        publisher: g.publisher ?? [],
        description: g.description,
        headerImage: g.headerImage,
        libraryImage: g.libraryImage,
        addedAt: g.addedAt,
        platformSource: g.platformSource,
        isSynced: g.isSynced,
        trophies: trophiesMap[g.appId] ?? [],
      );
    }).toList();
  }

  @override
  Future<void> saveGamesToDb(List<GameModel> games) async {
    if (games.isEmpty) return;

    await db.batch((batch) {
      final gameCompanions = games
          .map(
            (game) => GamesCompanion.insert(
              appId: Value(game.appId),
              name: game.name,
              publisher: Value(game.publisher),
              description: Value(game.description),
              headerImage: Value(game.headerImage),
              libraryImage: Value(game.libraryImage),
              addedAt: Value(game.addedAt),
              platformSource: Value(game.platformSource),
              isSynced: Value(game.isSynced),
            ),
          )
          .toList();

      final trophyCompanions = games.expand((game) {
        return game.trophies.map(
          (trophy) => TrophiesCompanion.insert(
            apiName: trophy.apiName,
            displayName: trophy.displayName,
            gameId: game.appId,
            description: Value(trophy.description),
            icon: Value(trophy.icon),
            coloredIcon: Value(trophy.coloredIcon),
            isAchieved: Value(trophy.isAchieved),
            achievedAt: Value(trophy.achievedAt),
          ),
        );
      }).toList();

      batch.insertAllOnConflictUpdate(db.games, gameCompanions);

      if (trophyCompanions.isNotEmpty) {
        batch.insertAllOnConflictUpdate(db.trophies, trophyCompanions);
      }
    });
  }

  @override
  Future<void> saveGameToDb(GameModel game) async {
    await saveGamesToDb([game]);
  }

  @override
  Future<void> deleteGamesFromDb(
    String source, {
    bool onlySynced = false,
  }) async {
    await (db.delete(db.games)..where((t) {
          var expression = t.platformSource.equals(source);
          if (onlySynced) {
            expression &= t.isSynced.equals(true);
          }
          return expression;
        }))
        .go();
  }

  @override
  Future<void> deleteGameFromDb(int appId) async {
    await (db.delete(db.games)..where((t) => t.appId.equals(appId))).go();
  }

  @override
  Stream<List<GameModel>> watchLibrary() {
    final gamesStream = db.select(db.games).watch();
    final trophiesStream = db.select(db.trophies).watch();

    return Rx.combineLatest2<List<Game>, List<Trophy>, List<GameModel>>(
      gamesStream,
      trophiesStream,
      (gamesData, trophiesData) {
        final Map<int, List<TrophyModel>> trophiesMap = {};
        for (final t in trophiesData) {
          trophiesMap
              .putIfAbsent(t.gameId, () => [])
              .add(
                TrophyModel(
                  apiName: t.apiName,
                  displayName: t.displayName,
                  description: t.description,
                  icon: t.icon,
                  coloredIcon: t.coloredIcon,
                  isAchieved: t.isAchieved,
                  achievedAt: t.achievedAt,
                ),
              );
        }

        return gamesData.map((g) {
          return GameModel(
            appId: g.appId,
            name: g.name,
            publisher: g.publisher ?? [],
            description: g.description,
            headerImage: g.headerImage,
            libraryImage: g.libraryImage,
            addedAt: g.addedAt,
            platformSource: g.platformSource,
            isSynced: g.isSynced,
            trophies: trophiesMap[g.appId] ?? [],
          );
        }).toList();
      },
    ).distinct((prev, next) => const ListEquality().equals(prev, next));
  }

  @override
  Future<List<GameModel>> searchInLocalCatalog(String query) async {
    final lowerQuery = query.toLowerCase();
    final results = await (db.select(
      db.steamCatalog,
    )..where((t) => t.name.lower().like('%$lowerQuery%'))).get();
    return results
        .map(
          (r) => GameModel(
            appId: r.appId,
            name: r.name,
            publisher: [],
            platformSource: 'steam',
          ),
        )
        .toList();
  }

  @override
  Future<bool> isCatalogEmpty() async {
    final countExp = db.steamCatalog.appId.count();
    final query = db.selectOnly(db.steamCatalog)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();

    return result == 0;
  }

  @override
  Future<void> saveSteamCatalogToDb(List<Map<String, dynamic>> apps) async {
    if (apps.isEmpty) return;

    final companions = apps.map((app) {
      return SteamCatalogCompanion.insert(
        appId: Value(app['appid'] as int),
        name: app['name'] as String,
      );
    }).toList();

    await db.batch((batch) {
      batch.insertAll(
        db.steamCatalog,
        companions,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  @override
  Future<GameModel?> getGameByIdLocal(int appId) async {
    final gamesData = await (db.select(
      db.games,
    )..where((t) => t.appId.equals(appId))).getSingleOrNull();

    if (gamesData == null) return null;

    final trophiesData = await (db.select(
      db.trophies,
    )..where((t) => t.gameId.equals(appId))).get();

    final trophies = trophiesData
        .map(
          (t) => TrophyModel(
            apiName: t.apiName,
            displayName: t.displayName,
            description: t.description,
            icon: t.icon,
            coloredIcon: t.coloredIcon,
            isAchieved: t.isAchieved,
            achievedAt: t.achievedAt,
          ),
        )
        .toList();

    return GameModel(
      appId: gamesData.appId,
      name: gamesData.name,
      publisher: gamesData.publisher ?? [],
      description: gamesData.description,
      headerImage: gamesData.headerImage,
      libraryImage: gamesData.libraryImage,
      addedAt: gamesData.addedAt,
      platformSource: gamesData.platformSource,
      isSynced: gamesData.isSynced,
      trophies: trophies,
    );
  }

  @override
  Future<void> updateStateTrophy(
    int appId,
    String trophyName,
    bool status,
  ) async {
    await db.transaction(() async {
      await (db.update(db.trophies)..where(
            (t) => t.gameId.equals(appId) & t.apiName.equals(trophyName),
          ))
          .write(
            TrophiesCompanion(
              isAchieved: Value(status),
              achievedAt: Value(status ? DateTime.now() : null),
            ),
          );

      final trophy =
          await (db.select(db.trophies)..where(
                (t) => t.gameId.equals(appId) & t.apiName.equals(trophyName),
              ))
              .getSingleOrNull();

      if (trophy == null) return;

      if (status) {
        await db
            .into(db.activities)
            .insert(
              ActivitiesCompanion.insert(
                gameAppId: appId,
                timestamp: DateTime.now(),
                trophyDisplayName: Value(trophy.displayName),
              ),
            );
      } else {
        await (db.delete(db.activities)..where(
              (a) =>
                  a.gameAppId.equals(appId) &
                  a.trophyDisplayName.equals(trophy.displayName),
            ))
            .go();
      }
    });
  }
}
