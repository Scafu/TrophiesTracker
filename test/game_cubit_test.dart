import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/features/account/domain/repositories/account_repository.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';

class _SyncRepository extends Fake implements GameRepository {
  _SyncRepository(this._result);

  final Future<int> Function() _result;
  int calls = 0;

  @override
  Stream<List<Game>> watchLibrary() =>
      Stream.value(const [Game(code: '1', name: 'G')]);

  @override
  Future<int> fetchGamesFromSteamAccount(String token) {
    calls++;
    return _result();
  }
}

class _TokenAccountRepository extends Fake implements AccountRepository {
  @override
  Future<String?> getToken() async => 't';
}

({GameCubit cubit, List<GameState> states}) _setUp(_SyncRepository repository) {
  final cubit = GameCubit(
    repository,
    _TokenAccountRepository(),
    Logger(level: Level.off),
    RateRequestLimiter(),
  );
  addTearDown(cubit.close);
  final states = <GameState>[];
  cubit.stream.listen(states.add);
  return (cubit: cubit, states: states);
}

List<String> _errors(List<GameState> states) => [
  for (final s in states) ?s.maybeWhen(error: (m) => m, orElse: () => null),
];

void main() {
  test('a failed sync reports the error, then restores the library', () async {
    final (:cubit, :states) = _setUp(
      _SyncRepository(() => Future.error(Exception('Network error'))),
    );

    await cubit.fetchGamesFromSteamAccount();
    await pumpEventQueue();

    expect(_errors(states), [
      'Could not sync your Steam library. Please try again.',
    ]);
    expect(
      cubit.state.maybeWhen(
        loaded: (games) => games.length == 1,
        orElse: () => false,
      ),
      isTrue,
    );
  });

  test('a failed sync can be retried right away', () async {
    final repository = _SyncRepository(() => Future.error(Exception('x')));
    final (:cubit, :states) = _setUp(repository);

    await cubit.fetchGamesFromSteamAccount();
    await cubit.fetchGamesFromSteamAccount();
    await pumpEventQueue();

    expect(repository.calls, 2);
    expect(_errors(states), isNot(contains(rateLimitedMessage)));
  });

  test('a sync that saves nothing says so and can be retried', () async {
    final repository = _SyncRepository(() async => 0);
    final (:cubit, :states) = _setUp(repository);

    await cubit.fetchGamesFromSteamAccount();
    await cubit.fetchGamesFromSteamAccount();
    await pumpEventQueue();

    expect(repository.calls, 2);
    expect(_errors(states).first, contains('No games with trophies found'));
  });

  test('a successful sync reports success, then is rate limited', () async {
    final repository = _SyncRepository(() async => 3);
    final (:cubit, :states) = _setUp(repository);

    await cubit.fetchGamesFromSteamAccount();
    await cubit.fetchGamesFromSteamAccount();
    await pumpEventQueue();

    expect(repository.calls, 1);
    expect(
      states.any(
        (s) => s.maybeWhen(syncSuccess: () => true, orElse: () => false),
      ),
      isTrue,
    );
    expect(_errors(states), [rateLimitedMessage]);
  });
}
