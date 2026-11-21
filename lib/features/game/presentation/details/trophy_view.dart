import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';

enum TrophyFilter { all, unlocked, locked }

enum TrophySort { defaultOrder, recent, rarest, name }

/// How rare a trophy is, from the share of players who unlocked it.
enum RarityTier { ultraRare, veryRare, rare, common }

/// Maps the unlock [percent] (0-100) to a tier: up to 5% is ultra rare, 15%
/// very rare, 40% rare, anything above is common.
RarityTier rarityTier(double percent) {
  if (percent <= 5) return RarityTier.ultraRare;
  if (percent <= 15) return RarityTier.veryRare;
  if (percent <= 40) return RarityTier.rare;
  return RarityTier.common;
}

/// The rarity of each trophy by API name: what the trophies carry (PlayStation
/// sends it with them) with [fetched] over it (Steam's separate lookup).
Map<String, double> rarityOf(
  List<Trophy> trophies,
  Map<String, double> fetched,
) => {
  for (final trophy in trophies)
    if (trophy.rarity != null) trophy.apiName: trophy.rarity!,
  ...fetched,
};

typedef TrophyGroups = ({List<Trophy> unlocked, List<Trophy> locked});

/// Keeps the trophies matching [query] (in name or description) and [filter],
/// sorts each group by [sort] and splits them into unlocked and locked.
///
/// The sort is stable: trophies that compare equal keep Steam's order. Trophies
/// with no date (for `recent`) or no rarity (for `rarest`) go last.
TrophyGroups arrangeTrophies(
  List<Trophy> trophies, {
  TrophyFilter filter = TrophyFilter.all,
  String query = '',
  TrophySort sort = TrophySort.defaultOrder,
  Map<String, double> rarity = const {},
}) {
  final needle = query.trim().toLowerCase();
  bool matches(Trophy trophy) =>
      needle.isEmpty ||
      trophy.displayName.toLowerCase().contains(needle) ||
      (trophy.description ?? '').toLowerCase().contains(needle);

  final compare = _comparator(sort, rarity);
  List<Trophy> pick(bool unlocked, bool wanted) {
    if (!wanted) return const [];
    final group = [
      for (final trophy in trophies)
        if (trophy.isAchieved == unlocked && matches(trophy)) trophy,
    ];
    return compare == null ? group : _stableSorted(group, compare);
  }

  return (
    unlocked: pick(true, filter != TrophyFilter.locked),
    locked: pick(false, filter != TrophyFilter.unlocked),
  );
}

int Function(Trophy, Trophy)? _comparator(
  TrophySort sort,
  Map<String, double> rarity,
) {
  switch (sort) {
    case TrophySort.defaultOrder:
      return null;
    case TrophySort.recent:
      return (a, b) => _nullsLast(a.achievedAt, b.achievedAt, descending: true);
    case TrophySort.rarest:
      return (a, b) => _nullsLast(rarity[a.apiName], rarity[b.apiName]);
    case TrophySort.name:
      return (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  }
}

/// Orders ascending (or descending), with nulls after every value either way.
int _nullsLast<T extends Comparable<Object>>(
  T? a,
  T? b, {
  bool descending = false,
}) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return descending ? b.compareTo(a) : a.compareTo(b);
}

List<Trophy> _stableSorted(
  List<Trophy> trophies,
  int Function(Trophy, Trophy) compare,
) {
  final indexed = trophies.indexed.toList();
  indexed.sort((a, b) {
    final result = compare(a.$2, b.$2);
    return result != 0 ? result : a.$1.compareTo(b.$1);
  });
  return [for (final entry in indexed) entry.$2];
}

/// How many trophies are unlocked, how many there are, and the one unlocked
/// last (null when none has a date).
({int unlocked, int total, Trophy? latest}) summarize(List<Trophy> trophies) {
  Trophy? latest;
  var unlocked = 0;
  for (final trophy in trophies) {
    if (!trophy.isAchieved) continue;
    unlocked++;
    final date = trophy.achievedAt;
    if (date != null &&
        (latest?.achievedAt == null || date.isAfter(latest!.achievedAt!))) {
      latest = trophy;
    }
  }
  return (unlocked: unlocked, total: trophies.length, latest: latest);
}
