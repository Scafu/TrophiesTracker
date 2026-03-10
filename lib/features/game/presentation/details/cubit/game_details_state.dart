import 'package:equatable/equatable.dart';

import 'package:trophies_tracker/features/game/domain/entities/game.dart';

abstract class GameDetailsState extends Equatable {
  const GameDetailsState();

  @override
  List<Object?> get props => [];
}

class GameDetailsInitial extends GameDetailsState {
  const GameDetailsInitial();
}

class GameDetailsLoading extends GameDetailsState {
  const GameDetailsLoading();
}

class GameDetailsLoaded extends GameDetailsState {
  final Game game;
  final bool isSyncing;

  const GameDetailsLoaded({
    required this.game,
    this.isSyncing = false,
  });

  GameDetailsLoaded copyWith({Game? game, bool? isSyncing}) {
    return GameDetailsLoaded(
      game: game ?? this.game,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [game, isSyncing];
}

class GameDetailsSyncSuccess extends GameDetailsLoaded {
  const GameDetailsSyncSuccess(Game game) : super(game: game, isSyncing: false);

  @override
  List<Object?> get props => [game, isSyncing];
}

class GameDetailsError extends GameDetailsState {
  final String message;
  const GameDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class GameDetailsDeleted extends GameDetailsState {
  const GameDetailsDeleted();
}
