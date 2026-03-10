// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steam_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SteamUserModel _$SteamUserModelFromJson(Map<String, dynamic> json) =>
    _SteamUserModel(
      steamId: json['steamId'] as String,
      personaName: json['personaName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$SteamUserModelToJson(_SteamUserModel instance) =>
    <String, dynamic>{
      'steamId': instance.steamId,
      'personaName': instance.personaName,
      'avatarUrl': instance.avatarUrl,
      'token': instance.token,
    };
