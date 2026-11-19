import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_remote_data_source.dart';
import 'package:trophies_tracker/features/game/data/repositories/game_repositories_impl.dart';

class _FakeLocal extends Fake implements GameLocalDataSource {
  _FakeLocal(this.lastAppId);

  final int lastAppId;
  final saved = <Map<String, dynamic>>[];

  @override
  Future<int> getLastCatalogAppId() async => lastAppId;

  @override
  Future<void> saveSteamCatalogToDb(List<Map<String, dynamic>> apps) async =>
      saved.addAll(apps);
}

typedef _Slice = ({
  List<Map<String, dynamic>> apps,
  int lastAppId,
  bool hasMore,
});

class _FakeRemote extends Fake implements GameRemoteDataSource {
  _FakeRemote([_Slice Function(int startFromAppId)? slice])
    : _slice = slice ?? ((_) => _single);

  static const _Slice _single = (
    apps: [
      {'appid': 600, 'name': 'New'},
    ],
    lastAppId: 600,
    hasMore: false,
  );

  final _Slice Function(int startFromAppId) _slice;
  final startedFrom = <int>[];

  @override
  Future<_Slice> fetchSteamCatalogOnline({
    int? maxChunks,
    int startFromAppId = 0,
  }) async {
    startedFrom.add(startFromAppId);
    return _slice(startFromAppId);
  }
}

void main() {
  test('a populated catalog resumes from the highest saved appId', () async {
    final local = _FakeLocal(500);
    final remote = _FakeRemote();

    await GameRepositoriesImpl(
      localDataSource: local,
      remoteDataSource: remote,
    ).syncSteamCatalog();
    await pumpEventQueue();

    expect(remote.startedFrom, [500]);
    expect(local.saved.single['appid'], 600);
  });

  test('an empty catalog is downloaded from the start', () async {
    final local = _FakeLocal(0);
    final remote = _FakeRemote();

    await GameRepositoriesImpl(
      localDataSource: local,
      remoteDataSource: remote,
    ).syncSteamCatalog();

    expect(remote.startedFrom, [0]);
    expect(local.saved.single['appid'], 600);
  });

  test('the rest of the catalog is saved slice by slice', () async {
    final local = _FakeLocal(500);
    final remote = _FakeRemote(
      (start) => start == 500
          ? (
              apps: [
                {'appid': 601, 'name': 'A'},
              ],
              lastAppId: 601,
              hasMore: true,
            )
          : (
              apps: [
                {'appid': 700, 'name': 'B'},
              ],
              lastAppId: 700,
              hasMore: false,
            ),
    );

    await GameRepositoriesImpl(
      localDataSource: local,
      remoteDataSource: remote,
    ).syncSteamCatalog();
    await pumpEventQueue();

    expect(remote.startedFrom, [500, 601]);
    expect(local.saved.map((app) => app['appid']), [601, 700]);
  });

  test('a slice that does not advance ends the download', () async {
    final remote = _FakeRemote(
      (start) => (apps: const [], lastAppId: start, hasMore: true),
    );

    await GameRepositoriesImpl(
      localDataSource: _FakeLocal(500),
      remoteDataSource: remote,
    ).syncSteamCatalog();
    await pumpEventQueue();

    expect(remote.startedFrom, [500]);
  });
}
