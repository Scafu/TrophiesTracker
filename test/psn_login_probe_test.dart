import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/psn/data/psn_remote_data_source.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';
import 'package:trophies_tracker/features/psn/presentation/psn_login_probe.dart';

const _access = 'ACCESS-SENTINEL';
const _refresh = 'REFRESH-SENTINEL';
const _code = 'CODE-SENTINEL';
const _online = 'OnlineSentinel';

PsnTitle _title(
  String id,
  String name, {
  List<String> consoles = const ['PS5'],
  int earned = 3,
  int total = 10,
  int platinum = 0,
}) => PsnTitle(
  id: id,
  service: consoles.contains('PS5') ? 'trophy2' : 'trophy',
  name: name,
  iconUrl: null,
  consoles: consoles,
  defined: PsnTrophyCounts(bronze: total - 1, platinum: 1),
  earned: PsnTrophyCounts(bronze: earned, platinum: platinum),
  progress: 30,
  lastUpdated: null,
);

PsnTrophy _trophy(
  String id, {
  String name = 'Trophy',
  bool hidden = false,
  bool earned = false,
  String type = 'bronze',
  double? rarity = 10,
}) => PsnTrophy(
  id: id,
  name: name,
  detail: 'Detail $id',
  iconUrl: null,
  type: type,
  hidden: hidden,
  rarity: rarity,
  group: 'default',
  earned: earned,
  earnedAt: null,
);

class _DataSource extends Fake implements PsnRemoteDataSource {
  PsnFailure? authorizationFails;
  PsnFailure? loginFails;
  PsnFailure? titlesFail;
  PsnFailure? trophiesFail;
  PsnFailure? refreshFails;
  String? onlineId = _online;
  List<String> nameSteps = ['summary 403', 'legacy 404'];
  String refreshedTo = 'NEW-REFRESH';
  int? refreshedExpiresIn = 864000;
  List<PsnTitle> games = [
    _title(
      'NPWR10001_00',
      'Secret Game A',
      consoles: ['PS4'],
      earned: 2,
      platinum: 0,
    ),
    _title(
      'NPWR20002_00',
      'Secret Game B',
      consoles: ['PS5'],
      earned: 6,
      total: 30,
      platinum: 1,
    ),
    _title(
      'NPWR20003_00',
      'Secret Game C',
      consoles: ['PS4', 'PS5'],
      earned: 0,
      total: 99,
    ),
  ];
  List<PsnTrophy> trophyList = [
    _trophy('0', earned: true, type: 'platinum', rarity: 1.5),
    _trophy('1', name: 'Hidden Trophy', hidden: true),
    _trophy('2', name: 'Hidden Trophy', hidden: true),
    _trophy('3', name: 'Real secret', hidden: true, earned: true),
    _trophy('4', rarity: null),
  ];
  final calls = <String>[];
  String? trophiesAskedFor;

  @override
  Future<PsnAuthorization> authorization() async {
    calls.add('authorization');
    if (authorizationFails != null) throw PsnException(authorizationFails!);
    return const PsnAuthorization(
      url: 'https://sony.test/login',
      callbackScheme: 'scheme',
    );
  }

  @override
  Future<PsnSession> login(String code) async {
    calls.add('login:$code');
    if (loginFails != null) throw PsnException(loginFails!);
    return PsnSession(
      accessToken: _access,
      refreshToken: _refresh,
      expiresIn: 3599,
      refreshTokenExpiresIn: 5183999,
      onlineId: onlineId,
    );
  }

  @override
  Future<List<PsnTitle>> titles(String accessToken) async {
    calls.add('titles');
    if (titlesFail != null) throw PsnException(titlesFail!);
    return games;
  }

  @override
  Future<List<PsnTrophy>> trophies(
    String accessToken, {
    required String id,
    required String service,
  }) async {
    calls.add('trophies');
    trophiesAskedFor = id;
    if (trophiesFail != null) throw PsnException(trophiesFail!);
    return trophyList;
  }

  @override
  Future<PsnProfile> profile(String accessToken) async {
    calls.add('profile');
    return PsnProfile(attempts: nameSteps);
  }

