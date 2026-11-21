import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/core/utils/pkce/pkce.dart';
import 'package:trophies_tracker/features/account/data/datasource/account_local_data_source.dart';
import 'package:trophies_tracker/features/account/data/datasource/account_remote_data_source.dart';
import 'package:trophies_tracker/features/account/domain/entities/steam_user.dart';
import 'package:trophies_tracker/features/account/domain/repositories/account_repository.dart';

/// Implementation of the [AccountRepository] handling authentication and user data.
class AccountRepositoryImpl implements AccountRepository {
  /// The remote data source for network authentication requests.
  final AccountRemoteDataSource remoteDataSource;

  /// The local data source for persisting user sessions.
  final AccountLocalDataSource localDataSource;

  /// Creates a new [AccountRepositoryImpl].
  AccountRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<String> startLogin() async {
    final pkce = Pkce.generate();
    await localDataSource.saveLoginVerifier(pkce.verifier);
    return remoteDataSource.getSteamLoginUrl(pkce.challenge);
  }

  @override
  Future<String?> getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<SteamUser?> finishLogin(String code) async {
    final verifier = await localDataSource.takeLoginVerifier();
    if (verifier == null) return null;

    final token = await remoteDataSource.exchangeCode(code, verifier);
    await localDataSource.saveToken(token);
    final userModel = await remoteDataSource.getSteamUserInfo(token);
    await localDataSource.saveUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<SteamUser?> getLoggedInUser() async {
    final userModel = await localDataSource.getUser();
    if (userModel == null) return null;
    final token = await localDataSource.getToken();
    return userModel.toEntity().copyWith(token: token);
  }

  /// Ends the session. Revoking the token on the server is best effort: the
  /// local session is cleared even when the network call fails.
  @override
  Future<void> logout() async {
    final token = await localDataSource.getToken();
    if (token != null) {
      try {
        await remoteDataSource.revokeToken(token);
      } catch (e) {
        logger.w('Could not revoke the session token: $e');
      }
    }
    await localDataSource.deleteToken();
    await localDataSource.deleteUser();
  }
}
