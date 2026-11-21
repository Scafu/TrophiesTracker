import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/utils/time/time_format.dart';
import 'package:trophies_tracker/core/widgets/app_toast.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/details/trophy_view.dart';
import 'package:trophies_tracker/styles/colors_palette.dart';

/// One trophy: its icon, name, description, when it was unlocked, its grade
/// (PlayStation) and how rare it is. Unlocked trophies get a gold tint.
///
/// A hidden trophy that is not unlocked shows as "Hidden trophy" until it is
/// tapped. What a tap does after that depends on the game: in a game that is
/// not in the library and in a synced game it only explains why nothing
/// changes; in a manually added game it unlocks or locks the trophy.
class TrophyTile extends StatefulWidget {
  final Game game;
  final Trophy trophy;
  final bool fromExplorer;

  /// Share of players (0-100) who unlocked it, when known.
  final double? rarity;

  const TrophyTile({
    required this.game,
    required this.trophy,
    this.fromExplorer = true,
    this.rarity,
    super.key,
  });

  @override
  State<TrophyTile> createState() => _TrophyTileState();
}

class _TrophyTileState extends State<TrophyTile> {
  bool _revealed = false;

  Game get _game => widget.game;
  Trophy get _trophy => widget.trophy;

  bool get _manual => !widget.fromExplorer && !_game.isSynced;
  bool get _masked => _trophy.hidden && !_trophy.isAchieved && !_revealed;

  void _onTap(BuildContext context) {
    if (_masked) {
      setState(() => _revealed = true);
    } else if (widget.fromExplorer) {
      showAppToast(context, 'Add to library to unlock trophies');
    } else if (_game.isSynced) {
      showAppToast(context, 'Cannot manually unlock trophies for synced games');
    } else {
      context.read<GameDetailsCubit>().toggleTrophy(
        _game.key,
        _trophy.apiName,
        _trophy.isAchieved,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final trophy = _trophy;
    final unlocked = !widget.fromExplorer && trophy.isAchieved;
    final showColored = widget.fromExplorer || trophy.isAchieved;
    final iconUrl = showColored ? trophy.coloredIcon : trophy.icon;
    final date = trophy.achievedAt;
    final name = _masked ? 'Hidden trophy' : trophy.displayName;
    final description = _masked ? 'Tap to reveal' : trophy.description ?? '';
    final percent = widget.rarity;
    final type = trophy.type;

    final status = unlocked
        ? 'Unlocked${date == null ? '' : ' on ${formatShortDate(date)}'}'
        : widget.fromExplorer
        ? ''
        : 'Locked';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: [
          name,
          if (type != null) TrophyTypeChip.label(type),
          status,
          if (percent != null) RarityChip.label(percent),
        ].where((part) => part.isNotEmpty).join('. '),
        excludeSemantics: true,
        child: Material(
          color: unlocked
              ? Color.alphaBlend(
                  ColorsPalette.colorGold.withValues(alpha: 0.07),
                  colors.surfaceContainerHigh,
                )
              : colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: unlocked
                  ? ColorsPalette.colorGold.withValues(alpha: 0.35)
                  : colors.onSurface.withValues(alpha: 0.06),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _onTap(context),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _Icon(
                    url: _masked ? null : iconUrl,
                    colored: showColored,
                    masked: _masked,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (type != null ||
                            (unlocked && date != null) ||
                            percent != null) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (type != null) TrophyTypeChip(type: type),
                              if (percent != null) RarityChip(percent: percent),
                              if (unlocked && date != null)
                                Text(
                                  formatShortDate(date),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_manual || unlocked) ...[
                    const SizedBox(width: 10),
                    _Check(unlocked: unlocked),
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

class _Icon extends StatelessWidget {
  final String? url;
  final bool colored;

  /// A hidden trophy: a lock instead of its art.
  final bool masked;

  const _Icon({required this.url, required this.colored, this.masked = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = Icon(
      masked ? Symbols.lock_rounded : Symbols.emoji_events_rounded,
      color: colored ? ColorsPalette.colorGold : colors.onSurfaceVariant,
    );

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url!.isEmpty
          ? placeholder
          : Opacity(
              opacity: colored ? 1 : 0.6,
              child: CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                color: colored ? null : Colors.grey,
                colorBlendMode: colored ? null : BlendMode.saturation,
                placeholder: (context, url) => const SizedBox.shrink(),
                errorWidget: (context, url, error) => placeholder,
              ),
            ),
    );
  }
}

/// The unlocked state of a trophy: a gold check, or an empty circle.
class _Check extends StatelessWidget {
  final bool unlocked;

  const _Check({required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked ? ColorsPalette.colorGold : Colors.transparent,
        border: unlocked
            ? null
            : Border.all(
                color: colors.onSurface.withValues(alpha: 0.25),
                width: 2,
              ),
      ),
      child: unlocked
          ? const Icon(
              Symbols.check_rounded,
              size: 18,
              color: Color(0xFF1F2937),
              weight: 700,
            )
          : null,
    );
  }
}

/// How rare a trophy is: a tier-colored dot, the percentage of players who
/// unlocked it and the tier's name. The name carries the meaning; the color
/// is only a hint.
class RarityChip extends StatelessWidget {
  final double percent;

  const RarityChip({super.key, required this.percent});

  static const _labels = {
    RarityTier.ultraRare: 'Ultra rare',
    RarityTier.veryRare: 'Very rare',
    RarityTier.rare: 'Rare',
    RarityTier.common: 'Common',
  };

  /// `3.5% · Ultra rare`.
  static String label(double percent) {
    final text = percent < 0.1
        ? '<0.1'
        : percent < 10
        ? percent.toStringAsFixed(1)
        : percent.toStringAsFixed(0);
    return '$text% · ${_labels[rarityTier(percent)]}';
  }

  Color _dot(ThemeData theme) {
    final dark = theme.brightness == Brightness.dark;
    return switch (rarityTier(percent)) {
      RarityTier.ultraRare => ColorsPalette.colorGold,
      RarityTier.veryRare =>
        dark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
      RarityTier.rare => theme.colorScheme.primary,
      RarityTier.common => theme.colorScheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dot = _dot(theme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: dot.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              child: const SizedBox(width: 7, height: 7),
            ),
            const SizedBox(width: 5),
            Text(
              label(percent),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The grade of a PlayStation trophy: a medal in the grade's color and its
/// name. The name carries the meaning; the color is only a hint.
class TrophyTypeChip extends StatelessWidget {
  final TrophyType type;

  const TrophyTypeChip({super.key, required this.type});

  static const _labels = {
    TrophyType.bronze: 'Bronze',
    TrophyType.silver: 'Silver',
    TrophyType.gold: 'Gold',
    TrophyType.platinum: 'Platinum',
  };

  static String label(TrophyType type) => _labels[type]!;

  static Color color(TrophyType type) => switch (type) {
    TrophyType.bronze => const Color(0xFFCD7F32),
    TrophyType.silver => const Color(0xFF9CA3AF),
    TrophyType.gold => ColorsPalette.colorGold,
    TrophyType.platinum => const Color(0xFF38BDF8),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color(type);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.workspace_premium_rounded, size: 13, color: tint),
            const SizedBox(width: 4),
            Text(
              label(type),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
