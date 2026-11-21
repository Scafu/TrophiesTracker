import 'package:trophies_tracker/features/psn/domain/psn_models.dart';

/// The PlayStation account: the login, the library sync and the logout.
///
/// Every failure is a [PsnException] with one of the fixed [PsnFailure]s.
/// [PsnFailure.tokenExpired] means the user has to log in again.
abstract class PsnRepository {
  /// The login page of Sony and the scheme it returns to the app with.
  Future<PsnAuthorization> authorization();

  /// Exchanges the [code] that Sony sent back after the login and keeps the
  /// account linked.
  Future<PsnLink> login(String code);

  /// The linked account, or null when there is none.
  Future<PsnLink?> link();

  /// Brings the library up to date, reading again only the games that are new
  /// or changed. [onProgress] is told how many of those are done.
  Future<PsnSyncResult> sync({void Function(int done, int total)? onProgress});

  /// Unlinks the account and deletes the games synced from it.
  Future<void> logout();
}
