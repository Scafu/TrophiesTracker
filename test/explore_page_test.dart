import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/explore_page.dart';

import 'helpers/fake_account_cubit.dart';

class _EmptyCatalog extends Fake implements GameRepository {
  final searched = <String>[];

  @override
  Future<List<Game>> searchLocalCatalog(String query) async {
    searched.add(query);
    return const [];
  }
}

Future<_EmptyCatalog> _open(WidgetTester tester) async {
  final repository = _EmptyCatalog();
  final cubit = ExploreCubit(repository);
  final accounts = FakeAccountCubit();
  addTearDown(cubit.close);
  addTearDown(accounts.close);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<ExploreCubit>.value(value: cubit),
            BlocProvider<AccountCubit>.value(value: accounts),
          ],
          child: const ExplorePage(),
        ),
      ),
    ),
  );
  return repository;
}

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  testWidgets('before any search it shows a tile for each category', (
    tester,
  ) async {
    await _open(tester);

    expect(find.text('BROWSE BY CATEGORY'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
    expect(find.text('RPG'), findsOneWidget);
    expect(find.byIcon(Symbols.cancel_rounded), findsNothing);
  });

  testWidgets('tapping a category opens it', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<ExploreCubit>.value(
                value: ExploreCubit(_EmptyCatalog()),
              ),
              BlocProvider<AccountCubit>.value(value: FakeAccountCubit()),
            ],
            child: const Scaffold(body: ExplorePage()),
          ),
        ),
        GoRoute(
          name: 'category',
          path: '/category/:tagId',
          builder: (context, state) =>
              Text('category ${state.pathParameters['tagId']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('RPG'));
    await tester.pumpAndSettle();

    expect(find.text('category 122'), findsOneWidget);
  });

  testWidgets('typing searches once, after a short pause', (tester) async {
    final repository = await _open(tester);

    await tester.enterText(find.byType(TextField), 'p');
    await tester.enterText(find.byType(TextField), 'po');
    await tester.enterText(find.byType(TextField), 'por');
    expect(repository.searched, isEmpty);
    await tester.pump(const Duration(milliseconds: 400));

    expect(repository.searched, ['por']);
    await tester.pumpAndSettle();
  });

  testWidgets('a search with no matches says so and names the query', (
    tester,
  ) async {
    await _open(tester);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('No games found'), findsOneWidget);
    expect(find.textContaining('"zzzz"'), findsOneWidget);
  });

  testWidgets('the clear button empties the field and returns to the start', (
    tester,
  ) async {
    await _open(tester);
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Symbols.cancel_rounded));
    await tester.pumpAndSettle();

    expect(_fieldText(tester), isEmpty);
    expect(find.text('BROWSE BY CATEGORY'), findsOneWidget);
  });
}
