import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophies_app_tracker/features/settings/model/user_settings.dart';

final settingsProvider = AsyncNotifierProvider<SettingsProvider, UserSettings>(
  SettingsProvider.new,
);

class SettingsProvider extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('UserSettings'); // fixed typo

    if (jsonString != null) {
      try {
        return UserSettings.fromJson(json.decode(jsonString));
      } catch (e) {
        final systemTheme =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light;
        return UserSettings(themeChosen: systemTheme);
      }
    } else {
      final systemTheme =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
      return UserSettings(themeChosen: systemTheme);
    }
  }

  Future<void> changeTheme() async {
    final currentSettings = state.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    if (currentSettings == null) return;

    final newTheme = currentSettings.themeChosen == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    final updatedSettings = currentSettings.copyWith(themeChosen: newTheme);

    // Update the state
    state = AsyncValue.data(updatedSettings);

    // Save the updated settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'UserSettings',
      json.encode(updatedSettings.toJson()),
    );
  }
}
