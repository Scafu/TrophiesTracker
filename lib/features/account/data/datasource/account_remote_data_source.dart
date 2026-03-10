import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trophies_tracker/features/account/data/models/steam_user_model.dart';

/// Interface for remote account data operations.
abstract class AccountRemoteDataSource {
  /// Returns the URL for Steam authentication.
  String getSteamLoginUrl();

  /// Fetches Steam user information by Steam ID.
  Future<SteamUserModel> getSteamUserInfo(String steamId);
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
  String getSteamLoginUrl() {
    return '$proxyBaseUrl/auth/steam';
  }

  @override
  Future<SteamUserModel> getSteamUserInfo(String token) async {
    final url = Uri.parse('$proxyBaseUrl/user?token=$token');
    try {
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SteamUserModel(
          steamId: data['steamid']?.toString() ?? '',
          personaName: data['personaname']?.toString() ?? 'Unknown',
          avatarUrl:
              data['avatarfull']?.toString() ??
              data['avatar']?.toString() ??
              '',
          token: token, // ← aggiungi questo
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
