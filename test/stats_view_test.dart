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
    code: '$id',
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
        const Game(code: '4', name: 'Empty'),
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

  group('unlocksPerDay', () {
    final today = DateTime(2025, 6, 18);

    test('starts on a Monday and ends today', () {
      final days = unlocksPerDay(const [], weeks: 3, now: today);

      expect(days.first.day, DateTime(2025, 6, 2));
      expect(days.first.day.weekday, DateTime.monday);
      expect(days.last.day, today);
      expect(days, hasLength(2 * 7 + today.weekday));
    });

    test('counts the unlocks of each day and skips the undated ones', () {
      final days = unlocksPerDay(
        [
          _game('A', [
            DateTime(2025, 6, 18, 9),
            DateTime(2025, 6, 18, 23, 59),
            DateTime(2025, 6, 2),
            null,
          ]),
          _game('B', [DateTime(2025, 6, 18)], id: 2),
        ],
        weeks: 3,
        now: today,
      );

      int on(int day) =>
          days.firstWhere((d) => d.day == DateTime(2025, 6, day)).count;
      expect(on(18), 3);
      expect(on(2), 1);
      expect(on(3), 0);
      expect(days.fold(0, (sum, d) => sum + d.count), 4);
    });

    test('leaves out what is older than the window', () {
      final days = unlocksPerDay(
        [
          _game('A', [DateTime(2025, 1, 1)]),
        ],
        weeks: 3,
        now: today,
      );

      expect(days.every((d) => d.count == 0), isTrue);
    });

    test('crosses the year boundary', () {
      final days = unlocksPerDay(
        [
          _game('A', [DateTime(2024, 12, 31)]),
        ],
        weeks: 2,
        now: DateTime(2025, 1, 2),
      );

      expect(days.first.day, DateTime(2024, 12, 23));
      expect(days.firstWhere((d) => d.count == 1).day, DateTime(2024, 12, 31));
    });
  });

  test('activityLevel grows with the unlocks of the day', () {
    expect([0, 1, 2, 3, 4, 5, 20].map(activityLevel), [0, 1, 2, 3, 3, 4, 4]);
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
