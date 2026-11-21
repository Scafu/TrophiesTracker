import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophies_tracker/core/services/log.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_local_data_source.dart';
import 'package:trophies_tracker/features/game/data/datasource/game_remote_data_source.dart';
import 'package:trophies_tracker/features/game/data/models/game_model.dart';
import 'package:trophies_tracker/features/game/data/models/trophy_model.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';

/// Implementation of the [GameRepository] that orchestrates data flow
/// between local ([GameLocalDataSource]) and remote ([GameRemoteDataSource]) sources.
class GameRepositoriesImpl implements GameRepository {
  final GameLocalDataSource localDataSource;
  final GameRemoteDataSource remoteDataSource;

  /// Where the time of the last Steam sync is kept; without it nothing is.
  final SharedPreferences? sharedPreferences;
  static const _lastSyncKey = 'last_steam_sync';
  final Map<GameKey, Game> _cachedGames = {};

  /// Creates a new instance of [GameRepositoriesImpl].
  GameRepositoriesImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    this.sharedPreferences,
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

  final Map<String, String> _covers = {};

  /// Returns [games] with the cover Steam really serves for them.
  ///
  /// Used for search results, which come from the offline catalog and have no
  /// images. Lookups are remembered for the session, including the games that
  /// have no cover, so typing a longer query does not ask for them again.
  @override
  Future<List<Game>> withCovers(List<Game> games) async {
    final missing = [
      for (final game in games)
        if (game.platform == GamePlatform.steam &&
            !_covers.containsKey(game.code))
          int.parse(game.code),
    ];
    if (missing.isNotEmpty) {
      final found = await remoteDataSource.fetchCovers(missing);
      for (final appId in missing) {
        _covers['$appId'] = found[appId] ?? '';
      }
    }

    return [
      for (final game in games)
        game.platform != GamePlatform.steam ||
                (_covers[game.code] ?? '').isEmpty
            ? game
            : game.copyWith(libraryImage: _covers[game.code]),
    ];
  }

  /// The popular games with trophies in the Steam genre [tagId]; throws when
  /// they cannot be fetched.
  @override
  Future<List<Game>> getCategoryGames(int tagId) async => [
    for (final model in await remoteDataSource.fetchCategory(tagId))
      model.toEntity(),
  ];

  final Map<GameKey, Map<String, double>> _rarity = {};

  /// The share of players who unlocked each trophy of the game [key], by API
  /// name. Only Steam needs this lookup: PlayStation sends the rarity with the
  /// trophies, so any other game has none here.
  ///
  /// Remembered for the session, but only when something was found, so a
  /// failed lookup is retried the next time the page opens.
  @override
  Future<Map<String, double>> getRarity(GameKey key) async {
    if (key.platform != GamePlatform.steam) return const {};
    final known = _rarity[key];
    if (known != null) return known;

    final found = await remoteDataSource.fetchRarity(int.parse(key.code));
    if (found.isNotEmpty) _rarity[key] = found;
    return found;
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

  /// Deletes a specific game from the local database using its [key].
  @override
  Future<void> deleteGame(GameKey key) async {
    await localDataSource.deleteGameFromDb(key);
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
      platform: game.platform,
      code: game.code,
      name: game.name,
      publisher: game.publisher,
      description: game.description,
      headerImage: game.headerImage,
      libraryImage: game.libraryImage,
      addedAt: game.addedAt,
      platformSource: game.platformSource,
      isSynced: game.isSynced,
      consoles: game.consoles,
      remoteUpdatedAt: game.remoteUpdatedAt,
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
              type: t.type,
              hidden: t.hidden,
              rarity: t.rarity,
            ),
          )
          .toList(),
    );
  }

  /// Retrieves a specific game from the local database by its [key].
  @override
  Future<Game> getGameByIdLocal(GameKey key) async {
    final gameModel = await localDataSource.getGameByIdLocal(key);
    if (gameModel == null) {
      throw Exception('Game not found');
    }
    return gameModel.toEntity();
  }

  @override
  Future<bool> isGameInLibrary(GameKey key) async {
    final game = await localDataSource.getGameByIdLocal(key);
    return game != null;
  }

  /// Retrieves game details directly from the remote data source and converts
  /// the resulting model into a domain entity.
  ///
  /// Throws an [Exception] if the underlying remote data source operation fails.
  @override
  Future<Game> getGameByIdRemote(GameKey key, {String? token}) async {
    if (key.platform != GamePlatform.steam) {
      throw UnsupportedError('Only Steam games can be fetched remotely');
    }
    if (token == null && _cachedGames.containsKey(key)) {
      return _cachedGames[key]!;
    }
    final remoteModel = await remoteDataSource.getGameByIdRemote(
      int.parse(key.code),
      token: token,
    );
    final entity = remoteModel.toEntity();
    if (token == null) _cachedGames[key] = entity;
    return entity;
  }

  /// Updates the achievement status of a specific trophy in the local database.
  @override
  Future<void> updateStateTrophy(
    GameKey key,
    String trophyName,
    bool status,
  ) async {
    return await localDataSource.updateStateTrophy(key, trophyName, status);
  }

  @override
  DateTime? get lastSteamSync {
    final millis = sharedPreferences?.getInt(_lastSyncKey);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
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

    await sharedPreferences?.setInt(
      _lastSyncKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    logger.i("Fetched and synced games from Steam account successfully");
    return syncedGames.length;
  }
}
