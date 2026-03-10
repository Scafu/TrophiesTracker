import 'package:trophies_tracker/features/game/domain/entities/game.dart';

/// Provides methods to calculate trophy completion statistics for a game.
extension GameCompletion on Game {
  /// Calculates the percentage of achieved trophies.
  ///
  /// Returns a double between 0.0 and 100.0. If the game has no trophies,
  /// it safely returns 0.0 to prevent division by zero errors.
  double get completionPercentage {
    if (trophies.isEmpty) {
      return 0.0;
    }

    final achievedCount = trophies.where((trophy) {
      return trophy.isAchieved;
    }).length;

    return (achievedCount / trophies.length) * 100;
  }

  /// Returns the formatted completion percentage as a string with no decimal places.
  String get formattedCompletionPercentage {
    return '${completionPercentage.toStringAsFixed(0)}%';
  }
}
