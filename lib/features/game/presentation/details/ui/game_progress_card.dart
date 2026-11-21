import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/utils/html_entities.dart';
import 'package:trophies_tracker/core/utils/time/time_format.dart';
import 'package:trophies_tracker/core/widgets/completion_ring.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/styles/colors_palette.dart';

BoxDecoration _cardDecoration(ColorScheme colors) => BoxDecoration(
  color: colors.surfaceContainerHigh,
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: colors.onSurface.withValues(alpha: 0.06)),
);

/// How far along the player is: a ring with the percentage (gold once every
/// trophy is unlocked), the counts and the trophy unlocked last.
class ProgressCard extends StatelessWidget {
  final ({int unlocked, int total, Trophy? latest}) summary;

  const ProgressCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (:unlocked, :total, :latest) = summary;
    final progress = total == 0 ? 0.0 : unlocked / total;
    final complete = total > 0 && unlocked == total;
    final date = latest?.achievedAt;

    return DecoratedBox(
      decoration: _cardDecoration(colors),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CompletionRing(progress: progress, complete: complete),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlocked of $total trophies',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  if (complete)
                    const _CompletedPill()
                  else
                    Text(
                      total == 0
                          ? 'No trophies to unlock'
                          : '${total - unlocked} left to unlock',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  if (latest != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Latest: ${latest.displayName}'
                      '${date == null ? '' : ' · ${formatShortDate(date)}'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedPill extends StatelessWidget {
  const _CompletedPill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorsPalette.colorGold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Symbols.trophy_rounded,
              size: 16,
              fill: 1,
              color: ColorsPalette.colorGold,
            ),
            const SizedBox(width: 6),
            Text(
              'Completed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown instead of [ProgressCard] for a game that is not in the library yet:
/// there is no progress to show, only an invitation to add it.
class ExplorerCard extends StatelessWidget {
  final int total;
  final VoidCallback onAdd;

  const ExplorerCard({super.key, required this.total, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: _cardDecoration(colors),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Symbols.trophy_rounded,
                  fill: 1,
                  color: ColorsPalette.colorGold,
                ),
                const SizedBox(width: 10),
                Text('$total trophies', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add this game to your library to track which ones you unlock.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Symbols.add_rounded, size: 20),
              label: const Text('Add to library'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A game description cut to three lines, with a toggle only when the text
/// really is longer than that at the width it is shown in.
///
/// Without a line limit the text must not ask for an ellipsis: a [Text] with
/// `overflow: ellipsis` and no `maxLines` is cut to a single line.
class ExpandableDescription extends StatefulWidget {
  final String text;

  const ExpandableDescription({super.key, required this.text});

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  static const _collapsedLines = 3;
  bool _expanded = false;

  /// Whether [text] needs more than [_collapsedLines] lines in [width].
  bool _overflows(
    BuildContext context,
    String text,
    TextStyle? style,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: _collapsedLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: width);
    final overflows = painter.didExceedMaxLines;
    painter.dispose();
    return overflows;
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);
    final text = decodeHtmlEntities(widget.text);

    return LayoutBuilder(
      builder: (context, constraints) {
        final long = _overflows(context, text, style, constraints.maxWidth);
        final showAll = _expanded || !long;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: Text(
                text,
                maxLines: showAll ? null : _collapsedLines,
                overflow: showAll ? TextOverflow.clip : TextOverflow.ellipsis,
                style: style,
              ),
            ),
            if (long)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(_expanded ? 'Show less' : 'Show more'),
              ),
          ],
        );
      },
    );
  }
}
