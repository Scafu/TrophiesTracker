import 'package:flutter/material.dart';
import 'package:trophies_tracker/styles/colors_palette.dart';

/// A ring that fills up to [progress] (0 to 1) with the percentage in the
/// middle. It turns gold when [complete].
class CompletionRing extends StatelessWidget {
  final double progress;
  final bool complete;
  final double size;

  const CompletionRing({
    super.key,
    required this.progress,
    this.complete = false,
    this.size = 92,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final percent = (progress * 100).round();

    return Semantics(
      label: '$percent percent complete',
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: size / 11.5,
                strokeCap: StrokeCap.round,
                backgroundColor: colors.onSurface.withValues(alpha: 0.08),
                color: complete ? ColorsPalette.colorGold : colors.primary,
              ),
            ),
            Center(
              child: Text(
                '$percent%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
