import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/utils/debouncer/debouncer.dart';
import 'package:trophies_tracker/core/widgets/capsule_search_field.dart';
import 'package:trophies_tracker/core/widgets/section_label.dart';
import 'package:trophies_tracker/core/widgets/tab_header.dart';
import 'package:trophies_tracker/features/account/presentation/ui/account_button.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/categories.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/explore_state.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/category_tile.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/explore_helpers.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/explore_page_tiles.dart';

/// Search over the offline Steam catalog.
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExploreUiState();
}

class _ExploreUiState extends State<ExplorePage> {
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
                    ExploreInitial() => const _Categories(),
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

/// Shown before the first search: a tile for each genre to browse.
class _Categories extends StatelessWidget {
  const _Categories();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        const SliverToBoxAdapter(child: SectionLabel('Browse by category')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 92,
            ),
            itemCount: gameCategories.length,
            itemBuilder: (context, index) {
              final category = gameCategories[index];

              return CategoryTile(
                category: category,
                onTap: () => context.pushNamed(
                  'category',
                  pathParameters: {'tagId': category.tagId.toString()},
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 120 + MediaQuery.paddingOf(context).bottom),
        ),
      ],
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
    final inLibrary = libraryKeys(context);

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
        final owned = inLibrary.contains(game.key);

        return ExploreGameTile(
          game: game,
          query: query,
          inLibrary: owned,
          onTap: () => openGame(context, game, owned: owned),
        );
      },
    );
  }
}
