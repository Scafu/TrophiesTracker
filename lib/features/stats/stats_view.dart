import 'package:trophies_tracker/core/utils/game/game_completion.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';

int _unlocked(Game game) => game.trophies.where((t) => t.isAchieved).length;

typedef LibraryTotals = ({
  int games,
  int completed,
  int inProgress,
  int notStarted,
  int unlocked,
  int total,
});

/// The library in numbers: how many games are completed, in progress or not
/// started, and how many trophies are unlocked out of all of them. A game
/// with no trophies counts only in [games].
LibraryTotals libraryTotals(List<Game> games) {
  var completed = 0, inProgress = 0, notStarted = 0, unlocked = 0, total = 0;
  for (final game in games) {
    final done = _unlocked(game);
    unlocked += done;
    total += game.trophies.length;
    if (game.isCompleted) {
      completed++;
    } else if (done > 0) {
      inProgress++;
    } else if (game.trophies.isNotEmpty) {
      notStarted++;
    }
  }
  return (
    games: games.length,
    completed: completed,
    inProgress: inProgress,
    notStarted: notStarted,
    unlocked: unlocked,
    total: total,
  );
}

typedef MonthCount = ({int year, int month, int count});

/// Trophies unlocked in each of the last [months] months, oldest first, the
/// last entry being the month of [now]. Trophies with no date are not counted.
List<MonthCount> unlocksPerMonth(
  List<Game> games, {
  int months = 6,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final counts = <(int, int), int>{};
  for (final game in games) {
    for (final trophy in game.trophies) {
      final date = trophy.achievedAt;
      if (trophy.isAchieved && date != null) {
        counts.update((date.year, date.month), (n) => n + 1, ifAbsent: () => 1);
      }
    }
  }

  return [
    for (var back = months - 1; back >= 0; back--)
      () {
        final month = DateTime(today.year, today.month - back);
        return (
          year: month.year,
          month: month.month,
          count: counts[(month.year, month.month)] ?? 0,
        );
      }(),
  ];
}

/// The games with the most trophies unlocked, at most [limit]; games with
/// none are left out. Ties go alphabetically.
List<Game> topGames(List<Game> games, {int limit = 5}) {
  final started =
      [
        for (final game in games)
          if (_unlocked(game) > 0) game,
      ]..sort((a, b) {
        final byCount = _unlocked(b).compareTo(_unlocked(a));
        return byCount != 0
            ? byCount
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
  return started.take(limit).toList();
}

typedef RecentUnlock = ({Game game, Trophy trophy});

/// The trophies unlocked last across the whole library, newest first, at most
/// [limit]. Only trophies with an unlock date can be placed in time.
List<RecentUnlock> recentUnlocks(List<Game> games, {int limit = 12}) {
  final unlocks = <RecentUnlock>[
    for (final game in games)
      for (final trophy in game.trophies)
        if (trophy.isAchieved && trophy.achievedAt != null)
          (game: game, trophy: trophy),
  ]..sort((a, b) => b.trophy.achievedAt!.compareTo(a.trophy.achievedAt!));
  return unlocks.take(limit).toList();
}
