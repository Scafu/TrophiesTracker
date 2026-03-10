import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:trophies_tracker/core/domain/entities/game_activity.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';

class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const AutoScrollText({required this.text, this.style, super.key});

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startScrolling();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll > 0) {
      final duration = Duration(milliseconds: (maxScroll * 30).toInt());
      _scrollController.animateTo(
        maxScroll,
        duration: duration,
        curve: Curves.linear,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(widget.text, style: widget.style, maxLines: 1),
    );
  }
}

/// A dispatcher tile that renders either a Game Added activity or a Trophy Unlocked activity.
class ActivityTile extends StatelessWidget {
  final GameActivity activity;
  final List<Game> games;

  const ActivityTile({super.key, required this.activity, required this.games});

  @override
  Widget build(BuildContext context) {
    final game = games.firstWhereOrNull((g) => g.appId == activity.gameAppId);

    if (game == null) return const SizedBox.shrink();

    if (activity.isGameAdded) {
      return _GameAddedActivityTile(activity: activity, game: game);
    }

    return _TrophyUnlockedActivityTile(activity: activity, game: game);
  }
}

/// A reusable base widget that mimics the exact look and feel of ExploreGameTile.
/// It handles the container styling, the 'holding' state for auto-scroll, and the layout.
class _ActivityBaseTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final VoidCallback onTap;

  const _ActivityBaseTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.leading,
  });

  @override
  State<_ActivityBaseTile> createState() => _ActivityBaseTileState();
}

class _ActivityBaseTileState extends State<_ActivityBaseTile> {
  bool _isHolding = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: theme.dividerColor, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (isHighlighted) {
            setState(() {
              _isHolding = isHighlighted;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 16.0),
                ],

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isHolding
                          ? AutoScrollText(
                              text: widget.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Text(
                              widget.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      const SizedBox(height: 4.0),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tile for "Game Added". Identical to ExploreTile (Text only).
class _GameAddedActivityTile extends StatelessWidget {
  final GameActivity activity;
  final Game game;

  const _GameAddedActivityTile({required this.activity, required this.game});

  @override
  Widget build(BuildContext context) {
    return _ActivityBaseTile(
      title: game.name,
      subtitle: "Added to Library",
      onTap: () => context.pushNamed(
        'gameDetails',
        pathParameters: {
          'appId': game.appId.toString(),
          'fromExplorer': 'false',
        },
      ),
    );
  }
}

/// Tile for "Trophy Unlocked". Identical to ExploreTile but adds the colored icon.
class _TrophyUnlockedActivityTile extends StatelessWidget {
  final GameActivity activity;
  final Game game;

  const _TrophyUnlockedActivityTile({
    required this.activity,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final Trophy? trophy = game.trophies.firstWhereOrNull(
      (t) => t.displayName == activity.trophyDisplayName,
    );

    final String? iconUrl = trophy?.coloredIcon;

    return _ActivityBaseTile(
      title: trophy?.displayName ?? "Unknown Trophy",
      subtitle: "${game.name} • Unlocked",
      leading: SizedBox(
        width: 48,
        height: 48,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: iconUrl != null && iconUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: iconUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Symbols.trophy, color: Colors.amber),
                )
              : Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Symbols.trophy),
                ),
        ),
      ),
      onTap: () => context.pushNamed(
        'gameDetails',
        pathParameters: {
          'appId': game.appId.toString(),
          'fromExplorer': 'false',
        },
      ),
    );
  }
}
