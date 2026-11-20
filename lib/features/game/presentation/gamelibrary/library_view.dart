import 'package:trophies_tracker/core/utils/game/game_completion.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';

enum LibraryFilter { all, inProgress, completed, notStarted }

enum LibrarySort { lastActivity, name, progress, trophiesLeft }

int _unlocked(Game game) => game.trophies.where((t) => t.isAchieved).length;

/// Share of the trophies that are unlocked, from 0 to 1 (0 with no trophies).
double gameProgress(Game game) =>
    game.trophies.isEmpty ? 0 : _unlocked(game) / game.trophies.length;

/// When the last trophy of [game] was unlocked, or null if none has a date.
DateTime? lastActivity(Game game) {
  DateTime? latest;
  for (final trophy in game.trophies) {
    final date = trophy.achievedAt;
    if (trophy.isAchieved && date != null) {
      if (latest == null || date.isAfter(latest)) latest = date;
    }
  }
  return latest;
}

bool _matches(Game game, LibraryFilter filter) {
  final unlocked = _unlocked(game);
  final total = game.trophies.length;
  return switch (filter) {
    LibraryFilter.all => true,
    LibraryFilter.inProgress => unlocked > 0 && unlocked < total,
    LibraryFilter.completed => game.isCompleted,
    LibraryFilter.notStarted => total > 0 && unlocked == 0,
  };
}

/// Keeps the games that match [filter] and whose name contains [query], and
/// sorts them by [sort]. Ties are broken by name and then by appId, so the
/// order never depends on how the games happen to be stored.
///
/// Sorting by trophies left puts the games with the fewest left first and
/// leaves finished ones, which have nothing left, at the end.
List<Game> arrangeLibrary(
  List<Game> games, {
  LibraryFilter filter = LibraryFilter.all,
  String query = '',
  LibrarySort sort = LibrarySort.lastActivity,
}) {
  final needle = query.trim().toLowerCase();
  final result = [
    for (final game in games)
      if (_matches(game, filter) && game.name.toLowerCase().contains(needle))
        game,
  ];

  int byName(Game a, Game b) {
    final byText = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return byText != 0 ? byText : a.appId.compareTo(b.appId);
  }

  int primary(Game a, Game b) {
    switch (sort) {
      case LibrarySort.name:
        return 0;
      case LibrarySort.progress:
        return gameProgress(b).compareTo(gameProgress(a));
      case LibrarySort.trophiesLeft:
        int left(Game game) {
          final remaining = game.trophies.length - _unlocked(game);
          return remaining == 0 ? 1 << 30 : remaining;
        }

        return left(a).compareTo(left(b));
      case LibrarySort.lastActivity:
        final da = lastActivity(a);
        final db = lastActivity(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
    }
  }

  result.sort((a, b) {
    final result = primary(a, b);
    return result != 0 ? result : byName(a, b);
  });
  return result;
}

/// The games that are close to done: at least 80% but not 100%, closest
/// first, at most [limit].
List<Game> almostThere(List<Game> games, {int limit = 10}) {
  final close = [
    for (final game in games)
      if (gameProgress(game) >= 0.8 && !game.isCompleted) game,
  ]..sort((a, b) => gameProgress(b).compareTo(gameProgress(a)));
  return close.take(limit).toList();
}

/// How many games there are and how many trophies are unlocked in total.
({int games, int trophies}) librarySummary(List<Game> games) => (
  games: games.length,
  trophies: games.fold(0, (sum, game) => sum + _unlocked(game)),
);
