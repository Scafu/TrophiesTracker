import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/categories.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/category_tile.dart';

void main() {
  Widget host(GameCategory category, VoidCallback onTap) => MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 170,
        height: 92,
        child: CategoryTile(category: category, onTap: onTap),
      ),
    ),
  );

  testWidgets('shows the name of the genre and opens on tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(categoryById(29482)!, () => taps++));

    expect(find.text('Souls-like'), findsOneWidget);
    await tester.tap(find.byType(CategoryTile));
    expect(taps, 1);
  });

  testWidgets('every genre fits its tile, even the longest name', (
    tester,
  ) async {
    for (final category in gameCategories) {
      await tester.pumpWidget(host(category, () {}));
      expect(tester.takeException(), isNull, reason: category.name);
    }
  });

  test('white text reads on every tile color', () {
    for (final category in gameCategories) {
      final contrast = 1.05 / (category.color.computeLuminance() + 0.05);
      expect(contrast, greaterThanOrEqualTo(4.5), reason: category.name);
    }
  });
}
