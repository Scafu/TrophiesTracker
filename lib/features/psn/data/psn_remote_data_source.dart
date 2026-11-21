import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';

/// The PlayStation routes of the Worker (`/psn/*`).
///
/// Every call is a POST with the data in the JSON body: tokens and codes never
/// go in an address or a header, which request logs can show. An error is only
/// ever one of the fixed [PsnFailure]s, never text from Sony or from what was
/// sent, so nothing sensitive can reach a log through it.
abstract class PsnRemoteDataSource {
  Future<PsnAuthorization> authorization();
  Future<PsnSession> login(String code);
  Future<PsnSession> refresh(String refreshToken);

  /// The player's name, which is decoration: it is null when Sony will not
  /// say, never an error.
  Future<PsnProfile> profile(String accessToken);
  Future<List<PsnTitle>> titles(String accessToken);
  Future<List<PsnTrophy>> trophies(
    String accessToken, {
    required String id,
    required String service,
  });
}

class PsnRemoteDataSourceImpl implements PsnRemoteDataSource {
  final http.Client client;
  final String proxyBaseUrl;

  PsnRemoteDataSourceImpl({required this.client, required this.proxyBaseUrl});

  PsnFailure _failureOf(int status, Object? code) => switch (code) {
    'token_expired' => PsnFailure.tokenExpired,
    'psn_rejected' => PsnFailure.rejected,
    'invalid_request' => PsnFailure.invalidRequest,
    _ => PsnFailure.unavailable,
  };

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, Object?> body,
  ) async {
    final http.Response response;
    try {
      response = await client
          .post(
            Uri.parse('$proxyBaseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw const PsnException(PsnFailure.unavailable);
    }

    Map<String, dynamic>? data;
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}

    if (response.statusCode == 200 && data != null) return data;
    throw PsnException(_failureOf(response.statusCode, data?['error']));
  }

  /// Runs [parse] and turns anything it throws, such as a missing field, into
  /// [PsnFailure.unavailable] without keeping the message.
  T _parsed<T>(T Function() parse) {
    try {
      return parse();
    } on PsnException {
      rethrow;
    } catch (_) {
      throw const PsnException(PsnFailure.unavailable);
    }
  }

  @override
  Future<PsnAuthorization> authorization() async {
    final data = await _post('/psn/authorize', {});
    return _parsed(
      () => PsnAuthorization(
        url: data['url'] as String,
        callbackScheme: data['callbackScheme'] as String,
      ),
    );
  }

  PsnSession _session(Map<String, dynamic> data) => PsnSession(
    accessToken: data['accessToken'] as String,
    refreshToken: data['refreshToken'] as String,
    expiresIn: (data['expiresIn'] as num?)?.toInt(),
    refreshTokenExpiresIn: (data['refreshTokenExpiresIn'] as num?)?.toInt(),
    onlineId: data['onlineId'] as String?,
  );

  @override
  Future<PsnSession> login(String code) async {
    final data = await _post('/psn/login', {'code': code});
    return _parsed(() => _session(data));
  }

  @override
  Future<PsnSession> refresh(String refreshToken) async {
    final data = await _post('/psn/refresh', {'refreshToken': refreshToken});
    return _parsed(() => _session(data));
  }

  @override
  Future<PsnProfile> profile(String accessToken) async {
    final data = await _post('/psn/profile', {'accessToken': accessToken});
    return _parsed(
      () => PsnProfile(
        onlineId: data['onlineId'] as String?,
        attempts: [
          for (final attempt in data['attempts'] as List<dynamic>)
            attempt as String,
        ],
      ),
    );
  }

  PsnTrophyCounts _counts(Object? value) {
    final map = value as Map<String, dynamic>;
    int count(String type) => (map[type] as num?)?.toInt() ?? 0;
    return PsnTrophyCounts(
      bronze: count('bronze'),
      silver: count('silver'),
      gold: count('gold'),
      platinum: count('platinum'),
    );
  }

  @override
  Future<List<PsnTitle>> titles(String accessToken) async {
    final data = await _post('/psn/titles', {'accessToken': accessToken});
    return _parsed(
      () => [
        for (final item in data['titles'] as List<dynamic>)
          PsnTitle(
            id: item['id'] as String,
            service: item['service'] as String,
            name: item['name'] as String,
            iconUrl: item['iconUrl'] as String?,
            consoles: [
              for (final console in item['consoles'] as List<dynamic>)
                console as String,
            ],
            defined: _counts(item['defined']),
            earned: _counts(item['earned']),
            progress: (item['progress'] as num?)?.toInt() ?? 0,
            lastUpdated: item['lastUpdated'] == null
                ? null
                : DateTime.parse(item['lastUpdated'] as String),
          ),
      ],
    );
  }

  @override
  Future<List<PsnTrophy>> trophies(
    String accessToken, {
    required String id,
    required String service,
  }) async {
    final data = await _post('/psn/trophies', {
      'accessToken': accessToken,
      'id': id,
      'service': service,
    });
    return _parsed(
      () => [
        for (final item in data['trophies'] as List<dynamic>)
          PsnTrophy(
            id: item['id'] as String,
            name: item['name'] as String,
            detail: item['detail'] as String,
            iconUrl: item['iconUrl'] as String?,
            type: item['type'] as String?,
            hidden: item['hidden'] as bool,
            rarity: (item['rarity'] as num?)?.toDouble(),
            group: item['group'] as String,
            earned: item['earned'] as bool,
            earnedAt: item['earnedAt'] == null
                ? null
                : DateTime.parse(item['earnedAt'] as String),
          ),
      ],
    );
  }
}
