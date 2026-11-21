import 'package:equatable/equatable.dart';

import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';

class Game extends Equatable {
  /// The store the game comes from, and its code there (see [GameKey]).
  final GamePlatform platform;
  final String code;
  final String name;
  final String? headerImage;
  final String? libraryImage;
  final List<String> publisher;
  final List<Trophy> trophies;
  final String? description;
  final DateTime? addedAt;
  final String platformSource;
  final bool isSynced;

  /// The consoles the game was played on (`PS5`, `PS4`), for PlayStation games.
  final List<String> consoles;

  /// When the platform last updated the game's trophies, as it said. A sync
  /// compares it with the platform's to skip the games that did not change.
  final DateTime? remoteUpdatedAt;

  const Game({
    this.platform = GamePlatform.steam,
    required this.code,
    required this.name,
    this.headerImage,
    this.libraryImage,
    this.publisher = const [],
    this.trophies = const [],
    this.description,
    this.addedAt,
    this.platformSource = "local",
    this.isSynced = false,
    this.consoles = const [],
    this.remoteUpdatedAt,
  });

  /// What identifies the game: its platform and its code.
  GameKey get key => GameKey(platform, code);

  @override
  List<Object?> get props => [
    platform,
    code,
    name,
    headerImage,
    libraryImage,
    publisher,
    trophies,
    description,
    addedAt,
    platformSource,
    isSynced,
    consoles,
    remoteUpdatedAt,
  ];

  Game copyWith({
    String? libraryImage,
    List<Trophy>? trophies,
    DateTime? addedAt,
    String? platformSource,
    bool? isSynced,
  }) {
    return Game(
      platform: platform,
      code: code,
      name: name,
      headerImage: headerImage,
      libraryImage: libraryImage ?? this.libraryImage,
      publisher: publisher,
      trophies: trophies ?? this.trophies,
      description: description,
      addedAt: addedAt ?? this.addedAt,
      platformSource: platformSource ?? this.platformSource,
      isSynced: isSynced ?? this.isSynced,
      consoles: consoles,
      remoteUpdatedAt: remoteUpdatedAt,
    );
  }
}
