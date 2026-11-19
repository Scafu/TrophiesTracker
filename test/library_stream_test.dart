import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/database/app_database.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_remote_data_source.dart';
import 'package:trophies_tracker/features/game/data/models/game_model.dart';
import 'package:trophies_tracker/features/game/data/models/trophy_model.dart';
import 'package:trophies_tracker/features/game/data/repositories/game_repositories_impl.dart';

class _StreamLocal extends Fake implements GameLocalDataSource {
  _StreamLocal(this.library);

  final Stream<List<GameModel>> library;

  @override
  Stream<List<GameModel>> watchLibrary() => library;
}

class _NoRemote extends Fake implements GameRemoteDataSource {}

void main() {
  test(
    'a save that touches games and trophies emits a consistent library',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final ds = GameLocalDataSourceImpl(db);
      final emissions = <List<GameModel>>[];
      final subscription = ds.watchLibrary().listen(emissions.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();
      emissions.clear();

      await ds.saveGameToDb(
        const GameModel(
          appId: 1,
          name: 'G',
          trophies: [TrophyModel(apiName: 'a', displayName: 'A')],
        ),
      );
      await pumpEventQueue();

      expect(emissions, isNotEmpty);
      expect(
        emissions.every((library) => library.single.trophies.length == 1),
        isTrue,
      );
    },
  );

  test(
    'every listener shares one query and a late one gets the latest library',
    () async {
      var queries = 0;
      final upstream = StreamController<List<GameModel>>(
        onListen: () => queries++,
      );
      addTearDown(upstream.close);
      final repository = GameRepositoriesImpl(
        localDataSource: _StreamLocal(upstream.stream),
        remoteDataSource: _NoRemote(),
      );
      final first = <int>[];
      final second = <int>[];
      final a = repository.watchLibrary().listen(
        (games) => first.add(games.length),
      );
      final b = repository.watchLibrary().listen(
        (games) => second.add(games.length),
      );
      addTearDown(a.cancel);
      addTearDown(b.cancel);

      upstream.add([const GameModel(appId: 1, name: 'G')]);
      await pumpEventQueue();
      final late = await repository.watchLibrary().first;

      expect(queries, 1);
      expect(
        [first, second],
        [
          [1],
          [1],
        ],
      );
      expect(late.single.appId, 1);
    },
  );
}
