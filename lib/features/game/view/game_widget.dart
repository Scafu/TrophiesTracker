import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_app_tracker/core/models/game/game.dart';
import 'package:trophies_app_tracker/features/shared/globals.dart';

class GameWidget extends StatelessWidget {
  const GameWidget({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final imagePath = game.libraryImage;
    final bool hasImage = !(imagePath == null || imagePath.isEmpty);

    return Hero(
      tag: 'gameHero-${game.appId}',
      child: Material(
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          height: Globals.screenHeight(context) * 0.22,
          width: Globals.screenWidth(context) * 0.3,

          child: InkWell(
            splashColor: const Color.fromARGB(123, 255, 255, 255),
            onTap: () {
              context.pushNamed(
                'gameDetailsOffline',
                pathParameters: {'appId': game.appId.toString()},
                extra: {
                  'heroTag': 'gameHero-${game.appId}',
                  'disableHero': false,
                },
              );
            },

            child: hasImage
                ? Image.file(File(imagePath), fit: BoxFit.cover)
                : Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[600],
                      size: 40,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
