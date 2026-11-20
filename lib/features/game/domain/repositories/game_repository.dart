import 'package:trophies_tracker/features/game/domain/entities/game.dart';

abstract class GameRepository {
  Future<List<Game>> getAllGames();
  Stream<List<Game>> watchLibrary();
  Future<Game> getGameByIdLocal(int appId);
  Future<bool> isGameInLibrary(int appId);
  Future<Game> getGameByIdRemote(int appId, {String? token});
  Future<List<Game>> searchLocalCatalog(String query);
  Future<List<Game>> withCovers(List<Game> games);
  Future<Map<String, double>> getRarity(int appId);
  Future<void> syncSteamCatalog();
  Future<int> fetchGamesFromSteamAccount(String token);
  DateTime? get lastSteamSync;
  Future<void> saveGame(Game game);
  Future<void> saveGames(List<Game> games);
  Future<void> deleteGame(int appId);
  Future<void> deleteGamesBySource(
    String platformSource, {
    bool onlySynced = false,
  });
  Future<void> updateStateTrophy(int appId, String trophyName, bool status);
}
