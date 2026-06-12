import 'package:flutter/material.dart';

class KlinikShadows {
  KlinikShadows._();

  // Carte plate standard — --shadow-card
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x14283759), blurRadius: 3, offset: Offset(0, 1)),
  ];

  // Élévation douce (menus déroulants) — --shadow-sm
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0F283759), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // Élévation moyenne (popover, popup points) — --shadow-md
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x29283759),
      blurRadius: 24,
      spreadRadius: -8,
      offset: Offset(0, 8),
    ),
  ];

  // Carte de points AGENT (lueur bleue)
  static const List<BoxShadow> pointsAgent = [
    BoxShadow(
      color: Color(0x66304E91),
      blurRadius: 28,
      spreadRadius: -12,
      offset: Offset(0, 12),
    ),
  ];

  // Carte de points MÉDECIN (lueur turquoise)
  static const List<BoxShadow> pointsMedecin = [
    BoxShadow(
      color: Color(0x66317777),
      blurRadius: 28,
      spreadRadius: -12,
      offset: Offset(0, 12),
    ),
  ];

  // Bouton flottant scan (FAB)
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x66304E91),
      blurRadius: 18,
      spreadRadius: -6,
      offset: Offset(0, 8),
    ),
  ];
}
