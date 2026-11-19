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
  Future<List<GameModel>> searchInLocalCatalog(String query, {int limit});
  Future<int> getLastCatalogAppId();
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

  /// Emits the whole library whenever games or trophies change.
  ///
  /// A single invalidation stream covers both tables, so a write that touches
  /// them both (a save, a sync) gives one consistent emission, and a newer
  /// change cancels a read that is still in flight.
  @override
  Stream<List<GameModel>> watchLibrary() {
    return db
        .customSelect('SELECT 1', readsFrom: {db.games, db.trophies})
        .watch()
        .switchMap((_) => Stream.fromFuture(fetchGamesFromDb()))
        .distinct((prev, next) => const ListEquality().equals(prev, next));
  }

  /// Searches the offline catalog by name and returns at most [limit] games.
  ///
  /// Names that start with the query come first, then alphabetical order.
  /// `%`, `_` and `\` typed by the user are matched literally.
  @override
  Future<List<GameModel>> searchInLocalCatalog(
    String query, {
    int limit = 50,
  }) async {
    final escaped = query.toLowerCase().replaceAllMapped(
      RegExp(r'[\\%_]'),
      (match) => '\\${match[0]}',
    );
    final results =
        await (db.select(db.steamCatalog)
              ..where(
                (t) => t.name.lower().like('%$escaped%', escapeChar: r'\'),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(
                  t.name.lower().like('$escaped%', escapeChar: r'\'),
                ),
                (t) => OrderingTerm.asc(t.name),
              ])
              ..limit(limit))
            .get();
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

  /// Returns the highest appId saved in the catalog, or 0 when it is empty.
  ///
  /// The remote catalog is paginated by ascending appId, so this is the point
  /// to resume the download from.
  @override
  Future<int> getLastCatalogAppId() async {
    final maxExp = db.steamCatalog.appId.max();
    final query = db.selectOnly(db.steamCatalog)..addColumns([maxExp]);
    final result = await query.map((row) => row.read(maxExp)).getSingle();

    return result ?? 0;
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
