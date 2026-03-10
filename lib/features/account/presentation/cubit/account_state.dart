import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:trophies_tracker/features/account/domain/entities/steam_user.dart';

part 'account_state.freezed.dart';

/// Represents the various states of the account authentication process.
@freezed
class AccountState with _$AccountState {
  /// The initial state before any authentication check has occurred.
  const factory AccountState.initial() = _Initial;

  /// The state when authentication or user data fetching is in progress.
  const factory AccountState.loading() = _Loading;

  /// The state when a user is successfully authenticated.
  const factory AccountState.authenticated(SteamUser user) = _Authenticated;

  /// The state when no user is currently authenticated.
  const factory AccountState.unauthenticated() = _Unauthenticated;

  /// The state when an error occurs during the authentication process.
  const factory AccountState.error(String message) = _Error;
}
