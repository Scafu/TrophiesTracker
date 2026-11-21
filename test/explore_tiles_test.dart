import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/explore_page_tiles.dart';

void main() {
  test('the typed part is found whatever its case', () {
    final parts = splitAtMatch('Hollow Knight: Silksong', 'knight');

    expect(parts, (before: 'Hollow ', match: 'Knight', after: ': Silksong'));
  });

  test('without a match the whole name stays as it is', () {
    expect(splitAtMatch('Portal 2', 'hades'), (
      before: 'Portal 2',
      match: '',
      after: '',
    ));
    expect(splitAtMatch('Portal 2', ''), (
      before: 'Portal 2',
      match: '',
      after: '',
    ));
  });

  test('accented capitals do not throw the match off', () {
    final parts = splitAtMatch('İstanbul', 'stan');

    expect(parts, (before: 'İ', match: 'stan', after: 'bul'));
  });

  for (final owned in [false, true]) {
    testWidgets(
      'a result fits a narrow phone with large text (in library: $owned)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.6)),
              child: child!,
            ),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: ExploreGameTile(
                  game: const Game(code: '10', name: 'Balatro'),
                  query: '',
                  inLibrary: owned,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );
  }
}
