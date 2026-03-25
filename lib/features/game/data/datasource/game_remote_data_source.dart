import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trophies_tracker/features/game/data/models/game_model.dart';
import 'package:trophies_tracker/features/game/data/models/trophy_model.dart';

abstract class GameRemoteDataSource {
  Future<List<GameModel>> searchGamesOnline(String platform, String query);
  Future<({List<Map<String, dynamic>> apps, int lastAppId, bool hasMore})>
  fetchSteamCatalogOnline({int maxChunks, int startFromAppId});
  Future<List<GameModel>> fetchGamesFromSteamAccount(String token);
  Future<GameModel> getGameByIdRemote(int appId, {String? token});

}

List<Map<String, dynamic>> _parseSteamCatalogChunk(String responseBody) {
  final decoded = json.decode(responseBody);
  final responseData = decoded['response'];

  if (responseData == null || responseData['apps'] == null) {
    return [];
  }

  final apps = responseData['apps'] as List<dynamic>;

  return apps
      .map((e) => e as Map<String, dynamic>)
      .where((app) => app['name'] != null && app['name'].toString().isNotEmpty)
      .toList();
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final http.Client client;
  final String proxyBaseUrl;

  GameRemoteDataSourceImpl({required this.client, required this.proxyBaseUrl});


  @override
  Future<List<GameModel>> searchGamesOnline(
    String platform,
    String query,
  ) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
      '$proxyBaseUrl/search?platform=$platform&query=$encodedQuery',
    );

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      return jsonList.map((data) {
        return GameModel(
          appId: data['appId'],
          name: data['name'],
          publisher: List<String>.from(data['publisher'] ?? []),
          description: data['description'],
          headerImage: data['headerImage'],
          libraryImage: data['libraryImage'],
          addedAt: null,
          platformSource: platform,
          trophies: [],
        );
      }).toList();
    } else {
      throw Exception('ServerException');
    }
  }

  @override
  Future<({List<Map<String, dynamic>> apps, int lastAppId, bool hasMore})>
  fetchSteamCatalogOnline({int? maxChunks, int startFromAppId = 0}) async {
    int currentLastAppId = startFromAppId;
    bool hasMore = true;
    final List<Map<String, dynamic>> allApps = [];
    int chunkCount = 0;

    while (hasMore) {
      if (maxChunks != null && chunkCount >= maxChunks) break;

      final url = Uri.parse(
        '$proxyBaseUrl/catalog?last_appid=$currentLastAppId',
      );
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final chunk = await compute(_parseSteamCatalogChunk, response.body);
        allApps.addAll(chunk);
        chunkCount++;

        final decoded = json.decode(response.body);
        final responseData = decoded['response'];
        hasMore = responseData['have_more_results'] ?? false;
        if (hasMore) currentLastAppId = responseData['last_appid'];
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    }

    return (apps: allApps, lastAppId: currentLastAppId, hasMore: hasMore);
  }

  @override
  Future<GameModel> getGameByIdRemote(int appId, {String? token}) async {
    final gameUrl = Uri.parse('$proxyBaseUrl/game?appid=$appId');
    final achievementsUrl = Uri.parse(
      '$proxyBaseUrl/achievements?appid=$appId',
    );

    final List<Future<http.Response>> requests = [
      client.get(gameUrl),
      client.get(achievementsUrl),
    ];

    if (token != null) {
      final playerAchievementsUrl = Uri.parse(
        '$proxyBaseUrl/playerAchievements?token=$token&appid=$appId',
      );
      requests.add(client.get(playerAchievementsUrl));
    }

    final responses = await Future.wait(requests);

    final gameResponse = responses[0];
    final achievementsResponse = responses[1];
    http.Response? playerAchievementsResponse;
    if (token != null && responses.length > 2) {
      playerAchievementsResponse = responses[2];
    }

    if (gameResponse.statusCode != 200) {
      throw Exception(
        'Failed to fetch game details and no initial name provided.',
      );
    }

    return await compute(_parseAndMergeGameData, {
      'appId': appId,
      'gameBody': gameResponse.statusCode == 200 ? gameResponse.body : null,
      'achievementsBody': achievementsResponse.statusCode == 200
          ? achievementsResponse.body
          : null,
      'playerAchievementsBody': playerAchievementsResponse?.statusCode == 200
          ? playerAchievementsResponse?.body
          : null,
    });
  }

  @override
  Future<List<GameModel>> fetchGamesFromSteamAccount(String token) async {
    final gamesUrl = Uri.parse('$proxyBaseUrl/library?token=$token');
    try {
      final response = await client
          .get(
            gamesUrl,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> gamesList = await compute(
          _parseLibraryResponse,
          response.body,
        );

        final List<GameModel> results = [];

        const int batchSize = 5;
        for (int i = 0; i < gamesList.length; i += batchSize) {
          final end = (i + batchSize < gamesList.length)
              ? i + batchSize
              : gamesList.length;
          final batch = gamesList.sublist(i, end);

          final batchResults = await Future.wait(
            batch.map((gameData) async {
              final data = gameData as Map<String, dynamic>;
              final int appId = data['appId'] ?? data['appid'];
              final String? name = data['name'];

              try {
                return await getGameByIdRemote(appId, token: token);
              } catch (e) {
                debugPrint('Error fetching full details for game $appId: $e');

                final String headerImage =
                    'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/$appId/header.jpg';

                final String libraryImage =
                    'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/$appId/library_600x900_2x.jpg';

                return GameModel(
                  appId: appId,
                  name: name ?? 'Unknown',
                  headerImage: headerImage,
                  libraryImage: libraryImage,
                  publisher: [],
                  description: '',
                  platformSource: 'steam',
                  trophies: [],
                );
              }
            }),
          );
          results.addAll(
            batchResults.where((game) => game.trophies.isNotEmpty),
          );

          await Future.delayed(const Duration(milliseconds: 500));
        }

        return results;
      } else {
        throw Exception(
          'Failed to fetch games from Steam account: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out while fetching Steam library');
    } on FormatException catch (e) {
      throw Exception('Failed to parse JSON response: $e');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

List<dynamic> _parseLibraryResponse(String body) {
  final dynamic decoded = json.decode(body);
  if (decoded is List) {
    return decoded;
  } else if (decoded is Map<String, dynamic> && decoded.containsKey('games')) {
    return decoded['games'] as List<dynamic>;
  } else if (decoded is Map<String, dynamic> &&
      decoded.containsKey('response') &&
      decoded['response'].containsKey('games')) {
    return decoded['response']['games'] as List<dynamic>;
  }
  return [];
}

GameModel _parseAndMergeGameData(Map<String, dynamic> params) {
  final int appId = params['appId'];
  final String? gameBody = params['gameBody'];
  final String? achievementsBody = params['achievementsBody'];
  final String? playerAchievementsBody = params['playerAchievementsBody'];
  final String? initialName = params['initialName'];

  String name = initialName ?? 'Unknown Title';
  List<String> publishers = [];
  String description = '';
  String? headerImage;

  if (gameBody != null) {
    try {
      final Map<String, dynamic> gameJson = json.decode(gameBody);
      final gameDataNode = gameJson[appId.toString()];

      if (gameDataNode != null && gameDataNode['success'] == true) {
        final steamGameData = gameDataNode['data'];
        name = steamGameData['name'] ?? name;
        publishers = List<String>.from(steamGameData['publishers'] ?? []);
        description = steamGameData['short_description'] ?? '';
        headerImage = steamGameData['header_image'];
      }
    } catch (e) {
      debugPrint('Error parsing game body for $appId: $e');
    }
  }

  List<TrophyModel> trophies = [];

  if (achievementsBody != null) {
    try {
      final achJson = json.decode(achievementsBody);
      final stats = achJson['game']?['availableGameStats'];
      if (stats != null && stats['achievements'] != null) {
        final achievementsList = stats['achievements'] as List<dynamic>;
        trophies = achievementsList.map((ach) {
          return TrophyModel(
            apiName: ach['name'] ?? '',
            displayName: ach['displayName'] ?? 'Hidden Trophy',
            description: ach['description'] ?? '',
            icon: ach['icongray'] ?? ach['icon'],
            coloredIcon: ach['icon'],
            isAchieved: false,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error parsing achievements schema for $appId: $e');
    }
  }

  if (playerAchievementsBody != null) {
    try {
      final Map<String, dynamic> playerAchJson = json.decode(
        playerAchievementsBody,
      );
      final playerstats = playerAchJson['playerstats'];
      if (playerstats != null && playerstats['achievements'] != null) {
        final List<dynamic> playerAchievementsList =
            playerstats['achievements'];

        if (trophies.isEmpty) {
          trophies = playerAchievementsList.map((ach) {
            final int? unlockTime = ach['unlocktime'];
            return TrophyModel(
              apiName: ach['apiname'] ?? ach['name'] ?? '',
              displayName:
                  ach['displayname'] ?? ach['apiname'] ?? 'Hidden Trophy',
              description: ach['description'] ?? '',
              isAchieved: ach['achieved'] == 1,
              achievedAt: (unlockTime != null && unlockTime > 0)
                  ? DateTime.fromMillisecondsSinceEpoch(unlockTime * 1000)
                  : null,
            );
          }).toList();
        } else {
          final Map<String, dynamic> playerStatusMap = {
            for (var ach in playerAchievementsList)
              (ach['apiname'] ?? ach['name'] ?? ''): ach,
          };

          trophies = trophies.map((trophy) {
            final playerAch = playerStatusMap[trophy.apiName];
            if (playerAch != null) {
              final int? unlockTime = playerAch['unlocktime'];
              return trophy.copyWith(
                isAchieved: playerAch['achieved'] == 1,
                achievedAt: (unlockTime != null && unlockTime > 0)
                    ? DateTime.fromMillisecondsSinceEpoch(unlockTime * 1000)
                    : null,
              );
            }
            return trophy;
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error parsing player achievements for $appId: $e');
    }
  }

  return GameModel(
    appId: appId,
    name: name,
    publisher: publishers,
    description: description,
    headerImage: headerImage,
    libraryImage:
        'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/$appId/library_600x900_2x.jpg',
    platformSource: 'steam',
    addedAt: null,
    trophies: trophies,
  );
}
