import 'package:trophies_tracker/core/domain/entities/game_activity.dart';

/// Defines the contract for managing user activities.
///
/// This repository handles the persistence and retrieval of [GameActivity]
/// events without depending on a specific database implementation.
abstract class ActivityRepository {
  /// Returns a continuous stream of the most recent user activities.
  ///
  /// This stream automatically emits a new list of activities whenever
  /// the underlying data changes.
  Stream<List<GameActivity>> watchActivities();

  /// Records a new activity in the persistence layer.
  ///
  /// Provide the [gameAppId] and an optional [trophyDisplayName].
  /// If [trophyDisplayName] is omitted or null, it registers a "game added" activity.
  Future<void> addActivity(int gameAppId, [String? trophyDisplayName]);

  /// Removes a specific activity from the persistence layer.
  Future<void> removeActivity(int gameAppId, [String? trophyDisplayName]);
}
