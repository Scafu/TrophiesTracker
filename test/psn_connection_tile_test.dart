import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';
import 'package:trophies_tracker/features/psn/domain/psn_repository.dart';
import 'package:trophies_tracker/features/psn/presentation/cubit/psn_cubit.dart';
import 'package:trophies_tracker/features/psn/presentation/cubit/psn_state.dart';
import 'package:trophies_tracker/features/psn/presentation/psn_connection_tile.dart';

final _now = DateTime(2025, 6, 10, 12);

class _Psn extends Fake implements PsnRepository {
  var authorizations = 0;
  var syncs = 0;
  var logouts = 0;

  @override
  Future<PsnAuthorization> authorization() async {
    authorizations++;
    throw const PsnException(PsnFailure.unavailable);
  }

  @override
  Future<PsnSyncResult> sync({
    void Function(int done, int total)? onProgress,
  }) async {
    syncs++;
    return const PsnSyncResult(total: 0, updated: 0);
  }

  @override
  Future<PsnLink?> link() async => const PsnLink(onlineId: 'Player');

  @override
  Future<void> logout() async => logouts++;
}

class _Prepared extends PsnCubit {
  _Prepared(this.psn, PsnState state)
    : super(psn, (_, _, {fresh = false}) async => '') {
    emit(state);
  }

  final _Psn psn;
}

Future<_Psn> _pump(WidgetTester tester, PsnState state) async {
  final psn = _Psn();
  final cubit = _Prepared(psn, state);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider<PsnCubit>.value(
            value: cubit,
            child: PsnConnectionTile(now: () => _now),
          ),
        ),
      ),
    ),
  );
  return psn;
}

PsnLink _link({String? name = 'Player', DateTime? expires, DateTime? synced}) =>
    PsnLink(
      onlineId: name,
      refreshExpiresAt: expires ?? DateTime(2025, 6, 18, 12),
      lastSync: synced ?? DateTime(2025, 6, 10, 10),
    );

const _notice =
    'Not affiliated with Sony. The PlayStation connection is unofficial and '
    'may stop working.';

IconButton _syncButton(WidgetTester tester) => tester.widget<IconButton>(
  find.ancestor(
    of: find.byTooltip('Sync library'),
    matching: find.byType(IconButton),
  ),
);

