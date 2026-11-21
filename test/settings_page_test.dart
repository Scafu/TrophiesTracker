import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trophies_tracker/features/account/domain/entities/steam_user.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/account/presentation/ui/account_page.dart';
import 'package:trophies_tracker/features/account/presentation/ui/steam_connection_tile.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';
import 'package:trophies_tracker/features/psn/domain/psn_repository.dart';
import 'package:trophies_tracker/features/psn/presentation/cubit/psn_cubit.dart';
import 'package:trophies_tracker/features/psn/presentation/cubit/psn_state.dart';
import 'package:trophies_tracker/features/psn/presentation/psn_connection_tile.dart';
import 'package:trophies_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:trophies_tracker/features/settings/presentation/cubit/settings_cubit.dart';

import 'helpers/fake_account_cubit.dart';
import 'helpers/fake_game_cubit.dart';

class _Account extends FakeAccountCubit {
  _Account(super.state);

  var logins = 0;
  var logouts = 0;

  @override
  Future<void> login() async => logins++;

  @override
  Future<void> logout() async => logouts++;
}

class _Games extends FakeGameCubit {
  _Games([super.state = const GameState.loaded(games: [])]);

  DateTime? last;
  var syncs = 0;

  @override
  DateTime? get lastSync => last;

  @override
  Future<void> fetchGamesFromSteamAccount() async => syncs++;
}

class _Settings extends Fake implements SettingsRepository {
  @override
  ThemeMode getThemeMode() => ThemeMode.system;

  @override
  Locale getLocale() => const Locale('en');
}

class _NoPsnRepository extends Fake implements PsnRepository {}

class _Psn extends PsnCubit {
  _Psn(PsnState state)
    : super(_NoPsnRepository(), (_, _, {fresh = false}) async => '') {
    emit(state);
  }
}

const _alice = SteamUser(steamId: '7656', personaName: 'Alice');

Widget _providers(Widget app, _Account account, _Games games, PsnState psn) {
  final settings = SettingsCubit(_Settings());
  addTearDown(settings.close);
  return MultiBlocProvider(
    providers: [
      BlocProvider<AccountCubit>.value(value: account),
      BlocProvider<GameCubit>.value(value: games),
      BlocProvider<SettingsCubit>.value(value: settings),
      BlocProvider<PsnCubit>.value(value: _Psn(psn)),
    ],
    child: app,
  );
}

Future<(_Account, _Games)> _pumpSteam(
  WidgetTester tester,
  AccountState state, {
  GameState games = const GameState.loaded(games: []),
  DateTime? last,
}) async {
  final account = _Account(state);
  final cubit = _Games(games)..last = last;
  addTearDown(account.close);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    _providers(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SteamConnectionTile(),
          ),
        ),
      ),
      account,
      cubit,
      const PsnState(),
    ),
  );
  return (account, cubit);
}

Future<(_Account, _Games)> _pumpPage(
  WidgetTester tester, {
  AccountState state = const AccountState.unauthenticated(),
  PsnState psn = const PsnState(loaded: true),
}) async {
  PackageInfo.setMockInitialValues(
    appName: 'Trophies Tracker',
    packageName: 'test.trophies',
    version: '2.3.4',
    buildNumber: '56',
    buildSignature: '',
  );
  tester.view
    ..physicalSize = const Size(1000, 3200)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final account = _Account(state);
  final games = _Games();
  addTearDown(account.close);
  addTearDown(games.close);
  final router = GoRouter(
    initialLocation: '/accounts',
    routes: [
      GoRoute(path: '/accounts', builder: (_, _) => const AccountPage()),
    ],
  );
  await tester.pumpWidget(
    _providers(MaterialApp.router(routerConfig: router), account, games, psn),
  );
  await tester.pump();
  return (account, games);
}

IconButton _syncButton(WidgetTester tester) => tester.widget<IconButton>(
  find.ancestor(
    of: find.byTooltip('Sync library'),
    matching: find.byType(IconButton),
  ),
);

