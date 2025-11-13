import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_app_tracker/features/explore/view/explore_view.dart';
import 'package:trophies_app_tracker/features/game/view/game_details_page.dart';
import 'package:trophies_app_tracker/features/game/view/game_details_page_offline.dart';
import 'package:trophies_app_tracker/features/game/view/game_view.dart';
import 'package:trophies_app_tracker/features/shared/view/custom_appbar.dart';
import 'package:trophies_app_tracker/features/shared/view/custom_navigationbar.dart';
import 'package:trophies_app_tracker/features/shared/route_observer.dart';
import 'package:trophies_app_tracker/features/stats/view/stats_screen.dart';

class Routing {
  GoRouter createRouter() {
    return GoRouter(
      observers: [routeObserver],
      initialLocation: '/games',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: CustomAppBar(shell: navigationShell),
              body: navigationShell,
              bottomNavigationBar: CustomNavigationBar(shell: navigationShell),
            );
          },
          branches: branchList,
        ),
        /*GoRoute(
          name: 'settings',
          path: '/settings',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              name: 'settings',
              child: SettingsView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
              transitionDuration: const Duration(milliseconds: 250),
            );
          },
        ),*/
        GoRoute(
          name: 'gameDetailsOffline',
          path: '/gamesOffline/:appId',
          pageBuilder: (context, state) {
            final extra = state.extra as Map;
            final appId = int.parse(state.pathParameters['appId']!);
            final heroTag = extra['heroTag'] as String;
            final disableHero = extra['disableHero'] as bool;
            return CustomTransitionPage(
              key: state.pageKey,
              child: GameDetailsPageOffline(
                gameAppId: appId,
                heroTag: heroTag,
                disableHero: disableHero,
              ),

              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    if (disableHero) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    }
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 250),
            );
          },
        ),
        GoRoute(
          name: 'gameDetails',
          path: '/games/:appId',
          pageBuilder: (context, state) {
            final appId = int.tryParse(state.pathParameters['appId']!);
            return CustomTransitionPage(
              key: state.pageKey,
              name: 'gameDetails',
              child: GameDetailsPage(appId: appId!),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
              transitionDuration: const Duration(milliseconds: 250),
            );
          },
        ),
      ],
    );
  }

  /// List of main screen in [Routing] of the APP
  ///
  /// They will share the same [CustomNavigationBar] and the same [CustomAppBar] component
  List<StatefulShellBranch> branchList = [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/games',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: GameView()),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) =>
              NoTransitionPage(child: ExploreView()),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StatsScreen()),
        ),
      ],
    ),
  ];
}
