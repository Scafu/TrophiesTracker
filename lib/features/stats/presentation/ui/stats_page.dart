import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_state.dart';
import 'package:trophies_tracker/features/stats/presentation/ui/stats_widgets.dart';

/// Displays the user's statistics, including library summary and recent activity.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          return switch (state) {
            StatsLoading() => const Center(child: CircularProgressIndicator()),
            StatsError(message: var m) => Center(child: Text(m)),
            StatsLoaded(games: var games, activities: var acts) =>
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: "Library",
                              count: state.totalGames,
                              icon: Symbols.sports_esports_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: "Trophies",
                              count: state.totalAchievedTrophies,
                              icon: Symbols.trophy_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                      child: Text(
                        "Your Library",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180,
                      child: games.isEmpty
                          ? const Center(child: Text("No games added"))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: games.length,
                              itemBuilder: (context, i) =>
                                  _GameLibraryTile(game: games[i]),
                            ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
                      child: Text(
                        "Recent Trophies",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (acts.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("No recent trophies"),
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: acts.length,
                      itemBuilder: (context, i) =>
                          ActivityTile(activity: acts[i], games: games),
                    ),
                ],
              ),
          };
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _GameLibraryTile extends StatelessWidget {
  final Game game;

  const _GameLibraryTile({required this.game});

  @override
  Widget build(BuildContext context) {
    final achieved = game.trophies.where((t) => t.isAchieved).length;
    final total = game.trophies.length;
    final progress = total > 0 ? achieved / total : 0.0;

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                child: CachedNetworkImage(
                  imageUrl: game.libraryImage ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.gamepad)),
                  ),
                ),
                onTap: () => context.pushNamed(
                  'gameDetails',
                  pathParameters: {
                    'appId': game.appId.toString(),
                    'fromExplorer': 'false',
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            game.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
