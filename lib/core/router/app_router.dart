import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_tracker/core/di/injection_container.dart';
import 'package:trophies_tracker/core/router/game_route.dart';
import 'package:trophies_tracker/core/utils/splash/splash_screen.dart';
import 'package:trophies_tracker/core/widgets/app_navigation_bar.dart';
import 'package:trophies_tracker/features/account/presentation/ui/account_page.dart';
import 'package:trophies_tracker/features/account/presentation/ui/credits_page.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/details/ui/game_details_page.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/categories.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/category_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/category_page.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/explore_page.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/ui/game_page.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:trophies_tracker/features/stats/presentation/ui/stats_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Centralized routing configuration using [GoRouter].
class AppRouter {
  /// Static instance of [GoRouter] to be used in [MaterialApp.router].
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      final Uri uri = state.uri;
      final isCustomSchemeCallback =
          uri.scheme == 'trophiestracker' && uri.host == 'stats';
      if (isCustomSchemeCallback || uri.path == '/open') {
        return '/accounts?sync=true';
      }
      return null;
    },
    debugLogDiagnostics: kDebugMode,
    errorBuilder: (BuildContext context, GoRouterState state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: '/credits',
        builder: (BuildContext context, GoRouterState state) =>
            const CreditsPage(),
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return NoTransitionPage<void>(
                child: Scaffold(
                  extendBody: true,
                  body: SafeArea(bottom: false, child: navigationShell),
                  bottomNavigationBar: AppNavigationBar(
                    currentIndex: navigationShell.currentIndex,
                    onSelected: navigationShell.goBranch,
                  ),
                ),
              );
            },
        branches: <StatefulShellBranch>[
          _createBranch('/games', const GamePage()),
          _createBranch(
            '/explore',
            BlocProvider<ExploreCubit>(
              create: (_) => sl<ExploreCubit>(),
              child: const ExplorePage(),
            ),
          ),
          _createBranch(
            '/stats',
            BlocProvider<StatsCubit>(
              create: (_) => sl<StatsCubit>(),
              child: const StatsPage(),
            ),
          ),
        ],
      ),

      /// Route for the popular games of one Steam genre.
      GoRoute(
        name: 'category',
        path: '/category/:tagId',
        builder: (BuildContext context, GoRouterState state) {
          final category = categoryById(
            int.tryParse(state.pathParameters['tagId'] ?? '') ?? -1,
          );
          if (category == null) {
            return const Scaffold(
              body: Center(child: Text('Category not found')),
            );
          }

          return BlocProvider<CategoryCubit>(
            create: (_) => sl<CategoryCubit>()..load(category.tagId),
            child: CategoryPage(category: category),
          );
        },
      ),

      /// Route for the account page.
      GoRoute(
        path: '/accounts',
        builder: (BuildContext context, GoRouterState state) =>
            const AccountPage(),
      ),

      /// Route for offline game details.
      GoRoute(
        name: 'gameDetails',
        path: '/gamesDetails/:platform/:code/:fromExplorer',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final GameKey? game = gameKeyFromRoute(state.pathParameters);
          if (game == null) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: const Scaffold(
                body: Center(child: Text('Game not found')),
              ),
            );
          }
          final bool fromExplorer = bool.parse(
            state.pathParameters['fromExplorer']!,
          );

          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: BlocProvider<GameDetailsCubit>(
              create: (_) => sl<GameDetailsCubit>()..loadGameDetails(game),
              child: GameDetailsPage(gameKey: game, fromExplore: fromExplorer),
            ),
            transitionsBuilder:
                (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 200),
          );
        },
      ),
    ],
  );

  /// Helper method to create a [StatefulShellBranch] for the [StatefulShellRoute].
  static StatefulShellBranch _createBranch(String path, Widget child) {
    return StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          path: path,
          pageBuilder: (BuildContext context, GoRouterState state) =>
              NoTransitionPage<void>(child: child),
        ),
      ],
    );
  }
}
