import 'package:equatable/equatable.dart';

import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';

class Game extends Equatable {
  final int appId;
  final String name;
  final String? headerImage;
  final String? libraryImage;
  final List<String> publisher;
  final List<Trophy> trophies;
  final String? description;
  final DateTime? addedAt;
  final String platformSource;
  final bool isSynced;

  const Game({
    required this.appId,
    required this.name,
    this.headerImage,
    this.libraryImage,
    this.publisher = const [],
    this.trophies = const [],
    this.description,
    this.addedAt,
    this.platformSource = "local",
    this.isSynced = false,
  });

  @override
  List<Object?> get props => [
    appId,
    name,
    headerImage,
    libraryImage,
    publisher,
    trophies,
    description,
    addedAt,
    platformSource,
    isSynced,
  ];

  Game copyWith({
    String? libraryImage,
    List<Trophy>? trophies,
    DateTime? addedAt,
    String? platformSource,
    bool? isSynced,
  }) {
    return Game(
      appId: appId,
      name: name,
      headerImage: headerImage,
      libraryImage: libraryImage ?? this.libraryImage,
      publisher: publisher,
      trophies: trophies ?? this.trophies,
      description: description,
      addedAt: addedAt ?? this.addedAt,
      platformSource: platformSource ?? this.platformSource,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
