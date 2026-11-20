import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:trophies_tracker/features/stats/presentation/ui/stats_page.dart';
import 'package:trophies_tracker/features/stats/presentation/ui/stats_widgets.dart';
import 'package:trophies_tracker/features/stats/stats_view.dart';

import 'helpers/fake_account_cubit.dart';

class _EmptyLibrary extends Fake implements GameRepository {
  @override
  Stream<List<Game>> watchLibrary() => Stream.value(const []);
}

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('the overview shows the unlocked trophies and the share', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const StatsOverview(
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

    expect(find.text('400 trophies'), findsOneWidget);
    expect(find.textContaining('out of 1,250'), findsOneWidget);
    expect(find.textContaining('18 games'), findsOneWidget);
    expect(find.text('32%'), findsOneWidget);
  });

  testWidgets('a tile shows the number, its label and an icon', (tester) async {
    await tester.pumpWidget(
      _host(
        const StatTile(
          icon: Symbols.trophy_rounded,
          value: 1234,
          label: 'Completed',
        ),
      ),
    );

    expect(find.text('1,234'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.byIcon(Symbols.trophy_rounded), findsOneWidget);
  });

  testWidgets('the chart labels every month and counts the busy ones', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const MonthlyChart(
          months: [
            (year: 2025, month: 1, count: 0),
            (year: 2025, month: 2, count: 4),
            (year: 2025, month: 3, count: 9),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final month in ['Jan', 'Feb', 'Mar']) {
      expect(find.text(month), findsOneWidget);
    }
    expect(find.text('9'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('0'), findsNothing);
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

  test('months of the chart come from the library', () {
    expect(
      unlocksPerMonth(
        const [],
        months: 4,
        now: DateTime(2025, 2, 1),
      ).map((m) => m.month),
      [11, 12, 1, 2],
    );
  });
}
