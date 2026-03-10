import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Per il feedback aptico
import 'package:go_router/go_router.dart';

class AppNavigationBar extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppNavigationBar({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),

      child: NavigationBar(
        animationDuration: const Duration(milliseconds: 350),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    if (index != shell.currentIndex) {
      HapticFeedback.lightImpact();
      shell.goBranch(index, initialLocation: index == shell.currentIndex);
    }
  }
}
