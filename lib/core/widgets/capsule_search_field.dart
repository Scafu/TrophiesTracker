import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Search field in the app's capsule style: rounded, filled, with a magnifier
/// and a clear button that only shows while there is text.
class CapsuleSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClear;
  final bool dense;

  const CapsuleSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
    this.onSubmitted,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        filled: true,
        fillColor: colors.surfaceContainerHigh,
        isDense: dense,
        contentPadding: EdgeInsets.symmetric(vertical: dense ? 12 : 16),
        prefixIcon: Icon(
          Symbols.search_rounded,
          color: colors.onSurfaceVariant,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear',
                  icon: Icon(
                    Symbols.cancel_rounded,
                    fill: 1,
                    color: colors.onSurfaceVariant,
                  ),
                  onPressed: onClear,
                ),
        ),
        enabledBorder: border(colors.onSurface.withValues(alpha: 0.08)),
        border: border(colors.onSurface.withValues(alpha: 0.08)),
        focusedBorder: border(colors.primary.withValues(alpha: 0.7), 1.5),
      ),
    );
  }
}
