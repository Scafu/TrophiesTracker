import 'package:trophies_tracker/features/game/domain/entities/game.dart';

abstract class GameRepository {
  Future<List<Game>> getAllGames();
  Stream<List<Game>> watchLibrary();
  Future<Game> getGameByIdLocal(int appId);
  Future<bool> isGameInLibrary(int appId);
  Future<Game> getGameByIdRemote(int appId, {String? token});
  Future<List<Game>> searchLocalCatalog(String query);
  Future<void> syncSteamCatalog();
  Future<void> fetchGamesFromSteamAccount(String token);
  Future<void> saveGame(Game game);
  Future<void> saveGames(List<Game> games);
  Future<void> deleteGame(int appId);
  Future<void> deleteGamesBySource(
    String platformSource, {
    bool onlySynced = false,
  });
  Future<void> updateStateTrophy(int appId, String trophyName, bool status);
}
