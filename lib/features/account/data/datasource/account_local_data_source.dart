import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophies_tracker/features/account/data/models/steam_user_model.dart';

abstract class AccountLocalDataSource {
  Future<void> saveUser(SteamUserModel user);
  Future<void> deleteUser();
  Future<SteamUserModel?> getUser();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _userKey = 'cached_steam_user';
  static const String _tokenKey = 'session_token';

  AccountLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveUser(SteamUserModel user) async {
    final userJson = json.encode(user.toJson());
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
  Future<void> saveToken(String token) async {
    await sharedPreferences.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(_tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await sharedPreferences.remove(_tokenKey);
  }
}
