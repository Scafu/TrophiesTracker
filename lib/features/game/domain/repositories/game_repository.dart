import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';

abstract class GameRepository {
  Future<List<Game>> getAllGames();
  Stream<List<Game>> watchLibrary();
  Future<Game> getGameByIdLocal(GameKey key);
  Future<bool> isGameInLibrary(GameKey key);

  /// A game's details from its store. Only Steam games can be fetched.
  Future<Game> getGameByIdRemote(GameKey key, {String? token});
  Future<List<Game>> searchLocalCatalog(String query);
  Future<List<Game>> withCovers(List<Game> games);
  Future<Map<String, double>> getRarity(GameKey key);
  Future<List<Game>> getCategoryGames(int tagId);
  Future<void> syncSteamCatalog();
  Future<int> fetchGamesFromSteamAccount(String token);
  DateTime? get lastSteamSync;
  Future<void> saveGame(Game game);
  Future<void> saveGames(List<Game> games);
  Future<void> deleteGame(GameKey key);
  Future<void> deleteGamesBySource(
    String platformSource, {
    bool onlySynced = false,
  });
  Future<void> updateStateTrophy(GameKey key, String trophyName, bool status);
}
