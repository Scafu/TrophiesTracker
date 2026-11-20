import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/utils/debouncer/debouncer.dart';
import 'package:trophies_tracker/core/widgets/capsule_search_field.dart';
import 'package:trophies_tracker/core/widgets/tab_header.dart';
import 'package:trophies_tracker/features/account/presentation/ui/account_button.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_state.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/explore_page_tiles.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/cubit/game_state.dart';

/// Search over the offline Steam catalog.
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExploreUiState();
}

class _ExploreUiState extends State<ExplorePage> {
  static const _suggestions = [
    'Elden Ring',
    'Hades',
    'Portal 2',
    'Hollow Knight',
  ];

  final TextEditingController _controller = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 350);

  @override
  void dispose() {
    _debouncer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (mounted) context.read<ExploreCubit>().searchGames(query);
  }

  void _clear() {
    _debouncer.cancel();
    _controller.clear();
    _search('');
  }

  void _useSuggestion(String suggestion) {
    _controller.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    _search(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TabHeader(title: 'Explore', actions: [AccountButton()]),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: CapsuleSearchField(
            controller: _controller,
            hint: 'Search the Steam catalog',
            onChanged: (query) => _debouncer.run(() => _search(query)),
            onSubmitted: (query) {
              _debouncer.cancel();
              _search(query);
            },
            onClear: _clear,
          ),
        ),
        Expanded(
          child: BlocBuilder<ExploreCubit, ExploreState>(
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(state.runtimeType),
                  child: switch (state) {
                    ExploreInitial() => _Hint(
                      suggestions: _suggestions,
                      onSuggestion: _useSuggestion,
                    ),
                    ExploreEmpty() => _Message(
                      icon: Symbols.search_off_rounded,
                      title: 'No games found',
                      subtitle:
                          'Nothing matches "${_controller.text.trim()}". Check the spelling or try a shorter name.',
                    ),
                    ExploreError(message: final message) => _Message(
                      icon: Symbols.error_rounded,
                      title: 'Search failed',
                      subtitle: message,
                    ),
                    ExploreSuccess(searchResults: final games) => _Results(
                      games: games,
                      query: _controller.text.trim(),
                    ),
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Shown before the first search: what the page does, and a few titles to try.
class _Hint extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;

  const _Hint({required this.suggestions, required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Icon(
                Symbols.travel_explore_rounded,
                size: 40,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Find any Steam game',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Search the catalog, open a game and add it to your library to track its trophies.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'TRY',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in suggestions)
                ActionChip(
                  label: Text(suggestion),
                  backgroundColor: colors.surfaceContainerHigh,
                  side: BorderSide(
                    color: colors.onSurface.withValues(alpha: 0.10),
                  ),
                  shape: const StadiumBorder(),
                  onPressed: () => onSuggestion(suggestion),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shown when a search has no results, or failed.
class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final List<Game> games;
  final String query;

  const _Results({required this.games, required this.query});

  @override
  Widget build(BuildContext context) {
    final inLibrary = context.watch<GameCubit>().state.maybeWhen(
      loaded: (library) => {for (final game in library) game.appId},
      orElse: () => <int>{},
    );

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final owned = inLibrary.contains(game.appId);

        return ExploreGameTile(
          game: game,
          query: query,
          inLibrary: owned,
          onTap: () => context.pushNamed(
            'gameDetails',
            pathParameters: {
              'appId': game.appId.toString(),
              'fromExplorer': (!owned).toString(),
            },
          ),
        );
      },
    );
  }
}
