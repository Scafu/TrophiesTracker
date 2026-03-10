import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final StatefulNavigationShell shell;

  const AppAppBar({super.key, required this.shell});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      title: Text(_getAppBarTitle(shell.currentIndex)),
      centerTitle: true,
      elevation: 0,
      leading: _getLeading(context, shell.currentIndex),
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: [
        if (shell.currentIndex == 0)
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showDisclaimer(context),
          ),
        if (shell.currentIndex == 2)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/accounts'),
          ),
      ],
    );
  }

  void _showDisclaimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Legal Disclaimer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Trophies Tracker is an independent application and is NOT affiliated with, authorized, maintained, sponsored, or endorsed by Steam, Valve Corporation, or any other gaming platform. '
                'The app uses public APIs to provide its services.\n\n'
                'This application may be removed if requested by the respective rights holders. '
                'No revenue is generated from any copyrighted material displayed within this app (including game titles, icons, and descriptions). '
                'All trademarks and copyrights belong to their respective owners.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _getLeading(BuildContext context, int index) {
    /// Documentation: Listens to AccountCubit to reactively update the UI
    /// based on the user's authentication state.
    if (index == 0) {
      return BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          return state.maybeWhen(
            authenticated: (user) => IconButton(
              onPressed: () =>
                  context.read<GameCubit>().fetchGamesFromSteamAccount(),
              icon: Icon(Icons.sync_rounded),
            ),
            orElse: () => const SizedBox.shrink(),
          );
        },
      );
    } else {
      return null;
    }
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Your Games';
      case 1:
        return 'Explore';
      case 2:
        return 'Your Stats';
      default:
        return 'Trophy Tracker';
    }
  }
}
