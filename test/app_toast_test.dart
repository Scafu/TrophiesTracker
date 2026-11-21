import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/widgets/app_toast.dart';

Widget _host(void Function(BuildContext context) onPressed) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => onPressed(context),
          child: const Text('go'),
        ),
      ),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

double _contrast(Color a, Color b) {
  final light = a.computeLuminance() > b.computeLuminance() ? a : b;
  final dark = identical(light, a) ? b : a;
  return (light.computeLuminance() + 0.05) / (dark.computeLuminance() + 0.05);
}

void main() {
  testWidgets('shows the message with the icon of its kind', (tester) async {
    await tester.pumpWidget(
      _host(
        (context) =>
            showAppToast(context, 'Sync failed', kind: ToastKind.error),
      ),
    );

    await tester.tap(find.text('go'));
    await _settle(tester);

    expect(find.text('Sync failed'), findsOneWidget);
    expect(find.byIcon(Symbols.error_rounded), findsOneWidget);
  });

  testWidgets('a new toast replaces the one on screen', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      _host((context) => showAppToast(context, 'Toast ${++count}')),
    );

    await tester.tap(find.text('go'));
    await _settle(tester);
    await tester.tap(find.text('go'));
    await _settle(tester);

    expect(find.text('Toast 1'), findsNothing);
    expect(find.text('Toast 2'), findsOneWidget);
  });

  testWidgets('it goes away by itself', (tester) async {
    await tester.pumpWidget(
      _host(
        (context) => showAppToast(
          context,
          'Bye',
          duration: const Duration(milliseconds: 800),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await _settle(tester);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Bye'), findsNothing);
  });

  for (final dark in [true, false]) {
    test(
      'icon tints have 3:1 contrast on the ${dark ? 'dark' : 'light'} theme',
      () {
        final scheme = dark
            ? const ColorScheme.dark(
                surfaceContainerHigh: Color(0xFF1E1E28),
                primary: Color(0xFF3B82F6),
                error: Color(0xFFEF4444),
              )
            : const ColorScheme.light(
                surfaceContainerHigh: Colors.white,
                primary: Color(0xFF2563EB),
                error: Color(0xFFDC2626),
              );
        final theme = ThemeData(colorScheme: scheme);

        for (final kind in ToastKind.values) {
          expect(
            _contrast(toastTint(kind, theme), scheme.surfaceContainerHigh),
            greaterThanOrEqualTo(3),
            reason: '$kind',
          );
        }
      },
    );
  }
}
