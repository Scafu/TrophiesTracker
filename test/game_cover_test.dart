import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/widgets/game_cover.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';

const _base =
    'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/7';

void main() {
  test(
    'cover sources go from vertical art to landscape art, without repeats',
    () {
      final sources = GameCover.sourcesFor(
        const Game(
          appId: 7,
          name: 'G',
          libraryImage: '$_base/library_600x900_2x.jpg',
          headerImage: '$_base/abc/header.jpg?t=1',
        ),
      );

      expect(sources.map((s) => s.url), [
        '$_base/library_600x900_2x.jpg',
        '$_base/library_600x900.jpg',
        '$_base/abc/header.jpg?t=1',
        '$_base/header.jpg',
        '$_base/capsule_616x353.jpg',
      ]);
      expect(sources.map((s) => s.portrait), [true, true, false, false, false]);
    },
  );

  test('a game with no stored images still gets every Steam fallback', () {
    final sources = GameCover.sourcesFor(const Game(appId: 7, name: 'G'));

    expect(sources.map((s) => s.url), [
      '$_base/library_600x900.jpg',
      '$_base/header.jpg',
      '$_base/capsule_616x353.jpg',
    ]);
  });

  test('a stored header equal to a fallback is not tried twice', () {
    final sources = GameCover.sourcesFor(
      const Game(appId: 7, name: 'G', headerImage: '$_base/header.jpg'),
    );

    expect(sources.where((s) => s.url == '$_base/header.jpg'), hasLength(1));
  });
}
