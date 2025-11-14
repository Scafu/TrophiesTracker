import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MainScreen { games, explore, stats }

class ActiveScreenNotifier extends Notifier<MainScreen> {
  @override
  MainScreen build() => MainScreen.games;

  void setScreen(MainScreen screen) {
    state = screen;
  }
}

final activeScreenProvider = NotifierProvider<ActiveScreenNotifier, MainScreen>(
  () => ActiveScreenNotifier(),
);
