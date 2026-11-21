import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/utils/time/time_format.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/game/presentation/details/trophy_view.dart';

Trophy _t(
  String name, {
  bool done = false,
  DateTime? at,
  String? description,
}) => Trophy(
  apiName: name,
  displayName: name,
  description: description,
  isAchieved: done,
  achievedAt: at,
);

List<String> _names(List<Trophy> trophies) => [
  for (final t in trophies) t.displayName,
];

void main() {
  final trophies = [
    _t('Zeta', done: true, at: DateTime(2025, 1, 5)),
    _t('Alpha'),
    _t('Beta', done: true, at: DateTime(2025, 3, 9)),
    _t('Gamma', description: 'Defeat the Zeta boss'),
    _t('Delta', done: true),
  ];

  group('arrangeTrophies', () {
    test('splits unlocked from locked, keeping Steam order by default', () {
      final groups = arrangeTrophies(trophies);

      expect(_names(groups.unlocked), ['Zeta', 'Beta', 'Delta']);
      expect(_names(groups.locked), ['Alpha', 'Gamma']);
    });

    test('a filter hides the other group', () {
      expect(
        arrangeTrophies(trophies, filter: TrophyFilter.unlocked).locked,
        isEmpty,
      );
      expect(
        arrangeTrophies(trophies, filter: TrophyFilter.locked).unlocked,
        isEmpty,
      );
    });

    test('the query looks in names and descriptions, whatever the case', () {
      final groups = arrangeTrophies(trophies, query: ' ZETA ');

      expect(_names(groups.unlocked), ['Zeta']);
      expect(_names(groups.locked), ['Gamma']);
    });

    test('recent puts the latest unlock first and undated ones last', () {
      final groups = arrangeTrophies(trophies, sort: TrophySort.recent);

      expect(_names(groups.unlocked), ['Beta', 'Zeta', 'Delta']);
    });

    test(
      'rarest orders by percentage, unknown ones last, ties by Steam order',
      () {
        final groups = arrangeTrophies(
          trophies,
          sort: TrophySort.rarest,
          rarity: {'Zeta': 3.5, 'Beta': 3.5, 'Alpha': 40},
        );

        expect(_names(groups.unlocked), ['Zeta', 'Beta', 'Delta']);
        expect(_names(groups.locked), ['Alpha', 'Gamma']);
      },
    );

    test('name sorts alphabetically without regard to case', () {
      final groups = arrangeTrophies([
        _t('banana'),
        _t('Apple'),
        _t('cherry'),
      ], sort: TrophySort.name);

      expect(_names(groups.locked), ['Apple', 'banana', 'cherry']);
    });
  });

  test('rarity tiers change at 5, 15 and 40 percent', () {
    expect(rarityTier(0.6), RarityTier.ultraRare);
    expect(rarityTier(5), RarityTier.ultraRare);
    expect(rarityTier(5.1), RarityTier.veryRare);
    expect(rarityTier(15), RarityTier.veryRare);
    expect(rarityTier(40), RarityTier.rare);
    expect(rarityTier(40.1), RarityTier.common);
  });

  test('summarize counts unlocks and finds the latest dated one', () {
    final summary = summarize(trophies);

    expect(summary.unlocked, 3);
    expect(summary.total, 5);
    expect(summary.latest?.displayName, 'Beta');
    expect(summarize([_t('x')]).latest, isNull);
  });

  test('dates read like "5 Jan 2025"', () {
    expect(formatShortDate(DateTime(2025, 1, 5)), '5 Jan 2025');
  });
}
