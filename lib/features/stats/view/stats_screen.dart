import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:trophies_app_tracker/core/models/trophy/trophy.dart';
import 'package:trophies_app_tracker/core/providers/game_provider.dart';
import 'package:trophies_app_tracker/features/stats/viewmodel/stats_viewmodel.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameList = ref.watch(gameProviderOffline);
    final achievedTrophies = ref.watch(achievedTrophiesProvider);
    final lastActivityAsync = ref.watch(recentActivityProvider);

    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: screenSize.width * 0.45,
                    height: screenSize.height * 0.15,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenSize.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Symbols.sports_esports_rounded),
                            SizedBox(width: screenSize.width * 0.01),
                            Text(
                              "Owned",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        Text(
                          "${gameList.length}",
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenSize.width * 0.45,
                    height: screenSize.height * 0.15,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenSize.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Symbols.trophy_rounded),
                            Text(
                              " Achieved",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        Text(
                          "${achievedTrophies.length}",
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Game Library", style: TextStyle(fontSize: 25)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenSize.height * 0.3,
              child: gameList.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: gameList.length,
                      itemBuilder: (context, index) {
                        final game = gameList[index];
                        final totalTrophies = game.trophies.length;
                        final achievedTrophies = game.trophies
                            .where((t) => t.isAchieved == 1)
                            .length;
                        final progress = totalTrophies > 0
                            ? achievedTrophies / totalTrophies
                            : 0.0;
                        final imagePath = game.libraryImage;
                        final bool hasImage = !(imagePath == null);
                        return SizedBox(
                          width: screenSize.width * 0.33,
                          child: Column(
                            children: [
                              Hero(
                                tag: 'stats-${game.appId}',
                                child: Material(
                                  borderRadius: BorderRadius.circular(8),
                                  clipBehavior: Clip.hardEdge,
                                  child: SizedBox(
                                    height: screenSize.height * 0.22,
                                    width: screenSize.width * 0.3,
                                    child: InkWell(
                                      splashColor: const Color.fromARGB(
                                        123,
                                        255,
                                        255,
                                        255,
                                      ),
                                      onTap: () {
                                        context.pushNamed(
                                          'gameDetailsOffline',
                                          pathParameters: {
                                            'appId': game.appId.toString(),
                                          },
                                          extra: {
                                            'heroTag': 'gameHero-${game.appId}',
                                            'disableHero': false,
                                          },
                                        );
                                      },
                                      child: hasImage
                                          ? Image.file(
                                              File(imagePath),
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHigh,
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey[600],
                                                size: 40,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                game.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 8,
                                width: screenSize.width * 0.3,
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No Game added",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Recent Activity", style: TextStyle(fontSize: 25)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          lastActivityAsync.when(
            data: (lastActivity) {
              if (lastActivity.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      "No Activity registered",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final activity = lastActivity[index];
                  final game = gameList.firstWhere(
                    (g) => g.appId == activity.gameAppId,
                  );
                  Trophy? trophy = game.trophies.firstWhereOrNull(
                    (t) => t.displayName == activity.trophyDisplayName,
                  );

                  final title = trophy?.displayName ?? game.name;
                  final subtitle = trophy != null
                      ? game.name
                      : game.publisher.join(', ');
                  final timestamp = activity.timestamp;

                  final difference = DateTime.now().difference(timestamp);
                  final timeAgo = difference.inDays > 0
                      ? '${difference.inDays}d ago'
                      : difference.inHours > 0
                      ? '${difference.inHours}h ago'
                      : difference.inMinutes > 0
                      ? '${difference.inMinutes}m ago'
                      : 'Just now';
                  final bool isTrophyActivity = (trophy != null);

                  final String? imagePath = isTrophyActivity
                      ? trophy.coloredIcon
                      : game.libraryImage;

                  final bool hasImage =
                      (imagePath != null && imagePath.isNotEmpty);

                  final imageWidth = MediaQuery.of(context).size.width * 0.13;
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListTile(
                      tileColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: hasImage
                          ? Image.file(
                              File(imagePath),
                              width: imageWidth,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: imageWidth,
                              height: 50,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                            ),
                      title: Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                  );
                }, childCount: lastActivity.length),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, st) =>
                SliverToBoxAdapter(child: Center(child: Text('Errore: $err'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
