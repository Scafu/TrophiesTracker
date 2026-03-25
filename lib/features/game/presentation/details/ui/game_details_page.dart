import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_state.dart';
import 'package:trophies_tracker/features/game/presentation/details/ui/game_header_images.dart';

/// Displays the details of a specific game, including its header images,
/// general information, and a list of trophies or achievements.
class GameDetailsPage extends StatefulWidget {
  /// The unique application identifier for the game.
  final int gameAppId;

  /// Indicates whether the user navigated from the explore page.
  final bool fromExplore;

  /// Creates a [GameDetailsPage].
  const GameDetailsPage({
    required this.gameAppId,
    this.fromExplore = true,
    super.key,
  });

  @override
  State<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> {
  GameDetailsLoaded? _lastLoadedState;
  late bool _fromExplore;

  @override
  void initState() {
    super.initState();
    _fromExplore = widget.fromExplore;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameDetailsCubit, GameDetailsState>(
      listener: (BuildContext context, GameDetailsState state) {
        if (state is GameDetailsLoaded &&
            state.game.addedAt != null &&
            _fromExplore) {
          setState(() {
            _fromExplore = false;
          });
        }
        if (state is GameDetailsError) {
          final message = state.message.contains('429')
              ? 'Too many requests. Please try again later.'
              : state.message;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        } else if (state is GameDetailsSyncSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sync completed!'),
              duration: Duration(milliseconds: 1000),
            ),
          );
        } else if (state is GameDetailsDeleted) {
          context.pop();
        }
      },
      builder: (BuildContext context, GameDetailsState state) {
        if (state is GameDetailsLoaded) {
          _lastLoadedState = state;
        }

        if (state is GameDetailsLoading && _lastLoadedState == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_lastLoadedState != null) {
          final Game game = _lastLoadedState!.game;
          final bool isSyncing = state is GameDetailsLoaded
              ? state.isSyncing
              : false;

          return Scaffold(
            appBar: _buildAppBar(context, game, isSyncing, _fromExplore),
            body: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: GameHeaderImages(game: game),
                  ),
                ),
                SliverToBoxAdapter(child: GameInfoSection(game: game)),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) => TrophyTile(
                        game: game,
                        trophy: game.trophies[index],
                        fromExplorer: _fromExplore,
                      ),
                      childCount: game.trophies.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Error loading game details')),
        );
      },
    );
  }

  /// Builds the [AppBar] with contextually aware actions based on the game's
  /// synchronization status and target platform.
  AppBar _buildAppBar(
    BuildContext context,
    Game game,
    bool isSyncing,
    bool fromExplorer,
  ) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      title: Text(game.name),
      actions: <Widget>[
        if (!fromExplorer && game.isSynced) ...<Widget>[
          IconButton(
            icon: isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: isSyncing
                ? null
                : () {
                    final accountState = context.read<AccountCubit>().state;
                    final String? token = accountState.maybeWhen(
                      authenticated: (user) => user.token,
                      orElse: () => null,
                    );

                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Log in to sync achievements from Steam.',
                          ),
                        ),
                      );
                      return;
                    }

                    context.read<GameDetailsCubit>().syncAchievements(
                      game.appId,
                      token: token,
                    );
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, game),
          ),
        ] else if (!fromExplorer && !game.isSynced) ...<Widget>[
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, game),
          ),
        ] else ...<Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, game),
          ),
        ],
      ],
    );
  }

  /// Displays an [AlertDialog] prompting the user to confirm the deletion of a game.
  void _showDeleteDialog(BuildContext context, Game game) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Game'),
        content: Text('Are you sure you want to delete ${game.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GameDetailsCubit>().deleteGame(game.appId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Displays an [AlertDialog] prompting the user to confirm adding a game to their library.
  void _showAddDialog(BuildContext context, Game game) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Add Game'),
        content: Text('Are you sure you want to add ${game.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GameDetailsCubit>().saveGameToLibrary(game);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
