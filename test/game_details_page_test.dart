import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/domain/repositories/activity_repository.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/details/ui/game_details_page.dart';

class _Repository extends Fake implements GameRepository {
  _Repository(this.game, {required this.inLibrary});

  final Game game;
  final bool inLibrary;

  @override
  Future<bool> isGameInLibrary(GameKey key) async => inLibrary;

  @override
  Future<Game> getGameByIdLocal(GameKey key) async => game;

  @override
  Future<Game> getGameByIdRemote(GameKey key, {String? token}) async => game;

  @override
  Future<Map<String, double>> getRarity(GameKey key) async => const {};
}

class _Activities extends Fake implements ActivityRepository {}

Future<void> _open(
  WidgetTester tester, {
  required Game game,
  required bool inLibrary,
}) async {
  final cubit = GameDetailsCubit(
    _Repository(game, inLibrary: inLibrary),
    RateRequestLimiter(),
    _Activities(),
  );
  addTearDown(cubit.close);
  await cubit.loadGameDetails(game.key);

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<GameDetailsCubit>.value(
        value: cubit,
        child: GameDetailsPage(gameKey: game.key, fromExplore: !inLibrary),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a game to add has one add button, in the card, not the header', (
    tester,
  ) async {
    await _open(
      tester,
      game: const Game(code: '1', name: 'Portal 2'),
      inLibrary: false,
    );

    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('Add to library'), findsNothing);
    expect(find.text('Add to library'), findsOneWidget);
  });

  testWidgets('a game in the library keeps the delete button in the header', (
    tester,
  ) async {
    await _open(
      tester,
      game: Game(code: '1', name: 'Portal 2', addedAt: DateTime(2025, 1, 1)),
      inLibrary: true,
    );

    expect(find.byTooltip('Delete game'), findsOneWidget);
    expect(find.text('Add to library'), findsNothing);
  });
}
