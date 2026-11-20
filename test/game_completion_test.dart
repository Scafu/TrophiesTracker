import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/utils/game/game_completion.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';

Game _game(List<bool> unlocked) => Game(
  appId: 1,
  name: 'G',
  trophies: [
    for (var i = 0; i < unlocked.length; i++)
      Trophy(apiName: '$i', displayName: '$i', isAchieved: unlocked[i]),
  ],
);

void main() {
  test(
    'a game is completed only when it has trophies and all are unlocked',
    () {
      expect(_game([]).isCompleted, isFalse);
      expect(_game([true, false]).isCompleted, isFalse);
      expect(_game([false, false]).isCompleted, isFalse);
      expect(_game([true, true]).isCompleted, isTrue);
    },
  );
}
