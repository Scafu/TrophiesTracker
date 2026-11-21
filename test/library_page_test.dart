import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/features/account/domain/entities/steam_user.dart';
import 'package:trophies_tracker/features/account/domain/repositories/account_repository.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/ui/game_page.dart';

import 'helpers/fake_account_cubit.dart';
import 'helpers/floating_bar.dart';

class _EmptyLibrary extends Fake implements GameRepository {
  @override
  Stream<List<Game>> watchLibrary() => Stream.value(const []);

  @override
  DateTime? get lastSteamSync => null;
}

class _Accounts extends Fake implements AccountRepository {}

Future<void> _open(
  WidgetTester tester,
  AccountState account, {
  bool floatingBar = false,
  bool routed = false,
}) async {
  final games = GameCubit(
    _EmptyLibrary(),
    _Accounts(),
    Logger(level: Level.off),
    RateRequestLimiter(),
  )..watchGames();
  final accounts = FakeAccountCubit(account);
  addTearDown(games.close);
  addTearDown(accounts.close);

  final providers = [
    BlocProvider<GameCubit>.value(value: games),
    BlocProvider<AccountCubit>.value(value: accounts),
  ];
  final page = MultiBlocProvider(providers: providers, child: const GamePage());
  await tester.pumpWidget(
    routed
        ? MultiBlocProvider(
            providers: providers,
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (_, _) => const Scaffold(body: GamePage()),
                  ),
                  GoRoute(
                    path: '/accounts',
                    builder: (_, _) =>
                        const Scaffold(body: Text('the settings page')),
                  ),
                ],
              ),
            ),
          )
        : floatingBar
        ? underFloatingBar(page)
        : MaterialApp(home: Scaffold(body: page)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the empty library is centered above the floating bar', (
    tester,
  ) async {
    await _open(
      tester,
      const AccountState.unauthenticated(),
      floatingBar: true,
    );

    expectCenteredInFreeSpace(
      tester,
      first: find
          .ancestor(
            of: find.byIcon(Symbols.sports_esports_rounded),
            matching: find.byType(DecoratedBox),
          )
          .first,
      last: buttonLabeled('Explore games'),
    );
  });

  testWidgets('an empty library invites to link an account or explore', (
    tester,
  ) async {
    await _open(tester, const AccountState.unauthenticated());

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Your library is empty'), findsOneWidget);
    expect(find.text('Link account'), findsOneWidget);
    expect(find.text('Link Steam account'), findsNothing);
    expect(
      find.text(
        'Link an account to import your games, or find one to add by hand.',
      ),
      findsOneWidget,
    );
    expect(find.text('Explore games'), findsOneWidget);
    expect(find.byTooltip('Sync with Steam'), findsNothing);
  });

  testWidgets('a linked account is offered a sync instead', (tester) async {
    await _open(
      tester,
      const AccountState.authenticated(SteamUser(steamId: '1')),
    );

    expect(find.text('Sync with Steam'), findsOneWidget);
    expect(find.byTooltip('Sync with Steam'), findsOneWidget);
    expect(find.text('Link account'), findsNothing);
  });

  testWidgets('Link account opens the settings', (tester) async {
    await _open(tester, const AccountState.unauthenticated(), routed: true);

    await tester.tap(find.text('Link account'));
    await tester.pumpAndSettle();

    expect(find.text('the settings page'), findsOneWidget);
    expect(find.text('Your library is empty'), findsNothing);
  });
}
