import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophies_tracker/features/account/data/models/steam_user_model.dart';

abstract class AccountLocalDataSource {
  Future<void> saveUser(SteamUserModel user);
  Future<void> deleteUser();
  Future<SteamUserModel?> getUser();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();

  /// Keeps the PKCE verifier of the login in progress. It is stored, not held
  /// in memory, because the app can be killed while the browser is open.
  Future<void> saveLoginVerifier(String verifier);

  /// Returns the pending verifier and forgets it, so a login code works once.
  Future<String?> takeLoginVerifier();
}

/// Stores the cached profile in [SharedPreferences] and the session token in
/// [FlutterSecureStorage], so the token is never written in plain text.
class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;
  static const String _userKey = 'cached_steam_user';
  static const String _tokenKey = 'session_token';
  static const String _verifierKey = 'login_verifier';

  AccountLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  /// Caches the profile without its token, which lives only in secure storage.
  @override
  Future<void> saveUser(SteamUserModel user) async {
    final userJson = json.encode(user.copyWith(token: null).toJson());
    await sharedPreferences.setString(_userKey, userJson);
  }

  @override
  Future<void> deleteUser() async {
    await sharedPreferences.remove(_userKey);
  }

  @override
  Future<SteamUserModel?> getUser() async {
    final userJson = sharedPreferences.getString(_userKey);
    if (userJson != null) {
      return SteamUserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  @override
  Future<void> saveToken(String token) {
    return secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() {
    return secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> deleteToken() {
    return secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<void> saveLoginVerifier(String verifier) {
    return secureStorage.write(key: _verifierKey, value: verifier);
  }

  @override
  Future<String?> takeLoginVerifier() async {
    final verifier = await secureStorage.read(key: _verifierKey);
    await secureStorage.delete(key: _verifierKey);
    return verifier;
  }
}
