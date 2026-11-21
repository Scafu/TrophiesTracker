import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:trophies_tracker/features/stats/presentation/ui/stats_page.dart';
import 'package:trophies_tracker/features/stats/presentation/ui/stats_widgets.dart';
import 'package:trophies_tracker/features/stats/stats_view.dart';

import 'helpers/fake_account_cubit.dart';
import 'helpers/floating_bar.dart';

class _EmptyLibrary extends Fake implements GameRepository {
  @override
  Stream<List<Game>> watchLibrary() => Stream.value(const []);
}

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets(
    'the hero shows the unlocked trophies, the share and what is left',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const StatsHero(
            totals: (
              games: 18,
              completed: 3,
              inProgress: 9,
              notStarted: 6,
              unlocked: 400,
              total: 1250,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('400'), findsOneWidget);
      expect(find.text('/ 1,250'), findsOneWidget);
      expect(find.textContaining('across 18 games'), findsOneWidget);
      expect(find.text('32%'), findsOneWidget);
      expect(find.text('850 to go'), findsOneWidget);
    },
  );

  testWidgets('the hero copes with a library with no trophies', (tester) async {
    await tester.pumpWidget(
      _host(
        const StatsHero(
          totals: (
            games: 1,
            completed: 0,
            inProgress: 0,
            notStarted: 0,
            unlocked: 0,
            total: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0%'), findsOneWidget);
    expect(find.text('0 to go'), findsOneWidget);
    expect(find.textContaining('across 1 game'), findsOneWidget);
  });

  testWidgets('the breakdown counts the three groups of games', (tester) async {
    await tester.pumpWidget(
      _host(
        const LibraryBreakdown(
          totals: (
            games: 18,
            completed: 3,
            inProgress: 9,
            notStarted: 6,
            unlocked: 400,
            total: 1250,
          ),
        ),
      ),
    );

    for (final label in ['Completed', 'In progress', 'Not started']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('3'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('the breakdown draws an empty bar when there is nothing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const LibraryBreakdown(
          totals: (
            games: 0,
            completed: 0,
            inProgress: 0,
            notStarted: 0,
            unlocked: 0,
            total: 0,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('0'), findsNWidgets(3));
  });

  group('the activity heatmap', () {
    final days = unlocksPerDay(
      [
        Game(
          code: '1',
          name: 'A',
          trophies: [
            Trophy(
              apiName: 'a',
              displayName: 'a',
              isAchieved: true,
              achievedAt: DateTime(2025, 6, 17),
            ),
            Trophy(
              apiName: 'b',
              displayName: 'b',
              isAchieved: true,
              achievedAt: DateTime(2025, 6, 18),
            ),
          ],
        ),
      ],
      weeks: 20,
      now: DateTime(2025, 6, 18),
    );

    testWidgets('sums up the unlocks and the active days', (tester) async {
      await tester.pumpWidget(_host(ActivityHeatmap(days: days)));

      expect(find.text('2 unlocks · 2 active days'), findsOneWidget);
      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('labels the months along the weeks', (tester) async {
      await tester.pumpWidget(_host(ActivityHeatmap(days: days)));

      for (final month in ['Feb', 'Mar', 'Apr', 'May', 'Jun']) {
        expect(find.text(month), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a narrow phone without overflowing', (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ActivityHeatmap(days: days),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(ActivityHeatmap)).width, 280);
    });

    test('drops a first label that has no room before the next month', () {
      final starts = ActivityHeatmap.monthStarts(
        unlocksPerDay(const [], weeks: 20, now: DateTime(2025, 6, 18)),
      );

      expect(starts.first, greaterThanOrEqualTo(0));
      for (var i = 1; i < starts.length; i++) {
        expect(starts[i] - starts[i - 1], greaterThanOrEqualTo(3));
      }
    });
  });

  testWidgets('with no games the page says there is nothing to count yet', (
    tester,
  ) async {
    final stats = StatsCubit(_EmptyLibrary());
    final accounts = FakeAccountCubit();
    addTearDown(stats.close);
    addTearDown(accounts.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<StatsCubit>.value(value: stats),
              BlocProvider<AccountCubit>.value(value: accounts),
            ],
            child: const StatsPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('No stats yet'), findsOneWidget);
    expect(find.text('Explore games'), findsOneWidget);
  });

  testWidgets('the empty stats are centered above the floating bar', (
    tester,
  ) async {
    final stats = StatsCubit(_EmptyLibrary());
    final accounts = FakeAccountCubit();
    addTearDown(stats.close);
    addTearDown(accounts.close);

    await tester.pumpWidget(
      underFloatingBar(
        MultiBlocProvider(
          providers: [
            BlocProvider<StatsCubit>.value(value: stats),
            BlocProvider<AccountCubit>.value(value: accounts),
          ],
          child: const StatsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expectCenteredInFreeSpace(
      tester,
      first: find
          .ancestor(
            of: find.byIcon(Symbols.bar_chart_rounded),
            matching: find.byType(DecoratedBox),
          )
          .first,
      last: buttonLabeled('Explore games'),
    );
  });
}