Future<void> _unlinkFromMenu(WidgetTester tester) async {
  await tester.tap(find.byTooltip('More'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Unlink'));
  await tester.pumpAndSettle();
}

void main() {
  group('not linked', () {
    testWidgets('is one short row with a button, and the notice', (
      tester,
    ) async {
      await _pump(tester, const PsnState(loaded: true));

      expect(find.text('PlayStation'), findsOneWidget);
      expect(find.text('Not linked'), findsOneWidget);
      expect(find.text('Link'), findsOneWidget);
      expect(find.text(_notice), findsOneWidget);
      expect(find.byTooltip('Sync library'), findsNothing);
      expect(find.byTooltip('More'), findsNothing);
    });

    testWidgets('the row is short, not a card', (tester) async {
      await _pump(tester, const PsnState(loaded: true));

      expect(
        tester.getSize(find.byType(PsnConnectionTile)).height,
        lessThan(120),
      );
    });

    testWidgets('the button starts the login', (tester) async {
      final psn = await _pump(tester, const PsnState(loaded: true));

      await tester.tap(find.text('Link'));
      await tester.pump();

      expect(psn.authorizations, 1);
    });

    testWidgets('the button waits while the browser is open', (tester) async {
      await _pump(
        tester,
        const PsnState(loaded: true, phase: PsnPhase.loggingIn),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('a failure is told in words', (tester) async {
      await _pump(
        tester,
        const PsnState(loaded: true, failure: PsnFailure.rejected),
      );

      expect(
        find.text('PlayStation refused the link. Try again.'),
        findsOneWidget,
      );
    });
  });

  group('linked', () {
    testWidgets('shows the name and the last sync on one line', (tester) async {
      await _pump(tester, PsnState(loaded: true, link: _link()));

      expect(find.text('Player · Synced 2 h ago'), findsOneWidget);
      expect(find.byTooltip('Sync library'), findsOneWidget);
      expect(find.byTooltip('More'), findsOneWidget);
      expect(find.text('Link'), findsNothing);
      expect(find.text(_notice), findsOneWidget);
    });

    testWidgets('does not mention the login while it has plenty of days', (
      tester,
    ) async {
      await _pump(tester, PsnState(loaded: true, link: _link()));

      expect(find.textContaining('Link expires'), findsNothing);
      expect(find.textContaining('Link expired'), findsNothing);
    });

    testWidgets('without a name it still says it is linked', (tester) async {
      await _pump(tester, PsnState(loaded: true, link: _link(name: null)));

      expect(find.text('PlayStation account · Synced 2 h ago'), findsOneWidget);
    });

    testWidgets('a library never synced says so', (tester) async {
      await _pump(
        tester,
        const PsnState(loaded: true, link: PsnLink(onlineId: 'Player')),
      );

      expect(find.text('Player · Not synced yet'), findsOneWidget);
    });

    testWidgets('sync and unlink call the account', (tester) async {
      final psn = await _pump(tester, PsnState(loaded: true, link: _link()));

      await tester.tap(find.byTooltip('Sync library'));
      await tester.pump();
      await _unlinkFromMenu(tester);

      expect((psn.syncs, psn.logouts), (1, 1));
    });

    testWidgets('while syncing it shows the progress and locks the buttons', (
      tester,
    ) async {
      await _pump(
        tester,
        PsnState(
          loaded: true,
          link: _link(),
          phase: PsnPhase.syncing,
          done: 3,
          total: 40,
        ),
      );

      expect(find.text('Syncing 3 of 40 games'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, closeTo(3 / 40, 1e-9));
      expect(_syncButton(tester).onPressed, isNull);
      expect(
        tester
            .widget<PopupMenuButton<void>>(find.byType(PopupMenuButton<void>))
            .enabled,
        isFalse,
      );
    });

    testWidgets('before it knows how many games, the bar has no end', (
      tester,
    ) async {
      await _pump(
        tester,
        PsnState(loaded: true, link: _link(), phase: PsnPhase.syncing),
      );

      expect(find.text('Checking your library…'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        isNull,
      );
    });

    testWidgets('the bar comes before the notice', (tester) async {
      await _pump(
        tester,
        PsnState(
          loaded: true,
          link: _link(),
          phase: PsnPhase.syncing,
          done: 1,
          total: 2,
        ),
      );

      expect(
        tester.getTopLeft(find.byType(LinearProgressIndicator)).dy,
        lessThan(tester.getTopLeft(find.text(_notice)).dy),
      );
    });
  });

  group('the login runs out', () {
    testWidgets('three days or less is a warning in the error color', (
      tester,
    ) async {
      await _pump(
        tester,
        PsnState(loaded: true, link: _link(expires: DateTime(2025, 6, 12, 18))),
      );

      final line = tester.widget<Text>(find.text('Link expires in 2 days'));
      final colors = Theme.of(
        tester.element(find.byType(Scaffold)),
      ).colorScheme;
      expect(line.style!.color, colors.error);
      expect(find.byTooltip('Sync library'), findsOneWidget);
    });

    testWidgets('once expired it asks to log in again instead of syncing', (
      tester,
    ) async {
      await _pump(
        tester,
        PsnState(loaded: true, link: _link(expires: DateTime(2025, 6, 9))),
      );

      expect(
        find.text('Link expired. Link again to keep syncing.'),
        findsOneWidget,
      );
      expect(find.text('Link again'), findsOneWidget);
      expect(find.byTooltip('Sync library'), findsNothing);
      expect(find.byTooltip('More'), findsOneWidget);
      expect(find.textContaining('Player'), findsOneWidget);
    });

    testWidgets('Sony refusing the login says why, once', (tester) async {
      await _pump(
        tester,
        PsnState(loaded: true, link: _link(), failure: PsnFailure.tokenExpired),
      );

      expect(find.text('Link again'), findsOneWidget);
      expect(find.byTooltip('Sync library'), findsNothing);
      expect(
        find.text(
          'Your PlayStation link has expired. Link it again to keep syncing.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the button logs in again', (tester) async {
      final psn = await _pump(
        tester,
        PsnState(loaded: true, link: _link(expires: DateTime(2025, 6, 9))),
      );

      await tester.tap(find.text('Link again'));
      await tester.pump();

      expect(psn.authorizations, 1);
    });

    testWidgets('a failure other than the login is shown under the status', (
      tester,
    ) async {
      await _pump(
        tester,
        PsnState(loaded: true, link: _link(), failure: PsnFailure.unavailable),
      );

      expect(
        find.text('PlayStation could not be reached. Try again in a moment.'),
        findsOneWidget,
      );
      expect(find.byTooltip('Sync library'), findsOneWidget);
    });
  });

  test('the days left read as a short line', () {
    PsnLink end(DateTime when) => PsnLink(refreshExpiresAt: when);

    expect(
      psnLinkLine(end(DateTime(2025, 6, 11, 12)), _now),
      'Link expires in 1 day',
    );
    expect(
      psnLinkLine(end(DateTime(2025, 6, 10, 20)), _now),
      'Link expires within a day',
    );
    expect(psnLinkLine(end(DateTime(2025, 6, 10)), _now), 'Link expired');
    expect(psnLinkLine(const PsnLink(), _now), '');
  });
}
