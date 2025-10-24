import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color darkCharcoal = Color(0xFF2C2C2C);
  static const Color mediumGray = Color(0xFF888888);

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
        // Style for recipe title
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: darkCharcoal,
          letterSpacing: -0.44,
        ),
        // Styke for author name
        bodyMedium: GoogleFonts.inter(
          color: mediumGray,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        // Style for likes count
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
