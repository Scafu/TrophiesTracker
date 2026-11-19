import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/database/app_database.dart';
import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/features/account/domain/repositories/account_repository.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_remote_data_source.dart';
import 'package:trophies_tracker/features/game/data/models/game_model.dart';
import 'package:trophies_tracker/features/game/data/models/trophy_model.dart';
import 'package:trophies_tracker/features/game/data/repositories/game_repositories_impl.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';

class _SteamRemote extends Fake implements GameRemoteDataSource {
  @override
  Future<List<GameModel>> fetchGamesFromSteamAccount(String token) async => [
    for (var id = 1; id <= 3; id++)
      GameModel(
        appId: id,
        name: 'Game $id',
        platformSource: 'steam',
        trophies: [TrophyModel(apiName: 'a', displayName: 'A')],
      ),
  ];
}

class _TokenAccounts extends Fake implements AccountRepository {
  @override
  Future<String?> getToken() async => 't';
}

void main() {
  test('after a Steam sync the library state holds the synced games', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final cubit = GameCubit(
      GameRepositoriesImpl(
        localDataSource: GameLocalDataSourceImpl(db),
        remoteDataSource: _SteamRemote(),
      ),
      _TokenAccounts(),
      Logger(level: Level.off),
      RateRequestLimiter(),
    );
    addTearDown(cubit.close);
    final states = <GameState>[];
    cubit.stream.listen(states.add);

    cubit.watchGames();
    await pumpEventQueue();
    await cubit.fetchGamesFromSteamAccount();
    await pumpEventQueue();

    final names = states.map(
      (s) => s.maybeWhen(
        loaded: (games) => 'loaded(${games.length})',
        loading: () => 'loading',
        syncSuccess: () => 'syncSuccess',
        error: (m) => 'error($m)',
        orElse: () => 'other',
      ),
    );
    expect(names.toList(), isNotEmpty);
    expect(
      cubit.state.maybeWhen(loaded: (games) => games.length, orElse: () => -1),
      3,
      reason: 'states seen: ${names.toList()}',
    );
  });
}
