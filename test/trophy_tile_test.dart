import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/domain/repositories/activity_repository.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/details/ui/trophy_tile.dart';

class _Repository extends Fake implements GameRepository {
  _Repository(this.game);

  final Game game;
  final toggles = <(String, bool)>[];

  @override
  Future<bool> isGameInLibrary(GameKey key) async => true;

  @override
  Future<Game> getGameByIdLocal(GameKey key) async => game;

  @override
  Future<void> updateStateTrophy(
    GameKey key,
    String trophyName,
    bool status,
  ) async => toggles.add((trophyName, status));
}

class _Activities extends Fake implements ActivityRepository {}

const _locked = Trophy(
  apiName: 'a',
  displayName: 'First Blood',
  description: 'Defeat your first enemy',
);

final _unlocked = Trophy(
  apiName: 'b',
  displayName: 'Veteran',
  isAchieved: true,
  achievedAt: DateTime(2025, 1, 5),
);

Future<_Repository> _pump(
  WidgetTester tester, {
  required Trophy trophy,
  bool synced = false,
  bool fromExplorer = false,
  double? rarity,
  GamePlatform platform = GamePlatform.steam,
}) async {
  final game = Game(
    platform: platform,
    code: '1',
    name: 'G',
    isSynced: synced,
    trophies: [trophy],
  );
  final repository = _Repository(game);
  final cubit = GameDetailsCubit(
    repository,
    RateRequestLimiter(),
    _Activities(),
  );
  addTearDown(cubit.close);
  await cubit.loadGameDetails(game.key);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: TrophyTile(
            game: game,
            trophy: trophy,
            fromExplorer: fromExplorer,
            rarity: rarity,
          ),
        ),
      ),
    ),
  );
  return repository;
}

Future<void> _tap(WidgetTester tester) async {
  await tester.tap(find.byType(InkWell));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('a trophy of a manual game is unlocked with a tap', (
    tester,
  ) async {
    final repository = await _pump(tester, trophy: _locked);

    expect(find.text('First Blood'), findsOneWidget);
    expect(find.text('Defeat your first enemy'), findsOneWidget);
    await _tap(tester);

    expect(repository.toggles, [('a', true)]);
  });

  testWidgets('a synced game explains it cannot be changed by hand', (
    tester,
  ) async {
    final repository = await _pump(tester, trophy: _locked, synced: true);

    await _tap(tester);

    expect(
      find.text('Cannot manually unlock trophies for synced games'),
      findsOneWidget,
    );
    expect(repository.toggles, isEmpty);
  });

  testWidgets('a game outside the library asks to be added first', (
    tester,
  ) async {
    final repository = await _pump(tester, trophy: _locked, fromExplorer: true);

    await _tap(tester);

    expect(find.text('Add to library to unlock trophies'), findsOneWidget);
    expect(repository.toggles, isEmpty);
  });

  testWidgets('an unlocked trophy shows its date and a check', (tester) async {
    await _pump(tester, trophy: _unlocked, synced: true);

    expect(find.text('5 Jan 2025'), findsOneWidget);
    expect(find.byIcon(Symbols.check_rounded), findsOneWidget);
  });

  testWidgets('a locked trophy of a synced game has no check to tap', (
    tester,
  ) async {
    await _pump(tester, trophy: _locked, synced: true);

    expect(find.byIcon(Symbols.check_rounded), findsNothing);
  });

  testWidgets('the rarity is shown and announced to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, trophy: _unlocked, synced: true, rarity: 3.5);

    expect(find.text('3.5% · Ultra rare'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Veteran. Unlocked on 5 Jan 2025. 3.5% · Ultra rare',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  group('PlayStation trophies', () {
    const hidden = Trophy(
      apiName: 'h',
      displayName: 'Secret Ending',
      description: 'Spoils the story',
      hidden: true,
      type: TrophyType.gold,
    );

    testWidgets('show their grade next to the rarity', (tester) async {
      await _pump(
        tester,
        trophy: const Trophy(
          apiName: 'p',
          displayName: 'Platinum',
          type: TrophyType.platinum,
        ),
        synced: true,
        rarity: 1.2,
        platform: GamePlatform.psn,
      );

      expect(find.text('Platinum'), findsNWidgets(2));
      expect(find.text('1.2% · Ultra rare'), findsOneWidget);
    });

    testWidgets('a trophy with no grade, like Steam\'s, shows none', (
      tester,
    ) async {
      await _pump(tester, trophy: _locked, synced: true);

      expect(find.byIcon(Symbols.workspace_premium_rounded), findsNothing);
    });

    testWidgets('a hidden trophy not yet earned does not show what it is', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        trophy: hidden,
        synced: true,
        platform: GamePlatform.psn,
      );

      expect(find.text('Hidden trophy'), findsOneWidget);
      expect(find.text('Tap to reveal'), findsOneWidget);
      expect(find.text('Secret Ending'), findsNothing);
      expect(find.text('Spoils the story'), findsNothing);
      expect(find.byIcon(Symbols.lock_rounded), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Secret Ending')), findsNothing);
      handle.dispose();
    });

    testWidgets('a tap reveals it, and the next tap explains as usual', (
      tester,
    ) async {
      await _pump(
        tester,
        trophy: hidden,
        synced: true,
        platform: GamePlatform.psn,
      );

      await _tap(tester);

      expect(find.text('Secret Ending'), findsOneWidget);
      expect(find.text('Spoils the story'), findsOneWidget);
      expect(find.text('Hidden trophy'), findsNothing);
      expect(
        find.text('Cannot manually unlock trophies for synced games'),
        findsNothing,
      );

      await _tap(tester);

      expect(
        find.text('Cannot manually unlock trophies for synced games'),
        findsOneWidget,
      );
    });

    testWidgets('a hidden trophy that is earned shows its name', (
      tester,
    ) async {
      await _pump(
        tester,
        trophy: hidden.copyWith(isAchieved: true),
        synced: true,
        platform: GamePlatform.psn,
      );

      expect(find.text('Secret Ending'), findsOneWidget);
      expect(find.text('Hidden trophy'), findsNothing);
    });
  });

  test('the grades have a name and a color of their own', () {
    expect(TrophyType.values.map(TrophyTypeChip.label), [
      'Bronze',
      'Silver',
      'Gold',
      'Platinum',
    ]);
    expect(TrophyType.values.map(TrophyTypeChip.color).toSet(), hasLength(4));
  });

  test('rarity labels read as a percentage and a tier', () {
    expect(RarityChip.label(0.04), '<0.1% · Ultra rare');
    expect(RarityChip.label(12.3), '12% · Very rare');
    expect(RarityChip.label(33), '33% · Rare');
    expect(RarityChip.label(87), '87% · Common');
  });
}
