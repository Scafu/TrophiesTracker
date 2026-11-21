/// Why a PlayStation call failed. Only these fixed reasons are ever reported:
/// nothing the user sent or Sony answered goes into an error.
enum PsnFailure {
  /// What the app sent was not valid.
  invalidRequest,

  /// Sony refused the code or the renewal token.
  rejected,

  /// The access is no longer valid: the user has to log in again.
  tokenExpired,

  /// Sony or the Worker could not be reached or answered something unusable.
  unavailable,
}

class PsnException implements Exception {
  final PsnFailure failure;

  const PsnException(this.failure);

  @override
  String toString() => 'PsnException(${failure.name})';
}

/// The login page of Sony and the scheme it returns to the app with.
class PsnAuthorization {
  final String url;
  final String callbackScheme;

  const PsnAuthorization({required this.url, required this.callbackScheme});
}

/// What a login or a renewal gives. The tokens are secrets: they are kept in
/// the secure storage and never shown or logged.
class PsnSession {
  final String accessToken;
  final String refreshToken;

  /// Seconds the access token lasts, if Sony said.
  final int? expiresIn;

  /// Seconds the renewal token lasts, if Sony said.
  final int? refreshTokenExpiresIn;

  /// The name of the player, if the profile could be read.
  final String? onlineId;

  const PsnSession({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
    this.refreshTokenExpiresIn,
    this.onlineId,
  });
}

/// What looking up the player's name gave: the name, if Sony has it, and the
/// steps taken with the status Sony answered each with (`summary 200`). The
/// steps hold no data; they only tell where a failed lookup stopped.
class PsnProfile {
  final String? onlineId;
  final List<String> attempts;

  const PsnProfile({this.onlineId, this.attempts = const []});
}

class PsnTrophyCounts {
  final int bronze;
  final int silver;
  final int gold;
  final int platinum;

  const PsnTrophyCounts({
    this.bronze = 0,
    this.silver = 0,
    this.gold = 0,
    this.platinum = 0,
  });

  int get total => bronze + silver + gold + platinum;
}

/// A game with trophies, for PS4 or PS5.
class PsnTitle {
  /// The `npCommunicationId`, like `NPWR20188_00`.
  final String id;

  /// `trophy2` for PS5, `trophy` for the rest.
  final String service;
  final String name;
  final String? iconUrl;

  /// `PS4`, `PS5` or both.
  final List<String> consoles;
  final PsnTrophyCounts defined;
  final PsnTrophyCounts earned;
  final int progress;
  final DateTime? lastUpdated;

  const PsnTitle({
    required this.id,
    required this.service,
    required this.name,
    required this.iconUrl,
    required this.consoles,
    required this.defined,
    required this.earned,
    required this.progress,
    required this.lastUpdated,
  });

  int get total => defined.total;
  int get earnedCount => earned.total;
}

class PsnTrophy {
  final String id;
  final String name;
  final String detail;
  final String? iconUrl;

  /// `bronze`, `silver`, `gold` or `platinum`.
  final String? type;
  final bool hidden;

  /// The share of players who earned it, from 0 to 100.
  final double? rarity;
  final String group;
  final bool earned;
  final DateTime? earnedAt;

  const PsnTrophy({
    required this.id,
    required this.name,
    required this.detail,
    required this.iconUrl,
    required this.type,
    required this.hidden,
    required this.rarity,
    required this.group,
    required this.earned,
    required this.earnedAt,
  });
}

/// The linked PlayStation account, as far as the app keeps it. Nothing secret:
/// the tokens stay in the secure storage.
class PsnLink {
  /// The name of the player, when the profile could be read.
  final String? onlineId;

  /// When the renewal token stops working, so the user has to log in again.
  final DateTime? refreshExpiresAt;

  /// When the library was last synced.
  final DateTime? lastSync;

  const PsnLink({this.onlineId, this.refreshExpiresAt, this.lastSync});

  /// Whole days left before the login is needed again, or null if unknown.
  int? daysLeft(DateTime now) {
    final end = refreshExpiresAt;
    if (end == null) return null;
    final left = end.difference(now);
    return left.isNegative ? 0 : left.inDays;
  }

  /// Whether the renewal token has stopped working.
  bool isExpired(DateTime now) {
    final end = refreshExpiresAt;
    return end != null && !end.isAfter(now);
  }
}

/// What a sync did: the games Sony lists and how many of them it had to read
/// again because they were new or had changed.
class PsnSyncResult {
  final int total;
  final int updated;

  const PsnSyncResult({required this.total, required this.updated});
}
