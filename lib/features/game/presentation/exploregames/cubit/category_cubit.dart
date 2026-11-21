import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/category_state.dart';

/// The popular games of one Steam genre.
class CategoryCubit extends Cubit<CategoryState> {
  final GameRepository _repository;

  CategoryCubit(this._repository) : super(const CategoryLoading());

  /// Loads the games of the genre [tagId] and shows them at once, then looks
  /// up their real covers and shows the list again. Calling it again retries
  /// after a failure.
  Future<void> load(int tagId) async {
    emit(const CategoryLoading());

    final List<Game> games;
    try {
      games = await _repository.getCategoryGames(tagId);
    } catch (e) {
      logger.e('Could not load category $tagId: $e');
      if (!isClosed) {
        emit(
          const CategoryError(
            'Could not load these games. Check your connection and try again.',
          ),
        );
      }
      return;
    }
    if (isClosed) return;
    emit(CategoryLoaded(games));

    try {
      final covered = await _repository.withCovers(games);
      if (!isClosed) emit(CategoryLoaded(covered));
    } catch (e) {
      logger.w('Could not look up covers for category $tagId: $e');
    }
  }
}
