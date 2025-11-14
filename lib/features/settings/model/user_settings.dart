import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

/// User Settings Model *temporary*
@freezed
abstract class UserSettings with _$UserSettings {
  /// Constructor with ThemeChosen ...
  const factory UserSettings({
    required ThemeMode themeChosen,
    bool? isHighContrastOn,
  }) = _UserSettings;

  /// User Settings traslation Json -> User Settings
  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}
