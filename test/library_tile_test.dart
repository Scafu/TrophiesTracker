import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/widgets/console_chip.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/game/presentation/details/trophy_view.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/ui/library_widgets.dart';

Future<void> _pump(WidgetTester tester, Game game) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 120,
        height: 200,
        child: LibraryGameTile(game: game),
      ),
    ),
  ),
);

void main() {
  testWidgets('a PlayStation game shows its console on the cover', (
    tester,
  ) async {
    await _pump(
      tester,
      const Game(
        platform: GamePlatform.psn,
        code: 'NPWR1_00',
        name: 'Astro',
        consoles: ['PS4', 'PS5'],
      ),
    );

    expect(find.text('PS4/PS5'), findsOneWidget);
    expect(find.text('Astro'), findsOneWidget);
  });

  testWidgets('a Steam game has no console label', (tester) async {
    await _pump(tester, const Game(code: '620', name: 'Portal 2'));

    expect(find.byType(ConsoleChip), findsNothing);
  });

  test('rarityOf takes the rarity the trophies carry, and the lookup wins', () {
    const trophies = [
      Trophy(apiName: 'a', displayName: 'A', rarity: 4.5),
      Trophy(apiName: 'b', displayName: 'B', rarity: 20),
      Trophy(apiName: 'c', displayName: 'C'),
    ];

    expect(rarityOf(trophies, const {}), {'a': 4.5, 'b': 20.0});
    expect(rarityOf(trophies, const {'b': 7.0, 'c': 1.0}), {
      'a': 4.5,
      'b': 7.0,
      'c': 1.0,
    });
  });

  test('the console label joins the consoles in Sony\'s order', () {
    expect(ConsoleChip.labelFor(const ['PS5']), 'PS5');
    expect(ConsoleChip.labelFor(const ['PS4', 'PS5']), 'PS4/PS5');
  });
}
