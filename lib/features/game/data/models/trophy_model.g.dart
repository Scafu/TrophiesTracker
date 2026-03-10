// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trophy_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrophyModel _$TrophyModelFromJson(Map<String, dynamic> json) => _TrophyModel(
  apiName: json['apiName'] as String,
  displayName: json['displayName'] as String,
  description: json['description'] as String?,
  icon: json['icon'] as String?,
  coloredIcon: json['coloredIcon'] as String?,
  isAchieved: json['isAchieved'] as bool? ?? false,
  achievedAt: json['achievedAt'] == null
      ? null
      : DateTime.parse(json['achievedAt'] as String),
);

Map<String, dynamic> _$TrophyModelToJson(_TrophyModel instance) =>
    <String, dynamic>{
      'apiName': instance.apiName,
      'displayName': instance.displayName,
      'description': instance.description,
      'icon': instance.icon,
      'coloredIcon': instance.coloredIcon,
      'isAchieved': instance.isAchieved,
      'achievedAt': instance.achievedAt?.toIso8601String(),
    };
