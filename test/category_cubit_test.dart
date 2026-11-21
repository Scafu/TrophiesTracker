import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/category_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/category_state.dart';

class _Repository extends Fake implements GameRepository {
  _Repository({this.games = const [], this.failCovers = false});

  List<Game> games;
  final bool failCovers;
  Object? failure;
  Completer<void>? coversGate;
  final asked = <int>[];

  @override
  Future<List<Game>> getCategoryGames(int tagId) async {
    asked.add(tagId);
    if (failure != null) throw failure!;
    return games;
  }

  @override
  Future<List<Game>> withCovers(List<Game> games) async {
    await coversGate?.future;
    if (failCovers) throw Exception('offline');
    return [for (final g in games) g.copyWith(libraryImage: 'cover-${g.code}')];
  }
}

const _portal = Game(code: '620', name: 'Portal 2');
const _terraria = Game(code: '105600', name: 'Terraria');

({CategoryCubit cubit, List<CategoryState> states}) _setUp(
  _Repository repository,
) {
  final cubit = CategoryCubit(repository);
  addTearDown(cubit.close);
  final states = <CategoryState>[];
  cubit.stream.listen(states.add);
  return (cubit: cubit, states: states);
}

List<String?> _covers(CategoryState state) => [
  for (final g in (state as CategoryLoaded).games) g.libraryImage,
];

void main() {
  test('the games show at once, then again with their real covers', () async {
    final (:cubit, :states) = _setUp(
      _Repository(games: const [_portal, _terraria]),
    );

    await cubit.load(122);
    await pumpEventQueue();

    expect(states.map((s) => s.runtimeType), [
      CategoryLoading,
      CategoryLoaded,
      CategoryLoaded,
    ]);
    expect(_covers(states[1]), [null, null]);
    expect(_covers(states[2]), ['cover-620', 'cover-105600']);
  });

  test('the genre asked for is the one loaded', () async {
    final repository = _Repository(games: const [_portal]);
    final (:cubit, states: _) = _setUp(repository);

    await cubit.load(1667);

    expect(repository.asked, [1667]);
  });

  test('a failure becomes a message the page can show', () async {
    final repository = _Repository()..failure = Exception('502');
    final (:cubit, :states) = _setUp(repository);

    await cubit.load(19);
    await pumpEventQueue();

    expect(states.last, isA<CategoryError>());
    expect((states.last as CategoryError).message, isNot(contains('502')));
  });

  test('loading again after a failure recovers', () async {
    final repository = _Repository(games: const [_portal])
      ..failure = Exception('down');
    final (:cubit, :states) = _setUp(repository);
    await cubit.load(19);

    repository.failure = null;
    await cubit.load(19);
    await pumpEventQueue();

    expect(cubit.state, isA<CategoryLoaded>());
    expect(_covers(cubit.state), ['cover-620']);
  });

  test('the list stays when the covers cannot be looked up', () async {
    final (:cubit, :states) = _setUp(
      _Repository(games: const [_portal], failCovers: true),
    );

    await cubit.load(19);
    await pumpEventQueue();

    expect(states.last, isA<CategoryLoaded>());
    expect(_covers(states.last), [null]);
  });

  test('a cubit closed while loading emits nothing more', () async {
    final repository = _Repository(games: const [_portal])
      ..coversGate = Completer<void>();
    final cubit = CategoryCubit(repository);

    final loading = cubit.load(19);
    await pumpEventQueue();
    await cubit.close();
    repository.coversGate!.complete();

    await loading;
  });
}
