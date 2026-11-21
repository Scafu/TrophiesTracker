import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:trophies_tracker/features/game/data/models/trophy_model.dart';

part 'game_model.freezed.dart';
part 'game_model.g.dart';

@freezed
abstract class GameModel with _$GameModel {
  const GameModel._();

  GameKey get key => GameKey(platform, code);

  const factory GameModel({
    @Default(GamePlatform.steam) GamePlatform platform,
    required String code,
    required String name,
    String? headerImage,
    String? libraryImage,
    @Default([]) List<String> publisher,
    @Default([]) List<TrophyModel> trophies,
    String? description,
    DateTime? addedAt,
    @Default("local") String platformSource,
    @Default(false) bool isSynced,
    @Default([]) List<String> consoles,
    DateTime? remoteUpdatedAt,
  }) = _GameModel;

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);

  Game toEntity() {
    return Game(
      platform: platform,
      code: code,
      name: name,
      headerImage: headerImage,
      libraryImage: libraryImage,
      publisher: publisher,
      trophies: trophies.map((t) => t.toEntity()).toList(),
      description: description,
      addedAt: addedAt,
      platformSource: platformSource,
      isSynced: isSynced,
      consoles: consoles,
      remoteUpdatedAt: remoteUpdatedAt,
    );
  }
}
