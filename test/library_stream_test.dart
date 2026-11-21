import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/database/app_database.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/models/game_model.dart';
import 'package:trophies_tracker/features/game/data/models/trophy_model.dart';

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
          code: '1',
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
}
