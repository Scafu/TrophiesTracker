import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/database/app_database.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/models/game_model.dart';
import 'package:trophies_tracker/features/game/data/models/trophy_model.dart';

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
        appId: 1,
        name: 'G',
        trophies: [TrophyModel(apiName: 'a', displayName: 'A')],
      ),
    );
    await ds.updateStateTrophy(1, 'a', true);
    expect(await db.select(db.activities).get(), hasLength(1));

    await ds.deleteGameFromDb(1);

    expect(await db.select(db.trophies).get(), isEmpty);
    expect(await db.select(db.activities).get(), isEmpty);
  });
}
