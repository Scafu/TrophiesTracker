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

  /// Synchronizes the complete Steam catalog from the remote API to the local database.
  ///
  /// This method checks if the local catalog is already populated. If empty,
  /// it downloads the catalog in chunks and performs a massive batch insert.
  @override
  Future<void> syncSteamCatalog() async {
    final isDbEmpty = await localDataSource.isCatalogEmpty();
    if (!isDbEmpty) {
      logger.i("Steam catalog already exists in local database.");
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

  void _syncRemainingCatalog(int fromAppId) {
    remoteDataSource
        .fetchSteamCatalogOnline(startFromAppId: fromAppId)
        .then((result) async {
          await localDataSource.saveSteamCatalogToDb(result.apps);
          logger.i(
            "Background catalog sync complete (${result.apps.length} more games).",
          );
        })
        .catchError((e) {
          logger.e("Background catalog sync failed: $e");
        });
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
  /// Emits a new list of [Game] entities whenever the underlying local data changes.
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

  @override
  Future<void> fetchGamesFromSteamAccount(String token) async {
    final List<GameModel> remoteGames = await remoteDataSource
        .fetchGamesFromSteamAccount(token);

    if (remoteGames.isEmpty) {
      return;
    }

    // Mark games as synced when they come from the account fetch
    final syncedGames = remoteGames
        .map((g) => g.copyWith(isSynced: true))
        .toList();

    await localDataSource.saveGamesToDb(syncedGames);

    logger.i("Fetched and synced games from Steam account successfully");
  }
}
