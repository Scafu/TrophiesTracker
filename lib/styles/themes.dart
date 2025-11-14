import 'package:flutter/material.dart';

/// Global Themes the APP
class Themes {
  /// LightTheme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // 🎨 Color Scheme
    scaffoldBackgroundColor: const Color(
      0xFFF5F5F7,
    ), // Grigio chiaro per lo sfondo
    colorScheme: const ColorScheme.light(
      surface: Color(0xFFF5F5F7), // Bianco per Card, Dialog, BottomSheet
      surfaceContainerHigh: Color(0xFFF5F5F7), // Bianco per AppBar, NavBar
      primary: Color(0xFF4A90E2), // Blu primario (come nel dark mode)
      secondary: Color(0xFF7AAEE8), // Blu secondario più chiaro
      onPrimary: Colors.white, // Testo/icone su sfondo primario
      onSurface: Color(0xFF1C1C1E), // Testo principale (quasi nero)
      onSurfaceVariant: Color(
        0xFF5A5A5C,
      ), // Testo secondario/hint (grigio scuro)
      error: Color(0xFFE53935), // Rosso per errori
    ),

    // 🔍 SearchBar
    searchBarTheme: const SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(
        Color(0xFFF0F2F5),
      ), // Grigio input
      hintStyle: WidgetStatePropertyAll(TextStyle(color: Color(0xFF5A5A5C))),
      textStyle: WidgetStatePropertyAll(TextStyle(color: Color(0xFF1C1C1E))),
    ),

    // 📋 ListTile
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFF1C1C1E),
      iconColor: Color(0xFF5A5A5C),
      tileColor: Color(0xFFFFFFFF),
    ),

    // 🧭 Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFFFFFFF),
      indicatorColor: const Color(0xFF4A90E2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: Colors.white, // Icona sull'indicatore (onPrimary)
            size: 26,
          );
        } else {
          return const IconThemeData(
            color: Color(
              0xFF5A5A5C,
            ), // Icona non selezionata (onSurfaceVariant)
            size: 24,
          );
        }
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: Color(0xFF1C1C1E), // Testo selezionato (onSurface)
            fontFamily: "BBH Sans Bartle",
            fontSize: 13,
          );
        } else {
          return const TextStyle(
            color: Color(
              0xFF5A5A5C,
            ), // Testo non selezionato (onSurfaceVariant)
            fontFamily: "BBH Sans Bartle",
            fontSize: 12,
          );
        }
      }),
    ),

    // 🧭 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF), // Sfondo bianco
      foregroundColor: Color(0xFF1C1C1E), // Icone e testo (onSurface)
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: "BBH Sans Bartle",
        color: Color(0xFF1C1C1E),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // 🖋️ TextTheme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: "BBH Sans Bogle",
        color: Color(0xFF1C1C1E),
      ),
      bodyMedium: TextStyle(
        fontFamily: "BBH Sans Bogle",
        color: Color(0xFF1C1C1E),
      ),
      bodySmall: TextStyle(
        fontFamily: "BBH Sans Bartle",
        color: Color(0xFF5A5A5C), // Testo secondario
      ),
      titleMedium: TextStyle(
        fontFamily: "BBH Sans Bartle",
        color: Color(0xFF1C1C1E),
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontFamily: "BBH Sans Bartle",
        color: Color(0xFF1C1C1E),
      ),
    ),

    // 🔘 ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          const Color(0xFF4A90E2), // Colore primario
        ),
        foregroundColor: WidgetStatePropertyAll(Colors.white), // onPrimary
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),

    // ➖ Altri colori
    dividerColor: const Color(0xFFDCDFE2), // Divisore grigio chiaro
    cardColor: const Color(0xFFFFFFFF), // Sfondo card bianco
  );

  /// DarkTheme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xFF0E0E12),
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF0E0E12),
      surfaceContainerHigh: Color(0xFF1A1B1E),
      primary: Color(0xFF4A90E2),
      secondary: Color(0xFF356AC3),
      onPrimary: Colors.white,
      onSurface: Color(0xFFEDEDED),
      error: Color(0xFFFF5C5C),
    ),

    searchBarTheme: const SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(Color(0xFF1A1B1E)),
      side: WidgetStatePropertyAll(BorderSide(color: Color(0xFF2F3035))),
      hintStyle: WidgetStatePropertyAll(TextStyle(color: Color(0xFF9CA0AA))),
      textStyle: WidgetStatePropertyAll(TextStyle(color: Color(0xFFEDEDED))),
    ),

    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFFEDEDED),
      iconColor: Color(0xFF9CA0AA),
      tileColor: Color(0xFF23252A),
    ),

    // 🧭 Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1A1B1E),
      indicatorColor: const Color(0xFF4A90E2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: Color.fromARGB(255, 255, 255, 255),
            size: 26,
          );
        } else {
          return const IconThemeData(
            color: Color.fromARGB(255, 116, 116, 116),
            size: 24,
          );
        }
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: Color(0xFFEDEDED),
            fontFamily: "BBH Sans Bartle",
            fontSize: 13,
          );
        } else {
          return const TextStyle(
            color: Colors.grey,
            fontFamily: "BBH Sans Bartle",
            fontSize: 12,
          );
        }
      }),
    ),

    // 🧭 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1B1E),
      foregroundColor: Color(0xFFEDEDED),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: "BBH Sans Bartle",
        color: Color(0xFFEDEDED),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: "BBH Sans Bogle",
        color: Color(0xFFEDEDED),
      ),
      bodyMedium: TextStyle(
        fontFamily: "BBH Sans Bogle",
        color: Color(0xFFEDEDED),
      ),
      bodySmall: TextStyle(
        fontFamily: "BBH Sans Bartle",
        color: Color(0xFF9CA0AA),
      ),
      titleMedium: TextStyle(
        fontFamily: "BBH Sans Bartle",
        color: Color(0xFFEDEDED),
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontFamily: "BBH Sans Bartle",
        color: Color(0xFFEDEDED),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          const Color(0xFF4A90E2),
        ), // accento blu
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),

    dividerColor: const Color(0xFF2F3035),
    cardColor: const Color(0xFF23252A),
  );
}
