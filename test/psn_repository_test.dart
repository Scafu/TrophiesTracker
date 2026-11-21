import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophies_tracker/core/database/app_database.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_remote_data_source.dart';
import 'package:trophies_tracker/features/game/data/models/game_model.dart';
import 'package:trophies_tracker/features/game/data/repositories/game_repositories_impl.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/psn/data/psn_local_data_source.dart';
import 'package:trophies_tracker/features/psn/data/psn_remote_data_source.dart';
import 'package:trophies_tracker/features/psn/data/psn_repository_impl.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';

class _NoSteam extends Fake implements GameRemoteDataSource {}

/// Sony as the Worker shows it: what it lists, with switches to fail.
class _Sony extends Fake implements PsnRemoteDataSource {
  List<PsnTitle> listed = [];
  final Map<String, List<PsnTrophy>> trophiesOf = {};
  final Set<String> failing = {};
  final loggedWith = <String>[];
  final refreshedWith = <String>[];
  final trophyCalls = <String>[];
  var titleCalls = 0;
  var refreshToken = 'refresh-1';
  PsnFailure? refreshFails;
  PsnFailure? titlesFailOnce;
  var accessCounter = 0;
  String? loginName = 'Player';
  String? profileName = 'Found';
  PsnFailure? profileFails;
  var profileCalls = 0;

  PsnSession _session() => PsnSession(
    accessToken: 'access-${++accessCounter}',
    refreshToken: refreshToken,
    expiresIn: 3600,
    refreshTokenExpiresIn: 864000,
    onlineId: loginName,
  );

  @override
  Future<PsnProfile> profile(String accessToken) async {
    profileCalls++;
    final failure = profileFails;
    if (failure != null) throw PsnException(failure);
    return PsnProfile(onlineId: profileName);
  }

  @override
  Future<PsnSession> login(String code) async {
    loggedWith.add(code);
    return _session();
  }

  @override
  Future<PsnSession> refresh(String refreshToken) async {
    refreshedWith.add(refreshToken);
    final failure = refreshFails;
    if (failure != null) throw PsnException(failure);
    return _session();
  }

  @override
  Future<List<PsnTitle>> titles(String accessToken) async {
    titleCalls++;
    final failure = titlesFailOnce;
    if (failure != null) {
      titlesFailOnce = null;
      throw PsnException(failure);
    }
    return listed;
  }

  @override
  Future<List<PsnTrophy>> trophies(
    String accessToken, {
    required String id,
    required String service,
  }) async {
    trophyCalls.add(id);
    if (failing.contains(id)) throw const PsnException(PsnFailure.unavailable);
    return trophiesOf[id] ?? [];
  }
}

PsnTitle _title(
  String id, {
  int earned = 1,
  int total = 2,
  DateTime? updated,
  List<String> consoles = const ['PS5'],
}) => PsnTitle(
  id: id,
  service: 'trophy2',
  name: 'Game $id',
  iconUrl: 'https://psn.test/$id.png',
  consoles: consoles,
  defined: PsnTrophyCounts(bronze: total),
  earned: PsnTrophyCounts(bronze: earned),
  progress: 0,
  lastUpdated: updated ?? DateTime.utc(2025, 5, 1, 12, 30, 15),
);

List<PsnTrophy> _trophies({int earned = 1, int total = 2}) => [
  for (var i = 0; i < total; i++)
    PsnTrophy(
      id: '$i',
      name: 'Trophy $i',
      detail: 'Do $i',
      iconUrl: 'https://psn.test/t$i.png',
      type: i == 0 ? 'platinum' : 'bronze',
      hidden: i == 1,
      rarity: 12.5,
      group: 'default',
      earned: i < earned,
      earnedAt: i < earned ? DateTime.utc(2025, 4, 2, 10) : null,
    ),
];

class _Setup {
  final AppDatabase db;
  final _Sony sony;
  final GameRepositoriesImpl games;
  final PsnLocalDataSourceImpl local;
  final PsnRepositoryImpl psn;
  DateTime now;

