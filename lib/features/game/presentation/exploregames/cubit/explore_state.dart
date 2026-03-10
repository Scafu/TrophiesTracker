import 'package:trophies_tracker/features/game/domain/entities/game.dart';

sealed class ExploreState {
  const ExploreState();
}

class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreLoading extends ExploreState {
  const ExploreLoading();
}

class ExploreSuccess extends ExploreState {
  final List<Game> searchResults;
  const ExploreSuccess(this.searchResults);
}

class ExploreError extends ExploreState {
  final String message;
  const ExploreError(this.message);
}

class ExploreEmpty extends ExploreState {
  const ExploreEmpty();
}
