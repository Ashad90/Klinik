import 'package:flutter/material.dart';

class KlinikAnimations {
  KlinikAnimations._();

  // ── DURÉES ─────────────────────────────────────────────────────────────────
  static const Duration tap          = Duration(milliseconds: 120);
  static const Duration fast         = Duration(milliseconds: 150);
  static const Duration toggle       = Duration(milliseconds: 200);
  static const Duration autoNext     = Duration(milliseconds: 230);
  static const Duration normal       = Duration(milliseconds: 350);
  static const Duration pop          = Duration(milliseconds: 500);
  static const Duration spin         = Duration(milliseconds: 800);
  static const Duration syncPulse    = Duration(milliseconds: 1200);
  static const Duration urgentPulse  = Duration(milliseconds: 1600);
  static const Duration pointsFloat  = Duration(milliseconds: 1800);
  static const Duration splash       = Duration(milliseconds: 2300);

  // ── COURBES ───────────────────────────────────────────────────────────────
  static const Curve standard  = Curves.easeOut;
  static const Curve emphasis  = Curves.easeInOut;
  static const Curve linear    = Curves.linear;
  static const Cubic popCurve  = Cubic(0.22, 1.3, 0.4, 1.0);

  // ── SCALES DE FEEDBACK TACTILE ─────────────────────────────────────────────
  static const double tapScale       = 0.98;
  static const double keypadTapScale = 0.95;
  static const double cardTapScale   = 0.99;
}
