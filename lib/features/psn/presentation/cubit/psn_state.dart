import 'package:equatable/equatable.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';

/// What the PlayStation account is busy with.
enum PsnPhase { idle, loggingIn, syncing }

/// The linked PlayStation account, what it is doing and the last failure.
class PsnState extends Equatable {
  /// Whether the saved link has been read yet.
  final bool loaded;

  /// The linked account, or null when there is none.
  final PsnLink? link;
  final PsnPhase phase;

  /// How many of the games to read are done, while syncing. `total` is 0 until
  /// Sony's list has been compared with the library.
  final int done;
  final int total;

  /// Why the last login or sync failed. Only a fixed reason, never Sony's text.
  final PsnFailure? failure;

  const PsnState({
    this.loaded = false,
    this.link,
    this.phase = PsnPhase.idle,
    this.done = 0,
    this.total = 0,
    this.failure,
  });

  bool get busy => phase != PsnPhase.idle;

  /// Whether the user has to log in again: Sony refused the last attempt, or
  /// the renewal token has run out.
  bool loginNeeded(DateTime now) =>
      link != null &&
      (failure == PsnFailure.tokenExpired || link!.isExpired(now));

  PsnState copyWith({
    bool? loaded,
    PsnLink? link,
    PsnPhase? phase,
    int? done,
    int? total,
    PsnFailure? failure,
    bool clearFailure = false,
  }) => PsnState(
    loaded: loaded ?? this.loaded,
    link: link ?? this.link,
    phase: phase ?? this.phase,
    done: done ?? this.done,
    total: total ?? this.total,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    loaded,
    link?.onlineId,
    link?.refreshExpiresAt,
    link?.lastSync,
    phase,
    done,
    total,
    failure,
  ];
}
