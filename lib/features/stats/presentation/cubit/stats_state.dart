import 'package:trophies_tracker/core/domain/entities/game_activity.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';

/// Represents the various states of the statistics feature.
sealed class StatsState {
  const StatsState();
}

/// Indicates that the statistics are currently being loaded.
class StatsLoading extends StatsState {
  const StatsLoading();
}

/// Contains the loaded data for the statistics view.
class StatsLoaded extends StatsState {
  final List<Game> games;
  final List<GameActivity> activities;

  const StatsLoaded({required this.games, required this.activities});

  /// Computes the total number of games in the user's library.
  int get totalGames => games.length;

  /// Computes the total number of achieved trophies across all games.
  int get totalAchievedTrophies {
    return games.fold(0, (sum, game) {
      return sum + game.trophies.where((t) => t.isAchieved == true).length;
    });
  }
}

/// Represents an error state if the statistics fail to load.
class StatsError extends StatsState {
  final String message;
  const StatsError(this.message);
}
