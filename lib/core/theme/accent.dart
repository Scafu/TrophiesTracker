import 'package:flutter/material.dart';

/// The theme's primary color adjusted for small text and icons that sit on a
/// tinted or translucent surface: nudged towards white on dark themes and
/// towards black on light ones, so it keeps a 4.5:1 contrast there.
Color accentColor(ThemeData theme) {
  final primary = theme.colorScheme.primary;
  return theme.brightness == Brightness.dark
      ? Color.lerp(primary, Colors.white, 0.28)!
      : Color.lerp(primary, Colors.black, 0.15)!;
}
