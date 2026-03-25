import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/features/account/domain/repositories/account_repository.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// Cubit responsible for managing the account authentication state and Steam login flow.
class AccountCubit extends Cubit<AccountState> {
  /// The repository handling account data operations.
  final AccountRepository repository;
  final GameRepository gameRepository;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initializes the [AccountCubit] and starts listening for deep links.
  AccountCubit(this.repository, this.gameRepository)
    : super(const AccountState.initial()) {
    _initDeepLinkListener();
  }

  /// Initializes the deep link listener to capture authentication callbacks.
  Future<void> _initDeepLinkListener() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      if (!isClosed) emit(AccountState.error(e.toString()));
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (Object e) {
        if (!isClosed) emit(AccountState.error(e.toString()));
      },
    );
  }

  /// Checks the current authentication status of the user.
  Future<void> checkStatus() async {
    emit(const AccountState.loading());
    try {
      final user = await repository.getLoggedInUser();

      if (isClosed) return;

      if (user != null) {
        emit(AccountState.authenticated(user));
      } else {
        emit(const AccountState.unauthenticated());
      }
    } catch (e) {
      if (!isClosed) emit(AccountState.error(e.toString()));
    }
  }

  /// Initiates the Steam login flow by launching the external browser.
  Future<void> login() async {
    final loginUrl = repository.getLoginUrl();
    final uri = Uri.parse(loginUrl);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!isClosed) {
        emit(const AccountState.error('Could not launch Steam login.'));
      }
    }
  }

  /// Logs out the currently authenticated user.
  Future<void> logout() async {
    emit(const AccountState.loading());
    try {
      await repository.logout();

      await gameRepository.deleteGamesBySource('steam', onlySynced: true);

      if (!isClosed) {
        emit(const AccountState.unauthenticated());
      }
    } catch (e) {
      if (!isClosed) emit(AccountState.error(e.toString()));
    }
  }

  /// Handles incoming deep links and extracts the Steam ID if present.
  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'trophiestracker') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        _finishLogin(token);
      }
    }
  }

  /// Completes the login process using the extracted Steam ID.
  Future<void> _finishLogin(String token) async {
    emit(const AccountState.loading());
    try {
      final user = await repository.finishLogin(token);
      if (!isClosed) emit(AccountState.authenticated(user));
    } catch (e) {
      if (!isClosed) emit(AccountState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _linkSubscription?.cancel();
    return super.close();
  }
}
