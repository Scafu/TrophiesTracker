import 'package:equatable/equatable.dart';

/// The store a game comes from.
enum GamePlatform {
  steam('Steam'),
  psn('PlayStation');

  /// The name to show to the user.
  final String label;

  const GamePlatform(this.label);
}

/// What identifies a game: the [platform] and its [code] there. For Steam the
/// code is the app id (`620`), for PlayStation the `npCommunicationId`
/// (`NPWR20188_00`). Games of different platforms never clash, whatever their
/// codes.
class GameKey extends Equatable {
  final GamePlatform platform;
  final String code;

  const GameKey(this.platform, this.code);

  const GameKey.steam(this.code) : platform = GamePlatform.steam;

  @override
  List<Object?> get props => [platform, code];

  @override
  String toString() => '${platform.name}:$code';
}

/// Orders two keys by platform and then by code, numerically when both codes
/// are numbers (Steam), so `9` comes before `10`.
int compareGameKeys(GameKey a, GameKey b) {
  final byPlatform = a.platform.index.compareTo(b.platform.index);
  if (byPlatform != 0) return byPlatform;
  final x = int.tryParse(a.code);
  final y = int.tryParse(b.code);
  return x != null && y != null ? x.compareTo(y) : a.code.compareTo(b.code);
}
