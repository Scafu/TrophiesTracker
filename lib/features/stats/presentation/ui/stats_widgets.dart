import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/utils/number_format.dart';
import 'package:trophies_tracker/core/utils/time/time_format.dart';
import 'package:trophies_tracker/core/widgets/completion_ring.dart';
import 'package:trophies_tracker/core/widgets/game_cover.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/stats/stats_view.dart';
import 'package:trophies_tracker/styles/colors_palette.dart';

BoxDecoration _cardDecoration(ColorScheme colors) => BoxDecoration(
  color: colors.surfaceContainerHigh,
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: colors.onSurface.withValues(alpha: 0.06)),
);

void _openGame(BuildContext context, Game game) => context.pushNamed(
  'gameDetails',
  pathParameters: {'appId': game.appId.toString(), 'fromExplorer': 'false'},
);

/// The whole library at a glance: a ring with the share of trophies unlocked,
/// the count behind it and how many games are completed.
class StatsOverview extends StatelessWidget {
  final LibraryTotals totals;

  const StatsOverview({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = totals.total == 0 ? 0.0 : totals.unlocked / totals.total;

    return DecoratedBox(
      decoration: _cardDecoration(colors),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CompletionRing(
              progress: progress,
              complete: totals.total > 0 && totals.unlocked == totals.total,
              size: 104,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatCount(totals.unlocked)} trophies',
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'unlocked out of ${formatCount(totals.total)}, '
                    'across ${totals.games} ${totals.games == 1 ? 'game' : 'games'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A number with its label and an icon, one of the four under the overview.
class StatTile extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color? color;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: _cardDecoration(colors),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color ?? colors.primary, fill: 1),
              const SizedBox(height: 12),
              Text(
                formatCount(value),
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 26),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trophies unlocked per month, as one bar for each of the last months. The
/// busiest month is solid, the others are faded.
class MonthlyChart extends StatelessWidget {
  final List<MonthCount> months;

  const MonthlyChart({super.key, required this.months});

  static const _barArea = 84.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final busiest = months.fold(
      0,
      (most, m) => m.count > most ? m.count : most,
    );
    final label = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
      fontSize: 11,
    );

    return DecoratedBox(
      decoration: _cardDecoration(colors),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final m in months)
              Expanded(
                child: Semantics(
                  label: '${monthAbbreviation(m.month)}: ${m.count} unlocked',
                  excludeSemantics: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(m.count > 0 ? '${m.count}' : '', style: label),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        height: busiest == 0
                            ? 4
                            : 4 + (m.count / busiest) * _barArea,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: m.count > 0 && m.count == busiest
                              ? colors.primary
                              : colors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(monthAbbreviation(m.month), style: label),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The games with the most trophies unlocked, each with a bar relative to the
/// first one.
class TopGamesCard extends StatelessWidget {
  final List<Game> games;

  const TopGamesCard({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    int unlocked(Game game) => game.trophies.where((t) => t.isAchieved).length;
    final most = games.isEmpty ? 1 : unlocked(games.first);

    return DecoratedBox(
      decoration: _cardDecoration(colors),
      child: Column(
        children: [
          for (final game in games)
            InkWell(
              onTap: () => _openGame(context, game),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GameCover(game: game),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: unlocked(game) / most,
                              minHeight: 6,
                              backgroundColor: colors.onSurface.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formatCount(unlocked(game)),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The last trophies unlocked, with the game and how long ago.
class RecentUnlocksCard extends StatelessWidget {
  final List<RecentUnlock> unlocks;

  const RecentUnlocksCard({super.key, required this.unlocks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: _cardDecoration(colors),
      child: Column(
        children: [
          for (final unlock in unlocks)
            InkWell(
              onTap: () => _openGame(context, unlock.game),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _TrophyIcon(url: unlock.trophy.coloredIcon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unlock.trophy.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${unlock.game.name} · '
                            '${formatRelative(unlock.trophy.achievedAt!)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrophyIcon extends StatelessWidget {
  final String? url;

  const _TrophyIcon({required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = const Icon(
      Symbols.emoji_events_rounded,
      color: ColorsPalette.colorGold,
    );

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url!.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => fallback,
            ),
    );
  }
}
