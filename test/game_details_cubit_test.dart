import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/domain/repositories/activity_repository.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_state.dart';

const _game = Game(code: '1', name: 'G');

class _DetailsRepository extends Fake implements GameRepository {
  _DetailsRepository({this.failRemote = false});

  final bool failRemote;
  int remoteCalls = 0;

  @override
  Future<bool> isGameInLibrary(GameKey key) async => true;

  @override
  Future<Game> getGameByIdLocal(GameKey key) async => _game;

  @override
  Future<Game> getGameByIdRemote(GameKey key, {String? token}) async {
    remoteCalls++;
    if (failRemote) throw Exception('x');
    return _game;
  }

  @override
  Future<void> saveGame(Game game) async {}
}

class _Activities extends Fake implements ActivityRepository {}

({GameDetailsCubit cubit, List<GameDetailsState> states}) _setUp(
  _DetailsRepository repository,
) {
  final cubit = GameDetailsCubit(
    repository,
    RateRequestLimiter(),
    _Activities(),
  );
  addTearDown(cubit.close);
  final states = <GameDetailsState>[];
  cubit.stream.listen(states.add);
  return (cubit: cubit, states: states);
}

void main() {
  test('a failed sync can be retried right away', () async {
    final repository = _DetailsRepository(failRemote: true);
    final (:cubit, :states) = _setUp(repository);
    await cubit.loadGameDetails(GameKey.steam('1'));

    await cubit.syncAchievements(GameKey.steam('1'), token: 't');
    await cubit.syncAchievements(GameKey.steam('1'), token: 't');

    expect(repository.remoteCalls, 2);
    expect(cubit.state, isA<GameDetailsLoaded>());
  });

  test('a rate-limited sync reports it and keeps the page loaded', () async {
    final repository = _DetailsRepository();
    final (:cubit, :states) = _setUp(repository);
    await cubit.loadGameDetails(GameKey.steam('1'));

    await cubit.syncAchievements(GameKey.steam('1'), token: 't');
    await cubit.syncAchievements(GameKey.steam('1'), token: 't');
    await pumpEventQueue();

    expect(repository.remoteCalls, 1);
    expect(states.whereType<GameDetailsError>().map((e) => e.message), [
      rateLimitedMessage,
    ]);
    expect(cubit.state, isA<GameDetailsLoaded>());
  });

  test(
    'syncing before the game is loaded does not use the rate limit',
    () async {
      final repository = _DetailsRepository();
      final (:cubit, :states) = _setUp(repository);

      await cubit.syncAchievements(GameKey.steam('1'), token: 't');
      expect(repository.remoteCalls, 0);

      await cubit.loadGameDetails(GameKey.steam('1'));
      await cubit.syncAchievements(GameKey.steam('1'), token: 't');

      expect(repository.remoteCalls, 1);
    },
  );
}
