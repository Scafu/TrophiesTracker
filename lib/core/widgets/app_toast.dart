import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// What a toast is about, which decides its icon and tint.
enum ToastKind { info, success, error }

/// Shows [message] as a floating glass capsule, in the same style as
/// [AppNavigationBar], replacing the toast that is currently on screen.
///
/// It is a floating `SnackBar` underneath, so the scaffold keeps it above the
/// bottom bar, screen readers announce it and swiping it away still works.
void showAppToast(
  BuildContext context,
  String message, {
  ToastKind kind = ToastKind.info,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(28, 0, 28, 8),
        duration: duration,
        content: _Toast(message: message, kind: kind),
      ),
    );
}

/// Icon color for [kind]. The greens differ per theme because the bright one
/// would fall below 3:1 against a light surface.
@visibleForTesting
Color toastTint(ToastKind kind, ThemeData theme) {
  final dark = theme.brightness == Brightness.dark;
  return switch (kind) {
    ToastKind.info => theme.colorScheme.primary,
    ToastKind.success =>
      dark ? const Color(0xFF22C55E) : const Color(0xFF15803D),
    ToastKind.error => theme.colorScheme.error,
  };
}

class _Toast extends StatelessWidget {
  final String message;
  final ToastKind kind;

  const _Toast({required this.message, required this.kind});

  static const _radius = 24.0;

  static IconData _icon(ToastKind kind) => switch (kind) {
    ToastKind.info => Symbols.info_rounded,
    ToastKind.success => Symbols.check_circle_rounded,
    ToastKind.error => Symbols.error_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(_icon(kind), size: 22, color: toastTint(kind, theme)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
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
