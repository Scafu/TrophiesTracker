import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/widgets/app_toast.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/trophy.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/details/cubit/game_details_state.dart';
import 'package:trophies_tracker/features/game/presentation/details/trophy_view.dart';
import 'package:trophies_tracker/features/game/presentation/details/ui/game_hero.dart';
import 'package:trophies_tracker/features/game/presentation/details/ui/game_progress_card.dart';
import 'package:trophies_tracker/features/game/presentation/details/ui/trophy_controls.dart';
import 'package:trophies_tracker/features/game/presentation/details/ui/trophy_tile.dart';

/// Displays a specific game: a collapsing hero with its art, the progress, and
/// the list of trophies with filter, search, sort and rarity.
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

  final TextEditingController _search = TextEditingController();
  TrophyFilter _filter = TrophyFilter.all;
  TrophySort _sort = TrophySort.defaultOrder;
  Map<String, double> _rarity = const {};

  @override
  void initState() {
    super.initState();
    _fromExplore = widget.fromExplore;
    _loadRarity();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Asks for the rarity of the trophies. It is decoration: until it arrives,
  /// or if it never does, the list simply shows no rarity.
  Future<void> _loadRarity() async {
    final rarity = await context.read<GameDetailsCubit>().fetchRarity(
      widget.gameAppId,
    );
    if (mounted && rarity.isNotEmpty) setState(() => _rarity = rarity);
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
          showAppToast(context, state.message, kind: ToastKind.error);
        } else if (state is GameDetailsSyncSuccess) {
          showAppToast(context, 'Sync completed!', kind: ToastKind.success);
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
          final bool isSyncing = state is GameDetailsLoaded
              ? state.isSyncing
              : false;
          return Scaffold(
            body: _content(context, _lastLoadedState!.game, isSyncing),
          );
        }

        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Error loading game details')),
        );
      },
    );
  }

  Widget _content(BuildContext context, Game game, bool isSyncing) {
    final explorer = _fromExplore;
    final groups = arrangeTrophies(
      game.trophies,
      filter: explorer ? TrophyFilter.all : _filter,
      query: _search.text,
      sort: _sort,
      rarity: _rarity,
    );
    final description = game.description ?? '';

    return CustomScrollView(
      slivers: <Widget>[
        GameSliverAppBar(
          game: game,
          actions: _actions(context, game, isSyncing),
          onBack: () => context.canPop() ? context.pop() : context.go('/games'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: explorer
                ? ExplorerCard(
                    total: game.trophies.length,
                    onAdd: () => _showAddDialog(context, game),
                  )
                : ProgressCard(summary: summarize(game.trophies)),
          ),
        ),
        if (description.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: ExpandableDescription(text: description),
            ),
          ),
        SliverPersistentHeader(
          pinned: true,
          delegate: TrophyControlsDelegate(
            showFilter: !explorer,
            filter: _filter,
            onFilter: (filter) => setState(() => _filter = filter),
            query: _search,
            onQuery: (_) => setState(() {}),
            onClearQuery: () => setState(_search.clear),
            sort: _sort,
            onSort: (sort) => setState(() => _sort = sort),
            rarityAvailable: _rarity.isNotEmpty,
          ),
        ),
        if (game.trophies.isEmpty)
          const _EmptyMessage('This game has no trophies.')
        else if (groups.unlocked.isEmpty && groups.locked.isEmpty)
          _EmptyMessage('No trophies match "${_search.text.trim()}".')
        else if (explorer)
          ..._section('Trophies', [...groups.unlocked, ...groups.locked], game)
        else ...[
          if (groups.unlocked.isNotEmpty)
            ..._section('Unlocked', groups.unlocked, game),
          if (groups.locked.isNotEmpty)
            ..._section('Locked', groups.locked, game),
        ],
        SliverToBoxAdapter(
          child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
        ),
      ],
    );
  }

  /// A heading with the count, then the trophies of the group.
  List<Widget> _section(String title, List<Trophy> trophies, Game game) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Text(
            '${title.toUpperCase()} · ${trophies.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.builder(
          itemCount: trophies.length,
          itemBuilder: (context, index) => TrophyTile(
            game: game,
            trophy: trophies[index],
            fromExplorer: _fromExplore,
            rarity: _rarity[trophies[index].apiName],
          ),
        ),
      ),
    ];
  }

  /// The buttons of the app bar, which depend on whether the game is in the
  /// library and whether it is synced from Steam.
  List<GlassAction> _actions(BuildContext context, Game game, bool isSyncing) {
    final delete = GlassAction(
      icon: Symbols.delete_rounded,
      tooltip: 'Delete game',
      onPressed: () => _showDeleteDialog(context, game),
    );

    if (_fromExplore) {
      return [
        GlassAction(
          icon: Symbols.add_rounded,
          tooltip: 'Add to library',
          onPressed: () => _showAddDialog(context, game),
        ),
      ];
    }
    if (!game.isSynced) return [delete];

    return [
      GlassAction(
        icon: Symbols.sync_rounded,
        tooltip: 'Sync achievements',
        busy: isSyncing,
        onPressed: () {
          final accountState = context.read<AccountCubit>().state;
          final String? token = accountState.maybeWhen(
            authenticated: (user) => user.token,
            orElse: () => null,
          );

          if (token == null) {
            showAppToast(context, 'Log in to sync achievements from Steam.');
            return;
          }

          context.read<GameDetailsCubit>().syncAchievements(
            game.appId,
            token: token,
          );
        },
      ),
      delete,
    ];
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

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage(this.message);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          children: [
            Icon(
              Symbols.search_off_rounded,
              size: 44,
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
