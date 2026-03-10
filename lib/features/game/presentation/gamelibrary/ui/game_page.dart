import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GamePageView();
  }
}

class GamePageView extends StatefulWidget {
  const GamePageView({super.key});

  @override
  State<GamePageView> createState() => _GamePageViewState();
}

class _GamePageViewState extends State<GamePageView> {
  List<Game> _lastGames = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) {
            if (message.contains('429')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Too many requests. Please try again later.'),
                ),
              );
            }
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: Text('Initialization...')),
          loading: () => const Center(child: CircularProgressIndicator()),
          syncSuccess: () => _buildGameGrid(_lastGames),
          error: (message) {
            if (message.contains('429')) {
              return _buildGameGrid(_lastGames);
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ),
            );
          },
          loaded: (games) {
            _lastGames = games;
            return _buildGameGrid(games);
          },
        );
      },
    );
  }

  /// Documentation: Builds the game grid dynamically.
  /// It can take an explicit list or try to recover one from the current state.
  Widget _buildGameGrid(List<Game> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No games found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final game = list[index];
        return GestureDetector(
          onTap: () => context.pushNamed(
            'gameDetails',
            pathParameters: {
              'appId': game.appId.toString(),
              'fromExplorer': 'false',
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: game.libraryImage ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[700],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                game.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${game.trophies.where((t) => t.isAchieved).length}/${game.trophies.length}',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
