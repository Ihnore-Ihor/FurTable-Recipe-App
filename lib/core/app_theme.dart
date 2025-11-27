import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines the visual theme for the application.
///
/// Contains color constants and the [ThemeData] configuration including
/// text styles, app bar theme, and bottom navigation bar theme.
class AppTheme {
  /// The off-white background color used in the app.
  static const Color offWhite = Color(0xFFF5F5F5);

  /// The dark charcoal color used for primary text and icons.
  static const Color darkCharcoal = Color(0xFF2C2C2C);

  /// The medium gray color used for secondary text.
  static const Color mediumGray = Color(0xFF888888);

  /// Returns the global [ThemeData] for the application.
  ///
  /// Configures the font family, scaffold background color, app bar,
  /// text theme, and bottom navigation bar.
  static ThemeData get theme {
    final baseTheme = ThemeData(fontFamily: GoogleFonts.inter().fontFamily);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: offWhite,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      appBarTheme: AppBarTheme(
        backgroundColor: offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkCharcoal),
        titleTextStyle: GoogleFonts.inter(
          color: darkCharcoal,
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
      ),

      textTheme: TextTheme(
        // Configures the style for recipe titles.
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: darkCharcoal,
          letterSpacing: -0.44,
        ),
        // Configures the style for author names.
        bodyMedium: GoogleFonts.inter(
          color: mediumGray,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        // Configures the style for like counts.
        labelSmall: GoogleFonts.inter(
          color: darkCharcoal,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: darkCharcoal,
        unselectedItemColor: mediumGray,
        selectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),
    );
  }
}
