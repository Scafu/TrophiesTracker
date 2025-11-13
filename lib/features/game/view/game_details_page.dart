import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_app_tracker/core/providers/game_provider.dart';
import 'package:trophies_app_tracker/features/shared/log.dart';
import 'package:trophies_app_tracker/features/stats/viewmodel/stats_viewmodel.dart';
import 'package:trophies_app_tracker/styles/themes.dart';

/// Detail Page of [Game] clicked by USER
class GameDetailsPage extends ConsumerWidget {
  /// appId associated with the GAME
  final int appId;

  /// Creates a [GameDetailsPage] for the given [appId].
  const GameDetailsPage({required this.appId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final asyncGame = ref.watch(gameProviderSteam(appId));

    return asyncGame.when(
      data: (game) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      title: Text(
                        style: TextStyle(
                          fontFamily: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.fontFamily,
                        ),
                        textAlign: TextAlign.center,
                        "Add Game",
                      ),

                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Do you want to add ${game.name} to your GamePage?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(115, 45),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    final addedGame = await ref
                                        .read(gameProviderOffline.notifier)
                                        .addGame(asyncGame.value!);

                                    await ref
                                        .read(recentActivityProvider.notifier)
                                        .addActivity(addedGame.appId);
                                    if (!context.mounted) return;
                                    context.pop();
                                  } catch (e) {
                                    logger.e(e);
                                  }
                                },
                                icon: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Yes",
                                  style: TextStyle(
                                    fontFamily: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.fontFamily,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(115, 45),
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "No",
                                  style: TextStyle(
                                    fontFamily: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: Icon(Symbols.add),
            ),
          ],
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          scrolledUnderElevation: 0.0,
          title: Text(
            game.name,
            style: Theme.of(
              context,
            ).appBarTheme.titleTextStyle?.copyWith(fontSize: 15),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        // [Game] headerImage
                        CachedNetworkImage(
                          filterQuality: FilterQuality.high,
                          imageUrl: game.headerImage ?? '',
                          placeholder: (context, url) => Container(
                            height: 150,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Themes
                                .darkTheme
                                .colorScheme
                                .surfaceContainerHigh,
                            child: const Icon(
                              Icons.broken_image,
                              color: Color(0xFF9CA0AA),
                            ),
                          ),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          height: 150,
                        ),
                        Positioned.fill(
                          child: Container(
                            color: const Color.fromARGB(60, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      height: screenSize.height * 0.12,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // [Game] Name
                            Text(
                              game.name,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 4),
                            // [Game] [appId]
                            Text(
                              "AppID: ${game.appId}",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // [Game] publisher
                            Text(
                              game.publisher.join(', '),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // [Game] libraryImage
                Positioned(
                  left: screenSize.width * 0.05,
                  top: screenSize.height * 0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(8),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: screenSize.height * 0.22,
                        width: screenSize.width * 0.3,
                        filterQuality: FilterQuality.high,
                        imageUrl: game.libraryImage ?? '',
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).cardColor,
                          child: Icon(
                            Icons.image,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).cardColor,
                          child: Icon(
                            Icons.broken_image,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: game.trophies.length,
                itemBuilder: (context, index) {
                  final trophy = game.trophies[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: trophy.coloredIcon!.startsWith('http')
                                ? CachedNetworkImage(
                                    filterQuality: FilterQuality.high,
                                    imageUrl: trophy.coloredIcon ?? '',
                                    placeholder: (context, url) => CircleAvatar(
                                      backgroundColor: Themes
                                          .darkTheme
                                          .colorScheme
                                          .surfaceContainerHigh,
                                      radius: screenSize.width * 0.05,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        CircleAvatar(
                                          backgroundColor: Themes
                                              .darkTheme
                                              .colorScheme
                                              .surfaceContainerHigh,
                                          radius: screenSize.width * 0.05,
                                          child: Icon(
                                            Icons.error_outline,
                                            size: 20,
                                            color: Themes
                                                .darkTheme
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                        ),
                                    width: screenSize.width * 0.13,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    trophy.coloredIcon!,
                                    width: screenSize.width * 0.13,
                                    fit: BoxFit.cover,
                                  ),
                            title: Text(
                              trophy.displayName,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              trophy.description ?? '',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          "Errore: $error",
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
