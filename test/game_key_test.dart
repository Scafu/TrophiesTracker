import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/router/game_route.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';

void main() {
  group('GameKey', () {
    test('the same code on two platforms is two different games', () {
      expect(const GameKey(GamePlatform.psn, '7'), isNot(GameKey.steam('7')));
      expect(GameKey.steam('7'), const GameKey(GamePlatform.steam, '7'));
      expect(
        {GameKey.steam('7'), const GameKey(GamePlatform.psn, '7')},
        {GameKey.steam('7'), const GameKey(GamePlatform.psn, '7')},
      );
    });

    test('it prints as platform:code, which logs and tests can read', () {
      expect(GameKey.steam('620').toString(), 'steam:620');
      expect(
        const GameKey(GamePlatform.psn, 'NPWR1_00').toString(),
        'psn:NPWR1_00',
      );
    });
  });

  group('compareGameKeys', () {
    List<String> sorted(List<GameKey> keys) =>
        ([...keys]..sort(compareGameKeys)).map((k) => '$k').toList();

    test('Steam codes sort as numbers, not as text', () {
      expect(sorted([GameKey.steam('10'), GameKey.steam('9')]), [
        'steam:9',
        'steam:10',
      ]);
    });

    test('platforms come first, then the codes', () {
      expect(
        sorted([
          const GameKey(GamePlatform.psn, 'B'),
          GameKey.steam('5'),
          const GameKey(GamePlatform.psn, 'A'),
        ]),
        ['steam:5', 'psn:A', 'psn:B'],
      );
    });
  });

  group('game route', () {
    test('the parameters of a key give the same key back', () {
      for (final key in [
        GameKey.steam('620'),
        const GameKey(GamePlatform.psn, 'NPWR20188_00'),
      ]) {
        final params = gameRouteParams(key, fromExplorer: true);
        expect(params['fromExplorer'], 'true');
        expect(gameKeyFromRoute(params), key);
      }
    });

    test('a route that names no known platform or code is no game', () {
      expect(gameKeyFromRoute({'platform': 'xbox', 'code': '1'}), isNull);
      expect(gameKeyFromRoute({'code': '1'}), isNull);
      expect(gameKeyFromRoute({'platform': 'steam'}), isNull);
      expect(gameKeyFromRoute({'platform': 'steam', 'code': ''}), isNull);
    });
  });
}
