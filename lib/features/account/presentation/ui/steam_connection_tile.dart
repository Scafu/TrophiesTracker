import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/utils/time/time_format.dart';
import 'package:trophies_tracker/core/widgets/connection_tile.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';

/// The Steam account as a row of the connections list: the account and the
/// last sync, with sync and log out when linked, or a button to link it.
class SteamConnectionTile extends StatelessWidget {
  const SteamConnectionTile({super.key});

  @override
  Widget build(BuildContext context) {
    final syncing = context.watch<GameCubit>().state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final lastSync = context.read<GameCubit>().lastSync;

    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const ConnectionTile(
            icon: Symbols.person_rounded,
            title: 'Steam',
            lines: [ConnectionLine('Checking your account…')],
            busy: true,
          ),
          authenticated: (user) {
            final name = user.personaName ?? 'Steam user';
            return ConnectionTile(
              icon: Symbols.person_rounded,
              avatarUrl: user.avatarUrl,
              title: 'Steam',
              lines: [
                ConnectionLine(
                  syncing
                      ? 'Syncing your library…'
                      : lastSync == null
                      ? name
                      : '$name · Synced ${formatRelative(lastSync)}',
                ),
              ],
              busy: syncing,
              actions: [
                ConnectionSyncButton(
                  busy: syncing,
                  onPressed: () =>
                      context.read<GameCubit>().fetchGamesFromSteamAccount(),
                ),
                ConnectionMenu(
                  enabled: !syncing,
                  onLogout: () => context.read<AccountCubit>().logout(),
                ),
              ],
            );
          },
          orElse: () => ConnectionTile(
            icon: Symbols.person_rounded,
            title: 'Steam',
            lines: const [ConnectionLine('Not linked')],
            actions: [
              ConnectionButton(
                label: 'Link',
                onPressed: () => context.read<AccountCubit>().login(),
              ),
            ],
          ),
        );
      },
    );
  }
}
