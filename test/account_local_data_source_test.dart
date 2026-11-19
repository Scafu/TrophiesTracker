import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophies_tracker/features/account/data/datasource/account_local_data_source.dart';
import 'package:trophies_tracker/features/account/data/models/steam_user_model.dart';

void main() {
  test('the token lives only in secure storage', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final ds = AccountLocalDataSourceImpl(
      sharedPreferences: prefs,
      secureStorage: const FlutterSecureStorage(),
    );

    await ds.saveToken('secret');
    await ds.saveUser(const SteamUserModel(steamId: '1', token: 'secret'));

    expect(await ds.getToken(), 'secret');
    expect((await ds.getUser())?.steamId, '1');
    expect(prefs.getKeys().map(prefs.get).join(), isNot(contains('secret')));

    await ds.deleteToken();
    expect(await ds.getToken(), isNull);
  });

  test('the login verifier can be taken only once', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final ds = AccountLocalDataSourceImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
      secureStorage: const FlutterSecureStorage(),
    );

    await ds.saveLoginVerifier('v');

    expect(await ds.takeLoginVerifier(), 'v');
    expect(await ds.takeLoginVerifier(), isNull);
  });
}
