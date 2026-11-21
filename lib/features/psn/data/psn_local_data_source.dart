import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';

/// What the app keeps of the PlayStation account: the renewal token in the
/// secure storage, never in plain text, and the rest in [SharedPreferences].
abstract class PsnLocalDataSource {
  Future<String?> refreshToken();

  /// Keeps [refreshToken] and, when given, the name and the end of its life.
  Future<void> saveLogin({
    required String refreshToken,
    String? onlineId,
    DateTime? refreshExpiresAt,
  });

  /// Keeps a renewal token Sony replaced, with the end of its life.
  Future<void> saveRefreshToken(
    String refreshToken, {
    DateTime? refreshExpiresAt,
  });

  Future<void> saveLastSync(DateTime when);

  /// Keeps the player's name, found after the login.
  Future<void> saveOnlineId(String onlineId);

  /// The linked account, or null when there is no renewal token.
  Future<PsnLink?> link();

  Future<void> clear();
}

class PsnLocalDataSourceImpl implements PsnLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  static const _tokenKey = 'psn_refresh_token';
  static const _nameKey = 'psn_online_id';
  static const _expiresKey = 'psn_refresh_expires_at';
  static const _syncKey = 'psn_last_sync';

  PsnLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<String?> refreshToken() => secureStorage.read(key: _tokenKey);

  @override
  Future<void> saveLogin({
    required String refreshToken,
    String? onlineId,
    DateTime? refreshExpiresAt,
  }) async {
    await saveRefreshToken(refreshToken, refreshExpiresAt: refreshExpiresAt);
    if (onlineId == null) {
      await sharedPreferences.remove(_nameKey);
    } else {
      await sharedPreferences.setString(_nameKey, onlineId);
    }
  }

  @override
  Future<void> saveRefreshToken(
    String refreshToken, {
    DateTime? refreshExpiresAt,
  }) async {
    await secureStorage.write(key: _tokenKey, value: refreshToken);
    if (refreshExpiresAt == null) {
      await sharedPreferences.remove(_expiresKey);
    } else {
      await sharedPreferences.setInt(
        _expiresKey,
        refreshExpiresAt.millisecondsSinceEpoch,
      );
    }
  }

  @override
  Future<void> saveLastSync(DateTime when) =>
      sharedPreferences.setInt(_syncKey, when.millisecondsSinceEpoch);

  @override
  Future<void> saveOnlineId(String onlineId) =>
      sharedPreferences.setString(_nameKey, onlineId);

  DateTime? _date(String key) {
    final millis = sharedPreferences.getInt(key);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  Future<PsnLink?> link() async {
    if (await refreshToken() == null) return null;
    return PsnLink(
      onlineId: sharedPreferences.getString(_nameKey),
      refreshExpiresAt: _date(_expiresKey),
      lastSync: _date(_syncKey),
    );
  }

  @override
  Future<void> clear() async {
    await secureStorage.delete(key: _tokenKey);
    for (final key in [_nameKey, _expiresKey, _syncKey]) {
      await sharedPreferences.remove(key);
    }
  }
}
