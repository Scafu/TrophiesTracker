import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';
import 'package:trophies_tracker/features/psn/domain/psn_repository.dart';
import 'package:trophies_tracker/features/psn/presentation/cubit/psn_cubit.dart';
import 'package:trophies_tracker/features/psn/presentation/cubit/psn_state.dart';

class _Psn extends Fake implements PsnRepository {
  PsnLink? current;
  Object? loginFails;
  Object? syncFails;
  Object? linkFails;
  final loggedWith = <String>[];
  var syncs = 0;
  var logouts = 0;
  final List<(int, int)> progress = [(0, 2), (1, 2), (2, 2)];
  Completer<void>? syncGate;

  @override
  Future<PsnAuthorization> authorization() async => const PsnAuthorization(
    url: 'https://sony.test/login',
    callbackScheme: 'sony.scheme',
  );

  @override
  Future<PsnLink?> link() async {
    final failure = linkFails;
    if (failure != null) throw failure;
    return current;
  }

  @override
  Future<PsnLink> login(String code) async {
    loggedWith.add(code);
    final failure = loginFails;
    if (failure != null) throw failure;
    return current = const PsnLink(onlineId: 'Player');
  }

  @override
  Future<PsnSyncResult> sync({
    void Function(int done, int total)? onProgress,
  }) async {
    syncs++;
    for (final (done, total) in progress) {
      onProgress?.call(done, total);
    }
    await syncGate?.future;
    final failure = syncFails;
    if (failure != null) throw failure;
    current = PsnLink(onlineId: 'Player', lastSync: DateTime(2025, 6));
    return const PsnSyncResult(total: 2, updated: 2);
  }

  @override
  Future<void> logout() async {
    logouts++;
    current = null;
  }
}

typedef _Opener =
    Future<String> Function(String url, String scheme, {bool fresh});

(PsnCubit, _Psn, List<(String, String, bool)>) _make({_Opener? opener}) {
  final psn = _Psn();
  final opened = <(String, String, bool)>[];
  final cubit = PsnCubit(psn, (url, scheme, {fresh = false}) {
    opened.add((url, scheme, fresh));
    return opener == null
        ? Future.value('sony.scheme://redirect?code=abc')
        : opener(url, scheme, fresh: fresh);
  });
  addTearDown(cubit.close);
  return (cubit, psn, opened);
}

