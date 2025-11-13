import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trophies_app_tracker/core/providers/game_provider.dart';
import 'package:trophies_app_tracker/features/explore/viewmodel/explore_view_model.dart';
import 'package:trophies_app_tracker/features/settings/viewmodel/settings_viewmodel.dart';
import 'package:trophies_app_tracker/features/shared/routing.dart';
import 'package:trophies_app_tracker/styles/themes.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(jsonDataProvider.future);
      ref.read(gameProviderOffline.notifier).fetchGamesFromDB();
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeModeState = ref.watch(settingsProvider);

    final router = Routing().createRouter();

    return themeModeState.when(
      data: (settings) {
        return MaterialApp.router(
          routerConfig: router,
          theme: Themes.lightTheme,
          darkTheme: Themes.darkTheme,
          themeMode: settings.themeChosen,
        );
      },
      loading: () {
        return MaterialApp.router(
          routerConfig: router,
          theme: Themes.lightTheme,
          darkTheme: Themes.darkTheme,
          themeMode: ThemeMode.light,
        );
      },
      error: (err, stack) {
        return MaterialApp.router(
          routerConfig: router,
          theme: Themes.lightTheme,
          darkTheme: Themes.darkTheme,
          themeMode: ThemeMode.light,
        );
      },
    );
  }
}
