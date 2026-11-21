import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trophies_tracker/features/psn/data/psn_remote_data_source.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';

const _access = 'eyJ-ACCESS-SENTINEL-0000000000';
const _refresh = 'eyJ-REFRESH-SENTINEL-000000000';
const _code = 'SENTINEL-code-123';

final _title = {
  'id': 'NPWR20001_00',
  'service': 'trophy2',
  'name': 'Game One',
  'iconUrl': 'https://image.api.playstation.com/one.png',
  'consoles': ['PS5'],
  'defined': {'bronze': 10, 'silver': 3, 'gold': 1, 'platinum': 1},
  'earned': {'bronze': 5, 'silver': 1, 'gold': 0, 'platinum': 0},
  'total': 15,
  'earnedCount': 6,
  'progress': 40,
  'lastUpdated': '2025-01-02T03:04:05Z',
};

final _trophy = {
  'id': '0',
  'name': 'Trophy 0',
  'detail': 'Do it',
  'iconUrl': null,
  'type': 'platinum',
  'hidden': true,
  'rarity': 1.9,
  'group': 'default',
  'earned': true,
  'earnedAt': '2025-03-04T05:06:07Z',
};

class _Sent {
  http.Request? request;
  Map<String, dynamic> get body =>
      json.decode(request!.body) as Map<String, dynamic>;
}

PsnRemoteDataSourceImpl _source(
  http.Response Function(http.Request) reply, [
  _Sent? sent,
]) => PsnRemoteDataSourceImpl(
  client: MockClient((request) async {
    sent?.request = request;
    return reply(request);
  }),
  proxyBaseUrl: 'https://w.test',
);

http.Response _ok(Object body) => http.Response(json.encode(body), 200);

Future<PsnFailure> _failureOf(Future<Object?> call) async {
  try {
    await call;
  } on PsnException catch (e) {
    return e.failure;
  }
  fail('it did not fail');
}