void main() {
  group('load', () {
    test('reads the linked account', () async {
      final (cubit, psn, _) = _make();
      psn.current = const PsnLink(onlineId: 'Player');

      await cubit.load();

      expect(cubit.state.loaded, isTrue);
      expect(cubit.state.link!.onlineId, 'Player');
    });

    test('with no account there is no link', () async {
      final (cubit, _, _) = _make();

      await cubit.load();

      expect((cubit.state.loaded, cubit.state.link), (true, null));
    });

    test('a storage failure leaves it unlinked, not stuck', () async {
      final (cubit, psn, _) = _make();
      psn.linkFails = Exception('storage');

      await cubit.load();

      expect((cubit.state.loaded, cubit.state.link), (true, null));
    });
  });

  group('login', () {
    test('opens Sony in the browser, links the account and syncs', () async {
      final (cubit, psn, opened) = _make();
      final seen = <PsnState>[];
      cubit.stream.listen(seen.add);

      await cubit.login();
      await Future<void>.delayed(Duration.zero);

      expect(opened, [('https://sony.test/login', 'sony.scheme', true)]);
      expect(psn.loggedWith, ['abc']);
      expect(psn.syncs, 1);
      expect(cubit.state.phase, PsnPhase.idle);
      expect(cubit.state.link!.onlineId, 'Player');
      expect(cubit.state.failure, isNull);
      expect(seen.map((s) => s.phase), contains(PsnPhase.loggingIn));
      expect(seen.map((s) => s.phase), contains(PsnPhase.syncing));
    });

    test('with no account linked the browser session is a fresh one', () async {
      final (cubit, _, opened) = _make();

      await cubit.login();

      expect(opened.single.$3, isTrue);
    });

    test(
      'logging in again with the linked account shares the session',
      () async {
        final (cubit, psn, opened) = _make();
        psn.current = const PsnLink(onlineId: 'Player');
        await cubit.load();

        await cubit.login();

        expect(opened.single.$3, isFalse);
      },
    );

    test(
      'after a logout the next login is fresh, to pick another account',
      () async {
        final (cubit, psn, opened) = _make();
        psn.current = const PsnLink(onlineId: 'Player');
        await cubit.load();
        await cubit.logout();

        await cubit.login();

        expect(opened.single.$3, isTrue);
        expect(psn.logouts, 1);
      },
    );

    test('a login the user cancels is not a failure', () async {
      final (cubit, psn, _) = _make(
        opener: (_, _, {fresh = false}) =>
            throw PlatformException(code: 'CANCELED'),
      );

      await cubit.login();

      expect(cubit.state.phase, PsnPhase.idle);
      expect(cubit.state.failure, isNull);
      expect(psn.loggedWith, isEmpty);
      expect(psn.syncs, 0);
    });

    test('another platform error is Sony being unreachable', () async {
      final (cubit, _, _) = _make(
        opener: (_, _, {fresh = false}) =>
            throw PlatformException(code: 'FAILED'),
      );

      await cubit.login();

      expect(cubit.state.failure, PsnFailure.unavailable);
      expect(cubit.state.phase, PsnPhase.idle);
    });

    test('coming back without a code is a failure', () async {
      final (cubit, psn, _) = _make(
        opener: (_, _, {fresh = false}) async =>
            'sony.scheme://redirect?error=access_denied',
      );

      await cubit.login();

      expect(cubit.state.failure, PsnFailure.unavailable);
      expect(psn.loggedWith, isEmpty);
    });

    test('Sony refusing the code stops before the sync', () async {
      final (cubit, psn, _) = _make();
      psn.loginFails = const PsnException(PsnFailure.rejected);

      await cubit.login();

      expect(cubit.state.failure, PsnFailure.rejected);
      expect(cubit.state.link, isNull);
      expect(psn.syncs, 0);
    });

    test('is ignored while another login is open in the browser', () async {
      final gate = Completer<String>();
      final (cubit, _, opened) = _make(
        opener: (_, _, {fresh = false}) => gate.future,
      );

      final first = cubit.login();
      await cubit.login();
      expect(opened, hasLength(1));
      expect(cubit.state.phase, PsnPhase.loggingIn);

      gate.complete('sony.scheme://redirect?code=abc');
      await first;
      expect(opened, hasLength(1));
    });

    test('clears the failure of the attempt before', () async {
      final (cubit, psn, _) = _make();
      psn.loginFails = const PsnException(PsnFailure.rejected);
      await cubit.login();
      psn.loginFails = null;

      await cubit.login();

      expect(cubit.state.failure, isNull);
    });
  });

  group('sync', () {
    test('tells how far it is, then the new last sync', () async {
      final (cubit, psn, _) = _make();
      psn.current = const PsnLink(onlineId: 'Player');
      await cubit.load();
      final seen = <(int, int)>[];
      cubit.stream.listen((s) {
        if (s.phase == PsnPhase.syncing) seen.add((s.done, s.total));
      });

      await cubit.sync();
      await Future<void>.delayed(Duration.zero);

      expect(seen, containsAllInOrder([(0, 0), (0, 2), (1, 2), (2, 2)]));
      expect(cubit.state.phase, PsnPhase.idle);
      expect(cubit.state.link!.lastSync, DateTime(2025, 6));
    });

    test('an expired login is told apart, and asks to log in again', () async {
      final (cubit, psn, _) = _make();
      psn.current = const PsnLink(onlineId: 'Player');
      await cubit.load();
      psn.syncFails = const PsnException(PsnFailure.tokenExpired);

      await cubit.sync();

      expect(cubit.state.failure, PsnFailure.tokenExpired);
      expect(cubit.state.loginNeeded(DateTime(2025, 6)), isTrue);
      expect(cubit.state.link!.onlineId, 'Player');
    });

    test('anything unexpected ends as Sony being unreachable', () async {
      final (cubit, psn, _) = _make();
      psn.syncFails = StateError('database');

      await cubit.sync();

      expect(cubit.state.failure, PsnFailure.unavailable);
      expect(cubit.state.phase, PsnPhase.idle);
    });

    test('does not start a second sync while one runs', () async {
      final (cubit, psn, _) = _make();
      psn.syncGate = Completer<void>();

      final first = cubit.sync();
      await cubit.sync();
      expect(psn.syncs, 1);

      psn.syncGate!.complete();
      await first;
      expect(psn.syncs, 1);
    });
  });

  group('logout', () {
    test('forgets the account and every failure', () async {
      final (cubit, psn, _) = _make();
      psn.current = const PsnLink(onlineId: 'Player');
      await cubit.load();
      psn.syncFails = const PsnException(PsnFailure.unavailable);
      await cubit.sync();

      await cubit.logout();

      expect(psn.logouts, 1);
      expect(
        (cubit.state.loaded, cubit.state.link, cubit.state.failure),
        (true, null, null),
      );
    });

    test('is ignored while syncing', () async {
      final (cubit, psn, _) = _make();
      psn.syncGate = Completer<void>();
      final syncing = cubit.sync();

      await cubit.logout();
      expect(psn.logouts, 0);

      psn.syncGate!.complete();
      await syncing;
    });
  });

  group('PsnState.loginNeeded', () {
    final now = DateTime(2025, 6, 10);

    test('is false with no account', () {
      expect(const PsnState().loginNeeded(now), isFalse);
    });

    test('is true once the renewal token has run out', () {
      final state = PsnState(
        link: PsnLink(refreshExpiresAt: DateTime(2025, 6, 9)),
      );

      expect(state.loginNeeded(now), isTrue);
    });

    test('is false while it still lasts', () {
      final state = PsnState(
        link: PsnLink(refreshExpiresAt: DateTime(2025, 6, 20)),
      );

      expect(state.loginNeeded(now), isFalse);
    });
  });
}
