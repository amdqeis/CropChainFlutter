import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CropChain Design Tokens
class AppColors {
  // Primary Green palette
  static const Color primaryGreen = Color(0xFF4A7C3F);
  static const Color primaryGreenDark = Color(0xFF3D6834);
  static const Color primaryGreenLight = Color(0xFF5A8E4E);

  // Accent Orange
  static const Color accentOrange = Color(0xFFE8711A);
  static const Color accentOrangeLight = Color(0xFFF08040);

  // Light green backgrounds
  static const Color lightGreenBg = Color(0xFFE8F0E3);
  static const Color lightGreenBg2 = Color(0xFFEFF5EC);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFAAAAAA);

  // Surface & Background
  static const Color white = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // Border
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFCCCCCC);

  // Status colors
  static const Color statusBaru = Color(0xFFE8711A);       // Orange
  static const Color statusDiproses = Color(0xFFE8711A);   // Orange
  static const Color statusDikirim = Color(0xFFE8711A);    // Orange
  static const Color statusSelesai = Color(0xFF4A7C3F);    // Green
  static const Color statusDibatalkan = Color(0xFFE8711A); // Orange
  static const Color statusAktif = Color(0xFF4A7C3F);      // Green
  static const Color statusNonaktif = Color(0xFF9E9E9E);   // Grey

  // Star / rating
  static const Color starYellow = Color(0xFFF5A623);

  // Success / Error
  static const Color success = Color(0xFF4A7C3F);
  static const Color error = Color(0xFFE53935);
}

/// CropChain App Theme
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.white,
        secondary: AppColors.accentOrange,
        onSecondary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.backgroundGrey,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreenDark,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreenDark,
          side: const BorderSide(color: AppColors.primaryGreenDark, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textHint,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderColor, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// Shared widget style helpers
class AppStyles {
  /// Green pill badge (e.g. "Aktif", "Selesai")
  static BoxDecoration greenBadge = BoxDecoration(
    color: AppColors.primaryGreen,
    borderRadius: BorderRadius.circular(20),
  );

  /// Orange pill badge (e.g. "Baru", "Diproses", "Dikirim")
  static BoxDecoration orangeBadge = BoxDecoration(
    color: AppColors.accentOrange,
    borderRadius: BorderRadius.circular(20),
  );

  /// Grey pill badge (e.g. "Nonaktif")
  static BoxDecoration greyBadge = BoxDecoration(
    color: AppColors.statusNonaktif,
    borderRadius: BorderRadius.circular(20),
  );

  /// Bottom Navigation pill container
  static BoxDecoration bottomNavContainer = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(40),
    border: Border.all(color: AppColors.primaryGreen, width: 1.5),
  );

  /// Card container
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.borderColor, width: 0.5),
  );

  /// Input with suffix unit (e.g. "/kg")
  static InputDecoration suffixInput({
    required String hint,
    String? suffix,
    String? label,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      suffixText: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