void main() {
  group('the Steam row', () {
    testWidgets('not linked is one line and a Link button', (tester) async {
      final (account, _) = await _pumpSteam(
        tester,
        const AccountState.unauthenticated(),
      );

      expect(find.text('Steam'), findsOneWidget);
      expect(find.text('Not linked'), findsOneWidget);
      expect(find.byTooltip('Sync library'), findsNothing);
      expect(
        tester.getSize(find.byType(SteamConnectionTile)).height,
        lessThan(80),
      );

      await tester.tap(find.text('Link'));
      expect(account.logins, 1);
    });

    testWidgets('linked shows the name and the last sync', (tester) async {
      await _pumpSteam(
        tester,
        const AccountState.authenticated(_alice),
        last: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(find.text('Alice · Synced 2 h ago'), findsOneWidget);
      expect(find.text('Link'), findsNothing);
    });

    testWidgets('linked before any sync shows just the name', (tester) async {
      await _pumpSteam(tester, const AccountState.authenticated(_alice));

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('an account with no name is a Steam user', (tester) async {
      await _pumpSteam(
        tester,
        const AccountState.authenticated(SteamUser(steamId: '1')),
      );

      expect(find.text('Steam user'), findsOneWidget);
    });

    testWidgets('sync and unlink call the account', (tester) async {
      final (account, games) = await _pumpSteam(
        tester,
        const AccountState.authenticated(_alice),
      );

      await tester.tap(find.byTooltip('Sync library'));
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlink'));
      await tester.pumpAndSettle();

      expect((games.syncs, account.logouts), (1, 1));
    });

    testWidgets('while syncing it shows a bar and locks the buttons', (
      tester,
    ) async {
      await _pumpSteam(
        tester,
        const AccountState.authenticated(_alice),
        games: const GameState.loading(),
      );

      expect(find.text('Syncing your library…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(_syncButton(tester).onPressed, isNull);
      expect(
        tester
            .widget<PopupMenuButton<void>>(find.byType(PopupMenuButton<void>))
            .enabled,
        isFalse,
      );
    });

    testWidgets('while the account is being checked it says so', (
      tester,
    ) async {
      await _pumpSteam(tester, const AccountState.loading());

      expect(find.text('Checking your account…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('an error leaves the way to link', (tester) async {
      await _pumpSteam(tester, const AccountState.error('boom'));

      expect(find.text('Link'), findsOneWidget);
    });
  });

  group('the page', () {
    testWidgets('is called Settings and has its groups in order', (
      tester,
    ) async {
      await _pumpPage(tester);

      expect(find.text('Settings'), findsOneWidget);
      final labels = ['CONNECTIONS', 'APPEARANCE', 'ABOUT'];
      final tops = [
        for (final label in labels) tester.getTopLeft(find.text(label)).dy,
      ];
      expect(tops, [...tops]..sort());
    });

    testWidgets('lists both connections as rows, not as cards', (tester) async {
      await _pumpPage(
        tester,
        state: const AccountState.authenticated(_alice),
        psn: PsnState(
          loaded: true,
          link: PsnLink(
            onlineId: 'Player',
            refreshExpiresAt: DateTime.now().add(const Duration(days: 9)),
            lastSync: DateTime.now(),
          ),
        ),
      );

      expect(find.byType(SteamConnectionTile), findsOneWidget);
      expect(find.byType(PsnConnectionTile), findsOneWidget);
      final block =
          tester.getBottomLeft(find.byType(PsnConnectionTile)).dy -
          tester.getTopLeft(find.byType(SteamConnectionTile)).dy;
      expect(block, lessThan(240), reason: 'the old cards took about 640');
    });

    testWidgets('keeps the theme and the information rows', (tester) async {
      await _pumpPage(tester);

      for (final title in [
        'App Theme',
        'Version',
        'Licenses',
        'Legal disclaimer',
        'Privacy Policy',
        'Credits',
      ]) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
    });

    testWidgets('shows the version and the build number of the app', (
      tester,
    ) async {
      await _pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('2.3.4 (56)'), findsOneWidget);
      expect(
        find.text('1.0.1'),
        findsNothing,
        reason: 'no number written by hand',
      );
    });

    testWidgets('has no Development section, not even in a debug build', (
      tester,
    ) async {
      await _pumpPage(tester);

      expect(find.text('DEVELOPMENT'), findsNothing);
      expect(find.text('PlayStation link test'), findsNothing);
    });

    testWidgets('the theme row still opens the choice', (tester) async {
      await _pumpPage(tester);

      await tester.tap(find.text('App Theme'));
      await tester.pumpAndSettle();

      expect(find.text('Select Theme'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('linking Steam from the row calls the account', (tester) async {
      final (account, _) = await _pumpPage(tester);

      expect(
        find.text('Link'),
        findsNWidgets(2),
        reason: 'Steam and PlayStation',
      );
      await tester.tap(find.text('Link').first);

      expect(account.logins, 1);
    });
  });
}
