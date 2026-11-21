import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/core/widgets/tab_header.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/categories.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/category_cubit.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/cubit/category_state.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/explore_helpers.dart';
import 'package:trophies_tracker/features/game/presentation/exploregames/ui/explore_page_tiles.dart';

/// The popular games of one genre, over a header tinted with its color.
class CategoryPage extends StatelessWidget {
  final GameCategory category;

  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  category.color.withValues(alpha: 0.45),
                  category.color.withValues(alpha: 0),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: RoundIconButton(
                      icon: Symbols.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/explore'),
                    ),
                  ),
                  Expanded(
                    child: TabHeader(
                      title: category.name,
                      subtitle: 'Popular games with trophies',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) => switch (state) {
                CategoryLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                CategoryError(message: final message) => _Notice(
                  icon: Symbols.error_rounded,
                  title: 'Something went wrong',
                  subtitle: message,
                  onRetry: () =>
                      context.read<CategoryCubit>().load(category.tagId),
                ),
                CategoryLoaded(games: final games) when games.isEmpty =>
                  const _Notice(
                    icon: Symbols.search_off_rounded,
                    title: 'No games found',
                    subtitle: 'Steam has nothing to show for this category.',
                  ),
                CategoryLoaded(games: final games) => _Games(games: games),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Games extends StatelessWidget {
  final List<Game> games;

  const _Games({required this.games});

  @override
  Widget build(BuildContext context) {
    final inLibrary = libraryKeys(context);

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final owned = inLibrary.contains(game.key);

        return ExploreGameTile(
          game: game,
          query: '',
          inLibrary: owned,
          onTap: () => openGame(context, game, owned: owned),
        );
      },
    );
  }
}

/// Shown when the category has no games or could not be loaded, with a retry
/// button for the second case.
class _Notice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const _Notice({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Symbols.refresh_rounded, size: 20),
                label: const Text('Try again'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(160, 46),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
