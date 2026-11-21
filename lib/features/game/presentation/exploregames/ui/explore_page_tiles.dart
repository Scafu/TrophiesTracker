import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/theme/accent.dart';
import 'package:trophies_tracker/core/widgets/game_cover.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';

/// Splits [text] around the first case-insensitive occurrence of [query];
/// [match] is empty when there is none.
@visibleForTesting
({String before, String match, String after}) splitAtMatch(
  String text,
  String query,
) {
  final lower = text.toLowerCase();
  final index = query.isEmpty || lower.length != text.length
      ? -1
      : lower.indexOf(query.toLowerCase());
  if (index < 0) return (before: text, match: '', after: '');

  final end = index + query.length;
  return (
    before: text.substring(0, index),
    match: text.substring(index, end),
    after: text.substring(end),
  );
}

/// A search result: cover, name with the typed part highlighted, and either
/// a chip when the game is already in the library or a chevron.
class ExploreGameTile extends StatelessWidget {
  final Game game;
  final String query;
  final bool inLibrary;
  final VoidCallback onTap;

  const ExploreGameTile({
    required this.game,
    required this.query,
    required this.inLibrary,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final nameStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );
    final parts = splitAtMatch(game.name, query);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.onSurface.withValues(alpha: 0.06)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 84,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GameCover(game: game),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: nameStyle,
                          children: [
                            TextSpan(text: parts.before),
                            TextSpan(
                              text: parts.match,
                              style: TextStyle(
                                color: accentColor(theme),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: parts.after),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${game.platform.label} · ID ${game.code}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                inLibrary
                    ? ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 112),
                        child: _LibraryChip(),
                      )
                    : Icon(
                        Symbols.chevron_right_rounded,
                        color: colors.onSurfaceVariant,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Marks a result that is already in the user's library.
class _LibraryChip extends StatelessWidget {
  const _LibraryChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor(theme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.check_rounded, size: 14, color: accent),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'In library',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
