import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/features/account/domain/repositories/account_repository.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';

/// Manages the reactive state of the game library and synchronization with external services.
class GameCubit extends Cubit<GameState> {
  final GameRepository repository;
  final AccountRepository accountRepository;
  final Logger _logger;
  final RateRequestLimiter _rateRequestLimiter;

  StreamSubscription<List<Game>>? _librarySubscription;

  GameCubit(
    this.repository,
    this.accountRepository,
    this._logger,
    this._rateRequestLimiter,
  ) : super(const GameState.initial());

  void watchGames() {
    _librarySubscription?.cancel();
    _librarySubscription = repository.watchLibrary().listen(
      (games) => emit(GameState.loaded(games: games)),
      onError: (error, stackTrace) {
        _logger.e(
          "Error in game library stream: $error",
          stackTrace: stackTrace,
        );
        emit(GameState.error(error.toString()));
      },
    );
  }

  /// Fetches games from Steam using the stored token.
  Future<void> fetchGamesFromSteamAccount() async {
    const key = 'fetch_steam_games';
    if (!_rateRequestLimiter.isAllowed(key, const Duration(minutes: 5))) {
      emit(const GameState.error('429'));
      return;
    }

    final token = await accountRepository.getToken();
    if (token == null) {
      emit(const GameState.error('No Steam token found.'));
      return;
    }

    _rateRequestLimiter.markRequest(key);
    emit(const GameState.loading());

    try {
      await repository.fetchGamesFromSteamAccount(token);
      watchGames();
    } catch (e) {
      emit(GameState.error(e.toString()));
    }
  }

  /// Clears synced games from the library.
  /// Usually called when the user logs out.
  Future<void> clearSyncedGames() async {
    try {
      await repository.deleteGamesBySource('steam', onlySynced: true);
    } catch (e) {
      _logger.e("Error clearing games: $e");
    }
  }

  @override
  Future<void> close() {
    _librarySubscription?.cancel();
    return super.close();
  }
}
