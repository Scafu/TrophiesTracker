import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trophies_tracker/features/psn/data/web_authenticate.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';
import 'package:trophies_tracker/features/psn/domain/psn_repository.dart';
import 'package:trophies_tracker/features/psn/presentation/cubit/psn_state.dart';

/// The PlayStation account: logging in through the browser, syncing the
/// library and logging out. Every failure becomes a fixed [PsnFailure] in the
/// state; nothing Sony sent is kept.
class PsnCubit extends Cubit<PsnState> {
  final PsnRepository _repository;
  final WebAuthenticate _authenticate;

  PsnCubit(this._repository, this._authenticate) : super(const PsnState());

  /// Reads the saved link, so the page knows whether an account is linked.
  Future<void> load() async {
    try {
      emit(state.copyWith(loaded: true, link: await _repository.link()));
    } catch (_) {
      emit(state.copyWith(loaded: true));
    }
  }

  /// Opens Sony's login in the browser, links the account and syncs it. It
  /// does nothing while another login or sync is running, and a login the user
  /// cancels is not a failure.
  ///
  /// With no account linked (the first login, or after a logout) the browser
  /// session is a fresh one, so Sony asks for the credentials and the user can
  /// pick another account. To log in again with the account already linked the
  /// session is shared, which keeps it to one tap.
  Future<void> login() async {
    if (state.busy) return;
    emit(state.copyWith(phase: PsnPhase.loggingIn, clearFailure: true));

    try {
      final authorization = await _repository.authorization();
      final callback = await _authenticate(
        authorization.url,
        authorization.callbackScheme,
        fresh: state.link == null,
      );
      final code = Uri.tryParse(callback)?.queryParameters['code'];
      if (code == null || code.isEmpty) {
        throw const PsnException(PsnFailure.unavailable);
      }
      emit(state.copyWith(link: await _repository.login(code)));
    } on PlatformException catch (e) {
      emit(
        state.copyWith(
          phase: PsnPhase.idle,
          failure: e.code == 'CANCELED' ? null : PsnFailure.unavailable,
        ),
      );
      return;
    } on PsnException catch (e) {
      emit(state.copyWith(phase: PsnPhase.idle, failure: e.failure));
      return;
    } catch (_) {
      emit(
        state.copyWith(phase: PsnPhase.idle, failure: PsnFailure.unavailable),
      );
      return;
    }

    await _sync();
  }

  /// Brings the library up to date. It does nothing while something else runs.
  Future<void> sync() async {
    if (state.busy) return;
    await _sync();
  }

  Future<void> _sync() async {
    emit(
      state.copyWith(
        phase: PsnPhase.syncing,
        done: 0,
        total: 0,
        clearFailure: true,
      ),
    );

    try {
      await _repository.sync(
        onProgress: (done, total) =>
            emit(state.copyWith(done: done, total: total)),
      );
      emit(
        state.copyWith(phase: PsnPhase.idle, link: await _repository.link()),
      );
    } on PsnException catch (e) {
      emit(state.copyWith(phase: PsnPhase.idle, failure: e.failure));
    } catch (_) {
      emit(
        state.copyWith(phase: PsnPhase.idle, failure: PsnFailure.unavailable),
      );
    }
  }

  /// Unlinks the account and deletes the games synced from it.
  Future<void> logout() async {
    if (state.busy) return;
    try {
      await _repository.logout();
      emit(const PsnState(loaded: true));
    } catch (_) {
      emit(state.copyWith(failure: PsnFailure.unavailable));
    }
  }
}
