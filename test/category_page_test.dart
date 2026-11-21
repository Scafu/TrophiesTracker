import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/categories.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/category_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/category_page.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';

import 'helpers/fake_game_cubit.dart';

class _Repository extends Fake implements GameRepository {
  List<Game> games = const [];
  bool failing = false;
  int loads = 0;

  @override
  Future<List<Game>> getCategoryGames(int tagId) async {
    loads++;
    if (failing) throw Exception('down');
    return games;
  }

  @override
  Future<List<Game>> withCovers(List<Game> games) async => games;
}

const _portal = Game(code: '620', name: 'Portal 2');
const _terraria = Game(code: '105600', name: 'Terraria');

/// The page at `/category/122` over stub routes for what it navigates to.
Future<_Repository> _open(
  WidgetTester tester, {
  List<Game> games = const [_portal, _terraria],
  bool failing = false,
  List<Game> library = const [],
}) async {
  final repository = _Repository()
    ..games = games
    ..failing = failing;
  final cubit = CategoryCubit(repository);
  final libraryCubit = FakeGameCubit(GameState.loaded(games: library));
  addTearDown(cubit.close);
  addTearDown(libraryCubit.close);
  cubit.load(122);

  final router = GoRouter(
    initialLocation: '/category/122',
    routes: [
      GoRoute(
        path: '/category/:tagId',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<CategoryCubit>.value(value: cubit),
            BlocProvider<GameCubit>.value(value: libraryCubit),
          ],
          child: CategoryPage(category: categoryById(122)!),
        ),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const Text('explore page'),
      ),
      GoRoute(
        name: 'gameDetails',
        path: '/gamesDetails/:platform/:code/:fromExplorer',
        builder: (context, state) => Text(
          'details ${state.pathParameters['code']} '
          'explorer=${state.pathParameters['fromExplorer']}',
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('shows the genre and its games', (tester) async {
    await _open(tester);

    expect(find.text('RPG'), findsOneWidget);
    expect(find.text('Portal 2'), findsOneWidget);
    expect(find.text('Terraria'), findsOneWidget);
  });

  testWidgets('a game already in the library is marked as such', (
    tester,
  ) async {
    await _open(tester, library: const [_terraria]);

    expect(find.text('In library'), findsOneWidget);
  });

  testWidgets('a game opens as something to add, unless it is owned', (
    tester,
  ) async {
    await _open(tester, library: const [_terraria]);

    await tester.tap(find.text('Portal 2'));
    await tester.pumpAndSettle();
    expect(find.text('details 620 explorer=true'), findsOneWidget);
  });

  testWidgets('an owned game opens as part of the library', (tester) async {
    await _open(tester, library: const [_terraria]);

    await tester.tap(find.text('Terraria'));
    await tester.pumpAndSettle();
    expect(find.text('details 105600 explorer=false'), findsOneWidget);
  });

  testWidgets('with nothing to show it says so', (tester) async {
    await _open(tester, games: const []);

    expect(find.text('No games found'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('a failure offers to try again, and trying again recovers', (
    tester,
  ) async {
    final repository = await _open(tester, failing: true);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(repository.loads, 1);

    repository.failing = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(repository.loads, 2);
    expect(find.text('Portal 2'), findsOneWidget);
    expect(find.text('Something went wrong'), findsNothing);
  });

  testWidgets('back leaves to Explore when there is nothing to go back to', (
    tester,
  ) async {
    await _open(tester);

    await tester.tap(find.byIcon(Symbols.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('explore page'), findsOneWidget);
  });
}
