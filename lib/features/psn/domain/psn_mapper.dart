import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/psn/domain/psn_models.dart';

/// The `platformSource` of the games synced from PlayStation, which logout uses
/// to delete only them.
const psnSource = 'psn';

/// The group Sony gives to the trophies of the base game.
const _baseGroup = 'default';

/// The [Game] for [title] with its [trophies], marked as synced.
///
/// [addedAt] is when the game first reached the library: a sync keeps the date
/// of the games it already had. A trophy of an add-on group is named
/// `group-id`, so ids that repeat between groups can never overwrite each
/// other. The name of a hidden trophy is kept: hiding it is up to the screen.
Game gameFromPsn(
  PsnTitle title,
  List<PsnTrophy> trophies, {
  required DateTime addedAt,
}) {
  return Game(
    platform: GamePlatform.psn,
    code: title.id,
    name: title.name,
    libraryImage: title.iconUrl,
    addedAt: addedAt,
    platformSource: psnSource,
    isSynced: true,
    consoles: title.consoles,
    remoteUpdatedAt: title.lastUpdated,
    trophies: [
      for (final trophy in trophies)
        Trophy(
          apiName: trophy.group == _baseGroup
              ? trophy.id
              : '${trophy.group}-${trophy.id}',
          displayName: trophy.name,
          description: trophy.detail,
          icon: trophy.iconUrl,
          coloredIcon: trophy.iconUrl,
          isAchieved: trophy.earned,
          achievedAt: trophy.earnedAt,
          type: TrophyType.values.asNameMap()[trophy.type],
          hidden: trophy.hidden,
          rarity: trophy.rarity,
        ),
    ],
  );
}
