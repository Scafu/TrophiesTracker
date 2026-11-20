import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/theme/accent.dart';
import 'package:trophies_tracker/core/widgets/game_cover.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';

/// A round button of the details app bar.
class GlassAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Shows a spinner instead of the icon, for an action in progress.
  final bool busy;

  const GlassAction({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.busy = false,
  });
}

/// The top of the details page: a hero with the game's art, cover and name
/// that collapses into a plain bar with the name as title when scrolled.
///
/// The back button and the actions are drawn here, not as app bar widgets, so
/// they can change from white-on-glass over the art to themed controls as the
/// bar collapses.
class GameSliverAppBar extends StatelessWidget {
  final Game game;
  final List<GlassAction> actions;
  final VoidCallback onBack;

  const GameSliverAppBar({
    super.key,
    required this.game,
    required this.actions,
    required this.onBack,
  });

  static const expandedHeight = 330.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final top = MediaQuery.paddingOf(context).top;

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: expandedHeight,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // 1 while fully expanded, 0 once collapsed to the toolbar.
          final t =
              ((constraints.maxHeight - top - kToolbarHeight) /
                      (expandedHeight - kToolbarHeight))
                  .clamp(0.0, 1.0);
          final foreground = Color.lerp(colors.onSurface, Colors.white, t)!;
          final background = Color.lerp(
            colors.onSurface.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.35),
            t,
          )!;

          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: t,
                child: GameHero(game: game),
              ),
              Positioned(
                left: 64,
                right: 64 + 48.0 * (actions.length - 1).clamp(0, 2),
                top: top,
                height: kToolbarHeight,
                child: Opacity(
                  opacity: (1 - t * 2).clamp(0.0, 1.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      game.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 1,
                child: ColoredBox(
                  color: colors.onSurface.withValues(alpha: 0.08 * (1 - t)),
                ),
              ),
              Positioned(
                left: 12,
                top: top + 8,
                child: _GlassButton(
                  action: GlassAction(
                    icon: Symbols.arrow_back_ios_new_rounded,
                    tooltip: 'Back',
                    onPressed: onBack,
                  ),
                  foreground: foreground,
                  background: background,
                ),
              ),
              Positioned(
                right: 12,
                top: top + 8,
                child: Row(
                  children: [
                    for (final action in actions) ...[
                      const SizedBox(width: 8),
                      _GlassButton(
                        action: action,
                        foreground: foreground,
                        background: background,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final GlassAction action;
  final Color foreground;
  final Color background;

  const _GlassButton({
    required this.action,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: action.tooltip,
      child: Semantics(
        button: true,
        enabled: action.onPressed != null,
        label: action.tooltip,
        excludeSemantics: true,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Material(
              color: background,
              child: InkWell(
                onTap: action.busy ? null : action.onPressed,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: action.busy
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: foreground,
                            ),
                          )
                        : Icon(action.icon, size: 20, color: foreground),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The expanded hero: blurred art fading into the page, the cover with a
/// shadow, and the name, publisher and AppID beside it.
class GameHero extends StatelessWidget {
  final Game game;

  const GameHero({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final page = theme.scaffoldBackgroundColor;
    final header = game.headerImage;

    final art = header != null && header.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: header,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => const SizedBox.shrink(),
          )
        : GameCover(game: game);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: colors.surfaceContainerHigh),
        ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Transform.scale(scale: 1.15, child: art),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
                page.withValues(alpha: 0.85),
                page,
              ],
              stops: const [0, 0.35, 0.78, 1],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 112,
                  height: 168,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: GameCover(game: game),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        game.name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 24,
                          height: 1.15,
                        ),
                      ),
                      if (game.publisher.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          game.publisher.join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: accentColor(theme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        'AppID ${game.appId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
