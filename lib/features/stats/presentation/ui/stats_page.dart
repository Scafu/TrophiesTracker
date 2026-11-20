import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/widgets/section_label.dart';
import 'package:trophies_tracker/core/widgets/tab_header.dart';
import 'package:trophies_tracker/features/account/presentation/ui/account_button.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_state.dart';
import 'package:trophies_tracker/features/stats/presentation/ui/stats_widgets.dart';
import 'package:trophies_tracker/features/stats/stats_view.dart';
import 'package:trophies_tracker/styles/colors_palette.dart';

/// The library in numbers: overall progress, what is completed or under way,
/// the busiest months, the games with the most trophies and the latest unlocks.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsCubit, StatsState>(
      builder: (context, state) {
        return switch (state) {
          StatsLoading() => const _UnderHeader(
            child: Center(child: CircularProgressIndicator()),
          ),
          StatsError(message: final message) => _UnderHeader(
            child: Center(child: Text(message)),
          ),
          StatsLoaded(games: final games) when games.isEmpty =>
            const _UnderHeader(child: _NoStats()),
          StatsLoaded(games: final games) => _Stats(games: games),
        };
      },
    );
  }
}

class _Stats extends StatelessWidget {
  final List<Game> games;

  const _Stats({required this.games});

  @override
  Widget build(BuildContext context) {
    final totals = libraryTotals(games);
    final months = unlocksPerMonth(games);
    final top = topGames(games);
    final recent = recentUnlocks(games);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _Header()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverList.list(
            children: [
              StatsOverview(totals: totals),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: Symbols.sports_esports_rounded,
                      value: totals.games,
                      label: 'Games',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      icon: Symbols.trophy_rounded,
                      value: totals.completed,
                      label: 'Completed',
                      color: ColorsPalette.colorGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: Symbols.play_circle_rounded,
                      value: totals.inProgress,
                      label: 'In progress',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      icon: Symbols.hourglass_empty_rounded,
                      value: totals.notStarted,
                      label: 'Not started',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (months.any((m) => m.count > 0)) ...[
          const SliverToBoxAdapter(child: SectionLabel('Unlocks per month')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: MonthlyChart(months: months)),
          ),
        ],
        if (top.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionLabel('Most trophies')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: TopGamesCard(games: top)),
          ),
        ],
        if (recent.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionLabel('Recent unlocks')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: RecentUnlocksCard(unlocks: recent),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) =>
      const TabHeader(title: 'Stats', actions: [AccountButton()]);
}

/// The header of the page above [child], for the states with no stats.
class _UnderHeader extends StatelessWidget {
  final Widget child;

  const _UnderHeader({required this.child});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _Header(),
      Expanded(child: child),
    ],
  );
}

/// Shown while the library has no games: there is nothing to count yet.
class _NoStats extends StatelessWidget {
  const _NoStats();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.bar_chart_rounded,
            size: 48,
            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text('No stats yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Add games to your library and your progress shows up here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.go('/explore'),
            icon: const Icon(Symbols.explore_rounded, size: 20),
            label: const Text('Explore games'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 46),
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
