import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_remote_data_source.dart';
import 'package:trophies_tracker/features/game/data/repositories/game_repositories_impl.dart';

class _Remote extends Fake implements GameRemoteDataSource {
  _Remote(this.answers);

  final List<Map<String, double>> answers;
  int calls = 0;

  @override
  Future<Map<String, double>> fetchRarity(int appId) async =>
      answers[calls++ < answers.length ? calls - 1 : answers.length - 1];
}

class _NoLocal extends Fake implements GameLocalDataSource {}

GameRepositoriesImpl _repository(_Remote remote) =>
    GameRepositoriesImpl(localDataSource: _NoLocal(), remoteDataSource: remote);

void main() {
  group('data source', () {
    GameRemoteDataSourceImpl source(http.Response Function() answer) =>
        GameRemoteDataSourceImpl(
          client: MockClient((request) async {
            expect(request.url.path, '/rarity');
            expect(request.url.queryParameters['appid'], '7');
            return answer();
          }),
          proxyBaseUrl: 'https://x.test',
        );

    test('reads the percentages and ignores what is not a number', () async {
      final ds = source(
        () => http.Response('{"A":12.5,"B":3,"C":"x","D":null}', 200),
      );

      expect(await ds.fetchRarity(7), {'A': 12.5, 'B': 3.0});
    });

    test('a failure is an empty map, never an error', () async {
      expect(
        await source(() => http.Response('down', 502)).fetchRarity(7),
        isEmpty,
      );
      expect(
        await source(() => http.Response('not json', 200)).fetchRarity(7),
        isEmpty,
      );
    });
  });

  group('repository', () {
    test('a successful lookup is remembered for the session', () async {
      final remote = _Remote([
        {'A': 1.0},
      ]);
      final repository = _repository(remote);

      expect(await repository.getRarity(7), {'A': 1.0});
      expect(await repository.getRarity(7), {'A': 1.0});
      expect(remote.calls, 1);
    });

    test('an empty answer is asked again next time', () async {
      final remote = _Remote([
        {},
        {'A': 1.0},
      ]);
      final repository = _repository(remote);

      expect(await repository.getRarity(7), isEmpty);
      expect(await repository.getRarity(7), {'A': 1.0});
      expect(remote.calls, 2);
    });
  });
}
