import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';

part 'game_state.freezed.dart';

@freezed
class GameState with _$GameState {
  const factory GameState.initial() = _Initial;
  const factory GameState.loading() = _Loading;
  const factory GameState.loaded({required List<Game> games}) = _Loaded;
  const factory GameState.syncSuccess() = _SyncSuccess;
  const factory GameState.error(String message) = _Error;
}
