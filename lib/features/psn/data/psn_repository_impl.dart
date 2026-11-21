import 'dart:math' as math;

import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/psn/data/psn_local_data_source.dart';
import 'package:trophies_tracker/features/psn/data/psn_remote_data_source.dart';
import 'package:trophies_tracker/features/psn/domain/psn_mapper.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';
import 'package:trophies_tracker/features/psn/domain/psn_repository.dart';

class PsnRepositoryImpl implements PsnRepository {
  final PsnRemoteDataSource remote;
  final PsnLocalDataSource local;
  final GameRepository games;
  final DateTime Function() _now;

  /// How many games are read from Sony at once, and how many are saved
  /// together: a save refreshes the whole library on screen.
  static const _parallel = 3;
  static const _batch = 10;

  /// How long an access token is trusted when Sony does not say, and how
  /// early it is renewed.
  static const _defaultLife = Duration(minutes: 50);
  static const _margin = Duration(minutes: 1);

  String? _access;
  DateTime? _accessUntil;
  bool _nameTried = false;

  PsnRepositoryImpl({
    required this.remote,
    required this.local,
    required this.games,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  @override
  Future<PsnAuthorization> authorization() => remote.authorization();

  @override
  Future<PsnLink?> link() => local.link();

  DateTime? _after(int? seconds) =>
      seconds == null ? null : _now().add(Duration(seconds: seconds));

  void _rememberAccess(PsnSession session) {
    _access = session.accessToken;
    _accessUntil = _now().add(
      session.expiresIn == null
          ? _defaultLife
          : Duration(seconds: session.expiresIn!) - _margin,
    );
  }

  @override
  Future<PsnLink> login(String code) async {
    final session = await remote.login(code);
    _nameTried = false;
    _rememberAccess(session);
    await local.saveLogin(
      refreshToken: session.refreshToken,
      onlineId: session.onlineId,
      refreshExpiresAt: _after(session.refreshTokenExpiresIn),
    );
    return (await local.link())!;
  }

  /// A valid access token: the one in memory, or a new one got with the
  /// renewal token. Sony may answer with the same renewal token, whose end of
  /// life then stays the one saved at login.
  ///
  /// Throws [PsnFailure.tokenExpired] when there is no renewal token or Sony
  /// no longer accepts it. The saved link is left as it is, so the screen can
  /// still show the name and offer to log in again.
  Future<String> _accessToken() async {
    final known = _access;
    if (known != null && _now().isBefore(_accessUntil!)) return known;

    final stored = await local.refreshToken();
    if (stored == null) throw const PsnException(PsnFailure.tokenExpired);

    final PsnSession session;
    try {
      session = await remote.refresh(stored);
    } on PsnException catch (e) {
      if (e.failure == PsnFailure.rejected) {
        throw const PsnException(PsnFailure.tokenExpired);
      }
      rethrow;
    }

    _rememberAccess(session);
    if (session.refreshToken != stored) {
      await local.saveRefreshToken(
        session.refreshToken,
        refreshExpiresAt: _after(session.refreshTokenExpiresIn),
      );
    }
    return session.accessToken;
  }

  /// Runs [call] with an access token. If Sony refuses the one in memory, it
  /// is renewed and the call is made once more.
  Future<T> _withAccess<T>(Future<T> Function(String token) call) async {
    try {
      return await call(await _accessToken());
    } on PsnException catch (e) {
      if (e.failure != PsnFailure.tokenExpired || _access == null) rethrow;
      _access = null;
      return call(await _accessToken());
    }
  }

  /// Whether [a] and [b] are the same second: the database keeps no less, and
  /// two [DateTime]s of the same moment differ if only one of them is UTC.
  bool _sameSecond(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == b;
    return a.millisecondsSinceEpoch ~/ 1000 == b.millisecondsSinceEpoch ~/ 1000;
  }

  /// Whether [title] has to be read again: it is new, Sony changed it, or the
  /// trophies kept here do not add up to what Sony counts.
  bool _changed(PsnTitle title, Game? known) {
    if (known == null) return true;
    final earned = known.trophies.where((t) => t.isAchieved).length;
    return !_sameSecond(known.remoteUpdatedAt, title.lastUpdated) ||
        known.trophies.length != title.total ||
        earned != title.earnedCount;
  }

  /// Looks up the player's name when the link has none, once per session. It
  /// is decoration: whatever goes wrong, the sync goes on without it.
  Future<void> _fillInName() async {
    if (_nameTried) return;
    _nameTried = true;
    try {
      if ((await local.link())?.onlineId != null) return;
      final name = (await _withAccess(remote.profile)).onlineId;
      if (name != null) await local.saveOnlineId(name);
    } catch (_) {
      return;
    }
  }

  @override
  Future<PsnSyncResult> sync({
    void Function(int done, int total)? onProgress,
  }) async {
    final titles = await _withAccess(remote.titles);
    await _fillInName();
    final library = {
      for (final game in await games.getAllGames())
        if (game.platform == GamePlatform.psn) game.key: game,
    };
    final todo = [
      for (final title in titles)
        if (_changed(title, library[GameKey(GamePlatform.psn, title.id)]))
          title,
    ];

    final pending = <Game>[];
    var done = 0;
    onProgress?.call(0, todo.length);

    Future<void> flush() async {
      if (pending.isEmpty) return;
      final batch = [...pending];
      pending.clear();
      await games.saveGames(batch);
    }

    var next = 0;
    var failed = false;
    Future<void> worker() async {
      while (!failed && next < todo.length) {
        final title = todo[next++];
        try {
          final trophies = await _withAccess(
            (token) =>
                remote.trophies(token, id: title.id, service: title.service),
          );
          final known = library[GameKey(GamePlatform.psn, title.id)];
          pending.add(
            gameFromPsn(title, trophies, addedAt: known?.addedAt ?? _now()),
          );
          done++;
          onProgress?.call(done, todo.length);
          if (pending.length >= _batch) await flush();
        } catch (_) {
          failed = true;
          rethrow;
        }
      }
    }

    try {
      await Future.wait([
        for (var i = 0; i < math.min(_parallel, todo.length); i++) worker(),
      ]);
    } finally {
      await flush();
    }

    await local.saveLastSync(_now());
    return PsnSyncResult(total: titles.length, updated: todo.length);
  }

  @override
  Future<void> logout() async {
    _access = null;
    _accessUntil = null;
    _nameTried = false;
    await local.clear();
    await games.deleteGamesBySource(psnSource, onlySynced: true);
  }
}
