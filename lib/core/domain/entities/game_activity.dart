import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';

/// Represents an activity event performed by the user, such as
/// adding a new game to the library or unlocking a specific trophy.
class GameActivity {
  /// The game associated with this activity.
  final GameKey game;

  /// The display name of the unlocked trophy.
  /// If this is null, the activity represents adding the game to the library.
  final String? trophyDisplayName;

  /// The exact date and time when the activity occurred.
  final DateTime timestamp;

  /// Creates a new [GameActivity] instance.
  const GameActivity({
    required this.game,
    this.trophyDisplayName,
    required this.timestamp,
  });

  /// Returns true if this activity represents adding a game to the library.
  bool get isGameAdded => trophyDisplayName == null;

  /// Returns true if this activity represents unlocking a trophy.
  bool get isTrophyUnlocked => trophyDisplayName != null;
}
