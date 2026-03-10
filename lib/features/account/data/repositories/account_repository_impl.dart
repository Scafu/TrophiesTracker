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
  String getLoginUrl() {
    return remoteDataSource.getSteamLoginUrl();
  }

  @override
  Future<String?> getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<SteamUser> finishLogin(String token) async {
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

  @override
  Future<void> logout() async {
    await localDataSource.deleteToken();
    await localDataSource.deleteUser();
  }
}
