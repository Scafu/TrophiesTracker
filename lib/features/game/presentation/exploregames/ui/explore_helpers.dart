import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_tracker/core/router/game_route.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';

/// The keys of the games already in the library. Rebuilds when it changes.
Set<GameKey> libraryKeys(BuildContext context) =>
    context.watch<GameCubit>().state.maybeWhen(
      loaded: (library) => {for (final game in library) game.key},
      orElse: () => <GameKey>{},
    );

/// Opens the details of [game]; one that is not in the library [owned] is
/// opened as something to add.
void openGame(BuildContext context, Game game, {required bool owned}) =>
    context.pushNamed(
      'gameDetails',
      pathParameters: gameRouteParams(game.key, fromExplorer: !owned),
    );
