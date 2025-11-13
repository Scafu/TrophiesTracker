// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trophy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Trophy _$TrophyFromJson(Map<String, dynamic> json) => _Trophy(
  displayName: json['displayName'] as String,
  description: json['description'] as String?,
  isAchieved: (json['isAchieved'] as num?)?.toInt() ?? 0,
  coloredIcon: json['coloredIcon'] as String?,
  uncoloredIcon: json['uncoloredIcon'] as String?,
  achievedAt: json['achievedAt'] == null
      ? null
      : DateTime.parse(json['achievedAt'] as String),
);

Map<String, dynamic> _$TrophyToJson(_Trophy instance) => <String, dynamic>{
  'displayName': instance.displayName,
  'description': instance.description,
  'isAchieved': instance.isAchieved,
  'coloredIcon': instance.coloredIcon,
  'uncoloredIcon': instance.uncoloredIcon,
  'achievedAt': instance.achievedAt?.toIso8601String(),
};
