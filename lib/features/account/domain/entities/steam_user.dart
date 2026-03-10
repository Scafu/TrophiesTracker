import 'package:equatable/equatable.dart';

class SteamUser extends Equatable {
  final String steamId;
  final String? personaName;
  final String? avatarUrl;
  final String? token;

  const SteamUser({
    required this.steamId,
    this.personaName,
    this.avatarUrl,
    this.token,
  });

  SteamUser copyWith({
    String? steamId,
    String? personaName,
    String? avatarUrl,
    String? token,
  }) {
    return SteamUser(
      steamId: steamId ?? this.steamId,
      personaName: personaName ?? this.personaName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [steamId, personaName, avatarUrl, token];
}
