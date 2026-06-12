import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'klinik_colors.dart';

class KlinikTypography {
  KlinikTypography._();

  // ── 2.1 POLICE ────────────────────────────────────────────────────────────
  static const String fontPrimary = 'Inter';

  // ── 2.2 ÉCHELLE DE TAILLES ────────────────────────────────────────────────
  static const double sizeDisplay      = 28.0;
  static const double sizeHeading      = 20.0;
  static const double sizeBody         = 15.0;
  static const double sizeCaption      = 12.0;

  // Tailles spécifiques aux écrans
  static const double sizeScoreResult  = 54.0;
  static const double sizeTemp         = 52.0;
  static const double sizeScoreDossier = 48.0;
  static const double sizeScoreUnit    = 26.0;
  static const double sizeStatNumber   = 28.0;
  static const double sizePointsNumber = 26.0;
  static const double sizeGreeting     = 21.0;
  static const double sizeAppBarTitle  = 18.0;
  static const double sizeKeypad       = 21.0;
  static const double sizeOtp          = 24.0;
  static const double sizeListTitle    = 14.5;
  static const double sizeTab          = 10.5;

  // ── 2.3 GRAISSES ──────────────────────────────────────────────────────────
  static const FontWeight weightRegular   = FontWeight.w400;
  static const FontWeight weightMedium    = FontWeight.w500;
  static const FontWeight weightSemiBold  = FontWeight.w600;
  static const FontWeight weightBold      = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;

  // ── 2.4 LINE HEIGHTS ──────────────────────────────────────────────────────
  static const double heightDisplay  = 1.2;
  static const double heightHeading  = 1.3;
  static const double heightBody     = 1.5;
  static const double heightCaption  = 1.4;
  static const double heightQuestion = 1.35;
  static const double heightNumber   = 1.0;

  // ── 2.5 LETTER SPACING ────────────────────────────────────────────────────
  static const double trackDisplay  = -0.02 * 28;
  static const double trackHeading  = -0.01 * 20;
  static const double trackNumber   = -0.03 * 54;
  static const double trackWordmark = -0.03 * 28;
  static const double trackTagline  =  0.16 * 13;

  // ── 2.6 STYLES PRÉDÉFINIS ─────────────────────────────────────────────────
  static TextStyle display({Color? color}) => GoogleFonts.inter(
    fontSize: sizeDisplay,
    fontWeight: weightSemiBold,
    color: color ?? KlinikColors.textPrimary,
    height: heightDisplay,
    letterSpacing: -0.56,
  );

  static TextStyle heading({Color? color}) => GoogleFonts.inter(
    fontSize: sizeHeading,
    fontWeight: weightSemiBold,
    color: color ?? KlinikColors.textPrimary,
    height: heightHeading,
    letterSpacing: -0.2,
  );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
    fontSize: sizeBody,
    fontWeight: weightRegular,
    color: color ?? KlinikColors.textSecondary,
    height: heightBody,
  );

  static TextStyle bodyStrong({Color? color}) => GoogleFonts.inter(
    fontSize: sizeBody,
    fontWeight: weightSemiBold,
    color: color ?? KlinikColors.textPrimary,
    height: heightBody,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
    fontSize: sizeCaption,
    fontWeight: weightRegular,
    color: color ?? KlinikColors.textTertiary,
    height: heightCaption,
  );

  static TextStyle captionStrong({Color? color}) => GoogleFonts.inter(
    fontSize: sizeCaption,
    fontWeight: weightMedium,
    color: color ?? KlinikColors.textSecondary,
    height: heightCaption,
  );

  static TextStyle appBarTitle({Color? color}) => GoogleFonts.inter(
    fontSize: sizeAppBarTitle,
    fontWeight: weightSemiBold,
    color: color ?? KlinikColors.textPrimary,
    letterSpacing: -0.18,
  );

  // Chiffres géants (score, température) : extra-bold, tabulaires
  static TextStyle bigNumber(double size, Color color) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weightExtraBold,
    color: color,
    height: heightNumber,
    letterSpacing: size * -0.03,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle riskScore(Color color)  => bigNumber(sizeScoreResult, color);
  static TextStyle temperature(Color color) => bigNumber(sizeTemp, color);

  // Question du module scan
  static TextStyle question({Color? color}) => GoogleFonts.inter(
    fontSize: sizeGreeting,
    fontWeight: weightSemiBold,
    color: color ?? KlinikColors.textPrimary,
    height: heightQuestion,
  );
}
