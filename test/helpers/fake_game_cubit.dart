import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';

/// A [GameCubit] that only holds a state, for pages that just read the
/// library from it.
class FakeGameCubit extends Cubit<GameState> implements GameCubit {
  FakeGameCubit([super.initialState = const GameState.loaded(games: [])]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
