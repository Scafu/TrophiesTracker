import 'package:trophies_tracker/features/account/domain/entities/steam_user.dart';

abstract class AccountRepository {
  String getLoginUrl();
  Future<SteamUser> finishLogin(String steamId);
  Future<void> logout();
  Future<SteamUser?> getLoggedInUser();
  Future<String?> getToken();
}
