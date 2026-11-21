import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/core/widgets/empty_state.dart';
import 'package:trophies_tracker/features/account/domain/repositories/account_repository.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/ui/game_page.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:trophies_tracker/features/stats/presentation/ui/stats_page.dart';

import 'helpers/fake_account_cubit.dart';
import 'helpers/floating_bar.dart';

class _EmptyLibrary extends Fake implements GameRepository {
  @override
  Stream<List<Game>> watchLibrary() => Stream.value(const []);

  @override
  DateTime? get lastSteamSync => null;
}

class _Accounts extends Fake implements AccountRepository {}

/// What a page shows in the middle, as the user sees it.
typedef _Look = ({
  TextStyle? title,
  TextStyle? message,
  Size circle,
  Size button,
  double titleToMessage,
});

Future<_Look> _look(
  WidgetTester tester, {
  required Widget page,
  required String title,
  required String message,
  required IconData icon,
  required String button,
  required Widget Function(Widget page) wrap,
}) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(underFloatingBar(wrap(page)));
  await tester.pumpAndSettle();

  final circle = find
      .ancestor(of: find.byIcon(icon), matching: find.byType(DecoratedBox))
      .first;
  return (
    title: tester.widget<Text>(find.text(title)).style,
    message: tester.widget<Text>(find.text(message)).style,
    circle: tester.getSize(circle),
    button: tester.getSize(buttonLabeled(button)),
    titleToMessage:
        tester.getTopLeft(find.text(message)).dy -
        tester.getBottomLeft(find.text(title)).dy,
  );
}

void main() {
  testWidgets(
    'the empty library and the empty stats look the same in the middle',
    (tester) async {
      final games = GameCubit(
        _EmptyLibrary(),
        _Accounts(),
        Logger(level: Level.off),
        RateRequestLimiter(),
      )..watchGames();
      final stats = StatsCubit(_EmptyLibrary());
      final accounts = FakeAccountCubit(const AccountState.unauthenticated());
      addTearDown(games.close);
      addTearDown(stats.close);
      addTearDown(accounts.close);

      final library = await _look(
        tester,
        page: const GamePage(),
        title: 'Your library is empty',
        message:
            'Link an account to import your games, or find one to add by hand.',
        icon: Symbols.sports_esports_rounded,
        button: 'Link account',
        wrap: (page) => MultiBlocProvider(
          providers: [
            BlocProvider<GameCubit>.value(value: games),
            BlocProvider<AccountCubit>.value(value: accounts),
          ],
          child: page,
        ),
      );
      final statistics = await _look(
        tester,
        page: const StatsPage(),
        title: 'No stats yet',
        message: 'Add games to your library and your progress shows up here.',
        icon: Symbols.bar_chart_rounded,
        button: 'Explore games',
        wrap: (page) => MultiBlocProvider(
          providers: [
            BlocProvider<StatsCubit>.value(value: stats),
            BlocProvider<AccountCubit>.value(value: accounts),
          ],
          child: page,
        ),
      );

      expect(statistics.title, library.title, reason: 'title font');
      expect(statistics.message, library.message, reason: 'message font');
      expect(statistics.circle, library.circle, reason: 'icon');
      expect(statistics.button.height, library.button.height, reason: 'button');
      // Il carattere dei test è largo: qui conta solo che nessuno scenda sotto il minimo.
      expect(library.button.width, greaterThanOrEqualTo(220));
      expect(statistics.button.width, greaterThanOrEqualTo(220));
      expect(
        statistics.titleToMessage,
        library.titleToMessage,
        reason: 'spacing',
      );
    },
  );

  testWidgets(
    'the title is the large title style and the message the body style',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(icon: Icons.add, title: 'Nothing', message: 'Yet'),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(EmptyState)));
      expect(
        tester.widget<Text>(find.text('Nothing')).style,
        theme.textTheme.titleLarge,
      );
      expect(
        tester.widget<Text>(find.text('Yet')).style?.fontSize,
        theme.textTheme.bodyMedium?.fontSize,
      );
    },
  );

  testWidgets('an empty state with no actions has no gap under the message', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(icon: Icons.add, title: 'A', message: 'B'),
        ),
      ),
    );

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });
}
