import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/core/services/log.dart';
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
    try {
      final uri = Uri.parse(await repository.startLogin());
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

  /// Handles the login callback: a `trophiestracker://` link or the verified
  /// `https` App Link carrying the one-time `code`. Any other link is ignored.
  void _handleDeepLink(Uri uri) {
    if (uri.scheme != 'trophiestracker' && uri.scheme != 'https') return;

    final code = uri.queryParameters['code'];
    if (code != null) _finishLogin(code);
  }

  /// Completes the login by exchanging the one-time [code] for a session.
  ///
  /// A repeated or unsolicited link finds no login in progress and leaves the
  /// state as it was.
  Future<void> _finishLogin(String code) async {
    final previous = state;
    emit(const AccountState.loading());
    try {
      final user = await repository.finishLogin(code);
      if (isClosed) return;
      emit(user == null ? previous : AccountState.authenticated(user));
    } catch (e) {
      logger.e('Steam login failed: $e');
      if (!isClosed) {
        emit(
          const AccountState.error(
            'Could not complete the Steam login. Please try again.',
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _linkSubscription?.cancel();
    return super.close();
  }
}
