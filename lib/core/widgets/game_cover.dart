import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trophies_tracker/features/game/domain/entities/game.dart';
import 'package:trophies_tracker/features/game/domain/entities/game_key.dart';

/// Cover art of a game: the first image that loads from a fallback chain.
///
/// Steam has no vertical artwork for many older games, so after the stored
/// cover come the 1x vertical file, then the landscape header and capsule.
/// Landscape art is shown whole over a blurred copy of itself instead of being
/// cropped to a sliver. When nothing loads, a neutral placeholder is shown.
class GameCover extends StatefulWidget {
  final Game game;

  const GameCover({super.key, required this.game});

  static const _base =
      'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps';

  /// URL that last loaded for each game, so a tile that is rebuilt (for
  /// example while scrolling) does not request again the images that failed.
  static final _resolved = <GameKey, String>{};

  /// Image URLs to try for [game], best first, without duplicates.
  @visibleForTesting
  static List<({String url, bool portrait})> sourcesFor(Game game) {
    final id = game.code;
    final steam = game.platform == GamePlatform.steam;
    final seen = <String>{};
    final sources = <({String url, bool portrait})>[];

    void add(String? url, {required bool portrait}) {
      if (url != null && url.isNotEmpty && seen.add(url)) {
        sources.add((url: url, portrait: portrait));
      }
    }

    // Steam art is vertical; a PlayStation icon is square and is shown whole.
    add(game.libraryImage, portrait: steam);
    if (steam) add('$_base/$id/library_600x900.jpg', portrait: true);
    add(game.headerImage, portrait: false);
    if (steam) {
      add('$_base/$id/header.jpg', portrait: false);
      add('$_base/$id/capsule_616x353.jpg', portrait: false);
    }
    return sources;
  }

  @override
  State<GameCover> createState() => _GameCoverState();
}

class _GameCoverState extends State<GameCover> {
  late List<({String url, bool portrait})> _sources;
  late int _index;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(GameCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game.key != widget.game.key ||
        oldWidget.game.libraryImage != widget.game.libraryImage) {
      _load();
    }
  }

  void _load() {
    _sources = GameCover.sourcesFor(widget.game);
    final known = _sources.indexWhere(
      (source) => source.url == GameCover._resolved[widget.game.key],
    );
    _index = known < 0 ? 0 : known;
  }

  /// Moves on to the next source, unless [index] is no longer the current one.
  void _failed(int index) {
    if (!mounted || index != _index) return;
    setState(() => _index = index + 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: colors.onSurface.withValues(alpha: 0.08),
    );
    if (_index >= _sources.length) {
      return ColoredBox(
        color: colors.onSurface.withValues(alpha: 0.08),
        child: Center(
          child: Icon(
            Symbols.sports_esports_rounded,
            color: colors.onSurface.withValues(alpha: 0.35),
          ),
        ),
      );
    }

    final index = _index;
    final source = _sources[index];
    return CachedNetworkImage(
      key: ValueKey(source.url),
      imageUrl: source.url,
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => placeholder,
      errorListener: (_) => _failed(index),
      imageBuilder: (context, image) {
        GameCover._resolved[widget.game.key] = source.url;
        return source.portrait
            ? Image(image: image, fit: BoxFit.cover)
            : _Letterboxed(image: image);
      },
    );
  }
}

/// Landscape artwork shown whole, over a darkened and blurred copy of itself.
class _Letterboxed extends StatelessWidget {
  final ImageProvider image;

  const _Letterboxed({required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Image(image: image, fit: BoxFit.cover),
        ),
        const ColoredBox(color: Color(0x59000000)),
        Image(image: image, fit: BoxFit.contain),
      ],
    );
  }
}
