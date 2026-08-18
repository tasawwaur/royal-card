import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get luxuryDarkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.goldPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.goldPrimary,
        secondary: AppColors.goldSecondary,
        surface: AppColors.cardSurfaceDark,
        error: AppColors.rubyRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 1.5),
        displayMedium: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 26, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        headlineMedium: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
        labelLarge: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(color: AppColors.goldPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: AppColors.goldPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardSurfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
