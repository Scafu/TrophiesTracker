// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
  appId: (json['appId'] as num).toInt(),
  name: json['name'] as String,
  publisher:
      (json['publisher'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  description: json['description'] as String?,
  headerImage: json['headerImage'] as String?,
  libraryImage: json['libraryImage'] as String?,
  addedAt: json['addedAt'] == null
      ? null
      : DateTime.parse(json['addedAt'] as String),
  trophies:
      (json['trophies'] as List<dynamic>?)
          ?.map((e) => Trophy.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
  'appId': instance.appId,
  'name': instance.name,
  'publisher': instance.publisher,
  'description': instance.description,
  'headerImage': instance.headerImage,
  'libraryImage': instance.libraryImage,
  'addedAt': instance.addedAt?.toIso8601String(),
  'trophies': instance.trophies,
};
