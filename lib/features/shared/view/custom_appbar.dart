import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Custom App Bar shared between [GameView] [ExploreView] [StatsView]
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Navigation Shell of [CustomNavigationBar] use to share the same components
  final StatefulNavigationShell shell;

  /// Constructor of [CustomAppBar] with his shell
  const CustomAppBar({required this.shell, super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      centerTitle: true,
      title: switch (shell.currentIndex) {
        0 => const Text(
          "Your Games",
          style: TextStyle(fontFamily: 'BBH Sans Bartle', fontSize: 20),
        ),
        1 => const Text(
          "Explore",
          style: TextStyle(fontFamily: 'BBH Sans Bartle', fontSize: 20),
        ),
        2 => const Text(
          "Stats",
          style: TextStyle(fontFamily: 'BBH Sans Bartle', fontSize: 20),
        ),
        _ => const Text(
          "TrophiesTracker",
          style: TextStyle(fontFamily: 'BBH Sans Bartle', fontSize: 20),
        ),
      },
      elevation: 0,
      actions: switch (shell.currentIndex) {
        /*0 => [
          IconButton(
            onPressed: () {
              context.pushNamed('settings');
            },
            icon: const Icon(Symbols.settings),
          ),
        ],*/
        1 => [
          IconButton(
            icon: const Icon(Symbols.help),
            onPressed: () => showModalBottomSheet<void>(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh,
              context: context,

              builder: (context) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Important Information",
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(height: 16),
                    Text(
                      textAlign: TextAlign.center,
                      "The games currently in the database are fetched from the IStoreService API (Steam). Not all games are available yet.\nPlease contact me if you'd like a game to be added.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall!.color!.withAlpha(200),
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],

        _ => null,
      },
    );
  }
}
