import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/core/domain/repositories/activity_repository.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_state.dart';

class GameDetailsCubit extends Cubit<GameDetailsState> {
  final GameRepository _repository;
  final RateRequestLimiter _rateRequestLimiter;
  final ActivityRepository _activityRepository;

  GameDetailsCubit(
    this._repository,
    this._rateRequestLimiter,
    this._activityRepository,
  ) : super(const GameDetailsInitial());

  /// Load game details
  /// It first checks if the game is in local library. If not, it fetches from remote.
  Future<void> loadGameDetails(int appId, {String? token}) async {
    emit(const GameDetailsLoading());

    try {
      final bool isInLibrary = await _repository.isGameInLibrary(appId);
      final Game game;
      if (isInLibrary) {
        game = await _repository.getGameByIdLocal(appId);
      } else {
        game = await _repository.getGameByIdRemote(appId, token: token);
      }

      emit(GameDetailsLoaded(game: game));
    } catch (e) {
      emit(GameDetailsError("Error loading game details: $e"));
    }
  }

  Future<void> syncAchievements(int appId, {String? token}) async {
    final key = 'syncAchievements_$appId';

    if (!_rateRequestLimiter.isAllowed(key, const Duration(minutes: 5))) {
      emit(GameDetailsError('429'));
      return;
    }

    _rateRequestLimiter.markRequest(key);
    if (state is! GameDetailsLoaded) return;

    final currentState = state as GameDetailsLoaded;

    emit(currentState.copyWith(isSyncing: true));

    try {
      final remoteGame = await _repository.getGameByIdRemote(
        appId,
        token: token,
      );

      final List<Trophy> mergedTrophies;
      if (token == null) {
        final Map<String, Trophy> currentTrophiesMap = {
          for (var t in currentState.game.trophies) t.apiName: t,
        };

        mergedTrophies = remoteGame.trophies.map((remoteTrophy) {
          final existingTrophy = currentTrophiesMap[remoteTrophy.apiName];
          if (existingTrophy != null) {
            return remoteTrophy.copyWith(
              isAchieved: existingTrophy.isAchieved,
              achievedAt: existingTrophy.achievedAt,
            );
          }
          return remoteTrophy;
        }).toList();
      } else {
        mergedTrophies = remoteGame.trophies;
      }

      final updatedGame = remoteGame.copyWith(
        trophies: mergedTrophies,
        isSynced: currentState.game.isSynced,
        addedAt: currentState.game.addedAt,
      );

      final previousTrophies = {
        for (var t in currentState.game.trophies) t.apiName: t,
      };

      for (final trophy in updatedGame.trophies) {
        final previous = previousTrophies[trophy.apiName];
        final wasAchieved = previous?.isAchieved ?? false;

        if (!wasAchieved && trophy.isAchieved) {
          await _activityRepository.addActivity(appId, trophy.displayName);
        } else if (wasAchieved && !trophy.isAchieved) {
          await _activityRepository.removeActivity(appId, trophy.displayName);
        }
      }

      await _repository.saveGame(updatedGame);

      emit(GameDetailsSyncSuccess(updatedGame));

      emit(GameDetailsLoaded(game: updatedGame, isSyncing: false));
    } catch (e) {
      emit(GameDetailsError("Sync error: $e"));
      emit(currentState.copyWith(isSyncing: false));
    }
  }

  Future<void> deleteGame(int appId) async {
    try {
      await _repository.deleteGame(appId);

      emit(const GameDetailsDeleted());
    } catch (e) {
      emit(GameDetailsError("Error deleting game: $e"));
    }
  }

  Future<void> saveGameToLibrary(Game game) async {
    try {
      final gameToSave = game.copyWith(addedAt: DateTime.now());
      await _repository.saveGame(gameToSave);
      emit(GameDetailsLoaded(game: gameToSave, isSyncing: false));
    } catch (e) {
      emit(GameDetailsError("Error saving game to library: $e"));
    }
  }

  Future<void> toggleTrophy(
    int appId,
    String trophyName,
    bool isCurrentlyAchieved,
  ) async {
    final currentState = state;
    if (currentState is! GameDetailsLoaded) return;

    final newStatus = !isCurrentlyAchieved;

    final updatedTrophies = currentState.game.trophies.map((trophy) {
      if (trophy.apiName == trophyName) {
        return trophy.copyWith(
          isAchieved: newStatus,
          achievedAt: newStatus ? DateTime.now() : null,
        );
      }
      return trophy;
    }).toList();

    final updatedGame = currentState.game.copyWith(trophies: updatedTrophies);

    emit(
      GameDetailsLoaded(game: updatedGame, isSyncing: currentState.isSyncing),
    );

    try {
      await _repository.updateStateTrophy(appId, trophyName, newStatus);
    } catch (e) {
      emit(GameDetailsError("Error toggling trophy: $e"));
      final originalGame = await _repository.getGameByIdLocal(appId);
      emit(
        GameDetailsLoaded(
          game: originalGame,
          isSyncing: currentState.isSyncing,
        ),
      );
    }
  }
}
