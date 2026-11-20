import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/utils/number_format.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/stats/stats_view.dart';

/// A game whose trophies are unlocked on the given dates; [locked] more are not.
Game _game(
  String name,
  List<DateTime?> unlockedOn, {
  int locked = 0,
  int id = 1,
}) {
  return Game(
    appId: id,
    name: name,
    trophies: [
      for (var i = 0; i < unlockedOn.length; i++)
        Trophy(
          apiName: '$i',
          displayName: '$name $i',
          isAchieved: true,
          achievedAt: unlockedOn[i],
        ),
      for (var i = 0; i < locked; i++)
        Trophy(apiName: 'l$i', displayName: 'locked $i'),
    ],
  );
}

void main() {
  final now = DateTime(2025, 6, 15);

  group('libraryTotals', () {
    test('sorts the games into completed, in progress and not started', () {
      final totals = libraryTotals([
        _game('Done', [now, now]),
        _game('Half', [now], locked: 1, id: 2),
        _game('Fresh', [], locked: 3, id: 3),
        const Game(appId: 4, name: 'Empty'),
      ]);

      expect(totals, (
        games: 4,
        completed: 1,
        inProgress: 1,
        notStarted: 1,
        unlocked: 3,
        total: 7,
      ));
    });

    test('an empty library is all zeros', () {
      expect(libraryTotals(const []).games, 0);
      expect(libraryTotals(const []).total, 0);
    });
  });

  group('unlocksPerMonth', () {
    test('counts the last months, oldest first, ending with this one', () {
      final games = [
        _game('A', [
          DateTime(2025, 6, 1),
          DateTime(2025, 6, 9),
          DateTime(2025, 4, 20),
        ]),
        _game('B', [DateTime(2025, 6, 30), DateTime(2024, 12, 1), null], id: 2),
      ];

      final months = unlocksPerMonth(games, now: now);

      expect(
        [for (final m in months) (m.month, m.count)],
        [(1, 0), (2, 0), (3, 0), (4, 1), (5, 0), (6, 3)],
      );
      expect(months.first.year, 2025);
    });

    test('crosses the year boundary', () {
      final months = unlocksPerMonth(
        [
          _game('A', [DateTime(2024, 12, 5)]),
        ],
        months: 3,
        now: DateTime(2025, 1, 10),
      );

      expect(
        [for (final m in months) (m.year, m.month, m.count)],
        [(2024, 11, 0), (2024, 12, 1), (2025, 1, 0)],
      );
    });
  });

  test('topGames ranks by unlocked trophies, leaving out games with none', () {
    final games = [
      _game('Few', [now], id: 1),
      _game('Many', [now, now, now], id: 2),
      _game('Alpha', [now], id: 3),
      _game('None', [], locked: 4, id: 4),
    ];

    expect([for (final g in topGames(games)) g.name], ['Many', 'Alpha', 'Few']);
    expect(topGames(games, limit: 1).single.name, 'Many');
  });

  test('recentUnlocks lists the newest first and skips undated trophies', () {
    final games = [
      _game('A', [DateTime(2025, 1, 1), null, DateTime(2025, 5, 1)]),
      _game('B', [DateTime(2025, 3, 1)], id: 2),
    ];

    final unlocks = recentUnlocks(games);

    expect([for (final u in unlocks) u.trophy.achievedAt?.month], [5, 3, 1]);
    expect(unlocks.first.game.name, 'A');
    expect(recentUnlocks(games, limit: 2), hasLength(2));
  });

  test('counts get thousands separators', () {
    expect(formatCount(0), '0');
    expect(formatCount(999), '999');
    expect(formatCount(1234), '1,234');
    expect(formatCount(1234567), '1,234,567');
    expect(formatCount(-4200), '-4,200');
  });
}
