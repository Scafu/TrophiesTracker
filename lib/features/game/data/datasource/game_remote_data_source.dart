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
  Future<Map<int, String>> fetchCovers(List<int> appIds);
  Future<Map<String, double>> fetchRarity(int appId);
  Future<List<GameModel>> fetchCategory(int tagId);
}

/// Parses one `/catalog` page (runs in an isolate via `compute`): the apps that
/// have a name, whether more pages follow and the appId to continue from.
({List<Map<String, dynamic>> apps, bool hasMore, int? lastAppId})
_parseSteamCatalogChunk(String responseBody) {
  final responseData = json.decode(responseBody)['response'];
  final apps = (responseData?['apps'] as List<dynamic>? ?? const [])
      .map((e) => e as Map<String, dynamic>)
      .where((app) => app['name'] != null && app['name'].toString().isNotEmpty)
      .toList();

  return (
    apps: apps,
    hasMore: responseData?['have_more_results'] ?? false,
    lastAppId: responseData?['last_appid'],
  );
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
          code: '${data['appId']}',
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
      final response = await client
          .get(url)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final chunk = await compute(_parseSteamCatalogChunk, response.body);
        allApps.addAll(chunk.apps);
        chunkCount++;

        final nextAppId = chunk.lastAppId ?? currentLastAppId;
        hasMore = chunk.hasMore && nextAppId > currentLastAppId;
        if (hasMore) currentLastAppId = nextAppId;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    }

    return (apps: allApps, lastAppId: currentLastAppId, hasMore: hasMore);
  }

  /// Fetches a game, its trophy schema and its cover art, merged with the
  /// player's progress when a [token] is given.
  ///
  /// Throws if the player's achievements cannot be read: callers must never
  /// mistake a failed call for "nothing unlocked" and overwrite saved progress.
  @override
  Future<GameModel> getGameByIdRemote(int appId, {String? token}) async {
    final game = await _fetchGame(appId, token: token);
    return (await _withCovers([game])).single;
  }

  /// Same as [getGameByIdRemote] without the cover lookup, so that a library
  /// sync can look every cover up in a single request.
  Future<GameModel> _fetchGame(int appId, {String? token}) async {
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
        '$proxyBaseUrl/playerAchievements',
      ).replace(queryParameters: {'appid': '$appId'});
      requests.add(
        client.get(
          playerAchievementsUrl,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
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

    if (token != null && playerAchievementsResponse?.statusCode != 200) {
      throw Exception(
        'Failed to fetch player achievements '
        '(HTTP ${playerAchievementsResponse?.statusCode}).',
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

  /// Looks up the vertical cover Steam really serves for each of [appIds];
  /// games without one are left out of the result.
  ///
  /// The default URL built from the appId answers 200 with a grey placeholder
  /// for many recent games, whose art lives at a hashed path only the Worker
  /// can look up (`/covers`, up to 100 games per request). It is cosmetic, so
  /// a failure (old Worker, no network) just returns what was found so far.
  @override
  Future<Map<int, String>> fetchCovers(List<int> appIds) async {
    final covers = <int, String>{};

    for (var i = 0; i < appIds.length; i += 100) {
      final ids = appIds.skip(i).take(100).join(',');
      try {
        final response = await client
            .get(
              Uri.parse(
                '$proxyBaseUrl/covers',
              ).replace(queryParameters: {'ids': ids}),
            )
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) continue;

        final data = json.decode(response.body) as Map<String, dynamic>;
        for (final entry in data.entries) {
          final library = entry.value['library'];
          if (library is String && library.isNotEmpty) {
            covers[int.parse(entry.key)] = library;
          }
        }
      } catch (e) {
        debugPrint('Could not look up covers: $e');
      }
    }
    return covers;
  }

  /// The share of players (0-100) who unlocked each achievement of [appId],
  /// by API name, or an empty map when it cannot be read.
  ///
  /// It only decorates the trophy list, so a failure (old Worker, no network,
  /// a game without achievements) is not an error.
  @override
  Future<Map<String, double>> fetchRarity(int appId) async {
    try {
      final response = await client
          .get(Uri.parse('$proxyBaseUrl/rarity?appid=$appId'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return {};

      final data = json.decode(response.body) as Map<String, dynamic>;
      return {
        for (final entry in data.entries)
          if (entry.value is num) entry.key: (entry.value as num).toDouble(),
      };
    } catch (e) {
      debugPrint('Could not look up rarity for $appId: $e');
      return {};
    }
  }

  /// The most popular games with trophies in the Steam genre [tagId], from the
  /// Worker's `/category`, as models with only id and name. Unlike the
  /// cosmetic lookups, a failure is thrown: the page needs to say it.
  @override
  Future<List<GameModel>> fetchCategory(int tagId) async {
    final response = await client
        .get(
          Uri.parse(
            '$proxyBaseUrl/category',
          ).replace(queryParameters: {'tag': '$tagId'}),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Category $tagId failed: ${response.statusCode}');
    }

    return [
      for (final item in json.decode(response.body) as List<dynamic>)
        if (item is Map<String, dynamic> &&
            item['appid'] is int &&
            item['name'] is String)
          GameModel(code: '${item['appid']}', name: item['name'] as String),
    ];
  }

  /// Returns [games] with the covers [fetchCovers] finds for them.
  Future<List<GameModel>> _withCovers(List<GameModel> games) async {
    int steamId(GameModel game) => int.parse(game.code);
    final covers = await fetchCovers([for (final game in games) steamId(game)]);
    return [
      for (final game in games)
        covers.containsKey(steamId(game))
            ? game.copyWith(libraryImage: covers[steamId(game)])
            : game,
    ];
  }

  @override
  Future<List<GameModel>> fetchGamesFromSteamAccount(String token) async {
    final gamesUrl = Uri.parse('$proxyBaseUrl/library');
    try {
      final response = await client
          .get(
            gamesUrl,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
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
                return await _fetchGame(appId, token: token);
              } catch (e) {
                debugPrint('Error fetching full details for game $appId: $e');

                final String headerImage =
                    'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/$appId/header.jpg';

                final String libraryImage =
                    'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/$appId/library_600x900_2x.jpg';

                return GameModel(
                  code: '$appId',
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

        return await _withCovers(results);
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

/// Builds a [GameModel] from the raw `/game`, `/achievements` and
/// `/playerAchievements` bodies (runs in an isolate via `compute`).
///
/// Throws when `playerAchievementsBody` is present but has no `achievements`
/// (e.g. HTTP 200 with `success: false`), so it is never read as "all locked".
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
      } else {
        throw Exception('Player achievements unavailable for $appId');
      }
    } catch (e) {
      debugPrint('Error parsing player achievements for $appId: $e');
      rethrow;
    }
  }

  return GameModel(
    code: '$appId',
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
