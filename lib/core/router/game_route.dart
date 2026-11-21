import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';

/// The path parameters of the `gameDetails` route for the game [key].
Map<String, String> gameRouteParams(
  GameKey key, {
  required bool fromExplorer,
}) => {
  'platform': key.platform.name,
  'code': key.code,
  'fromExplorer': fromExplorer.toString(),
};

/// The game a `gameDetails` route is about, or null if its parameters do not
/// name a known platform and a code.
GameKey? gameKeyFromRoute(Map<String, String> params) {
  final platform = GamePlatform.values.asNameMap()[params['platform']];
  final code = params['code'];
  if (platform == null || code == null || code.isEmpty) return null;
  return GameKey(platform, code);
}
