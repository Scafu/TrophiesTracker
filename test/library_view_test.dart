import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/utils/time/time_format.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/library_view.dart';

/// A game with [unlocked] of [total] trophies, the last one unlocked on [last].
Game _game(String name, int unlocked, int total, {DateTime? last, int id = 1}) {
  return Game(
    appId: id,
    name: name,
    trophies: [
      for (var i = 0; i < total; i++)
        Trophy(
          apiName: '$i',
          displayName: '$i',
          isAchieved: i < unlocked,
          achievedAt: i == unlocked - 1 ? last : null,
        ),
    ],
  );
}

List<String> _names(List<Game> games) => [for (final g in games) g.name];

void main() {
  final hades = _game('Hades', 10, 10, last: DateTime(2025, 3, 1), id: 1);
  final portal = _game('Portal', 9, 10, last: DateTime(2025, 5, 1), id: 2);
  final celeste = _game('Celeste', 2, 10, last: DateTime(2025, 4, 1), id: 3);
  final fresh = _game('Abzu', 0, 10, id: 4);
  final all = [hades, portal, celeste, fresh];

  group('arrangeLibrary', () {
    test('puts the game played last on top, never-played ones at the end', () {
      expect(_names(arrangeLibrary(all)), [
        'Portal',
        'Celeste',
        'Hades',
        'Abzu',
      ]);
    });

    test('filters by progress', () {
      List<String> by(LibraryFilter f) =>
          _names(arrangeLibrary(all, filter: f, sort: LibrarySort.name));

      expect(by(LibraryFilter.completed), ['Hades']);
      expect(by(LibraryFilter.inProgress), ['Celeste', 'Portal']);
      expect(by(LibraryFilter.notStarted), ['Abzu']);
      expect(by(LibraryFilter.all), hasLength(4));
    });

    test('searches names whatever the case', () {
      expect(_names(arrangeLibrary(all, query: ' ODE ')), isEmpty);
      expect(_names(arrangeLibrary(all, query: ' LE')), ['Celeste']);
    });

    test('sorts by progress, most advanced first', () {
      expect(_names(arrangeLibrary(all, sort: LibrarySort.progress)), [
        'Hades',
        'Portal',
        'Celeste',
        'Abzu',
      ]);
    });

    test('sorts by trophies left, finished games last', () {
      expect(_names(arrangeLibrary(all, sort: LibrarySort.trophiesLeft)), [
        'Portal',
        'Celeste',
        'Abzu',
        'Hades',
      ]);
    });

    test('equal games keep a fixed order: by name, then by appId', () {
      final same = [
        _game('Twin', 1, 4, id: 9),
        _game('Twin', 1, 4, id: 5),
        _game('Ant', 1, 4, id: 7),
      ];

      final ids = arrangeLibrary(
        same,
        sort: LibrarySort.progress,
      ).map((g) => g.appId);

      expect(ids, [7, 5, 9]);
    });
  });

  test(
    'almostThere lists the unfinished games at 80% or more, closest first',
    () {
      final close = _game('Close', 8, 10, id: 6);

      expect(_names(almostThere([hades, close, portal, celeste, fresh])), [
        'Portal',
        'Close',
      ]);
      expect(almostThere([hades, close, portal], limit: 1), [portal]);
    },
  );

  test('summary counts the games and every unlocked trophy', () {
    expect(librarySummary(all), (games: 4, trophies: 21));
    expect(librarySummary(const []), (games: 0, trophies: 0));
  });

  test('progress of a game with no trophies is zero', () {
    expect(gameProgress(const Game(appId: 1, name: 'x')), 0);
    expect(gameProgress(portal), 0.9);
  });

  group('formatRelative', () {
    final now = DateTime(2025, 6, 10, 12);

    test('reads naturally from seconds to weeks', () {
      expect(
        formatRelative(now.subtract(const Duration(seconds: 20)), now: now),
        'just now',
      );
      expect(
        formatRelative(now.subtract(const Duration(minutes: 5)), now: now),
        '5 min ago',
      );
      expect(
        formatRelative(now.subtract(const Duration(hours: 3)), now: now),
        '3 h ago',
      );
      expect(
        formatRelative(now.subtract(const Duration(days: 2)), now: now),
        '2 d ago',
      );
    });

    test('after a month it gives the date', () {
      expect(formatRelative(DateTime(2025, 4, 1), now: now), '1 Apr 2025');
    });
  });
}
