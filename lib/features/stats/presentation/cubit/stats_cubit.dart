import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_state.dart';

/// Follows the library so the stats are always computed from the saved games
/// and their trophies.
class StatsCubit extends Cubit<StatsState> {
  final GameRepository _gameRepo;

  StreamSubscription? _streamSub;

  StatsCubit(this._gameRepo) : super(const StatsLoading()) {
    _streamSub = _gameRepo.watchLibrary().listen(
      (games) => emit(StatsLoaded(games: games)),
      onError: (Object error) => emit(StatsError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _streamSub?.cancel();
    return super.close();
  }
}
