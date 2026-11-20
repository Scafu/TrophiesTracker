import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_remote_data_source.dart';
import 'package:trophies_tracker/features/game/data/models/game_model.dart';

/// Builds a data source whose `/playerAchievements` call answers with
/// [playerStatus] / [playerBody]; `/game` and `/achievements` always succeed.
GameRemoteDataSourceImpl _dataSource(int playerStatus, String playerBody) {
  final client = MockClient((request) async {
    switch (request.url.path) {
      case '/game':
        return http.Response('{"1":{"success":true,"data":{"name":"G"}}}', 200);
      case '/achievements':
        return http.Response(
          '{"game":{"availableGameStats":{"achievements":'
          '[{"name":"a","displayName":"A"}]}}}',
          200,
        );
      default:
        return http.Response(playerBody, playerStatus);
    }
  });
  return GameRemoteDataSourceImpl(
    client: client,
    proxyBaseUrl: 'https://x.test',
  );
}

void main() {
  test('catalog pages are followed until there are no more results', () async {
    final pages = {
      '0':
          '{"response":{"apps":[{"appid":1,"name":"A"},{"appid":2,"name":""}],'
          '"have_more_results":true,"last_appid":2}}',
      '2': '{"response":{"apps":[{"appid":3,"name":"C"}]}}',
    };
    final ds = GameRemoteDataSourceImpl(
      client: MockClient(
        (request) async => http.Response(
          pages[request.url.queryParameters['last_appid']]!,
          200,
        ),
      ),
      proxyBaseUrl: 'https://x.test',
    );

    final result = await ds.fetchSteamCatalogOnline();

    expect(result.apps.map((app) => app['appid']), [1, 3]);
    expect(result.hasMore, isFalse);
  });

  test('a catalog page without a response ends the download', () async {
    final ds = GameRemoteDataSourceImpl(
      client: MockClient((request) async => http.Response('{}', 200)),
      proxyBaseUrl: 'https://x.test',
    );

    final result = await ds.fetchSteamCatalogOnline();

    expect(result.apps, isEmpty);
    expect(result.hasMore, isFalse);
  });

  test(
    'a page that claims more results without advancing ends the download',
    () async {
      var requests = 0;
      final ds = GameRemoteDataSourceImpl(
        client: MockClient((request) async {
          requests++;
          return http.Response(
            '{"response":{"apps":[],"have_more_results":true,"last_appid":0}}',
            200,
          );
        }),
        proxyBaseUrl: 'https://x.test',
      );

      await ds.fetchSteamCatalogOnline();

      expect(requests, 1);
    },
  );

  test(
    'the token travels in the Authorization header, never in the URL',
    () async {
      const token = 'a+b/c=&d';
      final received = <String>[];
      final client = MockClient((request) async {
        expect(request.url.toString(), isNot(contains('token')));
        final sent = request.headers['Authorization'];
        if (sent != null) received.add(sent);
        return http.Response(request.url.path == '/library' ? '[]' : '{}', 200);
      });
      final ds = GameRemoteDataSourceImpl(
        client: client,
        proxyBaseUrl: 'https://x.test',
      );

      await ds.fetchGamesFromSteamAccount(token);
      await ds
          .getGameByIdRemote(1, token: token)
          .catchError((_) => const GameModel(appId: 1, name: ''));

      expect(received, ['Bearer $token', 'Bearer $token']);
    },
  );

  test('token + playerAchievements non-200 throws instead of all-locked', () {
    final ds = _dataSource(403, 'forbidden');
    expect(ds.getGameByIdRemote(1, token: 't'), throwsException);
  });

  test('token + playerAchievements 200 without achievements throws', () {
    final ds = _dataSource(200, '{"playerstats":{"success":false}}');
    expect(ds.getGameByIdRemote(1, token: 't'), throwsException);
  });

  test('token + valid playerAchievements keeps the unlocked state', () async {
    final ds = _dataSource(
      200,
      '{"playerstats":{"achievements":'
      '[{"apiname":"a","achieved":1,"unlocktime":1700000000}]}}',
    );
    final game = await ds.getGameByIdRemote(1, token: 't');
    expect(game.trophies.single.isAchieved, isTrue);
  });

  test('no token never needs playerAchievements', () async {
    final ds = _dataSource(403, 'forbidden');
    final game = await ds.getGameByIdRemote(1);
    expect(game.trophies.single.isAchieved, isFalse);
  });

  group('covers', () {
    const placeholder =
        'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1/library_600x900_2x.jpg';
    const real = 'https://x.test/1/abc/library_capsule_2x.jpg';

    GameRemoteDataSourceImpl source(
      http.Response Function(http.Request request) covers,
    ) {
      return GameRemoteDataSourceImpl(
        client: MockClient((request) async {
          final appid = request.url.queryParameters['appid'];
          switch (request.url.path) {
            case '/library':
              return http.Response(
                '[{"appId":1,"name":"A"},{"appId":2,"name":"B"}]',
                200,
              );
            case '/game':
              return http.Response(
                '{"$appid":{"success":true,"data":{"name":"G"}}}',
                200,
              );
            case '/achievements':
              return http.Response(
                '{"game":{"availableGameStats":{"achievements":'
                '[{"name":"a","displayName":"A"}]}}}',
                200,
              );
            case '/playerAchievements':
              return http.Response(
                '{"playerstats":{"achievements":[{"apiname":"a","achieved":1}]}}',
                200,
              );
            default:
              return covers(request);
          }
        }),
        proxyBaseUrl: 'https://x.test',
      );
    }

    test('a game gets the cover Steam really serves', () async {
      final ds = source((_) => http.Response('{"1":{"library":"$real"}}', 200));

      expect((await ds.getGameByIdRemote(1)).libraryImage, real);
    });

    test('the default cover stays when the lookup fails', () async {
      for (final failing in [
        http.Response('down', 500),
        http.Response('not json', 200),
      ]) {
        final ds = source((_) => failing);

        expect((await ds.getGameByIdRemote(1)).libraryImage, placeholder);
      }
    });

    test('a library sync looks every cover up in one request', () async {
      final asked = <String>[];
      final ds = source((request) {
        asked.add(request.url.queryParameters['ids']!);
        return http.Response('{"2":{"library":"$real"}}', 200);
      });

      final games = await ds.fetchGamesFromSteamAccount('t');

      expect(asked, ['1,2']);
      expect(games.firstWhere((g) => g.appId == 2).libraryImage, real);
      expect(games.firstWhere((g) => g.appId == 1).libraryImage, placeholder);
    });
  });
}
