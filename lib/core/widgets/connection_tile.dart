import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A line of text under the name of a connection.
class ConnectionLine {
  final String text;

  /// Drawn in the error color, for what needs the user's attention.
  final bool warn;

  const ConnectionLine(this.text, {this.warn = false});
}

/// A linked service as one flat row: a round avatar, its name, up to a few
/// lines of status and, at the end, the actions that fit in the row.
///
/// While [busy] a thin bar runs under the text: with a [progress] from 0 to 1
/// it fills up, without one it has no end. A [footnote] goes last, under the
/// bar, in small print.
class ConnectionTile extends StatelessWidget {
  final IconData icon;

  /// A picture of the account to show instead of [icon].
  final String? avatarUrl;
  final String title;
  final List<ConnectionLine> lines;
  final bool busy;
  final double? progress;
  final String? footnote;
  final List<Widget> actions;

  const ConnectionTile({
    super.key,
    required this.icon,
    this.avatarUrl,
    required this.title,
    this.lines = const [],
    this.busy = false,
    this.progress,
    this.footnote,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatar = avatarUrl;

    final row = Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: colors.primary.withValues(alpha: 0.1),
          backgroundImage: avatar == null || avatar.isEmpty
              ? null
              : NetworkImage(avatar),
          child: avatar == null || avatar.isEmpty
              ? Icon(icon, size: 22, color: colors.primary)
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    line.text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: line.warn ? colors.error : colors.onSurfaceVariant,
                      fontWeight: line.warn ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              if (busy)
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
        ...actions,
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
      child: footnote == null
          ? row
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                row,
                Padding(
                  padding: const EdgeInsets.only(left: 54, top: 6, right: 8),
                  child: Text(
                    footnote!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// A small tonal button for the end of a row, like "Link" or "Log in again".
/// With no [onPressed] it is disabled; with [busy] it shows a spinner.
class ConnectionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  const ConnectionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilledButton.tonal(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.compact,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

/// The round sync button of a row. Disabled while [busy].
class ConnectionSyncButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool busy;

  const ConnectionSyncButton({
    super.key,
    required this.onPressed,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Sync library',
      onPressed: busy ? null : onPressed,
      icon: const Icon(Symbols.sync_rounded),
    );
  }
}

/// The menu of a row, with "Unlink". Disabled while [enabled] is false.
class ConnectionMenu extends StatelessWidget {
  final VoidCallback onLogout;
  final bool enabled;

  const ConnectionMenu({
    super.key,
    required this.onLogout,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'More',
      enabled: enabled,
      icon: const Icon(Symbols.more_vert_rounded),
      itemBuilder: (context) => [
        PopupMenuItem<void>(onTap: onLogout, child: const Text('Unlink')),
      ],
    );
  }
}
