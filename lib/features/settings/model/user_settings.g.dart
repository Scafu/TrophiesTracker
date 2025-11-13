// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      themeChosen: $enumDecode(_$ThemeModeEnumMap, json['themeChosen']),
      isHighContrastOn: json['isHighContrastOn'] as bool?,
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'themeChosen': _$ThemeModeEnumMap[instance.themeChosen]!,
      'isHighContrastOn': instance.isHighContrastOn,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};
