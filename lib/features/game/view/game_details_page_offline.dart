import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:trophies_app_tracker/core/models/game/game.dart';
import 'package:trophies_app_tracker/core/providers/game_provider.dart';
import 'package:trophies_app_tracker/features/shared/globals.dart';
import 'package:trophies_app_tracker/features/stats/viewmodel/stats_viewmodel.dart';

class GameDetailsPageOffline extends ConsumerWidget {
  final int gameAppId;
  final String heroTag;
  final bool disableHero;
  const GameDetailsPageOffline({
    required this.gameAppId,
    required this.heroTag,
    this.disableHero = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    final Game? game = ref.watch(singleGameProvider(gameAppId));
    if (game == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.pop();
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final totalTrophies = game.trophies.length;
    final achievedTrophies = game.trophies
        .where((t) => t.isAchieved == 1)
        .length;

    final double progress = (totalTrophies > 0)
        ? (achievedTrophies / totalTrophies)
        : 0.0;
    final headerImage = game.headerImage;
    bool hasHeader = !(headerImage == null);
    final libraryImage = game.libraryImage;
    bool hasLibrary = !(libraryImage == null);

    return Scaffold(
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
                      "Remove Game",
                    ),

                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Are you sure to remove ${game.name} from the GamePage?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
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
                              onPressed: () {
                                ref
                                    .read(gameProviderOffline.notifier)
                                    .removeGame(game.appId);
                                context.pop();
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
            icon: Icon(Symbols.delete),
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
                      hasHeader
                          ? Image.file(
                              File(headerImage),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: 150,
                            )
                          : Container(
                              height: 150,
                              width: double.infinity,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[600],
                                size: 40,
                              ),
                            ),

                      Positioned.fill(
                        child: Container(
                          color: const Color.fromARGB(60, 0, 0, 0),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: FloatingActionButton.small(
                          onPressed: () => showModalBottomSheet(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            context: context,
                            builder: (context) => Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Current progress",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Trophy achieved: $achievedTrophies/$totalTrophies",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(height: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${'${(progress * 100).toStringAsFixed(1)}%'} ",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(height: 16),
                                      SizedBox(
                                        height: 8,
                                        width: screenSize.width,
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                          child: Icon(Symbols.emoji_events_rounded),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      border: Border(
                        top: BorderSide(color: Theme.of(context).dividerColor),
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    height: screenSize.height * 0.12,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
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
                  child: HeroMode(
                    enabled: !disableHero,
                    child: Hero(
                      tag: heroTag,
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        clipBehavior: Clip.hardEdge,
                        child: hasLibrary
                            ? Image.file(
                                File(libraryImage),
                                height: Globals.screenHeight(context) * 0.22,
                                width: Globals.screenWidth(context) * 0.3,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: Globals.screenHeight(context) * 0.22,
                                width: Globals.screenWidth(context) * 0.3,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
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
              ),
            ],
          ),
          // Lista trofei
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: game.trophies.length,
              itemBuilder: (context, index) {
                final trophy = game.trophies[index];
                final bool isAchieved = trophy.isAchieved == 1;
                final String? iconPath = isAchieved
                    ? trophy.coloredIcon
                    : trophy.uncoloredIcon;
                final String? displayIconPath =
                    iconPath ?? trophy.coloredIcon ?? trophy.uncoloredIcon;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      if (trophy.displayName == 'Mastery Trophy') {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return masteryAlert(context, game, ref);
                          },
                        );
                        return;
                      }
                      final newAchieved = isAchieved ? 0 : 1;
                      await ref
                          .read(gameProviderOffline.notifier)
                          .setTrophyAchieved(
                            game.appId,
                            trophy.displayName,
                            newAchieved,
                          );
                      if (newAchieved == 1) {
                        ref
                            .read(recentActivityProvider.notifier)
                            .addActivity(game.appId, trophy.displayName);
                      }
                    },
                    child:
                        trophy.displayName == "Mastery Trophy" &&
                            trophy.isAchieved == 1
                        ? ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(12),
                            child: Shimmer(
                              duration: Duration(seconds: 2),
                              interval: Duration(seconds: 4),
                              color: Colors.amber.shade700,
                              colorOpacity: 0.8,
                              enabled: true,
                              direction: ShimmerDirection.fromLeftToRight(),
                              child: AnimatedContainer(
                                duration: Duration(seconds: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withAlpha(120),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Image.file(
                                    File(displayIconPath!),
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
                          )
                        : ListTile(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: BorderRadiusGeometry.circular(12),
                            ),
                            tileColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Image.file(
                              File(displayIconPath!),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AlertDialog masteryAlert(BuildContext context, Game game, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        style: TextStyle(
          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
        ),
        textAlign: TextAlign.center,
        "Attention",
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Clicking Yes will mark all trophies as achieved. Are you sure you want to continue?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(115, 45),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  await ref
                      .read(gameProviderOffline.notifier)
                      .setGameCompleted(game.appId);
                  for (final t in game.trophies) {
                    if (t.isAchieved == 0) {
                      await ref
                          .read(recentActivityProvider.notifier)
                          .addActivity(game.appId, t.displayName);
                    }
                  }
                  if (!context.mounted) return;
                  context.pop();
                },
                icon: const Icon(Icons.check_rounded, color: Colors.white),
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
                icon: const Icon(Icons.close_rounded, color: Colors.white),
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
  }
}
