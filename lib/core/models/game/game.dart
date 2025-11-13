import 'package:freezed_annotation/freezed_annotation.dart';
import '../trophy/trophy.dart';

part 'game.freezed.dart';
part 'game.g.dart';

/// Main Entity for the App
@freezed
abstract class Game with _$Game {
  /// Game entity composition
  const factory Game({
    required int appId,
    required String name,
    @Default([]) List<String> publisher,
    String? description,
    String? headerImage,
    String? libraryImage,
    @Default(0) DateTime? addedAt,
    @Default([]) List<Trophy> trophies,
  }) = _Game;

  /// Game Entity traslation JSON -> GAME
  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}
