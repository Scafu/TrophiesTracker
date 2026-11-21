import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/database/app_database.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/models/game_model.dart';
import 'package:trophies_tracker/features/game/data/models/trophy_model.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';

void main() {
  test('catalog search is limited, literal and prefix-first', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = GameLocalDataSourceImpl(db);
    await ds.saveSteamCatalogToDb([
      {'appid': 1, 'name': 'Portal'},
      {'appid': 2, 'name': 'Deep Portal'},
      {'appid': 3, 'name': '100% Orange Juice'},
      {'appid': 4, 'name': 'Half-Life'},
      {'appid': 5, 'name': 'Half_Life 2'},
    ]);
    Future<List<String>> search(String query, {int limit = 50}) async => [
      for (final game in await ds.searchInLocalCatalog(query, limit: limit))
        game.name,
    ];

    expect(await search('portal'), ['Portal', 'Deep Portal']);
    expect(await search('%'), ['100% Orange Juice']);
    expect(await search('half_'), ['Half_Life 2']);
    expect(await search('a', limit: 2), hasLength(2));
  });

  test('getLastCatalogAppId is 0 when empty, else the highest appId', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = GameLocalDataSourceImpl(db);
    expect(await ds.getLastCatalogAppId(), 0);

    await ds.saveSteamCatalogToDb([
      {'appid': 5, 'name': 'a'},
      {'appid': 9, 'name': 'b'},
    ]);

    expect(await ds.getLastCatalogAppId(), 9);
  });

  test('deleting a game cascades to its trophies and activities', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = GameLocalDataSourceImpl(db);

    await ds.saveGameToDb(
      const GameModel(
        code: '1',
        name: 'G',
        trophies: [TrophyModel(apiName: 'a', displayName: 'A')],
      ),
    );
    await ds.updateStateTrophy(GameKey.steam('1'), 'a', true);
    expect(await db.select(db.activities).get(), hasLength(1));

    await ds.deleteGameFromDb(GameKey.steam('1'));

    expect(await db.select(db.trophies).get(), isEmpty);
    expect(await db.select(db.activities).get(), isEmpty);
  });

  test(
    'the same code on Steam and PlayStation is two different games',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final ds = GameLocalDataSourceImpl(db);
      const trophies = [TrophyModel(apiName: 'a', displayName: 'A')];

      await ds.saveGameToDb(
        const GameModel(code: '7', name: 'On Steam', trophies: trophies),
      );
      await ds.saveGameToDb(
        const GameModel(
          platform: GamePlatform.psn,
          code: '7',
          name: 'On PlayStation',
          trophies: trophies,
        ),
      );

      expect(await db.select(db.games).get(), hasLength(2));
      expect(await db.select(db.trophies).get(), hasLength(2));

      await ds.updateStateTrophy(
        const GameKey(GamePlatform.psn, '7'),
        'a',
        true,
      );

      final steam = await ds.getGameByIdLocal(GameKey.steam('7'));
      final psn = await ds.getGameByIdLocal(
        const GameKey(GamePlatform.psn, '7'),
      );
      expect(steam!.name, 'On Steam');
      expect(steam.trophies.single.isAchieved, isFalse);
      expect(psn!.name, 'On PlayStation');
      expect(psn.trophies.single.isAchieved, isTrue);
    },
  );

  test('deleting one platform leaves the other game untouched', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = GameLocalDataSourceImpl(db);
    const trophies = [TrophyModel(apiName: 'a', displayName: 'A')];
    const psnKey = GameKey(GamePlatform.psn, '7');

    await ds.saveGameToDb(
      const GameModel(code: '7', name: 'On Steam', trophies: trophies),
    );
    await ds.saveGameToDb(
      const GameModel(
        platform: GamePlatform.psn,
        code: '7',
        name: 'On PlayStation',
        trophies: trophies,
      ),
    );
    await ds.updateStateTrophy(GameKey.steam('7'), 'a', true);
    await ds.updateStateTrophy(psnKey, 'a', true);

    await ds.deleteGameFromDb(GameKey.steam('7'));

    expect(await ds.getGameByIdLocal(GameKey.steam('7')), isNull);
    expect(await ds.getGameByIdLocal(psnKey), isNotNull);
    final left = await db.select(db.trophies).get();
    expect(left.map((t) => t.gamePlatform), ['psn']);
    final activities = await db.select(db.activities).get();
    expect(activities.map((a) => a.gamePlatform), ['psn']);
  });
}
