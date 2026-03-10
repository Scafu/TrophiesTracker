import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';

part 'trophy_model.freezed.dart';
part 'trophy_model.g.dart';

@freezed
abstract class TrophyModel with _$TrophyModel {
  const TrophyModel._();
  const factory TrophyModel({
    required String apiName,
    required String displayName,
    String? description,
    String? icon,
    String? coloredIcon,
    @Default(false) bool isAchieved,
    DateTime? achievedAt,
  }) = _TrophyModel;

  factory TrophyModel.fromJson(Map<String, dynamic> json) =>
      _$TrophyModelFromJson(json);

  Trophy toEntity() {
    return Trophy(
      apiName: apiName,
      displayName: displayName,
      description: description,
      icon: icon,
      coloredIcon: coloredIcon,
      isAchieved: isAchieved,
      achievedAt: achievedAt,
    );
  }
}
