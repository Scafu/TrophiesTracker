import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:trophies_tracker/core/di/injection_container.dart';
import 'package:trophies_tracker/core/utils/debouncer/debouncer.dart';
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_state.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/explore_page_tiles.dart';

/// Displays a search interface to explore and find games.
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExploreUiState();
}

class _ExploreUiState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search for a game...',
                leading: const Icon(Icons.search),
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<ExploreCubit>().searchGames('');
                    },
                  ),
                ],
                onChanged: (query) {
                  _debouncer.run(() {
                    context.read<ExploreCubit>().searchGames(query);
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ExploreCubit, ExploreState>(
              builder: (context, state) {
                if (state is ExploreInitial) {
                  return Center(
                    child: Text("Type a game name to start searching."),
                  );
                }
                if (state is ExploreLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ExploreError) {
                  return Center(child: Text(state.message));
                }
                if (state is ExploreSuccess) {
                  final games = state.searchResults;
                  if (games.isEmpty) {
                    return Center(child: Text('No games found'));
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ListView.builder(
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return ExploreGameTile(
                          game: game,
                          onTap: () async {
                            final existingGame = await sl<GameRepository>()
                                .isGameInLibrary(game.appId);
                            bool fromExplorer = true;
                            if (existingGame) {
                              fromExplorer = false;
                            }
                            if (!context.mounted) return;

                            context.pushNamed(
                              'gameDetails',
                              pathParameters: {
                                'appId': game.appId.toString(),
                                'fromExplorer': fromExplorer.toString(),
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
