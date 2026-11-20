import 'package:trophies_tracker/features/game/domain/entities/game.dart';

sealed class ExploreState {
  const ExploreState();
}

/// No search yet, or the search field was cleared.
class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreSuccess extends ExploreState {
  final List<Game> searchResults;
  const ExploreSuccess(this.searchResults);
}

/// The search ran and nothing in the catalog matches.
class ExploreEmpty extends ExploreState {
  const ExploreEmpty();
}

class ExploreError extends ExploreState {
  final String message;
  const ExploreError(this.message);
}
