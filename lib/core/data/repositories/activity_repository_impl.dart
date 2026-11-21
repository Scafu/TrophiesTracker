import 'package:drift/drift.dart';
import 'package:trophies_tracker/core/database/app_database.dart';
import 'package:trophies_tracker/core/domain/entities/game_activity.dart';
import 'package:trophies_tracker/core/domain/repositories/activity_repository.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';

/// Implementation of [ActivityRepository] using the Drift local database.
class ActivityRepositoryImpl implements ActivityRepository {
  final AppDatabase db;

  ActivityRepositoryImpl(this.db);

  @override
  Stream<List<GameActivity>> watchActivities() {
    /// Watches the activities table and maps database rows to Domain Entities.
    return (db.select(db.activities)..orderBy([
          (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
        ]))
        .watch()
        .map((rows) {
          return rows.map((row) {
            return GameActivity(
              game: GameKey(
                GamePlatform.values.byName(row.gamePlatform),
                row.gameCode,
              ),
              trophyDisplayName: row.trophyDisplayName,
              timestamp: row.timestamp,
            );
          }).toList();
        });
  }

  @override
  Future<void> addActivity(GameKey game, [String? trophyDisplayName]) async {
    /// Inserts a new activity record into the Drift database.
    await db
        .into(db.activities)
        .insert(
          ActivitiesCompanion.insert(
            gamePlatform: game.platform.name,
            gameCode: game.code,
            trophyDisplayName: Value(trophyDisplayName),
            timestamp: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> removeActivity(GameKey game, [String? trophyDisplayName]) async {
    /// Deletes specific activities matching the game and optional trophy name.
    await (db.delete(db.activities)..where((t) {
          final isSameGame =
              t.gamePlatform.equals(game.platform.name) &
              t.gameCode.equals(game.code);
          if (trophyDisplayName != null) {
            return isSameGame & t.trophyDisplayName.equals(trophyDisplayName);
          }
          return isSameGame & t.trophyDisplayName.isNull();
        }))
        .go();
  }
}
