import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_state.dart';

class _CatalogRepository extends Fake implements GameRepository {
  _CatalogRepository({
    this.matches = const {},
    this.failSearch = false,
    this.failCovers = false,
  });

  final Map<String, List<Game>> matches;
  final bool failSearch;
  final bool failCovers;
  Completer<void>? coversGate;
  final searched = <String>[];

  @override
  Future<List<Game>> searchLocalCatalog(String query) async {
    searched.add(query);
    if (failSearch) throw Exception('db');
    return matches[query] ?? const [];
  }

  @override
  Future<List<Game>> withCovers(List<Game> games) async {
    await coversGate?.future;
    if (failCovers) throw Exception('offline');
    return [
      for (final g in games) g.copyWith(libraryImage: 'cover-${g.appId}'),
    ];
  }
}

const _portal = Game(appId: 400, name: 'Portal');
const _portal2 = Game(appId: 620, name: 'Portal 2');

({ExploreCubit cubit, List<ExploreState> states}) _setUp(
  _CatalogRepository repository,
) {
  final cubit = ExploreCubit(repository);
  addTearDown(cubit.close);
  final states = <ExploreState>[];
  cubit.stream.listen(states.add);
  return (cubit: cubit, states: states);
}

List<String?> _covers(ExploreState state) => [
  for (final game in (state as ExploreSuccess).searchResults) game.libraryImage,
];

void main() {
  test('results show at once, then again with their real covers', () async {
    final (:cubit, :states) = _setUp(
      _CatalogRepository(
        matches: {
          'portal': [_portal, _portal2],
        },
      ),
    );

    await cubit.searchGames('  portal ');
    await pumpEventQueue();

    expect(states, hasLength(2));
    expect(_covers(states[0]), [null, null]);
    expect(_covers(states[1]), ['cover-400', 'cover-620']);
  });

  test('a search with no matches says so', () async {
    final (:cubit, :states) = _setUp(_CatalogRepository());

    await cubit.searchGames('zzz');
    await pumpEventQueue();

    expect(states.single, isA<ExploreEmpty>());
  });

  test('clearing the field goes back to the start screen', () async {
    final (:cubit, :states) = _setUp(
      _CatalogRepository(
        matches: {
          'portal': [_portal],
        },
      ),
    );

    await cubit.searchGames('portal');
    await cubit.searchGames('   ');
    await pumpEventQueue();

    expect(states.last, isA<ExploreInitial>());
  });

  test(
    'a late cover lookup never replaces the results of a newer query',
    () async {
      final gate = Completer<void>();
      final repository = _CatalogRepository(
        matches: {
          'portal': [_portal],
          'hades': [const Game(appId: 1145360, name: 'Hades')],
        },
      )..coversGate = gate;
      final (:cubit, :states) = _setUp(repository);

      final first = cubit.searchGames('portal');
      await pumpEventQueue();
      repository.coversGate = null;
      await cubit.searchGames('hades');
      gate.complete();
      await first;
      await pumpEventQueue();

      final last = states.last as ExploreSuccess;
      expect(last.searchResults.single.name, 'Hades');
    },
  );

  test('failing to look covers up keeps the results', () async {
    final (:cubit, :states) = _setUp(
      _CatalogRepository(
        matches: {
          'portal': [_portal],
        },
        failCovers: true,
      ),
    );

    await cubit.searchGames('portal');
    await pumpEventQueue();

    expect(states, hasLength(1));
    expect(states.single, isA<ExploreSuccess>());
  });

  test('a database failure becomes a readable error', () async {
    final (:cubit, :states) = _setUp(_CatalogRepository(failSearch: true));

    await cubit.searchGames('portal');
    await pumpEventQueue();

    expect(
      (states.single as ExploreError).message,
      'Search failed. Please try again.',
    );
  });
}
