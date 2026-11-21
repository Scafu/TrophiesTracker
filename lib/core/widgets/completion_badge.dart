import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/styles/colors_palette.dart';

/// Gold trophy placed over the cover of a game whose trophies are all unlocked.
class CompletionBadge extends StatelessWidget {
  const CompletionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Completed',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ColorsPalette.colorGold,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Symbols.trophy_rounded,
            size: 14,
            fill: 1,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
}
