import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/core/di/injection_container.dart' as di;
import 'package:trophies_tracker/core/router/app_router.dart';
import 'package:trophies_tracker/core/theme/themes.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:trophies_tracker/features/settings/presentation/cubit/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        /// Global Bloc to manage library state across the app.
        BlocProvider(create: (_) => di.sl<GameCubit>()..watchGames()),

        /// Global Bloc to manage account state and deep links.
        BlocProvider(create: (_) => di.sl<AccountCubit>()..checkStatus()),

        /// Global Bloc for app settings (Theme, Language).
        BlocProvider(create: (_) => di.sl<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Trophies Tracker',
            debugShowCheckedModeBanner: false,

            /// Centralized GoRouter instance.
            routerConfig: AppRouter.router,

            theme: Themes.lightTheme,
            darkTheme: Themes.darkTheme,
            themeMode: state.themeMode,
            locale: state.locale,

            builder: (context, child) {
              _applyGlobalSystemOverlayStyle(context);
              return child!;
            },
          );
        },
      ),
    );
  }

  void _applyGlobalSystemOverlayStyle(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }
}
