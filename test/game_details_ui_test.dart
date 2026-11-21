import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/game/presentation/details/trophy_view.dart';
import 'package:trophies_tracker/features/game/presentation/details/ui/game_progress_card.dart';
import 'package:trophies_tracker/features/game/presentation/details/ui/trophy_controls.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('ProgressCard', () {
    testWidgets('shows the counts, what is left and the latest unlock', (
      tester,
    ) async {
      final latest = Trophy(
        apiName: 'a',
        displayName: 'Veteran',
        isAchieved: true,
        achievedAt: DateTime(2025, 3, 9),
      );

      await tester.pumpWidget(
        _host(ProgressCard(summary: (unlocked: 3, total: 5, latest: latest))),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 of 5 trophies'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('2 left to unlock'), findsOneWidget);
      expect(find.text('Latest: Veteran · 9 Mar 2025'), findsOneWidget);
    });

    testWidgets('a finished game says so instead of what is left', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(ProgressCard(summary: (unlocked: 5, total: 5, latest: null))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
      expect(find.textContaining('left to unlock'), findsNothing);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('a game with no trophies does not divide by zero', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(ProgressCard(summary: (unlocked: 0, total: 0, latest: null))),
      );
      await tester.pumpAndSettle();

      expect(find.text('No trophies to unlock'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });
  });

  testWidgets('ExplorerCard counts the trophies and offers to add the game', (
    tester,
  ) async {
    var added = 0;
    await tester.pumpWidget(
      _host(ExplorerCard(total: 137, onAdd: () => added++)),
    );

    expect(find.text('137 trophies'), findsOneWidget);
    await tester.tap(find.text('Add to library'));

    expect(added, 1);
  });

  group('ExpandableDescription', () {
    Widget sized(double width, String text) => _host(
      SizedBox(
        width: width,
        child: ExpandableDescription(text: text),
      ),
    );

    testWidgets('a short text has no toggle', (tester) async {
      await tester.pumpWidget(
        _host(const ExpandableDescription(text: 'Short.')),
      );

      expect(find.text('Show more'), findsNothing);
    });

    testWidgets('a text that fits in three lines has no toggle', (
      tester,
    ) async {
      await tester.pumpWidget(sized(800, 'word ' * 30));

      expect(find.text('Show more'), findsNothing);
    });

    testWidgets('the same text gets a toggle where it needs more lines', (
      tester,
    ) async {
      await tester.pumpWidget(sized(300, 'word ' * 30));

      expect(find.text('Show more'), findsOneWidget);
    });

    testWidgets('a long text can be expanded and collapsed again', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(ExpandableDescription(text: 'Long text. ' * 40)),
      );

      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();
      expect(find.text('Show less'), findsOneWidget);

      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();
      expect(find.text('Show more'), findsOneWidget);
    });

    testWidgets('expanding shows the whole text, not a single line', (
      tester,
    ) async {
      const text = 'Long text. ';
      await tester.pumpWidget(sized(300, text * 40));
      final collapsed = tester.getSize(find.textContaining(text)).height;

      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();
      final expanded = tester.getSize(find.textContaining(text)).height;

      expect(expanded, greaterThan(collapsed));

      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.textContaining(text)).height, collapsed);
    });

    testWidgets('a text of two lines is shown whole, with no toggle', (
      tester,
    ) async {
      await tester.pumpWidget(sized(800, 'one'));
      final oneLine = tester.getSize(find.text('one')).height;

      final twoLines = 'word ' * 20;
      await tester.pumpWidget(sized(800, twoLines));
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.textContaining('word')).height,
        greaterThan(oneLine),
      );
      expect(find.text('Show more'), findsNothing);
    });

    testWidgets('shows the characters behind the HTML entities', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const ExpandableDescription(
            text: 'The &quot;Initiative&quot; &amp; co',
          ),
        ),
      );

      expect(find.text('The "Initiative" & co'), findsOneWidget);
    });
  });

  group('TrophyControlsDelegate', () {
    late TextEditingController query;
    late List<TrophyFilter> filters;
    late List<String> queries;
    late List<TrophySort> sorts;

    setUp(() {
      query = TextEditingController();
      filters = [];
      queries = [];
      sorts = [];
    });
    tearDown(() => query.dispose());

    Future<void> pump(
      WidgetTester tester, {
      bool showFilter = true,
      bool rarityAvailable = false,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: TrophyControlsDelegate(
                    showFilter: showFilter,
                    filter: TrophyFilter.all,
                    onFilter: filters.add,
                    query: query,
                    onQuery: queries.add,
                    onClearQuery: query.clear,
                    sort: TrophySort.defaultOrder,
                    onSort: sorts.add,
                    rarityAvailable: rarityAvailable,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('choosing a segment reports the filter', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Locked'));

      expect(filters, [TrophyFilter.locked]);
    });

    testWidgets('typing reports the query', (tester) async {
      await pump(tester);

      await tester.enterText(find.byType(TextField), 'boss');

      expect(queries, ['boss']);
    });

    testWidgets('a game outside the library has no filter switch', (
      tester,
    ) async {
      await pump(tester, showFilter: false);

      expect(find.text('Unlocked'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('the sort menu lists the orders and reports the choice', (
      tester,
    ) async {
      await pump(tester, rarityAvailable: true);

      await tester.tap(find.byTooltip('Sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rarest first'));
      await tester.pumpAndSettle();

      expect(sorts, [TrophySort.rarest]);
    });

    testWidgets('rarest first is disabled until rarity is known', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.byTooltip('Sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rarest first'));
      await tester.pumpAndSettle();

      expect(sorts, isEmpty);
    });
  });
}
