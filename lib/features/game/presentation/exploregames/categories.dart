import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A Steam genre shown as a tile in Explore.
///
/// [tagId] is the Steam tag id, which must also be in the Worker's
/// `CATEGORY_TAGS`: the route refuses any other.
class GameCategory {
  final int tagId;
  final String name;
  final IconData icon;

  /// Dark enough for white text on it.
  final Color color;

  const GameCategory(this.tagId, this.name, this.icon, this.color);
}

const gameCategories = <GameCategory>[
  GameCategory(19, 'Action', Symbols.swords_rounded, Color(0xFFB91C1C)),
  GameCategory(21, 'Adventure', Symbols.explore_rounded, Color(0xFF047857)),
  GameCategory(122, 'RPG', Symbols.shield_rounded, Color(0xFF6D28D9)),
  GameCategory(1774, 'Shooter', Symbols.target_rounded, Color(0xFFC2410C)),
  GameCategory(
    29482,
    'Souls-like',
    Symbols.local_fire_department_rounded,
    Color(0xFF475569),
  ),
  GameCategory(
    1695,
    'Open World',
    Symbols.landscape_rounded,
    Color(0xFF4D7C0F),
  ),
  GameCategory(9, 'Strategy', Symbols.chess_rounded, Color(0xFF1D4ED8)),
  GameCategory(
    599,
    'Simulation',
    Symbols.precision_manufacturing_rounded,
    Color(0xFF0369A1),
  ),
  GameCategory(1667, 'Horror', Symbols.skull_rounded, Color(0xFF9D174D)),
  GameCategory(1664, 'Puzzle', Symbols.extension_rounded, Color(0xFFA16207)),
  GameCategory(
    1625,
    'Platformer',
    Symbols.directions_run_rounded,
    Color(0xFF4338CA),
  ),
  GameCategory(492, 'Indie', Symbols.palette_rounded, Color(0xFF0E7490)),
];

/// The category with Steam tag [tagId], or null if it is not one of ours.
GameCategory? categoryById(int tagId) {
  for (final category in gameCategories) {
    if (category.tagId == tagId) return category;
  }
  return null;
}
