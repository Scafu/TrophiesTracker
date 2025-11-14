import 'package:freezed_annotation/freezed_annotation.dart';

part 'trophy.freezed.dart';
part 'trophy.g.dart';

@freezed
abstract class Trophy with _$Trophy {
  const factory Trophy({
    required String displayName,
    String? description,
    @Default(0) int isAchieved,
    String? coloredIcon,
    String? uncoloredIcon,
    DateTime? achievedAt,
  }) = _Trophy;

  factory Trophy.fromJson(Map<String, dynamic> json) => _$TrophyFromJson(json);
}