  _Setup(this.db, this.sony, this.games, this.local, this.psn, this.now);
}

Future<_Setup> _setup({DateTime? start}) async {
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final sony = _Sony();
  final games = GameRepositoriesImpl(
    localDataSource: GameLocalDataSourceImpl(db),
    remoteDataSource: _NoSteam(),
  );
  final local = PsnLocalDataSourceImpl(
    sharedPreferences: await SharedPreferences.getInstance(),
    secureStorage: const FlutterSecureStorage(),
  );
  late final _Setup setup;
  final psn = PsnRepositoryImpl(
    remote: sony,
    local: local,
    games: games,
    now: () => setup.now,
  );
  return setup = _Setup(
    db,
    sony,
    games,
    local,
    psn,
    start ?? DateTime(2025, 6),
  );
}

Future<List<String>> _psnCodes(_Setup s) async => [
  for (final g in await s.games.getAllGames())
    if (g.platform == GamePlatform.psn) g.code,
]..sort();

void main() {
  group('login', () {
    test(
      'keeps the account linked with the name and the end of the login',
      () async {
        final s = await _setup();

        final link = await s.psn.login('code-1');

        expect(s.sony.loggedWith, ['code-1']);
        expect(link.onlineId, 'Player');
        expect(link.refreshExpiresAt, DateTime(2025, 6, 11));
        expect(link.daysLeft(DateTime(2025, 6, 1)), 10);
        expect(await s.psn.link(), isNotNull);
      },
    );

    test('there is no link before a login', () async {
      final s = await _setup();

      expect(await s.psn.link(), isNull);
    });
  });

  group('PsnLink', () {
    test('counts the days left and says when the login is over', () {
      final link = PsnLink(refreshExpiresAt: DateTime(2025, 6, 11));

      expect(link.daysLeft(DateTime(2025, 6, 8, 12)), 2);
      expect(link.isExpired(DateTime(2025, 6, 8)), isFalse);
      expect(link.daysLeft(DateTime(2025, 6, 12)), 0);
      expect(link.isExpired(DateTime(2025, 6, 11)), isTrue);
      expect(const PsnLink().daysLeft(DateTime(2025, 6)), isNull);
      expect(const PsnLink().isExpired(DateTime(2025, 6)), isFalse);
    });
  });

  group('sync', () {
    test(
      'saves each game with its console, trophies, grades and rarity',
      () async {
        final s = await _setup();
        await s.psn.login('c');
        s.sony.listed = [
          _title('NPWR1_00', consoles: ['PS4', 'PS5']),
        ];
        s.sony.trophiesOf['NPWR1_00'] = _trophies();

        final result = await s.psn.sync();

        expect((result.total, result.updated), (1, 1));
        final game = await s.games.getGameByIdLocal(
          const GameKey(GamePlatform.psn, 'NPWR1_00'),
        );
        expect(game.name, 'Game NPWR1_00');
        expect(game.consoles, ['PS4', 'PS5']);
        expect(game.platformSource, 'psn');
        expect(game.isSynced, isTrue);
        expect(game.libraryImage, 'https://psn.test/NPWR1_00.png');
        expect(game.trophies, hasLength(2));
        final platinum = game.trophies.singleWhere((t) => t.apiName == '0');
        expect(platinum.type, TrophyType.platinum);
        expect(platinum.isAchieved, isTrue);
        expect(
          platinum.achievedAt!.isAtSameMomentAs(DateTime.utc(2025, 4, 2, 10)),
          isTrue,
        );
        expect(platinum.rarity, 12.5);
        final hidden = game.trophies.singleWhere((t) => t.apiName == '1');
        expect(hidden.hidden, isTrue);
        expect(hidden.displayName, 'Trophy 1');
        expect(hidden.isAchieved, isFalse);
      },
    );

    test('a second sync reads again only the games that changed', () async {
      final s = await _setup();
      await s.psn.login('c');
      s.sony.listed = [_title('A'), _title('B')];
      s.sony.trophiesOf['A'] = _trophies();
      s.sony.trophiesOf['B'] = _trophies();
      await s.psn.sync();
      s.sony.trophyCalls.clear();

      final unchanged = await s.psn.sync();

      expect((unchanged.total, unchanged.updated), (2, 0));
      expect(s.sony.trophyCalls, isEmpty);

      s.sony.listed = [
        _title('A'),
        _title('B', earned: 2, updated: DateTime.utc(2025, 5, 3)),
      ];
      s.sony.trophiesOf['B'] = _trophies(earned: 2);
      final changed = await s.psn.sync();

      expect((changed.total, changed.updated), (2, 1));
      expect(s.sony.trophyCalls, ['B']);
      final b = await s.games.getGameByIdLocal(
        const GameKey(GamePlatform.psn, 'B'),
      );
      expect(b.trophies.where((t) => t.isAchieved), hasLength(2));
    });

    test('a game with more trophies earned is read again', () async {
      final s = await _setup();
      await s.psn.login('c');
      s.sony.listed = [_title('A')];
      s.sony.trophiesOf['A'] = _trophies();
      await s.psn.sync();
      s.sony.trophyCalls.clear();

      s.sony.listed = [_title('A', earned: 2)];
      s.sony.trophiesOf['A'] = _trophies(earned: 2);
      await s.psn.sync();

      expect(s.sony.trophyCalls, ['A']);
    });

    test('a game whose trophies stop adding up is read again', () async {
      final s = await _setup();
      await s.psn.login('c');
      s.sony.listed = [_title('A')];
      s.sony.trophiesOf['A'] = _trophies();
      await s.psn.sync();
      s.sony.trophyCalls.clear();

      s.sony.listed = [_title('A', total: 3)];
      s.sony.trophiesOf['A'] = _trophies(total: 3);
      await s.psn.sync();

      expect(s.sony.trophyCalls, ['A']);
    });

    test('a game keeps the date it was added on', () async {
      final s = await _setup(start: DateTime(2025, 6, 1));
      await s.psn.login('c');
      s.sony.listed = [_title('A')];
      s.sony.trophiesOf['A'] = _trophies();
      await s.psn.sync();

      s.now = DateTime(2025, 6, 20);
      s.sony.listed = [_title('A', earned: 2, updated: DateTime.utc(2025, 6))];
      s.sony.trophiesOf['A'] = _trophies(earned: 2);
      await s.psn.sync();

      final game = await s.games.getGameByIdLocal(
        const GameKey(GamePlatform.psn, 'A'),
      );
      expect(game.addedAt, DateTime(2025, 6, 1));
    });

    test('tells how many games are done', () async {
      final s = await _setup();
      await s.psn.login('c');
      s.sony.listed = [_title('A'), _title('B'), _title('C')];

      final seen = <(int, int)>[];
      await s.psn.sync(onProgress: (done, total) => seen.add((done, total)));

      expect(seen.first, (0, 3));
      expect(seen.last, (3, 3));
    });

    test('a failure keeps what was read and the next sync finishes', () async {
      final s = await _setup();
      await s.psn.login('c');
      final ids = [
        for (var i = 0; i < 12; i++) 'G${i.toString().padLeft(2, '0')}',
      ];
      s.sony.listed = [for (final id in ids) _title(id)];
      for (final id in ids) {
        s.sony.trophiesOf[id] = _trophies();
      }
      s.sony.failing.add('G11');

      await expectLater(
        s.psn.sync(),
        throwsA(
          isA<PsnException>().having(
            (e) => e.failure,
            'failure',
            PsnFailure.unavailable,
          ),
        ),
      );
      final saved = await _psnCodes(s);
      expect(saved, ids.take(11));

      s.sony.failing.clear();
      s.sony.trophyCalls.clear();
      await s.psn.sync();

      expect(s.sony.trophyCalls.length, ids.length - saved.length);
      expect(await _psnCodes(s), ids);
    });
  });

  group('the name of the player', () {
    test('missing at login, it is found when syncing and kept', () async {
      final s = await _setup();
      s.sony.loginName = null;
      await s.psn.login('c');
      expect((await s.psn.link())!.onlineId, isNull);
      s.sony.listed = [_title('A')];

      await s.psn.sync();

      expect(s.sony.profileCalls, 1);
      expect((await s.psn.link())!.onlineId, 'Found');
    });

    test('a name already known is not looked up', () async {
      final s = await _setup();
      await s.psn.login('c');
      s.sony.listed = [_title('A')];

      await s.psn.sync();

      expect(s.sony.profileCalls, 0);
      expect((await s.psn.link())!.onlineId, 'Player');
    });

    test('a lookup that fails does not fail the sync', () async {
      final s = await _setup();
      s.sony.loginName = null;
      s.sony.profileFails = PsnFailure.unavailable;
      await s.psn.login('c');
      s.sony.listed = [_title('A')];

      final result = await s.psn.sync();

      expect(result.total, 1);
      expect((await s.psn.link())!.onlineId, isNull);
    });

    test(
      'Sony having no name is asked once per session, not on every sync',
      () async {
        final s = await _setup();
        s.sony.loginName = null;
        s.sony.profileName = null;
        await s.psn.login('c');
        s.sony.listed = [_title('A')];

        await s.psn.sync();
        await s.psn.sync();

        expect(s.sony.profileCalls, 1);
      },
    );

    test('a new login asks again', () async {
      final s = await _setup();
      s.sony.loginName = null;
      s.sony.profileName = null;
      await s.psn.login('c');
      s.sony.listed = [_title('A')];
      await s.psn.sync();

      await s.psn.logout();
      await s.psn.login('c');
      s.sony.profileName = 'Later';
      await s.psn.sync();

      expect(s.sony.profileCalls, 2);
      expect((await s.psn.link())!.onlineId, 'Later');
    });

    test('a failed sync does not spend the lookup', () async {
      final s = await _setup();
      s.sony.loginName = null;
      await s.psn.login('c');
      s.sony.titlesFailOnce = PsnFailure.unavailable;
      s.sony.listed = [_title('A')];

      await expectLater(s.psn.sync(), throwsA(isA<PsnException>()));
      expect(s.sony.profileCalls, 0);

      await s.psn.sync();
      expect(s.sony.profileCalls, 1);
    });
  });

  group('access', () {
    test('the access token from the login is used without renewing', () async {
      final s = await _setup();
      await s.psn.login('c');
      s.sony.listed = [_title('A')];

      await s.psn.sync();
      await s.psn.sync();

      expect(s.sony.refreshedWith, isEmpty);
    });

    test(
      'with no access token it is renewed with the saved renewal token',
      () async {
        final s = await _setup();
        await s.local.saveLogin(refreshToken: 'saved-refresh');
        s.sony.listed = [_title('A')];

        await s.psn.sync();

        expect(s.sony.refreshedWith, ['saved-refresh']);
      },
    );

    test('an access token that has run out is renewed', () async {
      final s = await _setup();
      await s.psn.login('c');
      s.sony.listed = [_title('A')];

      s.now = s.now.add(const Duration(hours: 2));
      await s.psn.sync();

      expect(s.sony.refreshedWith, ['refresh-1']);
    });

    test('a renewal token that Sony replaces is saved', () async {
      final s = await _setup();
      await s.psn.login('c');
      s.sony.refreshToken = 'refresh-2';
      s.now = s.now.add(const Duration(hours: 2));

      await s.psn.sync();

      expect(await s.local.refreshToken(), 'refresh-2');
      expect(
        (await s.psn.link())!.refreshExpiresAt,
        s.now.add(const Duration(days: 10)),
      );
    });

    test('a renewal token that stays the same keeps its end of life', () async {
      final s = await _setup();
      final link = await s.psn.login('c');
      s.now = s.now.add(const Duration(days: 3));

      await s.psn.sync();

      expect((await s.psn.link())!.refreshExpiresAt, link.refreshExpiresAt);
    });

    test(
      'Sony refusing the access token mid-sync renews it once and goes on',
      () async {
        final s = await _setup();
        await s.psn.login('c');
        s.sony.titlesFailOnce = PsnFailure.tokenExpired;
        s.sony.listed = [_title('A')];

        final result = await s.psn.sync();

        expect(result.total, 1);
        expect(s.sony.refreshedWith, ['refresh-1']);
        expect(s.sony.titleCalls, 2);
      },
    );

    test(
      'a renewal token Sony refuses means the login is over, and nothing is lost',
      () async {
        final s = await _setup();
        await s.psn.login('c');
        s.sony.listed = [_title('A')];
        await s.psn.sync();
        s.sony.refreshFails = PsnFailure.rejected;
        s.now = s.now.add(const Duration(hours: 2));

        await expectLater(
          s.psn.sync(),
          throwsA(
            isA<PsnException>().having(
              (e) => e.failure,
              'failure',
              PsnFailure.tokenExpired,
            ),
          ),
        );

        expect(await _psnCodes(s), ['A']);
        expect((await s.psn.link())!.onlineId, 'Player');
      },
    );

    test('syncing with no account says the login is needed', () async {
      final s = await _setup();

      await expectLater(
        s.psn.sync(),
        throwsA(
          isA<PsnException>().having(
            (e) => e.failure,
            'failure',
            PsnFailure.tokenExpired,
          ),
        ),
      );
      expect(s.sony.titleCalls, 0);
    });

    test('Sony being down is not taken for an expired login', () async {
      final s = await _setup();
      await s.psn.login('c');
      s.sony.refreshFails = PsnFailure.unavailable;
      s.now = s.now.add(const Duration(hours: 2));

      await expectLater(
        s.psn.sync(),
        throwsA(
          isA<PsnException>().having(
            (e) => e.failure,
            'failure',
            PsnFailure.unavailable,
          ),
        ),
      );
    });
  });

  group('logout', () {
    test(
      'unlinks and deletes only the games synced from PlayStation',
      () async {
        final s = await _setup();
        await s.psn.login('c');
        s.sony.listed = [_title('A')];
        await s.psn.sync();
        await s.games.saveGame(
          const GameModel(code: '620', name: 'Portal 2').toEntity(),
        );
        await s.games.saveGame(
          const GameModel(
            platform: GamePlatform.psn,
            code: 'MINE',
            name: 'Added by hand',
          ).toEntity(),
        );
        await s.games.saveGame(
          const GameModel(
            code: '7',
            name: 'Steam synced',
            platformSource: 'steam',
            isSynced: true,
          ).toEntity(),
        );

        await s.psn.logout();

        expect(await s.psn.link(), isNull);
        expect(await s.local.refreshToken(), isNull);
        final left = [for (final g in await s.games.getAllGames()) '${g.key}'];
        expect(left..sort(), ['psn:MINE', 'steam:620', 'steam:7']);
        expect(await s.db.select(s.db.trophies).get(), isEmpty);
      },
    );

    test('after it a sync needs a new login', () async {
      final s = await _setup();
      await s.psn.login('c');
      await s.psn.logout();

      await expectLater(s.psn.sync(), throwsA(isA<PsnException>()));
      expect(s.sony.refreshedWith, isEmpty);
    });
  });

  group('storage', () {
    test('the renewal token lives only in secure storage', () async {
      final s = await _setup();
      await s.psn.login('c');

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getKeys().map(prefs.get).join(),
        isNot(contains('refresh-1')),
      );
      expect(await s.local.refreshToken(), 'refresh-1');
    });
  });
}
