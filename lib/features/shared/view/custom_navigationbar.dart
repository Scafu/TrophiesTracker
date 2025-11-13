import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_app_tracker/core/providers/state_provider.dart';

class CustomNavigationBar extends ConsumerWidget {
  final StatefulNavigationShell shell;
  CustomNavigationBar({required this.shell, super.key});

  final List<NavigationDestination> navList = [
    NavigationDestination(
      icon: Icon(Icons.sports_esports_outlined),
      label: "Games",
      selectedIcon: Icon(Icons.sports_esports),
    ),
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      label: "Explore",
      selectedIcon: Icon(Icons.explore),
    ),
    NavigationDestination(
      icon: Icon(Icons.query_stats_outlined),
      label: "Stats",
      selectedIcon: Icon(Icons.query_stats),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeScreen = ref.watch(activeScreenProvider);
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color.fromARGB(0, 255, 255, 255), width: 1.0),
        ),
      ),
      child: NavigationBar(
        indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
        elevation: 2.0,
        selectedIndex: activeScreen.index,
        onDestinationSelected: (index) {
          ref
              .read(activeScreenProvider.notifier)
              .setScreen(MainScreen.values[index]);
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
        destinations: navList,
      ),
    );
  }
}
