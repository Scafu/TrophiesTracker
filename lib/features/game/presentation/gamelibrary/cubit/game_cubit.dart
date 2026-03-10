import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/features/account/domain/repositories/account_repository.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';

/// Manages the reactive state of the game library.
class GameCubit extends Cubit<GameState> {
  /// The repository handling game data operations.
  final GameRepository repository;
  final AccountRepository accountRepository;
  final Logger _logger;
  final RateRequestLimiter _rateRequestLimiter;

  StreamSubscription<List<Game>>? _librarySubscription;

  /// Creates a new [GameCubit].
  GameCubit(
    this.repository,
    this.accountRepository,
    this._logger,
    this._rateRequestLimiter,
  ) : super(const GameState.initial());

  /// Subscribes to the local database stream to reactively update the UI.
  void watchGames() {
    _logger.i("Subscribing to game library stream...");

    _librarySubscription?.cancel();

    _librarySubscription = repository.watchLibrary().listen(
      (games) {
        _logger.i("Stream updated: Loaded ${games.length} games");
        emit(GameState.loaded(games: games));
      },
      onError: (error, stackTrace) {
        _logger.e(
          "Error in game library stream: $error",
          stackTrace: stackTrace,
        );
        emit(GameState.error(error.toString()));
      },
    );
  }

  Future<void> fetchGamesFromSteamAccount() async {
    final key = 'fetchGamesFromSteamAccount';

    if (!_rateRequestLimiter.isAllowed(key, const Duration(minutes: 5))) {
      emit(GameState.error('429'));
      return;
    }

    final token = await accountRepository.getToken();
    if (token == null) {
      emit(const GameState.error('No token found. Please login.'));
      return;
    }

    _rateRequestLimiter.markRequest(key);
    emit(const GameState.loading());

    try {
      await repository.fetchGamesFromSteamAccount(token);
      _logger.i("Fetch from Steam successful");
      watchGames();
    } catch (error, stackTrace) {
      _logger.e(
        "Error fetching games from Steam: $error",
        stackTrace: stackTrace,
      );
      if (!isClosed) emit(GameState.error(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _logger.i("Closing GameCubit and cancelling stream subscription.");
    _librarySubscription?.cancel();
    return super.close();
  }
}
