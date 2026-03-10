// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameModel _$GameModelFromJson(Map<String, dynamic> json) => _GameModel(
  appId: (json['appId'] as num).toInt(),
  name: json['name'] as String,
  headerImage: json['headerImage'] as String?,
  libraryImage: json['libraryImage'] as String?,
  publisher:
      (json['publisher'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  trophies:
      (json['trophies'] as List<dynamic>?)
          ?.map((e) => TrophyModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  description: json['description'] as String?,
  addedAt: json['addedAt'] == null
      ? null
      : DateTime.parse(json['addedAt'] as String),
  platformSource: json['platformSource'] as String? ?? "local",
  isSynced: json['isSynced'] as bool? ?? false,
);

Map<String, dynamic> _$GameModelToJson(_GameModel instance) =>
    <String, dynamic>{
      'appId': instance.appId,
      'name': instance.name,
      'headerImage': instance.headerImage,
      'libraryImage': instance.libraryImage,
      'publisher': instance.publisher,
      'trophies': instance.trophies,
      'description': instance.description,
      'addedAt': instance.addedAt?.toIso8601String(),
      'platformSource': instance.platformSource,
      'isSynced': instance.isSynced,
    };