  @override
  Future<PsnSession> refresh(String refreshToken) async {
    calls.add('refresh');
    if (refreshFails != null) throw PsnException(refreshFails!);
    return PsnSession(
      accessToken: _access,
      refreshToken: refreshedTo,
      refreshTokenExpiresIn: refreshedExpiresIn,
    );
  }
}

Future<String> _returns(
  String url,
  String scheme, {
  bool fresh = false,
}) async => 'com.scee.psxandroid.scecompcall://redirect/?code=$_code';

String _text(PsnProbeReport report) => [
  for (final step in report.steps) '${step.label}|${step.ok}|${step.detail}',
].join('\n');

void main() {
  test('every step works and the report holds only counts', () async {
    final source = _DataSource();

    final report = await PsnLoginProbe(source, _returns).run();

    expect(report.ok, isTrue);
    expect(report.steps.map((s) => s.label), [
      'Worker gives the login page',
      'Login in the browser returns a code',
      'Worker exchanges the code with Sony',
      'Games',
      'Trophies of one game',
      'Worker renews the access',
    ]);
    final byLabel = {for (final s in report.steps) s.label: s.detail};
    expect(
      byLabel['Worker exchanges the code with Sony'],
      allOf(contains('online id found'), contains('renewal lasts 60 days')),
    );
    expect(
      byLabel['Games'],
      allOf(
        contains('3 games (PS4 2, PS5 2)'),
        contains('trophies 9 of 139'),
        contains('platinum 1 of 3'),
      ),
    );
    expect(
      byLabel['Trophies of one game'],
      allOf(
        contains('total 5, earned 2'),
        contains(
          'hidden 3 (not earned 2: with a name 2, distinct names 1, with a description 2)',
        ),
        contains('bronze 4, silver 0, gold 0, platinum 1'),
        contains('with a rarity 4'),
      ),
    );
    expect(byLabel['Worker renews the access'], contains('replaced'));
    expect(byLabel['Worker renews the access'], contains('then lasts 10 days'));
  });

  test('nothing the user or Sony sent is kept in the report', () async {
    final report = await PsnLoginProbe(_DataSource(), _returns).run();
    final text = _text(report);

    for (final secret in [
      _access,
      _refresh,
      _code,
      _online,
      'Secret Game',
      'Real secret',
      'NPWR',
    ]) {
      expect(text, isNot(contains(secret)), reason: secret);
    }
  });

  test('the code from the browser is what is sent to the Worker', () async {
    final source = _DataSource();

    await PsnLoginProbe(source, _returns).run();

    expect(source.calls, contains('login:$_code'));
  });

  test(
    'the trophies read are those of the played game with the most trophies',
    () async {
      final source = _DataSource();

      await PsnLoginProbe(source, _returns).run();

      expect(source.trophiesAskedFor, 'NPWR20002_00');
    },
  );

  test('with no game played there is no trophy list to read', () async {
    final source = _DataSource()
      ..games = [_title('NPWR10001_00', 'X', earned: 0)];

    final report = await PsnLoginProbe(source, _returns).run();

    expect(report.ok, isTrue);
    expect(source.calls, isNot(contains('trophies')));
    expect(
      report.steps.any(
        (s) => s.label == 'Trophies of one game' && s.detail == 'no game',
      ),
      isTrue,
    );
  });

  test(
    'an unchanged renewal token and a missing online id are reported as such',
    () async {
      final source = _DataSource()
        ..onlineId = null
        ..refreshedTo = _refresh;

      final report = await PsnLoginProbe(source, _returns).run();

      final byLabel = {for (final s in report.steps) s.label: s.detail};
      expect(
        byLabel['Worker exchanges the code with Sony'],
        contains('online id missing'),
      );
      expect(byLabel['Worker renews the access'], contains('unchanged'));
    },
  );

  test('a missing name says where the lookup stopped, with no data', () async {
    final source = _DataSource()..onlineId = null;

    final report = await PsnLoginProbe(source, _returns).run();

    final byLabel = {for (final s in report.steps) s.label: s.detail};
    expect(
      byLabel['Worker exchanges the code with Sony'],
      contains('online id missing (summary 403, legacy 404)'),
    );
    expect(source.calls.where((c) => c == 'profile'), hasLength(1));
  });

  test('a name that was found is not looked up again', () async {
    final source = _DataSource();

    final report = await PsnLoginProbe(source, _returns).run();

    expect(source.calls, isNot(contains('profile')));
    final byLabel = {for (final s in report.steps) s.label: s.detail};
    expect(
      byLabel['Worker exchanges the code with Sony'],
      isNot(contains('summary')),
    );
  });

  group('it stops at the first thing that fails', () {
    test('the Worker cannot give the login page', () async {
      final source = _DataSource()..authorizationFails = PsnFailure.unavailable;

      final report = await PsnLoginProbe(source, _returns).run();

      expect(report.ok, isFalse);
      expect(report.steps.single.detail, 'unavailable');
      expect(source.calls, ['authorization']);
    });

    test('the user closes the browser', () async {
      final source = _DataSource();

      final report = await PsnLoginProbe(
        source,
        (url, scheme, {fresh = false}) async =>
            throw PlatformException(code: 'CANCELED'),
      ).run();

      expect(report.steps.last.detail, 'cancelled by the user');
      expect(source.calls, ['authorization']);
    });

    test(
      'a platform error shows only its short code, never its message',
      () async {
        final report = await PsnLoginProbe(
          _DataSource(),
          (url, scheme, {fresh = false}) async => throw PlatformException(
            code: 'FAILED',
            message: 'went back to $_code',
            details: 'code=$_code',
          ),
        ).run();

        expect(report.steps.last.detail, 'platform error FAILED');
        expect(_text(report), isNot(contains(_code)));
      },
    );

    test('a strange platform code is not shown', () async {
      final report = await PsnLoginProbe(
        _DataSource(),
        (url, scheme, {fresh = false}) async =>
            throw PlatformException(code: 'a b; $_code'),
      ).run();

      expect(report.steps.last.detail, 'platform error unknown');
    });

    test('any other error is just "failed"', () async {
      final report = await PsnLoginProbe(
        _DataSource(),
        (url, scheme, {fresh = false}) async =>
            throw Exception('details $_code'),
      ).run();

      expect(report.steps.last.detail, 'failed');
      expect(_text(report), isNot(contains(_code)));
    });

    test('the browser comes back with no code', () async {
      final source = _DataSource();

      for (final address in [
        'com.scee.psxandroid.scecompcall://redirect/',
        'com.scee.psxandroid.scecompcall://redirect/?error=access_denied',
        'com.scee.psxandroid.scecompcall://redirect/?code=',
        'not an address %%%',
      ]) {
        final report = await PsnLoginProbe(
          source,
          (url, scheme, {fresh = false}) async => address,
        ).run();

        expect(report.ok, isFalse, reason: address);
        expect(
          report.steps.last.detail,
          'it came back to the app without a code',
        );
      }
      expect(source.calls.where((c) => c.startsWith('login')), isEmpty);
    });

    test('Sony rejects the code', () async {
      final source = _DataSource()..loginFails = PsnFailure.rejected;

      final report = await PsnLoginProbe(source, _returns).run();

      expect(report.steps.last.label, 'Worker exchanges the code with Sony');
      expect(report.steps.last.detail, 'rejected');
      expect(source.calls, isNot(contains('titles')));
    });

    test('the games cannot be read', () async {
      final source = _DataSource()..titlesFail = PsnFailure.tokenExpired;

      final report = await PsnLoginProbe(source, _returns).run();

      expect(report.steps.last.label, 'Games');
      expect(report.steps.last.detail, 'tokenExpired');
      expect(source.calls, isNot(contains('trophies')));
    });
  });

  test(
    'a failing trophy list or renewal is reported but does not hide the rest',
    () async {
      final source = _DataSource()
        ..trophiesFail = PsnFailure.unavailable
        ..refreshFails = PsnFailure.rejected;

      final report = await PsnLoginProbe(source, _returns).run();

      final byLabel = {for (final s in report.steps) s.label: s};
      expect(byLabel['Games']!.ok, isTrue);
      expect(byLabel['Trophies of one game']!.ok, isFalse);
      expect(byLabel['Worker renews the access']!.ok, isFalse);
      expect(report.ok, isFalse);
    },
  );
}
