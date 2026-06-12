import 'package:flutter/material.dart';

class KlinikColors {
  KlinikColors._();

  // ── 1.1 COULEURS FONDATRICES (choisies par le fondateur — IMMUABLES) ──────
  static const Color backgroundLight = Color(0xFFFDFFF5);
  static const Color backgroundDark  = Color(0xFF232323);
  static const Color accent          = Color(0xFF557CDC);
  static const Color secondary       = Color(0xFF59C3C3);

  static const Color accentDark    = Color(0xFF3D5FAA);
  static const Color secondaryDark = Color(0xFF3A9E9E);

  // ── 1.2 SURFACES ──────────────────────────────────────────────────────────
  static const Color surfaceLight      = Color(0xFFFFFFFF);
  static const Color surfaceDark       = Color(0xFF2E2E2E);
  static const Color surfaceVariant    = Color(0xFFF0F4F8);
  static const Color surfaceAccentSoft = Color(0xFFEAF0FF);
  static const Color surfaceInfoSoft   = Color(0xFFF5F6FA);

  // ── 1.3 TEXTES ────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1D23);
  static const Color textSecondary = Color(0xFF5A6474);
  static const Color textTertiary  = Color(0xFF9AA3AF);
  static const Color textOnAccent  = Color(0xFFFFFFFF);
  static const Color textOnDark    = Color(0xFFF5F5F5);

  // ── 1.4 BORDURES & SÉPARATEURS ────────────────────────────────────────────
  static const Color border      = Color(0xFFE8ECF4);
  static const Color borderFocus = Color(0xFF557CDC);

  // ── 1.5 SÉMANTIQUES — SCORE DE RISQUE (non négociables) ───────────────────
  static const Color riskLow           = Color(0xFF2E7D32);
  static const Color riskLowSurface    = Color(0xFFE8F5E9);
  static const Color riskMedium        = Color(0xFFE65100);
  static const Color riskMediumSurface = Color(0xFFFFF3E0);
  static const Color riskHigh          = Color(0xFFC62828);
  static const Color riskHighSurface   = Color(0xFFFFEBEE);

  // ── 1.6 SÉMANTIQUES — STATUTS SYSTÈME ─────────────────────────────────────
  static const Color online  = Color(0xFF43A047);
  static const Color offline = Color(0xFFE53935);
  static const Color syncing = Color(0xFFFF8F00);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color error   = Color(0xFFC62828);
  static const Color info    = Color(0xFF557CDC);

  // ── 1.7 GRADIENTS ─────────────────────────────────────────────────────────
  static const LinearGradient gradientAgent = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.7, 1),
    colors: [accent, accentDark],
  );

  static const LinearGradient gradientMedecin = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.7, 1),
    colors: [secondary, secondaryDark],
  );

  // Composantes du dégradé radial du splash (assemblé dans SplashScreen)
  static const Color gradientSplashStart = Color(0xFF7C9BE6);
  static const Color gradientSplashMid   = Color(0xFF557CDC);
  static const Color gradientSplashEnd   = Color(0xFF3D5FAA);
}
