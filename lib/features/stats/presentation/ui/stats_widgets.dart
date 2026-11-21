import 'package:trophies_tracker/core/router/game_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/utils/game/game_completion.dart';
import 'package:trophies_tracker/core/utils/number_format.dart';
import 'package:trophies_tracker/core/utils/time/time_format.dart';
import 'package:trophies_tracker/core/widgets/game_cover.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/stats/stats_view.dart';
import 'package:trophies_tracker/styles/colors_palette.dart';

/// The trophy gold, darkened on light themes so text in it stays readable.
Color _gold(ThemeData theme) => theme.brightness == Brightness.dark
    ? ColorsPalette.colorGold
    : Color.lerp(ColorsPalette.colorGold, Colors.black, 0.45)!;

Duration _animation(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : const Duration(milliseconds: 700);

void _openGame(BuildContext context, Game game) => context.pushNamed(
  'gameDetails',
  pathParameters: gameRouteParams(game.key, fromExplorer: false),
);

/// The whole library in one figure: the trophies unlocked, big, over a bar
/// with the share of the total and how many are left.
class StatsHero extends StatelessWidget {
  final LibraryTotals totals;

  const StatsHero({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = totals.total == 0 ? 0.0 : totals.unlocked / totals.total;
    final percent = (progress * 100).round();
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Semantics(
      label:
          '${totals.unlocked} of ${totals.total} trophies unlocked, '
          '$percent percent',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatCount(totals.unlocked),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 68,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: _gold(theme),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${formatCount(totals.total)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 26,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'trophies unlocked across ${totals.games} '
            '${totals.games == 1 ? 'game' : 'games'}',
            style: muted,
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: _animation(context),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                color: ColorsPalette.colorGold,
                backgroundColor: colors.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percent%',
                style: muted?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${formatCount(totals.total - totals.unlocked)} to go',
                style: muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// How the games split into completed, in progress and not started: one
/// segmented bar with the three counts under it.
class LibraryBreakdown extends StatelessWidget {
  final LibraryTotals totals;

  const LibraryBreakdown({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final parts = [
      (
        label: 'Completed',
        value: totals.completed,
        color: ColorsPalette.colorGold,
      ),
      (label: 'In progress', value: totals.inProgress, color: colors.primary),
      (
        label: 'Not started',
        value: totals.notStarted,
        color: colors.onSurface.withValues(alpha: 0.22),
      ),
    ];
    final shown = [
      for (final part in parts)
        if (part.value > 0) part,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: shown.isEmpty
                ? ColoredBox(color: colors.onSurface.withValues(alpha: 0.08))
                : Row(
                    children: [
                      for (var i = 0; i < shown.length; i++) ...[
                        if (i > 0) const SizedBox(width: 3),
                        Expanded(
                          flex: shown[i].value,
                          child: ColoredBox(color: shown[i].color),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final part in parts)
              Expanded(
                child: Semantics(
                  label: '${part.label}: ${part.value}',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: part.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              part.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCount(part.value),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A calendar of the unlocks, one square per day with a column for each week
/// and a row for each weekday, the busier the day the stronger the gold.
class ActivityHeatmap extends StatelessWidget {
  final List<DayCount> days;

  const ActivityHeatmap({super.key, required this.days});

  static const _gap = 3.0;
  static const _levels = [0.0, 0.3, 0.55, 0.78, 1.0];

  /// The columns where a month label goes: the first one, and each column
  /// whose Monday starts a new month, dropping the first if the next one is
  /// too close for both labels to fit.
  static List<int> monthStarts(List<DayCount> days) {
    final columns = (days.length / 7).ceil();
    final starts = [
      if (columns > 0) 0,
      for (var c = 1; c < columns; c++)
        if (days[c * 7].day.month != days[(c - 1) * 7].day.month) c,
    ];
    if (starts.length > 1 && starts[1] - starts[0] < 3) starts.removeAt(0);
    return starts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
      fontSize: 11,
    );
    final total = days.fold(0, (sum, d) => sum + d.count);
    final active = days.where((d) => d.count > 0).length;
    final columns = (days.length / 7).ceil();

    Color shade(int level) => level == 0
        ? colors.onSurface.withValues(alpha: 0.07)
        : _gold(theme).withValues(alpha: _levels[level]);

    return Semantics(
      label:
          '$total trophies unlocked on $active days in the last '
          '${columns - 1} weeks',
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cell = (constraints.maxWidth - _gap * (columns - 1)) / columns;
          final step = cell + _gap;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 18,
                child: Stack(
                  children: [
                    for (final c in monthStarts(days))
                      Positioned(
                        left: c * step,
                        child: Text(
                          monthAbbreviation(days[c * 7].day.month),
                          style: label,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var c = 0; c < columns; c++) ...[
                    if (c > 0) const SizedBox(width: _gap),
                    Column(
                      children: [
                        for (var r = 0; r < 7 && c * 7 + r < days.length; r++)
                          Padding(
                            padding: EdgeInsets.only(bottom: r < 6 ? _gap : 0),
                            child: SizedBox(
                              width: cell,
                              height: cell,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: shade(
                                    activityLevel(days[c * 7 + r].count),
                                  ),
                                  borderRadius: BorderRadius.circular(3.5),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatCount(total)} unlocks · '
                      '$active active ${active == 1 ? 'day' : 'days'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: label,
                    ),
                  ),
                  Text('Less', style: label),
                  const SizedBox(width: 6),
                  for (var level = 0; level < _levels.length; level++)
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: SizedBox(
                        width: 11,
                        height: 11,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: shade(level),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 3),
                  Text('More', style: label),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A tappable row of a list, with a line under it unless it is the [last].
class _ListRow extends StatelessWidget {
  final VoidCallback onTap;
  final bool last;
  final Widget child;

  const _ListRow({
    required this.onTap,
    required this.last,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: child,
          ),
        ),
        if (!last)
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: colors.onSurface.withValues(alpha: 0.07),
          ),
      ],
    );
  }
}

/// The games with the most trophies unlocked, ranked, each with its own
/// progress.
class TopGamesList extends StatelessWidget {
  final List<Game> games;

  const TopGamesList({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        for (var i = 0; i < games.length; i++)
          _ListRow(
            onTap: () => _openGame(context, games[i]),
            last: i == games.length - 1,
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: i == 0 ? _gold(theme) : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GameCover(game: games[i]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        games[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: games[i].completionPercentage / 100,
                          minHeight: 5,
                          color: games[i].isCompleted
                              ? ColorsPalette.colorGold
                              : colors.primary,
                          backgroundColor: colors.onSurface.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${games[i].trophies.where((t) => t.isAchieved).length}'
                        ' of ${games[i].trophies.length} trophies',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  games[i].formattedCompletionPercentage,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The last trophies unlocked, with the game and how long ago.
class RecentUnlocksList extends StatelessWidget {
  final List<RecentUnlock> unlocks;

  const RecentUnlocksList({super.key, required this.unlocks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        for (var i = 0; i < unlocks.length; i++)
          _ListRow(
            onTap: () => _openGame(context, unlocks[i].game),
            last: i == unlocks.length - 1,
            child: Row(
              children: [
                _TrophyIcon(url: unlocks[i].trophy.coloredIcon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unlocks[i].trophy.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${unlocks[i].game.name} · '
                        '${formatRelative(unlocks[i].trophy.achievedAt!)}',
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
      ],
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
        color: colors.surfaceContainerHigh,
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
