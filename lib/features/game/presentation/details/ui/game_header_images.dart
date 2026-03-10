import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_cubit.dart';

class GameHeaderImages extends StatefulWidget {
  final Game game;

  const GameHeaderImages({super.key, required this.game});
  @override
  State<GameHeaderImages> createState() => _GameHeaderImagesState();
}

class _GameHeaderImagesState extends State<GameHeaderImages> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.game.headerImage != null &&
            widget.game.headerImage!.isNotEmpty)
          _buildNetworkImage(
            widget.game.headerImage!,
            fit: BoxFit.cover,
            opacity: 0.6,
          )
        else
          Container(color: Theme.of(context).colorScheme.surfaceContainerHigh),
        Container(color: Colors.black.withValues(alpha: 0.4)),
        Positioned(
          left: 16,
          bottom: 10,
          child: SizedBox(
            height: 170,
            child: AspectRatio(
              aspectRatio: 600 / 900,
              child: Material(
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.hardEdge,
                child:
                    (widget.game.libraryImage != null &&
                        widget.game.libraryImage!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: widget.game.libraryImage!,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        placeholder: (context, url) => Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          child: Icon(
                            Icons.broken_image,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Displays a single trophy or achievement as an outlined card.
/// Holding down on the tile will scroll long titles and descriptions horizontally.
class TrophyTile extends StatefulWidget {
  final Game game;
  final Trophy trophy;
  final bool fromExplorer;

  const TrophyTile({
    required this.game,
    required this.trophy,
    this.fromExplorer = true,
    super.key,
  });

  @override
  State<TrophyTile> createState() => _TrophyTileState();
}

class _TrophyTileState extends State<TrophyTile> {
  bool _isHolding = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAchieved = widget.trophy.isAchieved;
    final bool showColored = widget.fromExplorer || isAchieved;

    final String? iconUrl = showColored
        ? widget.trophy.coloredIcon
        : widget.trophy.icon;

    final bool isActuallyUnlocked = !widget.fromExplorer && isAchieved;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: isActuallyUnlocked
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: isActuallyUnlocked
                ? theme.colorScheme.primary
                : theme.dividerColor,
            width: isActuallyUnlocked ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Listener(
          onPointerDown: (_) => setState(() => _isHolding = true),
          onPointerUp: (_) => setState(() => _isHolding = false),
          onPointerCancel: (_) => setState(() => _isHolding = false),
          child: InkWell(
            onTap: () {
              if (widget.fromExplorer) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Add to library to unlock trophies"),
                    duration: const Duration(milliseconds: 1000),
                  ),
                );
                return;
              }
              if (widget.game.isSynced) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Cannot manually unlock trophies for synced games",
                    ),
                    duration: const Duration(milliseconds: 1000),
                  ),
                );
                return;
              }

              context.read<GameDetailsCubit>().toggleTrophy(
                widget.game.appId,
                widget.trophy.apiName,
                isAchieved,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: iconUrl != null && iconUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: iconUrl,
                            fit: BoxFit.cover,
                            color: showColored ? null : Colors.grey,
                            colorBlendMode: showColored
                                ? null
                                : BlendMode.saturation,
                            placeholder: (context, url) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.broken_image,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        : Icon(
                            Icons.emoji_events,
                            color: showColored
                                ? Colors.amber
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isHolding
                            ? AutoScrollText(
                                text: widget.trophy.displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Text(
                                widget.trophy.displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        if (widget.trophy.description != null &&
                            widget.trophy.description!.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          _isHolding
                              ? AutoScrollText(
                                  text: widget.trophy.description!,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : Text(
                                  widget.trophy.description!,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ],
                      ],
                    ),
                  ),
                  if (isActuallyUnlocked) ...[
                    const SizedBox(width: 8.0),
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameInfoSection extends StatelessWidget {
  final Game game;

  const GameInfoSection({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                game.publisher.join(', '),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("AppID: ${game.appId}", style: theme.textTheme.bodySmall),
            ],
          ),
          if (game.description != null && game.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(game.description!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

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

/// Builds a cached network image with a loading placeholder and an error fallback.
/// Wraps the image in an Opacity widget if the opacity value is less than 1.0.
Widget _buildNetworkImage(
  String url, {
  BoxFit fit = BoxFit.contain,
  double opacity = 1.0,
}) {
  final Widget imageWidget = CachedNetworkImage(
    imageUrl: url,
    fit: fit,
    placeholder: (context, url) =>
        const Center(child: CircularProgressIndicator()),
    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
  );

  if (opacity < 1.0) {
    return Opacity(opacity: opacity, child: imageWidget);
  }

  return imageWidget;
}
