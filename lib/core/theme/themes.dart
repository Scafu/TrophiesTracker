import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Documentation: [Themes] defines the visual identity of the application.
/// It provides two static [ThemeData] configurations: [lightTheme] and [darkTheme].
/// The design system uses Kanit for display/headings, Inter for general UI,
/// and JetBrains Mono for technical labels.
class Themes {
  /// Documentation: [lightTheme] uses a soft gray background with vibrant blue
  /// accents to minimize eye strain while maintaining a clean, professional look.
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    colorScheme: const ColorScheme.light(
      surface: Colors.white,
      surfaceContainerHigh: Colors.white,
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF475569),
      onPrimary: Colors.white,
      onSurface: Color(0xFF0F172A),
      onSurfaceVariant: Color(0xFF64748B),
      error: Color(0xFFDC2626),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: const WidgetStatePropertyAll(Color(0xFFF1F5F9)),
      hintStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(color: const Color(0xFF64748B)),
      ),
      textStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(color: const Color(0xFF0F172A)),
      ),
      elevation: const WidgetStatePropertyAll(0),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFF0F172A),
      iconColor: Color(0xFF64748B),
      tileColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFF2563EB),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white, size: 24);
        }
        return const IconThemeData(color: Color(0xFF64748B), size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            color: const Color(0xFF2563EB),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return GoogleFonts.inter(
          color: const Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0F172A),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.kanit(
        color: const Color(0xFF0F172A),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.inter(
        color: const Color(0xFF0F172A),
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: const Color(0xFF334155),
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.inter(
        color: const Color(0xFF64748B),
        fontSize: 12,
      ),
      titleMedium: GoogleFonts.kanit(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleLarge: GoogleFonts.kanit(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        color: const Color(0xFF0F172A),
        fontSize: 13,
      ),
      displayLarge: GoogleFonts.kanit(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    dividerColor: const Color(0xFFE2E8F0),
    cardColor: Colors.white,
  );

  /// Documentation: [darkTheme] implements a pure black modern palette to ensure
  /// high contrast and legibility in low-light environments.
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0C0C0F),
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF14141A),
      surfaceContainerHigh: Color(0xFF1E1E28),
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF94A3B8),
      onPrimary: Colors.white,
      onSurface: Color(0xFFF8FAFC),
      onSurfaceVariant: Color(0xFF94A3B8),
      error: Color(0xFFEF4444),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF1E1E28)),
      side: const WidgetStatePropertyAll(BorderSide(color: Color(0xFF2E2E3D))),
      hintStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(color: const Color(0xFF94A3B8)),
      ),
      textStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(color: const Color(0xFFF8FAFC)),
      ),
      elevation: const WidgetStatePropertyAll(0),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFFF8FAFC),
      iconColor: Color(0xFF94A3B8),
      tileColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF14141A),
      indicatorColor: const Color(0xFF3B82F6),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white, size: 24);
        }
        return const IconThemeData(color: Color(0xFF94A3B8), size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            color: const Color(0xFF3B82F6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF14141A),
      foregroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.kanit(
        color: const Color(0xFFF8FAFC),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.inter(
        color: const Color(0xFFF8FAFC),
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: const Color(0xFFCBD5E1),
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.inter(
        color: const Color(0xFF94A3B8),
        fontSize: 12,
      ),
      titleMedium: GoogleFonts.kanit(
        color: const Color(0xFFF8FAFC),
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleLarge: GoogleFonts.kanit(
        color: const Color(0xFFF8FAFC),
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        color: const Color(0xFFF8FAFC),
        fontSize: 13,
      ),
      displayLarge: GoogleFonts.kanit(
        color: const Color(0xFFF8FAFC),
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    dividerColor: const Color(0xFF2E2E3D),
    cardColor: const Color(0xFF14141A),
  );
}
