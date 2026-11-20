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

  /// When the library was last synced from Steam, if it ever was.
  DateTime? get lastSync => repository.lastSteamSync;

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

  /// Emits [message] as an error, then resubscribes to the library so the
  /// state falls back to the saved games instead of staying on the error.
  void _fail(String message) {
    emit(GameState.error(message));
    watchGames();
  }

  /// Fetches games from Steam using the stored token.
  ///
  /// Emits [GameState.syncSuccess] when games were saved. Any failure, rate
  /// limit included, is emitted as a user-facing [GameState.error] followed by
  /// the current library. A failed sync frees the rate limit so it can be
  /// retried right away.
  Future<void> fetchGamesFromSteamAccount() async {
    const key = 'fetch_steam_games';
    if (!_rateRequestLimiter.isAllowed(key, const Duration(minutes: 5))) {
      _fail(rateLimitedMessage);
      return;
    }

    final token = await accountRepository.getToken();
    if (token == null) {
      _fail('No Steam token found.');
      return;
    }

    _rateRequestLimiter.markRequest(key);
    emit(const GameState.loading());

    try {
      final savedGames = await repository.fetchGamesFromSteamAccount(token);
      if (savedGames > 0) {
        emit(const GameState.syncSuccess());
        watchGames();
        return;
      }
      _rateRequestLimiter.clear(key);
      _fail(
        'No games with trophies found. '
        'Check that your Steam profile and game details are public.',
      );
    } catch (e) {
      _logger.e('Steam library sync failed: $e');
      _rateRequestLimiter.clear(key);
      _fail('Could not sync your Steam library. Please try again.');
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
