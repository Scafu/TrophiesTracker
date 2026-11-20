import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/explore_page_tiles.dart';

void main() {
  test('the typed part is found whatever its case', () {
    final parts = splitAtMatch('Hollow Knight: Silksong', 'knight');

    expect(parts, (before: 'Hollow ', match: 'Knight', after: ': Silksong'));
  });

  test('without a match the whole name stays as it is', () {
    expect(splitAtMatch('Portal 2', 'hades'), (
      before: 'Portal 2',
      match: '',
      after: '',
    ));
    expect(splitAtMatch('Portal 2', ''), (
      before: 'Portal 2',
      match: '',
      after: '',
    ));
  });

  test('accented capitals do not throw the match off', () {
    final parts = splitAtMatch('İstanbul', 'stan');

    expect(parts, (before: 'İ', match: 'stan', after: 'bul'));
  });
}
