import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A round button that opens a menu to choose how a list is sorted. The icon
/// turns blue while something other than the default order is selected.
class SortMenuButton<T> extends StatelessWidget {
  /// The choices, in the order they are listed, with their labels.
  final Map<T, String> options;
  final T value;

  /// The order the list has when nothing was chosen.
  final T defaultValue;
  final ValueChanged<T> onSelected;

  /// Choices that are listed but cannot be picked.
  final Set<T> disabled;

  const SortMenuButton({
    super.key,
    required this.options,
    required this.value,
    required this.defaultValue,
    required this.onSelected,
    this.disabled = const {},
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<T>(
      tooltip: 'Sort',
      initialValue: value,
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        for (final entry in options.entries)
          PopupMenuItem<T>(
            value: entry.key,
            enabled: !disabled.contains(entry.key),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: entry.key == value
                      ? const Icon(Symbols.check_rounded, size: 18)
                      : null,
                ),
                Flexible(
                  child: Text(
                    entry.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          shape: BoxShape.circle,
          border: Border.all(color: colors.onSurface.withValues(alpha: 0.08)),
        ),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Symbols.swap_vert_rounded,
            color: value == defaultValue
                ? colors.onSurfaceVariant
                : colors.primary,
          ),
        ),
      ),
    );
  }
}
