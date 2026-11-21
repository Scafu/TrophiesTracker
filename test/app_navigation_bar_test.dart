import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/theme/accent.dart';
import 'package:trophies_tracker/core/widgets/app_navigation_bar.dart';

Widget _host({
  int index = 0,
  required ValueChanged<int> onSelected,
  double textScale = 1,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme:
        theme ??
        ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(
      extendBody: true,
      bottomNavigationBar: AppNavigationBar(
        currentIndex: index,
        onSelected: onSelected,
      ),
    ),
  );
}

Color _labelColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!.color!;

double _contrast(Color a, Color b) {
  final light = a.computeLuminance() > b.computeLuminance() ? a : b;
  final dark = identical(light, a) ? b : a;
  return (light.computeLuminance() + 0.05) / (dark.computeLuminance() + 0.05);
}

void main() {
  testWidgets('every destination shows its label', (tester) async {
    await tester.pumpWidget(_host(onSelected: (_) {}));

    for (final label in ['Library', 'Explore', 'Stats']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('the selected destination has its own color', (tester) async {
    await tester.pumpWidget(_host(index: 1, onSelected: (_) {}));
    final theme = Theme.of(tester.element(find.text('Explore')));

    expect(_labelColor(tester, 'Explore'), accentColor(theme));
    expect(_labelColor(tester, 'Library'), theme.colorScheme.onSurfaceVariant);
    expect(_labelColor(tester, 'Stats'), theme.colorScheme.onSurfaceVariant);
  });

  testWidgets('the highlight capsule sits under the selected destination', (
    tester,
  ) async {
    for (final index in [0, 1, 2]) {
      await tester.pumpWidget(_host(index: index, onSelected: (_) {}));
      await tester.pumpAndSettle();

      final align = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(align.alignment, Alignment(index - 1.0, 0));
    }
  });

  testWidgets('tapping another destination reports it, the selected one not', (
    tester,
  ) async {
    final selected = <int>[];
    await tester.pumpWidget(_host(index: 0, onSelected: selected.add));

    await tester.tap(find.byIcon(Symbols.sports_esports_rounded));
    await tester.tap(find.byIcon(Symbols.explore_rounded));
    await tester.tap(find.byIcon(Symbols.bar_chart_rounded));

    expect(selected, [1, 2]);
  });

  testWidgets('every destination is announced to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(onSelected: (_) {}));

    for (final label in ['Library', 'Explore', 'Stats']) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
    handle.dispose();
  });

  testWidgets('the destinations fit a narrow phone without cutting a label', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(onSelected: (_) {}));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    for (final label in ['Library', 'Explore', 'Stats']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
      expect(paragraph.didExceedMaxLines, isFalse, reason: label);
    }
  });

  testWidgets('it does not overflow with large text', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(index: 1, onSelected: (_) {}, textScale: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets('labels have 4.5:1 contrast on the $brightness theme', (
      tester,
    ) async {
      final scheme = brightness == Brightness.dark
          ? const ColorScheme.dark(
              surfaceContainerHigh: Color(0xFF1E1E28),
              primary: Color(0xFF3B82F6),
              onSurfaceVariant: Color(0xFF94A3B8),
              onSurface: Color(0xFFF8FAFC),
            )
          : const ColorScheme.light(
              surfaceContainerHigh: Colors.white,
              primary: Color(0xFF2563EB),
              onSurfaceVariant: Color(0xFF64748B),
              onSurface: Color(0xFF0F172A),
            );
      await tester.pumpWidget(
        _host(
          index: 0,
          onSelected: (_) {},
          theme: ThemeData(colorScheme: scheme),
        ),
      );
      final bar = scheme.surfaceContainerHigh;
      final underHighlight = Color.alphaBlend(
        AppNavigationBar.highlightColor(scheme),
        bar,
      );

      expect(
        _contrast(_labelColor(tester, 'Library'), underHighlight),
        greaterThanOrEqualTo(4.5),
        reason: 'selected label on the highlight capsule',
      );
      expect(
        _contrast(_labelColor(tester, 'Explore'), bar),
        greaterThanOrEqualTo(4.5),
        reason: 'unselected label on the bar',
      );
    });
  }
}
