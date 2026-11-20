import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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

class _EmptyLibrary extends Fake implements GameRepository {
  @override
  Stream<List<Game>> watchLibrary() => Stream.value(const []);

  @override
  DateTime? get lastSteamSync => null;
}

class _Accounts extends Fake implements AccountRepository {}

Future<void> _open(WidgetTester tester, AccountState account) async {
  final games = GameCubit(
    _EmptyLibrary(),
    _Accounts(),
    Logger(level: Level.off),
    RateRequestLimiter(),
  )..watchGames();
  final accounts = FakeAccountCubit(account);
  addTearDown(games.close);
  addTearDown(accounts.close);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<GameCubit>.value(value: games),
            BlocProvider<AccountCubit>.value(value: accounts),
          ],
          child: const GamePage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an empty library invites to link an account or explore', (
    tester,
  ) async {
    await _open(tester, const AccountState.unauthenticated());

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Your library is empty'), findsOneWidget);
    expect(find.text('Link Steam account'), findsOneWidget);
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
    expect(find.text('Link Steam account'), findsNothing);
  });
}
