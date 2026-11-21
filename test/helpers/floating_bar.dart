import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/widgets/tab_header.dart';

const _barKey = ValueKey('floating-bar');

/// Like the app shell: the body runs under a bar that hovers above the bottom
/// edge, so the scaffold reports the bar height as the bottom padding.
Widget underFloatingBar(Widget body) => MaterialApp(
  home: Scaffold(
    extendBody: true,
    body: body,
    bottomNavigationBar: const SizedBox(key: _barKey, height: 90),
  ),
);

/// Expects what lies from the top of [first] to the bottom of [last] to be
/// centered in the free space: under the tab header and above the bar.
void expectCenteredInFreeSpace(
  WidgetTester tester, {
  required Finder first,
  required Finder last,
}) {
  final header = tester.getRect(find.byType(TabHeader));
  final bar = tester.getRect(find.byKey(_barKey));
  final content = (tester.getRect(first).top + tester.getRect(last).bottom) / 2;

  expect(content, closeTo((header.bottom + bar.top) / 2, 1));
}

/// The button that holds the text [label].
Finder buttonLabeled(String label) => find
    .ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    )
    .first;
