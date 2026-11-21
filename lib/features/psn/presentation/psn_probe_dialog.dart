import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/di/injection_container.dart';
import 'package:trophies_tracker/features/psn/presentation/psn_login_probe.dart';

/// Runs the PlayStation probe and shows what it found. Development only.
Future<void> showPsnProbe(BuildContext context) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  final report = await sl<PsnLoginProbe>().run();
  navigator.pop();
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (context) {
      final colors = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(
          report.ok ? 'PlayStation: all steps worked' : 'PlayStation: stopped',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final step in report.steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        step.ok
                            ? Symbols.check_circle_rounded
                            : Symbols.error_rounded,
                        size: 20,
                        color: step.ok ? colors.primary : colors.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.label,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (step.detail.isNotEmpty)
                              Text(
                                step.detail,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
