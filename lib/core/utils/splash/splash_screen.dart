import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_tracker/core/di/injection_container.dart' as di;
import 'package:trophies_tracker/features/game/domain/repositories/game_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initCatalog();
  }

  Future<void> _initCatalog() async {
    final gameRepository = di.sl<GameRepository>();

    try {
      await gameRepository.syncSteamCatalog();
    } catch (e) {
      debugPrint('Catalog sync error: $e');
    }

    if (mounted) {
      context.replace('/games');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Center(child: Image.asset('assets/splash.png', width: 300)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Preparing catalog...',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
