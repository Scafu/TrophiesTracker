import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/utils/pkce/pkce.dart';
import 'package:trophies_tracker/features/account/data/datasource/account_local_data_source.dart';
import 'package:trophies_tracker/features/account/data/datasource/account_remote_data_source.dart';
import 'package:trophies_tracker/features/account/data/models/steam_user_model.dart';
import 'package:trophies_tracker/features/account/data/repositories/account_repository_impl.dart';

class _MemoryLocal extends Fake implements AccountLocalDataSource {
  String? verifier;
  String? token;
  SteamUserModel? user;

  @override
  Future<void> saveLoginVerifier(String value) async => verifier = value;

  @override
  Future<String?> takeLoginVerifier() async {
    final value = verifier;
    verifier = null;
    return value;
  }

  @override
  Future<void> saveToken(String value) async => token = value;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> deleteToken() async => token = null;

  @override
  Future<void> saveUser(SteamUserModel value) async => user = value;

  @override
  Future<void> deleteUser() async => user = null;
}

class _FakeRemote extends Fake implements AccountRemoteDataSource {
  _FakeRemote({this.failRevoke = false});

  final bool failRevoke;
  String? sentChallenge;
  ({String code, String verifier})? exchanged;
  String? revoked;

  @override
  String getSteamLoginUrl(String challenge) {
    sentChallenge = challenge;
    return 'https://x.test/auth/steam?challenge=$challenge';
  }

  @override
  Future<String> exchangeCode(String code, String verifier) async {
    exchanged = (code: code, verifier: verifier);
    return 'session-token';
  }

  @override
  Future<SteamUserModel> getSteamUserInfo(String token) async =>
      SteamUserModel(steamId: '1', token: token);

  @override
  Future<void> revokeToken(String token) async {
    if (failRevoke) throw Exception('offline');
    revoked = token;
  }
}

AccountRepositoryImpl _repository(_FakeRemote remote, _MemoryLocal local) =>
    AccountRepositoryImpl(remoteDataSource: remote, localDataSource: local);

void main() {
  test('login sends only the challenge and keeps the verifier', () async {
    final remote = _FakeRemote();
    final local = _MemoryLocal();

    await _repository(remote, local).startLogin();

    expect(local.verifier, isNotNull);
    expect(remote.sentChallenge, Pkce.challengeFor(local.verifier!));
    expect(remote.sentChallenge, isNot(local.verifier));
  });

  test('the code is exchanged with the saved verifier, once', () async {
    final remote = _FakeRemote();
    final local = _MemoryLocal();
    final repository = _repository(remote, local);
    await repository.startLogin();
    final verifier = local.verifier;

    final user = await repository.finishLogin('the-code');

    expect(user?.steamId, '1');
    expect(remote.exchanged, (code: 'the-code', verifier: verifier!));
    expect(local.token, 'session-token');
    expect(await repository.finishLogin('the-code'), isNull);
  });

  test('a code without a login in progress is ignored', () async {
    final remote = _FakeRemote();

    final user = await _repository(remote, _MemoryLocal()).finishLogin('x');

    expect(user, isNull);
    expect(remote.exchanged, isNull);
  });

  test(
    'logout revokes the token on the server and clears the session',
    () async {
      final remote = _FakeRemote();
      final local = _MemoryLocal()..token = 't';

      await _repository(remote, local).logout();

      expect(remote.revoked, 't');
      expect(local.token, isNull);
    },
  );

  test(
    'logout clears the session even when the server is unreachable',
    () async {
      final local = _MemoryLocal()..token = 't';

      await _repository(_FakeRemote(failRevoke: true), local).logout();

      expect(local.token, isNull);
    },
  );
}
