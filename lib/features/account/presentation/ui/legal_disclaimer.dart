import 'package:flutter/material.dart';

/// Shows the legal disclaimer in a bottom sheet.
void showLegalDisclaimer(BuildContext context) {
  showModalBottomSheet<void>(
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Trophies Tracker is an independent application and is NOT affiliated with, authorized, maintained, sponsored, or endorsed by Steam, Valve Corporation, Sony Interactive Entertainment, PlayStation, or any other gaming platform. '
              'The app uses public APIs to provide its services.\n\n'
              'The PlayStation connection is unofficial: it works through the same login and services as Sony\'s own apps, which Sony has not published for third parties and may change or block at any time.\n\n'
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
