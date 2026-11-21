import 'package:trophies_tracker/features/game/domain/entities/game.dart';

sealed class CategoryState {
  const CategoryState();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

/// The games of the category, most popular first.
class CategoryLoaded extends CategoryState {
  final List<Game> games;
  const CategoryLoaded(this.games);
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
}
