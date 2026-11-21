import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/widgets/empty_state.dart';
import 'package:trophies_tracker/core/widgets/section_label.dart';
import 'package:trophies_tracker/core/widgets/tab_header.dart';
import 'package:trophies_tracker/features/account/presentation/ui/account_button.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_state.dart';
import 'package:trophies_tracker/features/stats/presentation/ui/stats_widgets.dart';
import 'package:trophies_tracker/features/stats/stats_view.dart';

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
    final days = unlocksPerDay(games);
    final top = topGames(games);
    final recent = recentUnlocks(games, limit: 6);
    const side = EdgeInsets.symmetric(horizontal: 20);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _Header()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverList.list(
            children: [
              StatsHero(totals: totals),
              const SizedBox(height: 28),
              LibraryBreakdown(totals: totals),
            ],
          ),
        ),
        if (days.any((d) => d.count > 0)) ...[
          const SliverToBoxAdapter(child: SectionLabel('Activity')),
          SliverPadding(
            padding: side,
            sliver: SliverToBoxAdapter(child: ActivityHeatmap(days: days)),
          ),
        ],
        if (top.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionLabel('Most trophies')),
          SliverToBoxAdapter(child: TopGamesList(games: top)),
        ],
        if (recent.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionLabel('Recent unlocks')),
          SliverToBoxAdapter(child: RecentUnlocksList(unlocks: recent)),
        ],
        SliverToBoxAdapter(
          child: SizedBox(height: 120 + MediaQuery.paddingOf(context).bottom),
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
/// [child] gets the space above the floating navigation bar, so what it
/// centers is not hidden.
class _UnderHeader extends StatelessWidget {
  final Widget child;

  const _UnderHeader({required this.child});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _Header(),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: child,
        ),
      ),
    ],
  );
}

/// Shown while the library has no games: there is nothing to count yet.
class _NoStats extends StatelessWidget {
  const _NoStats();

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Symbols.bar_chart_rounded,
      title: 'No stats yet',
      message: 'Add games to your library and your progress shows up here.',
      actions: [
        EmptyStateAction.primary(
          icon: Symbols.explore_rounded,
          label: 'Explore games',
          onPressed: () => context.go('/explore'),
        ),
      ],
    );
  }
}
