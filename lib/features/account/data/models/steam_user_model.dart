import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trophies_tracker/features/account/domain/entities/steam_user.dart';

part 'steam_user_model.freezed.dart';
part 'steam_user_model.g.dart';

@freezed
abstract class SteamUserModel with _$SteamUserModel {
  const SteamUserModel._();
  const factory SteamUserModel({
    required String steamId,
    String? personaName,
    String? avatarUrl,
    String? token,
  }) = _SteamUserModel;

  factory SteamUserModel.fromJson(Map<String, dynamic> json) =>
      _$SteamUserModelFromJson(json);

  SteamUser toEntity() {
    return SteamUser(
      steamId: steamId,
      personaName: personaName,
      avatarUrl: avatarUrl,
      token: token,
    );
  }

  factory SteamUserModel.fromEntity(SteamUser entity) {
    return SteamUserModel(
      steamId: entity.steamId,
      personaName: entity.personaName,
      avatarUrl: entity.avatarUrl,
      token: entity.token,
    );
  }
}
