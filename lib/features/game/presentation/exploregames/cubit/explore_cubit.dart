import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  final GameRepository _gameRepository;
  String _latestQuery = '';

  /// How many results get their real cover looked up, from the top.
  static const _coverBatch = 24;

  ExploreCubit(this._gameRepository) : super(const ExploreInitial());

  /// Searches the offline catalog for [query] and shows the matches at once,
  /// then looks up the real covers of the first ones and shows the list again.
  ///
  /// An answer for a query that is no longer the latest one is dropped, so a
  /// slow cover lookup can never replace the results of what was typed next.
  Future<void> searchGames(String query) async {
    final cleanQuery = query.trim();
    _latestQuery = cleanQuery;

    if (cleanQuery.isEmpty) {
      emit(const ExploreInitial());
      return;
    }

    final List<Game> results;
    try {
      results = await _gameRepository.searchLocalCatalog(cleanQuery);
    } catch (e) {
      logger.e('Catalog search failed: $e');
      if (_isCurrent(cleanQuery)) {
        emit(const ExploreError('Search failed. Please try again.'));
      }
      return;
    }
    if (!_isCurrent(cleanQuery)) return;

    if (results.isEmpty) {
      emit(const ExploreEmpty());
      return;
    }
    emit(ExploreSuccess(results));

    try {
      final covered = await _gameRepository.withCovers(
        results.take(_coverBatch).toList(),
      );
      if (_isCurrent(cleanQuery)) {
        emit(ExploreSuccess([...covered, ...results.skip(_coverBatch)]));
      }
    } catch (e) {
      logger.w('Could not look up covers for the results: $e');
    }
  }

  bool _isCurrent(String query) => !isClosed && _latestQuery == query;
}
