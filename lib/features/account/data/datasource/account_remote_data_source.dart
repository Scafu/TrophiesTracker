import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trophies_tracker/features/account/data/models/steam_user_model.dart';

/// Interface for remote account data operations.
abstract class AccountRemoteDataSource {
  /// Returns the URL that starts the Steam login, carrying the PKCE
  /// [challenge].
  String getSteamLoginUrl(String challenge);

  /// Exchanges the one-time [code] from the login callback for a session
  /// token, proving possession of the PKCE [verifier].
  Future<String> exchangeCode(String code, String verifier);

  /// Fetches Steam user information by token.
  Future<SteamUserModel> getSteamUserInfo(String token);

  /// Revokes the session [token] on the server.
  Future<void> revokeToken(String token);
}

/// Implementation of [AccountRemoteDataSource] using HTTP.
class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  /// The HTTP client used for requests.
  final http.Client client;

  /// The base URL of the backend proxy.
  final String proxyBaseUrl;

  /// Creates a new [AccountRemoteDataSourceImpl].
  AccountRemoteDataSourceImpl({
    required this.client,
    required this.proxyBaseUrl,
  });

  @override
  String getSteamLoginUrl(String challenge) {
    return Uri.parse(
      '$proxyBaseUrl/auth/steam',
    ).replace(queryParameters: {'challenge': challenge}).toString();
  }

  @override
  Future<String> exchangeCode(String code, String verifier) async {
    final response = await client.post(
      Uri.parse('$proxyBaseUrl/auth/token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code, 'verifier': verifier}),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data['token'] as String;
  }

  @override
  Future<SteamUserModel> getSteamUserInfo(String token) async {
    return _getUserInfo(Uri.parse('$proxyBaseUrl/user'), token);
  }

  @override
  Future<void> revokeToken(String token) async {
    await client.post(
      Uri.parse('$proxyBaseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<SteamUserModel> _getUserInfo(Uri url, String token) async {
    try {
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SteamUserModel(
          steamId: (data['steamid'] ?? data['accountId'] ?? '').toString(),
          personaName: (data['personaname'] ?? data['onlineId'] ?? 'Unknown')
              .toString(),
          avatarUrl:
              (data['avatarfull'] ??
                      (data['avatarUrls'] != null &&
                              data['avatarUrls'].isNotEmpty
                          ? data['avatarUrls'][0]['avatarUrl']
                          : ''))
                  .toString(),
          token: token,
        );
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } on FormatException catch (e) {
      throw Exception('Failed to parse JSON response: $e');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
