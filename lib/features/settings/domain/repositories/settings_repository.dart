import 'package:flutter/material.dart';

abstract class SettingsRepository {
  Future<void> setThemeMode(ThemeMode themeMode);
  ThemeMode getThemeMode();
  
  Future<void> setLocale(Locale locale);
  Locale getLocale();
}
