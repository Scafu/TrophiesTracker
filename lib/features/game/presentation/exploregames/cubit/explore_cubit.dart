import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  final GameRepository _gameRepository;

  ExploreCubit(this._gameRepository) : super(ExploreInitial());

  Future<void> searchGames(String query) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      emit(ExploreInitial());
      return;
    }

    emit(ExploreLoading());

    try {
      final results = await _gameRepository.searchLocalCatalog(cleanQuery);

      if (results.isEmpty) {
        emit(const ExploreError("No games found."));
      } else {
        emit(ExploreSuccess(results));
      }
    } catch (e) {
      emit(ExploreError(e.toString()));
    }
  }
}