void main() {
  group('what is sent', () {
    test('every call is a POST with the data in the JSON body only', () async {
      final calls = <(String, Future<Object?> Function(PsnRemoteDataSource))>[
        ('/psn/authorize', (s) => s.authorization()),
        ('/psn/login', (s) => s.login(_code)),
        ('/psn/refresh', (s) => s.refresh(_refresh)),
        ('/psn/profile', (s) => s.profile(_access)),
        ('/psn/titles', (s) => s.titles(_access)),
        (
          '/psn/trophies',
          (s) => s.trophies(_access, id: 'NPWR20001_00', service: 'trophy2'),
        ),
      ];

      for (final (path, call) in calls) {
        final sent = _Sent();
        try {
          await call(_source((_) => http.Response('{}', 500), sent));
        } on PsnException {
          // the answer does not matter here, only what was sent
        }
        final request = sent.request!;

        expect(request.method, 'POST', reason: path);
        expect(request.url.path, path);
        expect(request.url.query, isEmpty, reason: '$path has no query');
        expect(request.headers.keys.map((k) => k.toLowerCase()), [
          'content-type',
        ], reason: '$path sends no authorization or cookie header');
        for (final secret in [_access, _refresh, _code]) {
          expect(request.url.toString(), isNot(contains(secret)));
        }
      }
    });

    test('the body carries the code, the tokens and the game', () async {
      final sent = _Sent();
      await _source((_) => http.Response('{}', 500), sent)
          .login(_code)
          .catchError(
            (_) => const PsnSession(accessToken: '', refreshToken: ''),
          );
      expect(sent.body, {'code': _code});

      await _source(
        (_) => http.Response('{}', 500),
        sent,
      ).profile(_access).catchError((_) => const PsnProfile());
      expect(sent.body, {'accessToken': _access});

      await _source((_) => http.Response('{}', 500), sent)
          .trophies(_access, id: 'NPWR20001_00', service: 'trophy')
          .catchError((_) => <PsnTrophy>[]);
      expect(sent.body, {
        'accessToken': _access,
        'id': 'NPWR20001_00',
        'service': 'trophy',
      });
    });
  });

  group('what comes back', () {
    test('the login page and its scheme', () async {
      final data = await _source(
        (_) => _ok({'url': 'https://sony.test/auth', 'callbackScheme': 'abc'}),
      ).authorization();

      expect(data.url, 'https://sony.test/auth');
      expect(data.callbackScheme, 'abc');
    });

    test('a login, with or without the online id', () async {
      final full = await _source(
        (_) => _ok({
          'accessToken': 'a',
          'refreshToken': 'r',
          'expiresIn': 3599,
          'refreshTokenExpiresIn': 5183999,
          'onlineId': 'Player',
        }),
      ).login(_code);
      expect(full.accessToken, 'a');
      expect(full.refreshToken, 'r');
      expect(full.expiresIn, 3599);
      expect(full.refreshTokenExpiresIn, 5183999);
      expect(full.onlineId, 'Player');

      final bare = await _source(
        (_) => _ok({
          'accessToken': 'a',
          'refreshToken': 'r',
          'expiresIn': null,
          'refreshTokenExpiresIn': null,
          'onlineId': null,
        }),
      ).refresh(_refresh);
      expect(bare.expiresIn, isNull);
      expect(bare.onlineId, isNull);
    });

    test('the name, with the steps that found it', () async {
      final found = await _source(
        (_) => _ok({
          'onlineId': 'Player',
          'attempts': ['summary 200', 'profile 200'],
        }),
      ).profile(_access);
      expect(found.onlineId, 'Player');
      expect(found.attempts, ['summary 200', 'profile 200']);

      final missing = await _source(
        (_) => _ok({
          'onlineId': null,
          'attempts': ['summary 403', 'legacy 404'],
        }),
      ).profile(_access);
      expect(missing.onlineId, isNull);
      expect(missing.attempts, ['summary 403', 'legacy 404']);
    });

    test('a name answer with no steps is unavailable', () async {
      expect(
        await _failureOf(
          _source((_) => _ok({'onlineId': 'Player'})).profile(_access),
        ),
        PsnFailure.unavailable,
      );
    });

    test('the games with their counts', () async {
      final titles = await _source(
        (_) => _ok({
          'titles': [_title],
        }),
      ).titles(_access);

      expect(titles.single.id, 'NPWR20001_00');
      expect(titles.single.service, 'trophy2');
      expect(titles.single.consoles, ['PS5']);
      expect(titles.single.total, 15);
      expect(titles.single.earnedCount, 6);
      expect(titles.single.defined.platinum, 1);
      expect(titles.single.earned.bronze, 5);
      expect(titles.single.lastUpdated, DateTime.utc(2025, 1, 2, 3, 4, 5));
    });

    test('the trophies with their type, rarity and date', () async {
      final trophies = await _source(
        (_) => _ok({
          'trophies': [_trophy],
        }),
      ).trophies(_access, id: 'NPWR20001_00', service: 'trophy2');

      expect(trophies.single.type, 'platinum');
      expect(trophies.single.hidden, isTrue);
      expect(trophies.single.rarity, 1.9);
      expect(trophies.single.earned, isTrue);
      expect(trophies.single.earnedAt, DateTime.utc(2025, 3, 4, 5, 6, 7));
    });

    test('a trophy with no icon, type, rarity or date', () async {
      final trophies = await _source(
        (_) => _ok({
          'trophies': [
            {
              ..._trophy,
              'type': null,
              'rarity': null,
              'earned': false,
              'earnedAt': null,
            },
          ],
        }),
      ).trophies(_access, id: 'NPWR20001_00', service: 'trophy2');

      expect(trophies.single.type, isNull);
      expect(trophies.single.rarity, isNull);
      expect(trophies.single.earnedAt, isNull);
    });
  });

  group('failures are only ever one of the fixed reasons', () {
    test('the Worker error codes', () async {
      final cases = {
        'token_expired': PsnFailure.tokenExpired,
        'psn_rejected': PsnFailure.rejected,
        'invalid_request': PsnFailure.invalidRequest,
        'psn_unavailable': PsnFailure.unavailable,
        'something_new': PsnFailure.unavailable,
      };
      for (final entry in cases.entries) {
        final failure = await _failureOf(
          _source(
            (_) => http.Response(json.encode({'error': entry.key}), 401),
          ).titles(_access),
        );
        expect(failure, entry.value, reason: entry.key);
      }
    });

    test(
      'no network, a bad answer or a missing field are all "unavailable"',
      () async {
        final noNetwork = PsnRemoteDataSourceImpl(
          client: MockClient(
            (_) async => throw http.ClientException('boom $_access $_code'),
          ),
          proxyBaseUrl: 'https://w.test',
        );
        expect(
          await _failureOf(noNetwork.login(_code)),
          PsnFailure.unavailable,
        );

        expect(
          await _failureOf(
            _source((_) => http.Response('<html>', 200)).titles(_access),
          ),
          PsnFailure.unavailable,
        );
        expect(
          await _failureOf(
            _source((_) => http.Response('[]', 200)).titles(_access),
          ),
          PsnFailure.unavailable,
        );
        expect(
          await _failureOf(
            _source(
              (_) => _ok({
                'titles': [
                  {'id': 'x'},
                ],
              }),
            ).titles(_access),
          ),
          PsnFailure.unavailable,
        );
        expect(
          await _failureOf(
            _source((_) => _ok({'accessToken': 'a'})).login(_code),
          ),
          PsnFailure.unavailable,
        );
      },
    );

    test('the error says nothing but its reason', () async {
      final noNetwork = PsnRemoteDataSourceImpl(
        client: MockClient(
          (_) async => throw http.ClientException('boom $_access $_code'),
        ),
        proxyBaseUrl: 'https://w.test',
      );
      PsnException? caught;
      try {
        await noNetwork.login(_code);
      } on PsnException catch (e) {
        caught = e;
      }

      expect(caught.toString(), 'PsnException(unavailable)');
      for (final secret in [_access, _code, 'boom', 'w.test']) {
        expect(caught.toString(), isNot(contains(secret)));
      }
    });
  });
}
