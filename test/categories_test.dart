import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/categories.dart';

void main() {
  test('every category has its own tag and name', () {
    expect(
      gameCategories.map((c) => c.tagId).toSet(),
      hasLength(gameCategories.length),
    );
    expect(
      gameCategories.map((c) => c.name).toSet(),
      hasLength(gameCategories.length),
    );
  });

  test('a category is found by its tag, and an unknown tag is not', () {
    expect(categoryById(122)?.name, 'RPG');
    expect(categoryById(-1), isNull);
    expect(categoryById(3859), isNull);
  });

  test('the Worker accepts exactly the tags the app shows', () {
    final source = File('worker/src/index.js').readAsStringSync();
    final list = RegExp(
      r'CATEGORY_TAGS = new Set\(\[(.*?)\]\)',
      dotAll: true,
    ).firstMatch(source)!.group(1)!;
    final accepted = RegExp(r'"(\d+)"').allMatches(list).map((m) => m[1]!);

    expect(accepted.toSet(), {for (final c in gameCategories) '${c.tagId}'});
  });
}
