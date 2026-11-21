import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trophies_tracker/core/widgets/app_toast.dart';
import 'package:trophies_tracker/core/widgets/section_label.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/account/presentation/ui/legal_disclaimer.dart';
import 'package:trophies_tracker/features/account/presentation/ui/steam_connection_tile.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/psn/presentation/psn_connection_tile.dart';
import 'package:trophies_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:trophies_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:url_launcher/url_launcher.dart';

/// The settings page: the linked accounts as a short list of rows, then the
/// theme and the information about the app.
class AccountPage extends StatefulWidget {
  /// Creates a new [AccountPage].
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _hasAutoSynced = false;

  void _trySyncIfNeeded(BuildContext context) {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/stats'),
        ),
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: BlocConsumer<AccountCubit, AccountState>(
        listener: (context, state) {
          state.maybeWhen(
            authenticated: (_) => _trySyncIfNeeded(context),
            error: (message) =>
                showAppToast(context, message, kind: ToastKind.error),
            orElse: () {},
          );
        },
        builder: (context, state) {
          state.maybeWhen(
            authenticated: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _trySyncIfNeeded(context);
              });
            },
            orElse: () {},
          );

          return ListView(
            children: [
              const SectionLabel('Connections'),
              const SteamConnectionTile(),
              Divider(
                height: 1,
                indent: 74,
                endIndent: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              const PsnConnectionTile(),
              const SectionLabel('Appearance'),
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
              const SectionLabel('About'),
              const _VersionTile(),
              _SettingsTile(
                icon: Symbols.description_rounded,
                title: 'Licenses',
                onTap: () => showLicensePage(context: context),
              ),
              _SettingsTile(
                icon: Symbols.gavel_rounded,
                title: 'Legal disclaimer',
                onTap: () => showLegalDisclaimer(context),
              ),
              _SettingsTile(
                icon: Icons.policy_outlined,
                title: 'Privacy Policy',
                onTap: () => launchUrl(
                  Uri.parse(
                    'https://trophiestracker.alessandro-mazzariol04.workers.dev/policy',
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
              Center(
                child: Text(
                  'Trophies Tracker',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

/// The version of the app, read from the build (`pubspec.yaml`), so it never
/// disagrees with the release. Until it is read, or if it cannot be, the row
/// shows no number.
class _VersionTile extends StatelessWidget {
  const _VersionTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        return _SettingsTile(
          icon: Symbols.info_rounded,
          title: 'Version',
          subtitle: info == null
              ? null
              : '${info.version} (${info.buildNumber})',
        );
      },
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: SizedBox(
        width: 40,
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
