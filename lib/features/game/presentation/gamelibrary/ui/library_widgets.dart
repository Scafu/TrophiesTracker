import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_tracker/core/utils/game/game_completion.dart';
import 'package:trophies_tracker/core/widgets/completion_badge.dart';
import 'package:trophies_tracker/core/widgets/game_cover.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/presentation/gamelibrary/library_view.dart';
import 'package:trophies_tracker/styles/colors_palette.dart';

void _open(BuildContext context, Game game) => context.pushNamed(
  'gameDetails',
  pathParameters: {'appId': game.appId.toString(), 'fromExplorer': 'false'},
);

/// A game of the library grid: the cover with its progress along the bottom,
/// a gold badge once every trophy is unlocked, the name and the trophy count.
class LibraryGameTile extends StatelessWidget {
  final Game game;

  const LibraryGameTile({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final unlocked = game.trophies.where((t) => t.isAchieved).length;

    return Semantics(
      button: true,
      label: '${game.name}, $unlocked of ${game.trophies.length} trophies',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _open(context, game),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GameCover(game: game),
                    if (game.isCompleted)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: CompletionBadge(),
                      ),
                    if (gameProgress(game) > 0)
                      Positioned(
                        left: 6,
                        right: 6,
                        bottom: 6,
                        child: _ProgressBar(game: game),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              game.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              '$unlocked/${game.trophies.length}',
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// A thin bar over the cover: white on a dark track so it shows on any art,
/// gold once the game is completed.
class _ProgressBar extends StatelessWidget {
  final Game game;

  const _ProgressBar({required this.game});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: gameProgress(game),
        minHeight: 4,
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        color: game.isCompleted ? ColorsPalette.colorGold : Colors.white,
      ),
    );
  }
}

/// The "Almost there" shelf: games that are nearly finished, with how much is
/// left.
class AlmostThereShelf extends StatelessWidget {
  final List<Game> games;

  const AlmostThereShelf({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            'ALMOST THERE',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: games.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final game = games[index];
              final left =
                  game.trophies.length -
                  game.trophies.where((t) => t.isAchieved).length;

              return Semantics(
                button: true,
                label:
                    '${game.name}, ${(gameProgress(game) * 100).round()} percent, $left left',
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => _open(context, game),
                  child: SizedBox(
                    width: 112,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                GameCover(game: game),
                                Positioned(
                                  left: 6,
                                  bottom: 6,
                                  child: _PercentPill(
                                    percent: (gameProgress(game) * 100).round(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          game.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$left left',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PercentPill extends StatelessWidget {
  final int percent;

  const _PercentPill({required this.percent});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          '$percent%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
