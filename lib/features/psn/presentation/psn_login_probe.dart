import 'package:flutter/services.dart' show PlatformException;
import 'package:trophies_tracker/features/psn/data/psn_remote_data_source.dart';
import 'package:trophies_tracker/features/psn/data/web_authenticate.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';

/// One thing the probe checked and what it found. The detail holds only counts
/// and fixed words: never a token, a code, a name or a game.
class PsnProbeStep {
  final String label;
  final bool ok;
  final String detail;

  const PsnProbeStep(this.label, this.ok, [this.detail = '']);
}

class PsnProbeReport {
  final List<PsnProbeStep> steps;

  const PsnProbeReport(this.steps);

  bool get ok => steps.isNotEmpty && steps.every((step) => step.ok);
}

/// A throwaway check of the whole PlayStation chain, from the login in the
/// browser to the trophies of one game, for development builds only.
///
/// It answers the open questions of the first phase: does Sony send the user
/// back with a code, does it answer the Worker, how do hidden trophies look,
/// how long do the calls take. It keeps nothing and reports only counts: the
/// tokens live in local variables for the length of [run].
class PsnLoginProbe {
  final PsnRemoteDataSource _dataSource;
  final WebAuthenticate _authenticate;

  PsnLoginProbe(this._dataSource, this._authenticate);

  /// A platform error code is a short fixed word; anything else is not shown.
  String _days(int? seconds) =>
      seconds == null ? 'unknown' : '${(seconds / 86400).round()} days';

  String _safeCode(String code) =>
      RegExp(r'^[A-Za-z_]{1,30}$').hasMatch(code) ? code : 'unknown';

  Future<PsnProbeReport> run() async {
    final steps = <PsnProbeStep>[];
    PsnProbeReport done() => PsnProbeReport(steps);

    final PsnAuthorization authorization;
    try {
      authorization = await _dataSource.authorization();
      steps.add(const PsnProbeStep('Worker gives the login page', true));
    } on PsnException catch (e) {
      steps.add(
        PsnProbeStep('Worker gives the login page', false, e.failure.name),
      );
      return done();
    }

    final String callback;
    try {
      callback = await _authenticate(
        authorization.url,
        authorization.callbackScheme,
      );
    } on PlatformException catch (e) {
      steps.add(
        PsnProbeStep(
          'Login in the browser',
          false,
          e.code == 'CANCELED'
              ? 'cancelled by the user'
              : 'platform error ${_safeCode(e.code)}',
        ),
      );
      return done();
    } catch (_) {
      steps.add(const PsnProbeStep('Login in the browser', false, 'failed'));
      return done();
    }

    final code = Uri.tryParse(callback)?.queryParameters['code'];
    if (code == null || code.isEmpty) {
      steps.add(
        const PsnProbeStep(
          'Login in the browser',
          false,
          'it came back to the app without a code',
        ),
      );
      return done();
    }
    steps.add(const PsnProbeStep('Login in the browser returns a code', true));

    final clock = Stopwatch()..start();
    final PsnSession session;
    try {
      session = await _dataSource.login(code);
      final lookup = session.onlineId == null
          ? await _whereTheNameStopped(session.accessToken)
          : '';
      steps.add(
        PsnProbeStep(
          'Worker exchanges the code with Sony',
          true,
          'online id ${session.onlineId == null ? 'missing$lookup' : 'found'}, '
              'renewal lasts ${_days(session.refreshTokenExpiresIn)}, '
              '${clock.elapsedMilliseconds} ms',
        ),
      );
    } on PsnException catch (e) {
      steps.add(
        PsnProbeStep(
          'Worker exchanges the code with Sony',
          false,
          e.failure.name,
        ),
      );
      return done();
    }

    clock
      ..reset()
      ..start();
    final List<PsnTitle> titles;
    try {
      titles = await _dataSource.titles(session.accessToken);
      steps.add(PsnProbeStep('Games', true, _gamesDetail(titles, clock)));
    } on PsnException catch (e) {
      steps.add(PsnProbeStep('Games', false, e.failure.name));
      return done();
    }

    final inspected = _largestPlayed(titles);
    if (inspected == null) {
      steps.add(const PsnProbeStep('Trophies of one game', true, 'no game'));
    } else {
      clock
        ..reset()
        ..start();
      try {
        final trophies = await _dataSource.trophies(
          session.accessToken,
          id: inspected.id,
          service: inspected.service,
        );
        steps.add(
          PsnProbeStep(
            'Trophies of one game',
            true,
            _trophiesDetail(trophies, clock),
          ),
        );
      } on PsnException catch (e) {
        steps.add(PsnProbeStep('Trophies of one game', false, e.failure.name));
      }
    }

    clock
      ..reset()
      ..start();
    try {
      final renewed = await _dataSource.refresh(session.refreshToken);
      steps.add(
        PsnProbeStep(
          'Worker renews the access',
          true,
          'renewal token '
              '${renewed.refreshToken == session.refreshToken ? 'unchanged' : 'replaced'}, '
              'then lasts ${_days(renewed.refreshTokenExpiresIn)}, '
              '${clock.elapsedMilliseconds} ms',
        ),
      );
    } on PsnException catch (e) {
      steps.add(
        PsnProbeStep('Worker renews the access', false, e.failure.name),
      );
    }
    return done();
  }

  /// The steps of the name lookup with the status of each, as ` (summary 200,
  /// profile 404)`: they hold no data, only where the lookup stopped.
  Future<String> _whereTheNameStopped(String accessToken) async {
    try {
      final profile = await _dataSource.profile(accessToken);
      return ' (${profile.attempts.join(', ')})';
    } on PsnException catch (e) {
      return ' (${e.failure.name})';
    }
  }

  String _gamesDetail(List<PsnTitle> titles, Stopwatch clock) {
    int sum(int Function(PsnTitle) of) =>
        titles.fold(0, (total, title) => total + of(title));
    int on(String console) =>
        titles.where((title) => title.consoles.contains(console)).length;

    return '${titles.length} games (PS4 ${on('PS4')}, PS5 ${on('PS5')}), '
        'trophies ${sum((t) => t.earnedCount)} of ${sum((t) => t.total)}, '
        'platinum ${sum((t) => t.earned.platinum)} of '
        '${sum((t) => t.defined.platinum)}, ${clock.elapsedMilliseconds} ms';
  }

  /// The played game with the most trophies, which is the longest list to read.
  PsnTitle? _largestPlayed(List<PsnTitle> titles) {
    PsnTitle? largest;
    for (final title in titles) {
      if (title.earnedCount == 0) continue;
      if (largest == null || title.total > largest.total) largest = title;
    }
    return largest;
  }

  String _trophiesDetail(List<PsnTrophy> trophies, Stopwatch clock) {
    final earned = trophies.where((t) => t.earned).length;
    final hidden = trophies.where((t) => t.hidden).toList();
    final locked = hidden.where((t) => !t.earned).toList();
    int type(String name) => trophies.where((t) => t.type == name).length;

    return 'total ${trophies.length}, earned $earned, '
        'hidden ${hidden.length} (not earned ${locked.length}: '
        'with a name ${locked.where((t) => t.name.isNotEmpty).length}, '
        'distinct names ${locked.map((t) => t.name).toSet().length}, '
        'with a description ${locked.where((t) => t.detail.isNotEmpty).length}), '
        'bronze ${type('bronze')}, silver ${type('silver')}, '
        'gold ${type('gold')}, platinum ${type('platinum')}, '
        'with a rarity ${trophies.where((t) => t.rarity != null).length}, '
        '${clock.elapsedMilliseconds} ms';
  }
}
