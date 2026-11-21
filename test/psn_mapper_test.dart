import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/psn/data/psn_local_data_source.dart';
import 'package:trophies_tracker/features/psn/domain/psn_mapper.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';

PsnTrophy _trophy(
  String id, {
  String group = 'default',
  String? type = 'bronze',
  bool hidden = false,
  bool earned = false,
}) => PsnTrophy(
  id: id,
  name: 'Name $id',
  detail: 'Detail $id',
  iconUrl: 'https://psn.test/$id.png',
  type: type,
  hidden: hidden,
  rarity: 3.5,
  group: group,
  earned: earned,
  earnedAt: earned ? DateTime.utc(2025, 1, 2) : null,
);

const _title = PsnTitle(
  id: 'NPWR9_00',
  service: 'trophy',
  name: 'A Game',
  iconUrl: 'https://psn.test/icon.png',
  consoles: ['PS4'],
  defined: PsnTrophyCounts(bronze: 3),
  earned: PsnTrophyCounts(),
  progress: 0,
  lastUpdated: null,
);

void main() {
  group('gameFromPsn', () {
    test('is a synced PlayStation game with the date it was added', () {
      final game = gameFromPsn(_title, [
        _trophy('0'),
      ], addedAt: DateTime(2025, 6));

      expect(game.key, const GameKey(GamePlatform.psn, 'NPWR9_00'));
      expect(game.platformSource, psnSource);
      expect(game.isSynced, isTrue);
      expect(game.consoles, ['PS4']);
      expect(game.libraryImage, 'https://psn.test/icon.png');
      expect(game.headerImage, isNull);
      expect(game.addedAt, DateTime(2025, 6));
      expect(game.remoteUpdatedAt, isNull);
    });

    test('an add-on trophy is named after its group, so ids can repeat', () {
      final game = gameFromPsn(_title, [
        _trophy('0'),
        _trophy('0', group: '001'),
        _trophy('1', group: '001'),
      ], addedAt: DateTime(2025, 6));

      expect(game.trophies.map((t) => t.apiName), ['0', '001-0', '001-1']);
    });

    test(
      'keeps the grade, the real name of a hidden trophy and the rarity',
      () {
        final game = gameFromPsn(_title, [
          _trophy('0', type: 'platinum'),
          _trophy('1', hidden: true, earned: true),
          _trophy('2', type: 'unheard-of'),
          _trophy('3', type: null),
        ], addedAt: DateTime(2025, 6));

        expect(game.trophies.map((t) => t.type), [
          TrophyType.platinum,
          TrophyType.bronze,
          null,
          null,
        ]);
        final hidden = game.trophies[1];
        expect(hidden.hidden, isTrue);
        expect(hidden.displayName, 'Name 1');
        expect(hidden.isAchieved, isTrue);
        expect(hidden.achievedAt, DateTime.utc(2025, 1, 2));
        expect(game.trophies.every((t) => t.rarity == 3.5), isTrue);
        expect(game.trophies.first.description, 'Detail 0');
        expect(game.trophies.first.icon, 'https://psn.test/0.png');
      },
    );
  });

  group('PsnLocalDataSource', () {
    Future<PsnLocalDataSourceImpl> open() async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      return PsnLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
        secureStorage: const FlutterSecureStorage(),
      );
    }

    test('a login without a name forgets the name of the one before', () async {
      final ds = await open();
      await ds.saveLogin(refreshToken: 'a', onlineId: 'Old');

      await ds.saveLogin(refreshToken: 'b');

      expect((await ds.link())!.onlineId, isNull);
      expect(await ds.refreshToken(), 'b');
    });

    test('a replaced renewal token keeps the name', () async {
      final ds = await open();
      await ds.saveLogin(refreshToken: 'a', onlineId: 'Name');

      await ds.saveRefreshToken('b', refreshExpiresAt: DateTime.utc(2025, 7));

      final link = (await ds.link())!;
      expect(link.onlineId, 'Name');
      expect(
        link.refreshExpiresAt!.isAtSameMomentAs(DateTime.utc(2025, 7)),
        isTrue,
      );
    });

    test('clear forgets everything', () async {
      final ds = await open();
      await ds.saveLogin(
        refreshToken: 'a',
        onlineId: 'Name',
        refreshExpiresAt: DateTime.utc(2025, 7),
      );
      await ds.saveLastSync(DateTime.utc(2025, 6));

      await ds.clear();

      expect(await ds.link(), isNull);
      expect(await ds.refreshToken(), isNull);
      await ds.saveLogin(refreshToken: 'c');
      final link = (await ds.link())!;
      expect(
        (link.onlineId, link.refreshExpiresAt, link.lastSync),
        (null, null, null),
      );
    });

    test('a name found later is kept with the rest of the link', () async {
      final ds = await open();
      await ds.saveLogin(
        refreshToken: 'a',
        refreshExpiresAt: DateTime.utc(2025, 7),
      );

      await ds.saveOnlineId('Later');

      final link = (await ds.link())!;
      expect(link.onlineId, 'Later');
      expect(
        link.refreshExpiresAt!.isAtSameMomentAs(DateTime.utc(2025, 7)),
        isTrue,
      );
    });

    test('the last sync is part of the link', () async {
      final ds = await open();
      await ds.saveLogin(refreshToken: 'a');

      await ds.saveLastSync(DateTime.utc(2025, 6, 5, 8));

      expect(
        (await ds.link())!.lastSync!.isAtSameMomentAs(
          DateTime.utc(2025, 6, 5, 8),
        ),
        isTrue,
      );
    });
  });
}
