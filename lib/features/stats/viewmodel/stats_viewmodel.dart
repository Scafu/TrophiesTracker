import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synchronized/synchronized.dart';
import 'package:trophies_app_tracker/core/services/app_database.dart';
import 'package:trophies_app_tracker/features/shared/log.dart';

final recentActivityProvider =
    AsyncNotifierProvider<RecentActivityProvider, List<GameActivityData>>(
      RecentActivityProvider.new,
    );

class RecentActivityProvider extends AsyncNotifier<List<GameActivityData>> {
  final _lock = Lock();

  @override
  Future<List<GameActivityData>> build() async {
    final db = await AppDatabase().database;
    final result = await db.query('activity', orderBy: 'timestamp DESC');

    return result.map((row) {
      return GameActivityData(
        gameAppId: row['gameAppId'] as int,
        trophyDisplayName: row['trophyDisplayName'] as String?,
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
      );
    }).toList();
  }

  Future<void> addActivity(int gameAppId, [String? trophyDisplayName]) async {
    final db = await AppDatabase().database;
    final now = DateTime.now();

    await _lock.synchronized(() async {
      try {
        await db.insert('activity', {
          'gameAppId': gameAppId,
          'trophyDisplayName': trophyDisplayName,
          'timestamp': now.millisecondsSinceEpoch,
        });

        final currentActivities = state.value ?? [];
        state = AsyncValue.data([
          GameActivityData(
            gameAppId: gameAppId,
            trophyDisplayName: trophyDisplayName,
            timestamp: now,
          ),
          ...currentActivities,
        ]);
      } catch (e, st) {
        logger.e("Error adding activity: $e", stackTrace: st);
        state = AsyncValue.error(e, st);
      }
    });
  }
}

class GameActivityData {
  final int gameAppId;
  final String? trophyDisplayName;
  final DateTime timestamp;

  GameActivityData({
    required this.gameAppId,
    this.trophyDisplayName,
    required this.timestamp,
  });
}
