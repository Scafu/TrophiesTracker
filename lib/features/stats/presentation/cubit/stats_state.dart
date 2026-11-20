import 'package:trophies_tracker/features/game/domain/entities/game.dart';

/// Represents the various states of the statistics feature.
sealed class StatsState {
  const StatsState();
}

/// Indicates that the statistics are currently being loaded.
class StatsLoading extends StatsState {
  const StatsLoading();
}

/// The library the statistics are computed from.
class StatsLoaded extends StatsState {
  final List<Game> games;

  const StatsLoaded({required this.games});
}

/// Represents an error state if the statistics fail to load.
class StatsError extends StatsState {
  final String message;
  const StatsError(this.message);
}
