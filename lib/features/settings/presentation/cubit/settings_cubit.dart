import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:trophies_tracker/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository repository;

  SettingsCubit(this.repository)
      : super(SettingsState(
          themeMode: repository.getThemeMode(),
          locale: repository.getLocale(),
        ));

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await repository.setThemeMode(themeMode);
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> setLocale(Locale locale) async {
    await repository.setLocale(locale);
    emit(state.copyWith(locale: locale));
  }
}
