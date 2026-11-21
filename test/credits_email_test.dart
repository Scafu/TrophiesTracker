import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/account/presentation/ui/credits_page.dart';

/// A button that writes to the developer with [launch] standing in for the
/// phone's mail app.
Widget _host(Future<bool> Function(Uri) launch) => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (context) => TextButton(
        onPressed: () => writeToDeveloper(context, launch: launch),
        child: const Text('write'),
      ),
    ),
  ),
);

void main() {
  final copied = <String>[];

  setUp(() {
    copied.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('a mail app opens with a message to the developer', (
    tester,
  ) async {
    Uri? opened;
    await tester.pumpWidget(
      _host((uri) async {
        opened = uri;
        return true;
      }),
    );

    await tester.tap(find.text('write'));
    await tester.pumpAndSettle();

    expect(opened, Uri.parse('mailto:$developerEmail'));
    expect(copied, isEmpty);
    expect(find.textContaining('No email app'), findsNothing);
  });

  testWidgets('with no mail app the address is copied and the user is told', (
    tester,
  ) async {
    await tester.pumpWidget(_host((_) async => false));

    await tester.tap(find.text('write'));
    await tester.pumpAndSettle();

    expect(copied, [developerEmail]);
    expect(
      find.text('No email app found. Address copied: $developerEmail'),
      findsOneWidget,
    );
  });

  testWidgets('a launcher that throws is handled like having no mail app', (
    tester,
  ) async {
    await tester.pumpWidget(_host((_) async => throw Exception('no handler')));

    await tester.tap(find.text('write'));
    await tester.pumpAndSettle();

    expect(copied, [developerEmail]);
    expect(find.textContaining('No email app found'), findsOneWidget);
  });
}
