import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_remote_data_source.dart';
import 'package:trophies_tracker/features/game/data/models/game_model.dart';
import 'package:trophies_tracker/features/game/data/models/trophy_model.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';

/// Implementation of the [GameRepository] that orchestrates data flow
/// between local ([GameLocalDataSource]) and remote ([GameRemoteDataSource]) sources.
class GameRepositoriesImpl implements GameRepository {
  final GameLocalDataSource localDataSource;
  final GameRemoteDataSource remoteDataSource;
  final Map<int, Game> _cachedGames = {};

  /// Creates a new instance of [GameRepositoriesImpl].
  GameRepositoriesImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// Retrieves all saved games from the local database.
  @override
  Future<List<Game>> getAllGames() async {
    final gameModels = await localDataSource.fetchGamesFromDb();
    return gameModels.map((gameModel) => gameModel.toEntity()).toList();
  }

  /// Searches for games directly within the massive, locally-stored offline catalog.
  /// This bypasses network requests for instantaneous, pageless results.
  @override
  Future<List<Game>> searchLocalCatalog(String query) async {
    final localModels = await localDataSource.searchInLocalCatalog(query);
    return localModels.map((model) => model.toEntity()).toList();
  }

  /// Keeps the local Steam catalog complete and up to date.
  ///
  /// On the first run it saves the first chunks before returning, so search
  /// works right away, and downloads the rest in the background. On later runs
  /// it resumes in the background from the highest saved appId, which finishes
  /// an interrupted download and adds newly released apps.
  @override
  Future<void> syncSteamCatalog() async {
    final lastAppId = await localDataSource.getLastCatalogAppId();
    if (lastAppId > 0) {
      _syncRemainingCatalog(lastAppId);
      return;
    }

    logger.i("Starting partial Steam catalog sync...");

    final partial = await remoteDataSource.fetchSteamCatalogOnline(
      maxChunks: 8,
      startFromAppId: 0,
    );
    await localDataSource.saveSteamCatalogToDb(partial.apps);
    logger.i("Partial catalog saved (${partial.apps.length} games).");

    if (!partial.hasMore) return;

    _syncRemainingCatalog(partial.lastAppId);
  }

  /// Downloads the catalog from [fromAppId] to the end, two chunks at a time.
  ///
  /// Each slice is saved as soon as it arrives, so memory stays bounded and an
  /// interrupted run resumes from the highest saved appId. Failures are only
  /// logged: this runs in the background.
  Future<void> _syncRemainingCatalog(int fromAppId) async {
    try {
      var next = fromAppId;
      var hasMore = true;
      var total = 0;
      while (hasMore) {
        final slice = await remoteDataSource.fetchSteamCatalogOnline(
          maxChunks: 2,
          startFromAppId: next,
        );
        await localDataSource.saveSteamCatalogToDb(slice.apps);
        total += slice.apps.length;
        hasMore = slice.hasMore && slice.lastAppId > next;
        next = slice.lastAppId;
      }
      logger.i("Background catalog sync complete ($total more games).");
    } catch (e) {
      logger.e("Background catalog sync failed: $e");
    }
  }

  /// Saves a single [Game] entity to the local database.
  @override
  Future<void> saveGame(Game game) {
    final gameModel = _mapToModel(game);
    return localDataSource.saveGameToDb(gameModel);
  }

  /// Saves a list of [Game] entities to the local database in a single transaction.
  @override
  Future<void> saveGames(List<Game> games) async {
    final gameModels = games.map((game) => _mapToModel(game)).toList();
    await localDataSource.saveGamesToDb(gameModels);
  }

  /// Deletes a specific game from the local database using its [appId].
  @override
  Future<void> deleteGame(int appId) async {
    await localDataSource.deleteGameFromDb(appId);
  }

  /// Deletes all games associated with a specific [platformSource] from the local database.
  @override
  Future<void> deleteGamesBySource(
    String platformSource, {
    bool onlySynced = false,
  }) async {
    await localDataSource.deleteGamesFromDb(
      platformSource,
      onlySynced: onlySynced,
    );
  }

  /// Returns a reactive stream of the user's game library.
  ///
  /// Emits a new list of [Game] entities whenever the underlying local data
  /// changes. Each listener gets its own subscription: a shared stream
  /// (`shareValue`) went stale once every listener had cancelled, so the
  /// library stayed empty after the cubit resubscribed following a sync.
  @override
  Stream<List<Game>> watchLibrary() {
    return localDataSource.watchLibrary().map((gameModels) {
      return gameModels.map((gameModel) => gameModel.toEntity()).toList();
    });
  }

  /// Converts a [Game] entity into a [GameModel] for local data operations.
  GameModel _mapToModel(Game game) {
    return GameModel(
      appId: game.appId,
      name: game.name,
      publisher: game.publisher,
      description: game.description,
      headerImage: game.headerImage,
      libraryImage: game.libraryImage,
      addedAt: game.addedAt,
      platformSource: game.platformSource,
      isSynced: game.isSynced,
      trophies: game.trophies
          .map(
            (t) => TrophyModel(
              apiName: t.apiName,
              displayName: t.displayName,
              description: t.description,
              icon: t.icon,
              coloredIcon: t.coloredIcon,
              isAchieved: t.isAchieved,
              achievedAt: t.achievedAt,
            ),
          )
          .toList(),
    );
  }

  /// Retrieves a specific game from the local database by its [appId].
  @override
  Future<Game> getGameByIdLocal(int appId) async {
    final gameModel = await localDataSource.getGameByIdLocal(appId);
    if (gameModel == null) {
      throw Exception('Game not found');
    }
    return gameModel.toEntity();
  }

  @override
  Future<bool> isGameInLibrary(int appId) async {
    final game = await localDataSource.getGameByIdLocal(appId);
    return game != null;
  }

  /// Retrieves game details directly from the remote data source and converts
  /// the resulting model into a domain entity.
  ///
  /// Throws an [Exception] if the underlying remote data source operation fails.
  @override
  Future<Game> getGameByIdRemote(int appId, {String? token}) async {
    if (token == null && _cachedGames.containsKey(appId)) {
      return _cachedGames[appId]!;
    }
    final remoteModel = await remoteDataSource.getGameByIdRemote(
      appId,
      token: token,
    );
    final entity = remoteModel.toEntity();
    if (token == null) _cachedGames[appId] = entity;
    return entity;
  }

  /// Updates the achievement status of a specific trophy in the local database.
  @override
  Future<void> updateStateTrophy(
    int appId,
    String trophyName,
    bool status,
  ) async {
    return await localDataSource.updateStateTrophy(appId, trophyName, status);
  }

  /// Downloads the games of the Steam account, marks them as synced and saves
  /// them locally. Returns how many games were saved.
  @override
  Future<int> fetchGamesFromSteamAccount(String token) async {
    final List<GameModel> remoteGames = await remoteDataSource
        .fetchGamesFromSteamAccount(token);

    if (remoteGames.isEmpty) {
      return 0;
    }

    final syncedGames = remoteGames
        .map((g) => g.copyWith(isSynced: true))
        .toList();

    await localDataSource.saveGamesToDb(syncedGames);

    logger.i("Fetched and synced games from Steam account successfully");
    return syncedGames.length;
  }
}
