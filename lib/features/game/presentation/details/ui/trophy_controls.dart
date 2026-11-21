import 'package:flutter/material.dart';
import 'package:trophies_tracker/core/theme/accent.dart';
import 'package:trophies_tracker/core/widgets/capsule_search_field.dart';
import 'package:trophies_tracker/core/widgets/sort_menu_button.dart';
import 'package:trophies_tracker/features/game/presentation/details/trophy_view.dart';

/// The bar that stays pinned under the app bar while the trophies scroll:
/// an All / Unlocked / Locked switch, a search field and a sort menu.
///
/// The switch is left out for a game that is not in the library, where no
/// trophy can be unlocked.
class TrophyControlsDelegate extends SliverPersistentHeaderDelegate {
  final bool showFilter;
  final TrophyFilter filter;
  final ValueChanged<TrophyFilter> onFilter;
  final TextEditingController query;
  final ValueChanged<String> onQuery;
  final VoidCallback onClearQuery;
  final TrophySort sort;
  final ValueChanged<TrophySort> onSort;

  /// Whether rarity data is available, which "Rarest first" needs.
  final bool rarityAvailable;

  TrophyControlsDelegate({
    required this.showFilter,
    required this.filter,
    required this.onFilter,
    required this.query,
    required this.onQuery,
    required this.onClearQuery,
    required this.sort,
    required this.onSort,
    required this.rarityAvailable,
  });

  double get _height => showFilter ? 124 : 72;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showFilter) ...[
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<TrophyFilter>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: TrophyFilter.all, label: Text('All')),
                    ButtonSegment(
                      value: TrophyFilter.unlocked,
                      label: Text('Unlocked'),
                    ),
                    ButtonSegment(
                      value: TrophyFilter.locked,
                      label: Text('Locked'),
                    ),
                  ],
                  selected: {filter},
                  onSelectionChanged: (selection) => onFilter(selection.first),
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: const StadiumBorder(),
                    backgroundColor: colors.surfaceContainerHigh,
                    foregroundColor: colors.onSurfaceVariant,
                    selectedBackgroundColor: colors.primary.withValues(
                      alpha: 0.18,
                    ),
                    selectedForegroundColor: accentColor(theme),
                    side: BorderSide(
                      color: colors.onSurface.withValues(alpha: 0.10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: CapsuleSearchField(
                    controller: query,
                    hint: 'Search trophies',
                    dense: true,
                    onChanged: onQuery,
                    onClear: onClearQuery,
                  ),
                ),
                const SizedBox(width: 8),
                SortMenuButton<TrophySort>(
                  options: const {
                    TrophySort.defaultOrder: 'Steam order',
                    TrophySort.recent: 'Recently unlocked',
                    TrophySort.rarest: 'Rarest first',
                    TrophySort.name: 'Name A–Z',
                  },
                  value: sort,
                  defaultValue: TrophySort.defaultOrder,
                  onSelected: onSort,
                  disabled: {if (!rarityAvailable) TrophySort.rarest},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
