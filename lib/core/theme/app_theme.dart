import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'klinik_colors.dart';
import 'klinik_typography.dart';
import 'klinik_radius.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: KlinikColors.accent,
        onPrimary: KlinikColors.textOnAccent,
        secondary: KlinikColors.secondary,
        onSecondary: Colors.white,
        surface: KlinikColors.surfaceLight,
        onSurface: KlinikColors.textPrimary,
        error: KlinikColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: KlinikColors.backgroundLight,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge:  KlinikTypography.display(),
        headlineMedium: KlinikTypography.heading(),
        bodyLarge:     KlinikTypography.body(),
        bodyMedium:    KlinikTypography.body(),
        bodySmall:     KlinikTypography.caption(),
        labelLarge:    KlinikTypography.bodyStrong(),
        labelSmall:    KlinikTypography.caption(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: KlinikColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: KlinikColors.border,
        titleTextStyle: KlinikTypography.appBarTitle(),
        iconTheme: const IconThemeData(color: KlinikColors.textPrimary, size: 22),
        actionsIconTheme: const IconThemeData(color: KlinikColors.textPrimary, size: 22),
      ),
      dividerTheme: const DividerThemeData(
        color: KlinikColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KlinikColors.surfaceVariant,
        contentPadding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KlinikRadius.btn),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KlinikRadius.btn),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KlinikRadius.btn),
          borderSide: const BorderSide(color: KlinikColors.borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KlinikRadius.btn),
          borderSide: const BorderSide(color: KlinikColors.error, width: 1.5),
        ),
        hintStyle: KlinikTypography.body(),
        labelStyle: KlinikTypography.body(),
        floatingLabelStyle: KlinikTypography.captionStrong(
          color: KlinikColors.accent,
        ).copyWith(fontSize: 11),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KlinikColors.surfaceLight,
        selectedItemColor: KlinikColors.accent,
        unselectedItemColor: KlinikColors.textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KlinikColors.surfaceVariant,
        selectedColor: KlinikColors.accent,
        labelStyle: KlinikTypography.captionStrong(),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KlinikRadius.pill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KlinikColors.textPrimary,
        contentTextStyle: KlinikTypography.body(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KlinikRadius.btn),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
