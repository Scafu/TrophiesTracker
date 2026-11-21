import 'package:equatable/equatable.dart';

/// The grade of a PlayStation trophy. Steam achievements have none.
enum TrophyType { bronze, silver, gold, platinum }

class Trophy extends Equatable {
  final String apiName;
  final String displayName;
  final String? description;
  final String? icon;
  final String? coloredIcon;
  final bool isAchieved;
  final DateTime? achievedAt;

  /// The grade of the trophy, for platforms that have one.
  final TrophyType? type;

  /// Whether the platform hides the trophy until it is earned.
  final bool hidden;

  /// The share of players who earned it, from 0 to 100, when the platform
  /// sends it with the trophy (Steam's comes from a separate lookup).
  final double? rarity;

  const Trophy({
    required this.apiName,
    required this.displayName,
    this.description,
    this.icon,
    this.coloredIcon,
    this.isAchieved = false,
    this.achievedAt,
    this.type,
    this.hidden = false,
    this.rarity,
  });

  @override
  List<Object?> get props => [
    apiName,
    displayName,
    description,
    icon,
    coloredIcon,
    isAchieved,
    achievedAt,
    type,
    hidden,
    rarity,
  ];

  Trophy copyWith({bool? isAchieved, DateTime? achievedAt}) {
    return Trophy(
      apiName: apiName,
      displayName: displayName,
      description: description,
      icon: icon,
      coloredIcon: coloredIcon,
      isAchieved: isAchieved ?? this.isAchieved,
      achievedAt: achievedAt ?? this.achievedAt,
      type: type,
      hidden: hidden,
      rarity: rarity,
    );
  }
}
