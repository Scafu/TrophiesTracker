import 'package:flutter/material.dart';

/// What a page shows in the middle when it has nothing yet: a round icon, a
/// title, a line of explanation and the actions to take. Every empty page uses
/// it, so they all look the same.
///
/// It centers itself in the space it is given. A page under a floating bar
/// leaves room for the bar around it.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  /// The buttons under the text, most important first. See [EmptyStateAction].
  final List<Widget> actions;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Icon(icon, size: 40, color: colors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (actions.isNotEmpty) const SizedBox(height: 24),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            actions[i],
          ],
        ],
      ),
    );
  }
}

/// A button of an [EmptyState]: the same size and shape on every page. With no
/// [onPressed] it is disabled.
class EmptyStateAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  const EmptyStateAction.primary({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : primary = true;

  const EmptyStateAction.secondary({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : primary = false;

  static const _size = Size(220, 48);

  @override
  Widget build(BuildContext context) {
    final icon = Icon(this.icon, size: 20);
    final text = Text(label);

    return primary
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: text,
            style: FilledButton.styleFrom(
              minimumSize: _size,
              shape: const StadiumBorder(),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: text,
            style: OutlinedButton.styleFrom(
              minimumSize: _size,
              shape: const StadiumBorder(),
            ),
          );
  }
}
