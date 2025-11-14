import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trophies_app_tracker/core/providers/game_provider.dart';
import 'package:trophies_app_tracker/features/game/view/game_widget.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({super.key});
  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  @override
  Widget build(BuildContext context) {
    final listGames = ref.watch(gameProviderOffline);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth == 0 || !constraints.hasTightWidth) {
          return const SizedBox.shrink();
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.615,
          ),
          itemCount: listGames.length,
          itemBuilder: (context, index) {
            final game = listGames[index];
            return GameWidget(game: game);
          },
        );
      },
    );
  }
}
