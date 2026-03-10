import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophies_tracker/core/data/repositories/activity_repository_impl.dart';
import 'package:trophies_tracker/core/database/app_database.dart';
import 'package:trophies_tracker/core/domain/repositories/activity_repository.dart';
import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/core/services/rate_request_limiter.dart';
import 'package:trophies_tracker/features/account/data/datasource/account_local_data_source.dart';
import 'package:trophies_tracker/features/account/data/datasource/account_remote_data_source.dart';
import 'package:trophies_tracker/features/account/data/repositories/account_repository_impl.dart';
import 'package:trophies_tracker/features/account/domain/repositories/account_repository.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_remote_data_source.dart';
import 'package:trophies_tracker/features/game/data/repositories/game_repositories_impl.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:trophies_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:trophies_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:trophies_tracker/features/stats/presentation/cubit/stats_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<Logger>(() => logger);

  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);

  sl.registerLazySingleton(() => AppDatabase(openConnection()));

  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton<GameLocalDataSource>(
    () => GameLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<GameRemoteDataSource>(
    () => GameRemoteDataSourceImpl(
      client: sl(),
      proxyBaseUrl:
          'https://trophiestracker.alessandro-mazzariol04.workers.dev',
    ),
  );

  sl.registerLazySingleton<GameRepository>(
    () => GameRepositoriesImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(sl()),
  );

  // Account Feature
  sl.registerLazySingleton<AccountLocalDataSource>(
    () => AccountLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(
      client: sl(),
      proxyBaseUrl:
          'https://trophiestracker.alessandro-mazzariol04.workers.dev',
    ),
  );

  sl.registerLazySingleton<RateRequestLimiter>(() => RateRequestLimiter());

  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sharedPreferences: sl()),
  );

  sl.registerFactory(() => AccountCubit(sl(), sl()));

  sl.registerFactory(() => GameCubit(sl(), sl(), sl(), sl()));

  sl.registerFactory(() => ExploreCubit(sl()));

  sl.registerFactory(() => StatsCubit(sl(), sl()));

  sl.registerFactory(() => GameDetailsCubit(sl(), sl(), sl()));

  sl.registerFactory(() => SettingsCubit(sl()));
}
