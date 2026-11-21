import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/theme/accent.dart';
import 'package:trophies_tracker/core/utils/time/time_format.dart';
import 'package:trophies_tracker/core/widgets/app_toast.dart';
import 'package:trophies_tracker/core/widgets/capsule_search_field.dart';
import 'package:trophies_tracker/core/widgets/empty_state.dart';
import 'package:trophies_tracker/core/widgets/sort_menu_button.dart';
import 'package:trophies_tracker/core/widgets/tab_header.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_cubit.dart';
import 'package:trophies_tracker/features/account/presentation/cubit/account_state.dart';
import 'package:trophies_tracker/features/account/presentation/ui/account_button.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/library_view.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/ui/library_widgets.dart';

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
  List<Game>? _lastGames;
  final TextEditingController _search = TextEditingController();
  LibraryFilter _filter = LibraryFilter.all;
  LibrarySort _sort = LibrarySort.lastActivity;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Shows [message] in a toast.
  ///
  /// This is the only place that reports library sync results, wherever the
  /// sync was started from: the page stays mounted below the account page.
  void _showMessage(
    BuildContext context,
    String message, {
    ToastKind kind = ToastKind.info,
  }) {
    showAppToast(context, message, kind: kind);
  }

  Future<void> _sync() =>
      context.read<GameCubit>().fetchGamesFromSteamAccount();

  void _clearFilters() => setState(() {
    _search.clear();
    _filter = LibraryFilter.all;
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) =>
              _showMessage(context, message, kind: ToastKind.error),
          syncSuccess: () => _showMessage(
            context,
            'Steam library synced successfully!',
            kind: ToastKind.success,
          ),
          orElse: () {},
        );
      },
      builder: (context, state) {
        final syncing = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return state.when(
          initial: () => const _WithHeader(
            child: Center(child: CircularProgressIndicator()),
          ),
          loading: () => _content(context, _lastGames ?? const [], syncing),
          syncSuccess: () => _content(context, _lastGames ?? const [], syncing),
          error: (message) {
            final lastGames = _lastGames;
            if (lastGames != null) return _content(context, lastGames, syncing);
            return _WithHeader(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(message),
                  ],
                ),
              ),
            );
          },
          loaded: (games) {
            _lastGames = games;
            return _content(context, games, syncing);
          },
        );
      },
    );
  }

  Widget _content(BuildContext context, List<Game> games, bool syncing) {
    final authenticated = context.watch<AccountCubit>().state.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    final summary = librarySummary(games);
    final lastSync = context.read<GameCubit>().lastSync;
    final visible = arrangeLibrary(
      games,
      filter: _filter,
      query: _search.text,
      sort: _sort,
    );
    final unfiltered =
        _filter == LibraryFilter.all && _search.text.trim().isEmpty;
    final shelf = unfiltered ? almostThere(games) : const <Game>[];

    return RefreshIndicator(
      onRefresh: _sync,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: TabHeader(
              title: 'Library',
              subtitle: games.isEmpty
                  ? null
                  : '${summary.games} games · ${summary.trophies} trophies'
                        '${lastSync == null ? '' : '\nSynced ${formatRelative(lastSync)}'}',
              actions: [
                if (authenticated)
                  RoundIconButton(
                    icon: Symbols.sync_rounded,
                    tooltip: 'Sync with Steam',
                    busy: syncing,
                    onPressed: _sync,
                  ),
                const AccountButton(),
              ],
            ),
          ),
          if (games.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _Welcome(
                authenticated: authenticated,
                syncing: syncing,
                onSync: _sync,
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: CapsuleSearchField(
                        controller: _search,
                        hint: 'Search your games',
                        dense: true,
                        onChanged: (_) => setState(() {}),
                        onClear: () => setState(_search.clear),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SortMenuButton<LibrarySort>(
                      options: const {
                        LibrarySort.lastActivity: 'Last played',
                        LibrarySort.name: 'Name A–Z',
                        LibrarySort.progress: 'Most progress',
                        LibrarySort.trophiesLeft: 'Fewest trophies left',
                      },
                      value: _sort,
                      defaultValue: LibrarySort.lastActivity,
                      onSelected: (sort) => setState(() => _sort = sort),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _FilterChips(
                selected: _filter,
                onSelected: (filter) => setState(() => _filter = filter),
              ),
            ),
            if (shelf.isNotEmpty)
              SliverToBoxAdapter(child: AlmostThereShelf(games: shelf)),
            if (visible.isEmpty)
              SliverToBoxAdapter(child: _NoMatches(onClear: _clearFilters))
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    unfiltered ? 'ALL GAMES' : '${visible.length} RESULTS',
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
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.56,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (context, index) =>
                      LibraryGameTile(game: visible[index]),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: SizedBox(
                height: 24 + MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The header above [child], for the states with no list. [child] gets the
/// space above the floating navigation bar, so what it centers is not hidden.
class _WithHeader extends StatelessWidget {
  final Widget child;

  const _WithHeader({required this.child});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const TabHeader(title: 'Library', actions: [AccountButton()]),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: child,
        ),
      ),
    ],
  );
}

class _FilterChips extends StatelessWidget {
  final LibraryFilter selected;
  final ValueChanged<LibraryFilter> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  static const _labels = {
    LibraryFilter.all: 'All',
    LibraryFilter.inProgress: 'In progress',
    LibraryFilter.completed: 'Completed',
    LibraryFilter.notStarted: 'Not started',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          for (final entry in _labels.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: selected == entry.key,
                showCheckmark: false,
                shape: const StadiumBorder(),
                backgroundColor: colors.surfaceContainerHigh,
                selectedColor: colors.primary.withValues(alpha: 0.18),
                side: BorderSide(
                  color: colors.onSurface.withValues(alpha: 0.10),
                ),
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: selected == entry.key
                      ? accentColor(theme)
                      : colors.onSurfaceVariant,
                  fontWeight: selected == entry.key
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
                onSelected: (_) => onSelected(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown when the filters or the search leave no game.
class _NoMatches extends StatelessWidget {
  final VoidCallback onClear;

  const _NoMatches({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
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
            'No games match',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          TextButton(onPressed: onClear, child: const Text('Clear filters')),
        ],
      ),
    );
  }
}

/// Shown when the library has no games yet, with what to do about it.
class _Welcome extends StatelessWidget {
  final bool authenticated;
  final bool syncing;
  final VoidCallback onSync;

  const _Welcome({
    required this.authenticated,
    required this.syncing,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: EmptyState(
        icon: Symbols.sports_esports_rounded,
        title: 'Your library is empty',
        message: authenticated
            ? 'Sync with Steam to import your games, or find one to add by hand.'
            : 'Link an account to import your games, or find one to add by hand.',
        actions: [
          EmptyStateAction.primary(
            icon: authenticated ? Symbols.sync_rounded : Symbols.link_rounded,
            label: authenticated ? 'Sync with Steam' : 'Link account',
            onPressed: syncing
                ? null
                : authenticated
                ? onSync
                : () => context.push('/accounts'),
          ),
          EmptyStateAction.secondary(
            icon: Symbols.explore_rounded,
            label: 'Explore games',
            onPressed: () => context.go('/explore'),
          ),
        ],
      ),
    );
  }
}
