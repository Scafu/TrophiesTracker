import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/theme/accent.dart';

/// Floating, capsule-shaped tab bar in the style of iOS: frosted glass that
/// hovers above the bottom edge, with a highlight capsule that slides under the
/// selected destination.
///
/// Place it in a `Scaffold` with `extendBody: true` so the content scrolls
/// behind the glass; the scaffold then reports the bar height through
/// `MediaQuery.padding.bottom`, which scrollable pages add to their own
/// bottom padding.
class AppNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  static const _destinations = [
    _Destination('Library', Symbols.sports_esports_rounded),
    _Destination('Explore', Symbols.explore_rounded),
    _Destination('Stats', Symbols.bar_chart_rounded),
  ];

  static const _height = 64.0;
  static const _inset = 5.0;
  static const _radius = 40.0;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    final bottom = math.max(
      MediaQuery.viewPaddingOf(context).bottom - 12,
      12.0,
    );
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 280);
    final slots = _destinations.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(28, 0, 28, bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.10),
              ),
            ),
            child: SizedBox(
              height: _height,
              child: Padding(
                padding: const EdgeInsets.all(_inset),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(
                        2 * currentIndex / (slots - 1) - 1,
                        0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1 / slots,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: highlightColor(colors),
                            borderRadius: BorderRadius.circular(
                              _radius - _inset,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < slots; i++)
                          Expanded(
                            child: _NavItem(
                              destination: _destinations[i],
                              selected: i == currentIndex,
                              onTap: () => _onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Fill of the capsule under the selected destination.
  @visibleForTesting
  static Color highlightColor(ColorScheme colors) =>
      colors.onSurface.withValues(alpha: 0.08);

  void _onTap(int index) {
    if (index == currentIndex) return;
    HapticFeedback.lightImpact();
    onSelected(index);
  }
}

class _Destination {
  final String label;
  final IconData icon;

  const _Destination(this.label, this.icon);
}

class _NavItem extends StatefulWidget {
  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  void _setPressed(bool pressed) => setState(() => _pressed = pressed);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = widget.selected;
    final color = selected
        ? accentColor(theme)
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: widget.destination.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTap: () {
          _setPressed(false);
          widget.onTap();
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _pressed ? 0.6 : 1,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.destination.icon,
                    size: 24,
                    color: color,
                    fill: selected ? 1 : 0,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.destination.label,
                    maxLines: 1,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
