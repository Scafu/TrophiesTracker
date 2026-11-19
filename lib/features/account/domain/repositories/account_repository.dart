import 'package:trophies_tracker/features/account/domain/entities/steam_user.dart';

abstract class AccountRepository {
  /// Starts a Steam login and returns the URL to open in the browser.
  Future<String> startLogin();

  /// Completes the login with the one-time [code] received in the deep link.
  ///
  /// Returns null when no login is in progress, e.g. for a repeated or
  /// unsolicited link.
  Future<SteamUser?> finishLogin(String code);

  Future<void> logout();
  Future<SteamUser?> getLoggedInUser();
  Future<String?> getToken();
}
