import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophies_tracker/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences sharedPreferences;
  
  static const String _themeKey = 'pref_theme_mode';
  static const String _localeKey = 'pref_locale';

  SettingsRepositoryImpl({required this.sharedPreferences});

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await sharedPreferences.setString(_themeKey, themeMode.name);
  }

  @override
  ThemeMode getThemeMode() {
    final themeName = sharedPreferences.getString(_themeKey);
    if (themeName == null) return ThemeMode.system;
    
    return ThemeMode.values.firstWhere(
      (e) => e.name == themeName,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Future<void> setLocale(Locale locale) async {
    await sharedPreferences.setString(_localeKey, locale.languageCode);
  }

  @override
  Locale getLocale() {
    final languageCode = sharedPreferences.getString(_localeKey);
    if (languageCode == null) return const Locale('en');
    
    return Locale(languageCode);
  }
}
