import 'package:equatable/equatable.dart';

class Trophy extends Equatable {
  final String apiName;
  final String displayName;
  final String? description;
  final String? icon;
  final String? coloredIcon;
  final bool isAchieved;
  final DateTime? achievedAt;

  const Trophy({
    required this.apiName,
    required this.displayName,
    this.description,
    this.icon,
    this.coloredIcon,
    this.isAchieved = false,
    this.achievedAt,
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
    );
  }
}
