import 'package:freezed_annotation/freezed_annotation.dart';

part "game_summary.freezed.dart";
part "game_summary.g.dart";

@freezed
abstract class GameSummary with _$GameSummary {
  const factory GameSummary({required int appid, required String name}) =
      _GameSummary;

  factory GameSummary.fromJson(Map<String, dynamic> json) =>
      _$GameSummaryFromJson(json);
}
