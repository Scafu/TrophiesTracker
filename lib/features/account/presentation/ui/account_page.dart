import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';
import 'package:trophies_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:trophies_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:url_launcher/url_launcher.dart';

/// The main account page, displaying user profile, sync controls, and app settings.
class AccountPage extends StatefulWidget {
  /// Creates a new [AccountPage].
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _hasAutoSynced = false;

  void _trySyncIfNeeded(BuildContext context, String token) {
    final uri = GoRouterState.of(context).uri;
    if (uri.queryParameters['sync'] == 'true' && !_hasAutoSynced) {
      setState(() => _hasAutoSynced = true);
      context.read<GameCubit>().fetchGamesFromSteamAccount();
    }
  }

  String _getThemeName(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System Default',
    ThemeMode.light => 'Light Mode',
    ThemeMode.dark => 'Dark Mode',
  };

  void _showThemeDialog(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: RadioGroup<ThemeMode>(
          groupValue: settingsCubit.state.themeMode,
          onChanged: (value) {
            if (value != null) {
              settingsCubit.setThemeMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values
                .map(
                  (mode) => RadioListTile<ThemeMode>(
                    title: Text(_getThemeName(mode)),
                    value: mode,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Account'),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/stats'),
        ),
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AccountCubit, AccountState>(
            listener: (context, state) {
              state.maybeWhen(
                authenticated: (user) =>
                    _trySyncIfNeeded(context, user.token ?? ''),
                error: (message) {
                  if (message == '429') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Too many requests. Try again later."),
                      ),
                    );
                  }
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<GameCubit, GameState>(
            listener: (context, state) {
              state.maybeWhen(
                syncSuccess: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Steam library synced successfully!'),
                  ),
                ),
                error: (message) => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message))),
                orElse: () {},
              );
            },
          ),
        ],
        child: Stack(
          children: [
            BlocBuilder<AccountCubit, AccountState>(
              builder: (context, state) {
                state.maybeWhen(
                  authenticated: (user) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _trySyncIfNeeded(context, user.token ?? '');
                    });
                  },
                  orElse: () {},
                );

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _AccountCard(state: state),
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'PREFERENCES'),
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          return _SettingsTile(
                            icon: Symbols.palette_rounded,
                            title: 'App Theme',
                            subtitle: _getThemeName(settingsState.themeMode),
                            onTap: () => _showThemeDialog(context),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const _SectionTitle(title: 'ABOUT'),
                      const _SettingsTile(
                        icon: Symbols.info_rounded,
                        title: 'Version',
                        subtitle: '1.0.1',
                      ),
                      _SettingsTile(
                        icon: Symbols.description_rounded,
                        title: 'Licenses',
                        onTap: () => showLicensePage(context: context),
                      ),
                      _SettingsTile(
                        icon: Icons.policy_outlined,
                        title: 'Privacy Policy',
                        onTap: () => launchUrl(
                          Uri.parse(
                            'https://trophiestracker.alessandro-mazzariol04.workers.dev/privacy-policy',
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: Symbols.groups_rounded,
                        title: 'Credits',
                        onTap: () => context.push('/credits'),
                      ),
                      const SizedBox(height: 25),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: InkWell(
                          onTap: () => launchUrl(
                            Uri.parse('https://ko-fi.com/alessandromazzariol'),
                            mode: LaunchMode.inAppBrowserView,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/support_me_on_kofi_beige.png',
                            height: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Trophies Tracker',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                                letterSpacing: 1.2,
                              ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
            BlocBuilder<GameCubit, GameState>(
              builder: (context, state) => state.maybeWhen(
                loading: () => Positioned.fill(
                  child: ColoredBox(
                    color: colorScheme.surface.withValues(alpha: 0.85),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 24),
                          Text(
                            'Syncing Steam Library...',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the user's account information inside a styled card.
///
/// Shows a loading indicator while authentication is in progress,
/// the user's profile when authenticated, or a guest view otherwise.
class _AccountCard extends StatelessWidget {
  /// The current [AccountState] used to determine which view to render.
  final AccountState state;

  const _AccountCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: state.maybeWhen(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(),
          ),
        ),
        authenticated: (user) => Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Icon(
                      Symbols.person_rounded,
                      size: 50,
                      color: colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.personaName ?? 'Steam User',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Steam ID: ${user.steamId}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  context.read<GameCubit>().fetchGamesFromSteamAccount(),
              icon: const Icon(Symbols.sync_rounded, size: 18),
              label: const Text('Sync Library'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.read<AccountCubit>().logout(),
              icon: const Icon(Symbols.logout_rounded, size: 18),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                side: BorderSide(
                  color: colorScheme.error.withValues(alpha: 0.5),
                ),
                foregroundColor: colorScheme.error,
              ),
            ),
          ],
        ),
        orElse: () => Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Symbols.person_rounded,
                size: 50,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Guest User',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Steam ID: Not Linked',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<AccountCubit>().login(),
              icon: const Icon(Symbols.link_rounded, size: 18),
              label: const Text('Link Steam Account'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A styled uppercase section title used to group settings entries.
class _SectionTitle extends StatelessWidget {
  /// The label displayed as the section header.
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

/// A single settings row with an icon, title, optional subtitle, and tap handler.
class _SettingsTile extends StatelessWidget {
  /// The icon displayed on the leading side of the tile.
  final IconData icon;

  /// The primary label of the settings entry.
  final String title;

  /// An optional secondary description shown below [title].
  final String? subtitle;

  /// Called when the tile is tapped. If null, no trailing arrow is shown.
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.bodySmall)
          : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right_rounded, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
