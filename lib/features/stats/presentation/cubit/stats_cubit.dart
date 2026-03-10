import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:trophies_tracker/core/domain/entities/game_activity.dart';
import 'package:trophies_tracker/core/domain/repositories/activity_repository.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final GameRepository _gameRepo;
  final ActivityRepository _activityRepo;

  StreamSubscription? _streamSub;

  StatsCubit(this._gameRepo, this._activityRepo) : super(const StatsLoading()) {
    _initStreams();
  }

  void _initStreams() {
    _streamSub =
        Rx.combineLatest2<List<Game>, List<GameActivity>, StatsLoaded>(
          _gameRepo.watchLibrary(),
          _activityRepo.watchActivities(),
          (games, activities) {
            return StatsLoaded(games: games, activities: activities);
          },
        ).listen(
          (statsLoadedState) {
            emit(statsLoadedState);
          },
          onError: (Object error) {
            emit(StatsError(error.toString()));
          },
        );
  }

  @override
  Future<void> close() {
    _streamSub?.cancel();
    return super.close();
  }
}
