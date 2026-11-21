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

typedef DayCount = ({DateTime day, int count});

/// Trophies unlocked on each day of the last [weeks] weeks, oldest first and
/// ending today. Weeks start on Monday and the first day is the Monday
/// `weeks - 1` weeks back, so the index modulo 7 is the weekday row and the
/// last week stops at today. Trophies with no date are not counted.
///
/// [now] only exists so the result can be tested.
List<DayCount> unlocksPerDay(
  List<Game> games, {
  int weeks = 20,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final counts = <DateTime, int>{};
  for (final game in games) {
    for (final trophy in game.trophies) {
      final date = trophy.achievedAt?.toLocal();
      if (trophy.isAchieved && date != null) {
        final day = DateTime(date.year, date.month, date.day);
        counts.update(day, (n) => n + 1, ifAbsent: () => 1);
      }
    }
  }

  final first = DateTime(
    today.year,
    today.month,
    today.day - (today.weekday - 1) - (weeks - 1) * 7,
  );
  final length = (weeks - 1) * 7 + today.weekday;
  final days = <DayCount>[];
  for (var i = 0; i < length; i++) {
    final day = DateTime(first.year, first.month, first.day + i);
    days.add((day: day, count: counts[day] ?? 0));
  }
  return days;
}

/// How strongly a day with [count] unlocks is drawn, from 0 (none) to 4.
int activityLevel(int count) => switch (count) {
  <= 0 => 0,
  1 => 1,
  2 => 2,
  <= 4 => 3,
  _ => 4,
};

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
