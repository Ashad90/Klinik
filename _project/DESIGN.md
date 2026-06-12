# DESIGN.md — Système de Design Klinik-Scan
# Généré par Claude Design à partir des maquettes officielles (prototype Klinik)
# Date : 03 Juin 2026
# Version maquettes : 1.0
# Source : Klinik-Scan/app/ds.css + tous les écrans (onboarding, agent, scan, médecin, admin)

> ⚠️ Ce fichier est lu par Claude Code AVANT toute ligne de code UI.
> Chaque valeur ci-dessous correspond exactement à ce qui est utilisé dans les
> maquettes haute-fidélité. Les rares écarts avec le brief initial sont signalés
> par le commentaire `// ÉCART MAQUETTE` (la maquette fait foi).
> Les valeurs non déterminables avec certitude sont signalées `// À CONFIRMER`.

## Commandes Claude Design destinées à Claude Code comme reférence:

Read the attached klinik-scan.zip and the README inside.
Implement: Klinik-Scan/Klinik - Prototype.html

---

## 1. PALETTE DE COULEURS — KlinikColors

```dart
// lib/core/theme/klinik_colors.dart
import 'package:flutter/material.dart';

class KlinikColors {

  // ── 1.1 COULEURS FONDATRICES (choisies par le fondateur — IMMUABLES) ──────
  /// Fond principal — Light Mode (background de tous les écrans)
  static const backgroundLight = Color(0xFFFDFFF5);
  /// Fond principal — Dark Mode
  static const backgroundDark  = Color(0xFF232323);
  /// Accent — TOUS les CTA, boutons primaires, icônes actives, focus
  static const accent          = Color(0xFF557CDC);
  /// Secondaire — turquoise : badges, gradients médecin, succès décoratif
  static const secondary       = Color(0xFF59C3C3);

  // Variantes foncées des fondatrices (utilisées UNIQUEMENT en dégradés)
  static const accentDark      = Color(0xFF3D5FAA); // fin du dégradé bleu (carte points agent)
  static const secondaryDark   = Color(0xFF3A9E9E); // fin du dégradé turquoise (carte points médecin)

  // ── 1.2 SURFACES ──────────────────────────────────────────────────────────
  static const surfaceLight    = Color(0xFFFFFFFF); // cartes, modals, list items — Light
  static const surfaceDark     = Color(0xFF2E2E2E); // cartes, modals — Dark  // À CONFIRMER (dark mode non maquetté en détail)
  static const surfaceVariant  = Color(0xFFF0F4F8); // fond input, chips, pills, tuiles avatar, claviers
  static const surfaceAccentSoft = Color(0xFFEAF0FF); // tuiles d'icône bleues (thermomètre, mail, pilule, building)
  static const surfaceInfoSoft   = Color(0xFFF5F6FA); // fond des encarts disclaimer "Aide à la décision"

  // ── 1.3 TEXTES ────────────────────────────────────────────────────────────
  static const textPrimary     = Color(0xFF1A1D23); // titres, corps principal, chiffres
  static const textSecondary   = Color(0xFF5A6474); // descriptions, labels, sous-titres
  static const textTertiary    = Color(0xFF9AA3AF); // hints, placeholders, captions inactifs, icônes inactives
  static const textOnAccent    = Color(0xFFFFFFFF); // texte sur fond accent / score / dégradés
  static const textOnDark      = Color(0xFFF5F5F5); // texte sur fond sombre // À CONFIRMER

  // ── 1.4 BORDURES & SÉPARATEURS ────────────────────────────────────────────
  static const border          = Color(0xFFE8ECF4); // bordures cartes, inputs inactifs, dividers, progress track
  static const borderFocus     = Color(0xFF557CDC); // = accent : bordure input au focus
  // NB : aucun "divider" plus foncé n'est réellement utilisé dans les maquettes ;
  //      tous les traits de séparation utilisent `border` (#E8ECF4).

  // ── 1.5 SÉMANTIQUES — SCORE DE RISQUE (non négociables) ───────────────────
  static const riskLow          = Color(0xFF2E7D32); // score 0-3 — vert
  static const riskLowSurface   = Color(0xFFE8F5E9); // fond carte score faible
  static const riskMedium       = Color(0xFFE65100); // score 4-6 — orange
  static const riskMediumSurface= Color(0xFFFFF3E0); // fond carte score modéré
  static const riskHigh         = Color(0xFFC62828); // score 7-10 — rouge
  static const riskHighSurface  = Color(0xFFFFEBEE); // fond carte score élevé

  // ── 1.6 SÉMANTIQUES — STATUTS SYSTÈME ─────────────────────────────────────
  static const online   = Color(0xFF43A047); // réseau disponible (point + texte)
  static const offline  = Color(0xFFE53935); // hors ligne
  static const syncing  = Color(0xFFFF8F00); // synchronisation en cours (point pulsé)
  static const success  = Color(0xFF2E7D32); // = riskLow
  static const warning  = Color(0xFFE65100); // = riskMedium
  static const error    = Color(0xFFC62828); // = riskHigh
  static const info     = Color(0xFF557CDC); // = accent

  // ── 1.7 GRADIENTS ─────────────────────────────────────────────────────────
  // Carte de points AGENT — diagonale 120°
  static const gradientAgent = LinearGradient(
    begin: Alignment(-0.7, -1), end: Alignment(0.7, 1),
    colors: [accent, accentDark],            // #557CDC → #3D5FAA
  );
  // Carte de points MÉDECIN — diagonale 120°
  static const gradientMedecin = LinearGradient(
    begin: Alignment(-0.7, -1), end: Alignment(0.7, 1),
    colors: [secondary, secondaryDark],      // #59C3C3 → #3A9E9E
  );
  // Splash screen — radial : clair en haut → accent → accentDark
  static const gradientSplashStart = Color(0xFF7C9BE6); // ≈ accent mélangé 72% blanc en haut  // À CONFIRMER (color-mix)
  static const gradientSplashMid   = Color(0xFF557CDC);
  static const gradientSplashEnd   = Color(0xFF3D5FAA);
}
```

### Règle d'utilisation 60 / 30 / 10
```
60% → backgroundLight (#FDFFF5) + surfaceLight (#FFFFFF)
30% → textPrimary + textSecondary + border
10% → accent (#557CDC) + secondary (#59C3C3)
⚠️ accent n'est JAMAIS un fond de page (uniquement CTA, splash, dégradés de cartes).
```

---

## 2. TYPOGRAPHIE — KlinikTypography

```dart
// lib/core/theme/klinik_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KlinikTypography {

  // ── 2.1 POLICE ────────────────────────────────────────────────────────────
  // Police primaire des maquettes : Inter (via google_fonts).
  // (Le prototype propose aussi Manrope / Plus Jakarta Sans comme variantes de
  //  marque optionnelles, mais Inter est la police par défaut de référence.)
  static const String fontPrimary = 'Inter';

  // ── 2.2 ÉCHELLE DE TAILLES (toutes celles réellement utilisées) ───────────
  // Échelle de base du design system
  static const double sizeDisplay = 28.0; // t-display : titres onboarding, écrans de succès
  static const double sizeHeading = 20.0; // t-h : titres de section, en-têtes de carte
  static const double sizeBody    = 15.0; // t-body : corps de texte, descriptions
  static const double sizeCaption = 12.0; // t-cap : labels, hints, disclaimers, captions

  // Tailles spécifiques utilisées ponctuellement dans les écrans
  static const double sizeScoreResult = 54.0; // chiffre du score — écran Résultat agent
  static const double sizeTemp        = 52.0; // chiffre de température — module scan
  static const double sizeScoreDossier= 48.0; // chiffre du score — dossier médecin
  static const double sizeScoreUnit   = 26.0; // suffixe " /10" et " °C"
  static const double sizeStatNumber  = 28.0; // grands chiffres des cartes statistiques
  static const double sizePointsNumber= 26.0; // chiffre des cartes de points (12 pts / 87,5 pts)
  static const double sizeGreeting    = 21.0; // "Bonjour, Marie", question du scan
  static const double sizeAppBarTitle = 18.0; // titre d'AppBar
  static const double sizeKeypad      = 21.0; // touches du clavier numérique
  static const double sizeOtp         = 24.0; // cases de code d'activation
  static const double sizeListTitle   = 14.5;// nom dans un item de liste/patient
  static const double sizeTab         = 10.5;// labels de la bottom navigation

  // ── 2.3 GRAISSES (toutes réellement utilisées) ────────────────────────────
  // ÉCART MAQUETTE : le brief initial annonçait 2 graisses (400/600). Les
  // maquettes en utilisent 5 — notamment w700/w800 pour les chiffres et le
  // wordmark. On les expose toutes.
  static const FontWeight weightRegular   = FontWeight.w400; // corps, labels
  static const FontWeight weightMedium    = FontWeight.w500; // statuts, labels de tab, captions actifs
  static const FontWeight weightSemiBold  = FontWeight.w600; // titres, boutons, semib
  static const FontWeight weightBold      = FontWeight.w700; // badges, pills "Actif", code OTP
  static const FontWeight weightExtraBold = FontWeight.w800; // chiffres (score, temp, stats, points), wordmark

  // ── 2.4 LINE HEIGHTS ──────────────────────────────────────────────────────
  static const double heightDisplay = 1.2;
  static const double heightHeading = 1.3;
  static const double heightBody    = 1.5;  // = line-height global .ks
  static const double heightCaption = 1.4;
  static const double heightQuestion= 1.35; // question du scan (texte centré 2 lignes)
  static const double heightNumber  = 1.0;  // chiffres géants (score / temp)

  // ── 2.5 LETTER SPACING ────────────────────────────────────────────────────
  static const double trackDisplay  = -0.02 * 28; // -.02em sur t-display (≈ -0.56)
  static const double trackHeading  = -0.01 * 20; // -.01em sur t-h
  static const double trackNumber   = -0.03 * 54; // -.03em sur les chiffres géants
  static const double trackWordmark = -0.03 * 28; // -.03em sur le wordmark "Klinik"
  static const double trackTagline  =  0.16 * 13; // .16em sur la baseline splash (UPPERCASE)
  // (corps et captions : letter-spacing 0)

  // ── 2.6 STYLES PRÉDÉFINIS ─────────────────────────────────────────────────
  static TextStyle display({Color? color}) => GoogleFonts.inter(
    fontSize: sizeDisplay, fontWeight: weightSemiBold,
    color: color ?? KlinikColors.textPrimary, height: heightDisplay, letterSpacing: -0.56,
  );
  static TextStyle heading({Color? color}) => GoogleFonts.inter(
    fontSize: sizeHeading, fontWeight: weightSemiBold,
    color: color ?? KlinikColors.textPrimary, height: heightHeading, letterSpacing: -0.2,
  );
  static TextStyle body({Color? color}) => GoogleFonts.inter(
    fontSize: sizeBody, fontWeight: weightRegular,
    color: color ?? KlinikColors.textSecondary, height: heightBody,
  );
  static TextStyle bodyStrong({Color? color}) => GoogleFonts.inter(
    fontSize: sizeBody, fontWeight: weightSemiBold,
    color: color ?? KlinikColors.textPrimary, height: heightBody,
  );
  static TextStyle caption({Color? color}) => GoogleFonts.inter(
    fontSize: sizeCaption, fontWeight: weightRegular,
    color: color ?? KlinikColors.textTertiary, height: heightCaption,
  );
  static TextStyle captionStrong({Color? color}) => GoogleFonts.inter(
    fontSize: sizeCaption, fontWeight: weightMedium,
    color: color ?? KlinikColors.textSecondary, height: heightCaption,
  );
  static TextStyle appBarTitle({Color? color}) => GoogleFonts.inter(
    fontSize: sizeAppBarTitle, fontWeight: weightSemiBold,
    color: color ?? KlinikColors.textPrimary, letterSpacing: -0.18,
  );

  // Chiffre de score / température : extra-bold, chiffres tabulaires
  static TextStyle bigNumber(double size, Color color) => GoogleFonts.inter(
    fontSize: size, fontWeight: weightExtraBold, color: color,
    height: heightNumber, letterSpacing: size * -0.03,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static TextStyle riskScore(Color color) => bigNumber(sizeScoreResult, color); // 54px
  static TextStyle temperature(Color color) => bigNumber(sizeTemp, color);      // 52px

  // Question du module scan (centrée, équilibrée)
  static TextStyle question({Color? color}) => GoogleFonts.inter(
    fontSize: sizeGreeting, fontWeight: weightSemiBold,
    color: color ?? KlinikColors.textPrimary, height: heightQuestion,
  );
}
```

---

## 3. ESPACEMENT — KlinikSpacing

```dart
// lib/core/theme/klinik_spacing.dart

class KlinikSpacing {
  // ── 3.1 GRILLE 8 POINTS ───────────────────────────────────────────────────
  static const double base = 8.0;
  static const double xs   =  4.0;  // base × 0.5 — micro
  static const double sm   =  8.0;  // base × 1   — interne serré
  static const double md   = 16.0;  // base × 2   — standard
  static const double lg   = 24.0;  // base × 3   — généreux
  static const double xl   = 32.0;  // base × 4   — grands blocs
  static const double xxl  = 48.0;  // base × 6   — majeurs

  // ── 3.2 ESPACEMENTS SÉMANTIQUES (valeurs exactes des maquettes) ───────────
  static const double screenPaddingH = 20.0; // padding horizontal des écrans (.ks-pad)
  static const double cardPadding     = 20.0; // padding interne carte standard (.ks-card)
  static const double cardPaddingSm   = 16.0; // padding cartes "flat" compactes (15-16px)
  static const double listItemGap     = 11.0; // ÉCART MAQUETTE : gap réel des listes patient = 11 (brief : 12)
  static const double cardGridGap     = 12.0; // gap entre cartes stats / actions
  static const double formFieldGap    = 14.0; // ÉCART MAQUETTE : gap réel des formulaires = 14 (brief : 16)
  static const double sectionGap      = 24.0; // espace avant un nouveau bloc
  static const double ynGap           = 12.0; // espace entre boutons OUI / NON
  static const double keypadGap       = 10.0; // espace entre touches du clavier numérique
  static const double footerPadding   = 14.0; // padding vertical du footer collant (.ks-foot)
}
```

---

## 4. BORDER RADIUS — KlinikRadius

```dart
class KlinikRadius {
  static const double chip  =   8.0;  // chips / petits tags        (--r-chip)
  static const double btn   =  12.0;  // boutons, inputs, tuiles, encarts (--r-btn)
  static const double card  =  16.0;  // cartes, conteneurs, actions rapides (--r-card)
  static const double sheet =  20.0;  // bottom sheets, modals, grandes tuiles d'icône (--r-sheet)
  static const double pill  = 100.0;  // pills, badges, points, progress, dots actifs (--r-pill)

  // Rayons ponctuels relevés dans les maquettes (tuiles d'icône / avatars carrés) :
  static const double scoreBadge = 13.0; // badge de score (carré arrondi)
  static const double iconTileSm = 10.0; // tuiles 36-38px
  static const double iconTileMd = 11.0; // tuiles 40px
  static const double iconTileLg = 13.0; // tuiles 46px (trophée carte points)
  static const double iconTileXl = 14.0; // tuiles 52px (auth choice)
  static const double avatarSquare = 12.0; // avatar carré 42px (item patient)
  static const double checkbox   =  6.0; // case à cocher
}
```

---

## 5. OMBRES — KlinikShadows

```dart
// lib/core/theme/klinik_shadows.dart
import 'package:flutter/material.dart';

class KlinikShadows {
  // Carte plate standard (.ks-card.flat, list items, .ks-li)  — --shadow-card
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x14283759), blurRadius: 3, offset: Offset(0, 1)),
    // rgba(40,55,90,.08) ≈ 0x14283759
  ];

  // Élévation douce (menus déroulants, éléments flottants) — --shadow-sm
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0F283759), blurRadius: 8, offset: Offset(0, 2)),
    // rgba(40,55,90,.06)
  ];

  // Élévation moyenne (popover Select, popup points) — --shadow-md
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x29283759), blurRadius: 24, spreadRadius: -8, offset: Offset(0, 8)),
    // rgba(40,55,90,.16)
  ];

  // Carte de points AGENT (lueur bleue colorée sous la carte dégradée)
  static const List<BoxShadow> pointsAgent = [
    BoxShadow(color: Color(0x66304E91), blurRadius: 28, spreadRadius: -12, offset: Offset(0, 12)),
    // ≈ accent assombri à 70% noir, alpha .4  // À CONFIRMER (color-mix d'origine)
  ];
  // Carte de points MÉDECIN (lueur turquoise)
  static const List<BoxShadow> pointsMedecin = [
    BoxShadow(color: Color(0x66317777), blurRadius: 28, spreadRadius: -12, offset: Offset(0, 12)),
    // À CONFIRMER (color-mix d'origine)
  ];

  // Bouton flottant scan (FAB central de la tab bar agent)
  static const List<BoxShadow> fab = [
    BoxShadow(color: Color(0x66304E91), blurRadius: 18, spreadRadius: -6, offset: Offset(0, 8)),
  ];
}
```

---

## 6. COMPOSANTS — KlinikComponents

```dart
// 6.1 BOUTON PRIMAIRE (CTA)
class KlinikButtonSpecs {
  static const double primaryHeight   = 52.0;  // hauteur standard (.ks-btn)
  static const double primaryRadius   = 12.0;  // = KlinikRadius.btn
  static const double primaryFontSize = 15.0;
  static const FontWeight primaryWeight = FontWeight.w600;
  static const double primaryIconSize = 19.0;  // icône dans un bouton standard
  static const double primaryIconGap  = 8.0;   // gap icône ↔ texte
  static const double pressedScale     = 0.98; // feedback tap

  // 6.2 BOUTON SECONDAIRE (OUTLINE)
  static const double secondaryBorder  = 1.5;  // épaisseur bordure accent
  // (mêmes hauteur / radius / typo que le primaire ; fond transparent, texte+bordure accent)

  // Bouton "small" / pill (ex. actions de carte, langues, "Voir tout")
  static const double smallHeight   = 38.0;
  static const double smallFontSize = 13.0;
  static const double smallRadius   = 100.0;   // pill
  static const double smallIconSize = 16.0;

  // Bouton "action rapide" (accueil agent — vertical icône+label)
  static const double quickActionHeight = 58.0;
  static const double quickActionRadius = 16.0; // = card
  static const double quickActionIcon   = 22.0;

  // 6.3 BOUTONS OUI / NON (MODULE SCAN — CRITIQUES TERRAIN)
  static const double scanButtonHeight = 60.0; // OBLIGATOIRE (gants / plein soleil)
  static const double scanButtonRadius = 12.0;
  static const double scanButtonBorder = 1.5;  // bordure inactive (#E8ECF4)
  static const double scanButtonFont   = 16.0;
  static const FontWeight scanButtonWeight = FontWeight.w600;
  static const double scanButtonIcon   = 22.0;
  static const double scanButtonGap    = 10.0; // icône ↔ libellé
  // OUI inactif/actif : #F0F4F8 → #2E7D32 (texte+icône blanc, icône checkCircle)
  // NON inactif/actif : #F0F4F8 → #C62828 (texte+icône blanc, icône xCircle)
}

// 6.4 CHAMPS DE SAISIE (INPUTS — label flottant)
class KlinikInputSpecs {
  static const Color  fill        = Color(0xFFF0F4F8); // surfaceVariant
  static const double radius      = 12.0;
  static const double borderInactive = 1.5;  // transparent au repos
  static const double borderFocus    = 1.5;  // accent au focus (#557CDC)
  static const double fontSize    = 15.0;
  static const double labelRest   = 15.0;    // label au repos (couleur textTertiary)
  static const double labelFloat  = 11.0;    // label flottant (couleur accent)
  static const EdgeInsets padding = EdgeInsets.fromLTRB(16, 22, 16, 8); // place le label flottant
  static const double textareaMinHeight = 120.0;
  // Cases de code OTP : 48 × 60, radius 12, bordure 2px accent si rempli, texte 24px w700
  static const double otpBoxW = 48.0, otpBoxH = 60.0, otpRadius = 12.0, otpBorder = 2.0;
}

// 6.5 CARTES
class KlinikCardSpecs {
  static const Color  fill    = Color(0xFFFFFFFF);
  static const double radius  = 16.0;
  static const double border  = 1.0;            // #E8ECF4 (variante "outline")
  static const EdgeInsets padding = EdgeInsets.all(20.0);
  // Variante "flat" : pas de bordure, ombre KlinikShadows.card, padding souvent 14-16px.
  static const double pressedScale = 0.99;      // cartes tappables (.ks-card.tap / .ks-li)
}

// 6.6 APPBAR
class KlinikAppBarSpecs {
  static const double minHeight = 56.0;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  static const double itemGap   = 12.0;
  static const double titleSize = 18.0;         // w600
  static const double iconButton= 40.0;         // zone tactile carrée (radius pill)
  static const double backIcon  = 24.0;         // chevronLeft / menu = 22
  static const double avatar    = 36.0;         // radius 50%, initiales w600
  static const double elevation = 0.0;          // pas d'ombre native ; bordure 1px au scroll
}

// 6.7 CHIPS & PILLS
class KlinikChipSpecs {
  static const double pillHeight  = 38.0;
  static const EdgeInsets pillPad = EdgeInsets.symmetric(horizontal: 18);
  static const double pillRadius  = 100.0;
  static const double pillFont    = 13.0;       // w600
  static const double chipHeight  = 34.0;       // chip filtre (plus léger)
  static const EdgeInsets chipPad = EdgeInsets.symmetric(horizontal: 14);
  static const double chipFont    = 13.0;       // w500
  // état "on" : fond accent, texte blanc ; repos : fond surfaceVariant, texte textSecondary
}

// 6.8 BADGE DE SCORE DE RISQUE
class KlinikScoreBadgeSpecs {
  static const double defaultSize = 44.0;       // tailles utilisées : 38 / 40 / 42 / 44 / 48
  static const double radius      = 13.0;       // carré arrondi
  // chiffre : taille = size × 0.38, w800, tabular ; suffixe "/10" : size × 0.17, w600, opacity .7
  // couleurs : low/mid/high sur surface low/mid/high correspondante
}

// 6.9 BOTTOM NAVIGATION BAR
class KlinikTabBarSpecs {
  static const Color fill   = Color(0xFFFFFFFF);
  static const double topBorder = 1.0;          // #E8ECF4
  static const EdgeInsets padding = EdgeInsets.fromLTRB(4, 8, 4, 6);
  static const double iconSize = 21.0;
  static const double labelSize= 10.5;          // w500
  static const Color activeColor = Color(0xFF557CDC);
  static const Color inactiveColor = Color(0xFF9AA3AF);
  // FAB central (tab bar agent) : cercle 52, icône 24 blanc, accent, remonte de -18, ombre KlinikShadows.fab
}

// 6.10 NETWORK STATUS INDICATOR (OBLIGATOIRE sur tout écran avec AppBar)
class KlinikNetSpecs {
  static const double dot      = 8.0;           // pastille colorée
  static const double fontSize = 12.0;          // w500
  static const double gap      = 6.0;           // pastille ↔ texte
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 10, vertical: 5);
  static const double radius   = 100.0;         // pill, fond surfaceVariant
  // online  : dot #43A047  + "En ligne"
  // offline : dot #E53935  + "Hors ligne"
  // syncing : dot #FF8F00 (pulsé 1.2s) + "N en attente…"
}

// Composants additionnels présents dans les maquettes
class KlinikMiscSpecs {
  // Barre de progression (scan) : hauteur 6, radius pill, track #E8ECF4, remplissage accent
  static const double progressHeight = 6.0;
  // Dots d'onboarding : 8×8 inactif → largeur 24 (pill) actif, couleur accent
  static const double dotSize = 8.0, dotActiveWidth = 24.0;
  // Toggle (réglages) : 44×26, pastille 20, radius pill ; "on" = accent
  static const double toggleW = 44.0, toggleH = 26.0, toggleKnob = 20.0;
  // Checkbox : 22×22, radius 6, bordure 2px ; "on" = accent
  static const double checkbox = 22.0, checkboxRadius = 6.0, checkboxBorder = 2.0;
  // Clavier numérique (scan température) : touches 54 de haut, radius 12, texte 21 w600, gap 10
  // ÉCART MAQUETTE : hauteur réelle des touches = 54 (le brief évoquait 64).
  static const double keypadKeyHeight = 54.0;
  // Onglets médecin : padding 12/4, libellé 13.5 w600, soulignement actif 2.5px accent,
  //   badge d'urgence : minWidth 18, h 18, radius 9, fond riskHigh, texte 11 w700 blanc.
}
```

---

## 7. ICONOGRAPHIE — KlinikIcons

```dart
// 7.1 PACKAGE
// Package UNIQUE : lucide_icons (pub.dev) — équivalent Flutter de Lucide React.
// Style : stroke 2px, strokeLinecap & strokeLinejoin = round, fill: none, viewBox 24.
// INTERDIT : Material Icons, Cupertino Icons, FontAwesome.

// 7.2 TAILLES
class KlinikIconSizes {
  static const double xs      = 13.0; // icônes inline dans une caption (statut item patient)
  static const double sm      = 15.0; // icônes de chip / badge / disclaimer
  static const double md      = 18.0; // icônes secondaires (vitales, listes)
  static const double base    = 20.0; // taille standard par défaut
  static const double tab     = 21.0; // icônes de la bottom navigation
  static const double appbar  = 22.0; // menu / chevron AppBar (retour = 24)
  static const double btn     = 19.0; // icône dans un bouton (small : 16)
  static const double hero    = 32.0; // icônes d'en-tête (états vides, succès)
  static const double heroLg  = 36.0; // thermomètre du module scan
  static const double display = 48.0; // grandes icônes (mail, résultats, confirmations)
  static const double splash  = 88.0; // logo KMark sur le splash
}

// 7.3 CORRESPONDANCE ICÔNES → USAGES (toutes celles présentes dans les maquettes)
// LucideIcons.menu          → ouverture du menu (AppBar accueil)
// LucideIcons.chevronLeft   → retour
// LucideIcons.chevronRight  → navigation vers détail (cartes auth, entités)
// LucideIcons.chevronDown   → ouverture d'un Select
// LucideIcons.arrowRight    → "Suivant" / progression
// LucideIcons.arrowLeft     → "Précédent"
// LucideIcons.userPlus      → nouveau patient / créer-rejoindre un compte
// LucideIcons.user          → identité patient (fiche, dossier)
// LucideIcons.users         → liste patients (tab)
// LucideIcons.building      → entité / centre de santé
// LucideIcons.scanLine      → nouveau scan (action + tab + FAB)
// LucideIcons.scan          → lancer l'analyse vision
// LucideIcons.thermometer   → température
// LucideIcons.clipboardList → dossiers (tab médecin)
// LucideIcons.activity      → score / activité (tab médecin)
// LucideIcons.stethoscope   → médecin / validation / badge "Validateur"
// LucideIcons.checkCircle   → OUI / validé / étape réussie
// LucideIcons.xCircle       → NON / refusé
// LucideIcons.x             → fermer / retirer un élément
// LucideIcons.check         → "Commencer" (fin onboarding)
// LucideIcons.checkCheck    → demande envoyée (confirmation)
// LucideIcons.alertTriangle → urgence (score ≥ 7), signes d'alerte
// LucideIcons.alertCircle   → encart disclaimer "Aide à la décision"
// LucideIcons.info          → note informative (grade déclaratif)
// LucideIcons.fileText      → documents / voir les documents
// LucideIcons.fileCheck     → ordonnance signée / dossier validé
// LucideIcons.pill          → médicament / ordonnance
// LucideIcons.trophy        → points / gamification (cartes de points, tab Points)
// LucideIcons.star          → badge "Actif"
// LucideIcons.sparkles      → points gagnés (+1 pt / +2,5 pts)
// LucideIcons.send          → soumettre au médecin / envoyer
// LucideIcons.refresh       → recommencer le scan
// LucideIcons.camera        → caméra thermique / module vision
// LucideIcons.eye / eyeOff  → afficher/masquer mot de passe ; eye → indicateur vision
// LucideIcons.droplet       → indicateur "Pâleur" (vision)
// LucideIcons.heartPulse    → constantes vitales
// LucideIcons.clock         → en attente
// LucideIcons.mailOpen      → vérification email / lien envoyé
// LucideIcons.lock          → réinitialisation mot de passe
// LucideIcons.key           → "j'ai reçu mon code"
// LucideIcons.search        → recherche (patients, entités)
// LucideIcons.edit          → modifier la fiche
// LucideIcons.share         → référer vers un spécialiste
// LucideIcons.printer       → aperçu PDF
// LucideIcons.plus          → ajouter un médicament
// LucideIcons.delete        → retour arrière (touche ⌫ du clavier numérique)
// LucideIcons.home          → accueil (tab)
// LucideIcons.settings      → réglages (tab)
// LucideIcons.bell          → notifications
// LucideIcons.logOut        → déconnexion
// LucideIcons.shield        → sécurité / confidentialité
// LucideIcons.wifi / wifiOff/ cloudUpload → états réseau (online / offline / syncing)
```

---

## 8. ANIMATIONS — KlinikAnimations

```dart
// lib/core/theme/klinik_animations.dart
import 'package:flutter/animation.dart';

class KlinikAnimations {
  // ── DURÉES ─────────────────────────────────────────────────────────────────
  static const Duration tap     = Duration(milliseconds: 120);  // feedback scale boutons/cartes
  static const Duration fast     = Duration(milliseconds: 150);  // transitions de couleur (boutons, focus)
  static const Duration toggle   = Duration(milliseconds: 200);  // toggles, switch d'onglet, fade réseau
  static const Duration autoNext = Duration(milliseconds: 230);  // passage auto à la question suivante (OUI/NON)
  static const Duration normal   = Duration(milliseconds: 350);  // progression de barre / transitions cartes
  static const Duration pop      = Duration(milliseconds: 500);  // apparition "pop" des écrans de succès / score
  static const Duration spin     = Duration(milliseconds: 800);  // spinner (rotation continue)
  static const Duration syncPulse= Duration(milliseconds: 1200); // pulsation point "syncing"
  static const Duration urgentPulse = Duration(milliseconds: 1600); // halo pulsé alerte urgence
  static const Duration pointsFloat = Duration(milliseconds: 1800); // "+1 pt" fade up
  static const Duration splash   = Duration(milliseconds: 2300); // durée du splash avant redirection

  // ── COURBES ──────────────────────────────────────────────────────────────
  static const Curve standard = Curves.easeOut;                  // entrées de cartes (fade/slide up 9px)
  static const Curve emphasis = Curves.easeInOut;                // changements d'état lents
  static const Curve linear   = Curves.linear;                   // spinner
  static const Cubic pop      = Cubic(0.22, 1.3, 0.4, 1.0);      // "ks-pop" : scale 0.7→1.06→1 (effet ressort)

  // ── TRANSFORMATIONS DE RÉFÉRENCE ───────────────────────────────────────────
  static const double tapScale       = 0.98; // boutons standard
  static const double keypadTapScale = 0.95; // touches du clavier numérique
  static const double cardTapScale   = 0.99; // cartes / list items
  // Entrée d'écran (ks-anim) : translateY 9px → 0, opacity inchangée (capture/print restent visibles).
  // Points gagnés (ks-points-pop) : opacity 0→1→0 + translateY 0 → -40px sur la durée pointsFloat.
}
```

---

## 9. SPÉCIFICATIONS PAR ÉCRAN

> Cadre de référence des maquettes : **iPhone 390 × 844**, coins 44, statut OS 40px,
> barre de gestes 22px. Valeurs ci-dessous = écarts/précisions par rapport au système.

### 9.1 Splash
- Fond : dégradé **radial** `120% 80% at 50% 0%` clair → `accent` (#557CDC, 46%) → `accentDark` (#3D5FAA, 100%).
- Logo : `KMark` blanc **88px**, dans une tuile translucide `rgba(255,255,255,.14)`, radius 32, padding 26.
- Wordmark : blanc **42px** (w800). Baseline : « TRIAGE MÉDICAL INTELLIGENT », 13px w500, UPPERCASE, tracking .16em, `rgba(255,255,255,.85)`.
- Spinner blanc en bas (54px du bord). Redirection auto après **2300 ms** (tap pour passer).

### 9.2 Onboarding (4 slides)
- Image illustrative : hauteur **380**, radius **22**, ombre `0 16px 32px -16px rgba(40,55,90,.30)`, `object-fit: cover`.
- Titre `t-display` (28px), description `t-body` `textSecondary`, largeur max ~300, centrés.
- Dots : 8px, actif → largeur **24** (pill) accent ; gap 8 ; placés au-dessus du bouton (marge 18).
- Bouton plein largeur 52px. Bouton « Passer » discret en haut à droite (13px w600, textTertiary).

### 9.3 Authentification
- **AuthChoice** : 2 cartes tappables `minHeight 96`, padding 18 ; tuile d'icône **52×52** radius 14 (fond couleur à 10% : bleu pour « Créer », turquoise pour « Rejoindre »).
- **Login** : KMark 56, wordmark 30, champs gap 16, lien « Mot de passe oublié » aligné à droite 12px, sélecteur de langue (pills FR/EN/ES) en pied.
- **Activate (OTP)** : 6 cases **48×60**, radius 12, bordure 2px accent si remplie, texte 24 w700 ; compte à rebours en `warning`.
- **SetPassword** : 4 règles de validation (icône checkCircle 15px low / circle muted) + bandeau « Code validé » sur `riskLowSurface`.

### 9.4 Accueil Agent
- **Carte Points** : dégradé agent, radius 16, padding 18/20 ; tuile trophée 46×46 radius 13 (`rgba(255,255,255,.18)`) ; chiffre **26 w800** « 12 pts » + sous-ligne 12.5 opacité .85 ; pastille « Actif » (pill translucide, étoile 13px).
- **Stats (2 colonnes)** : cartes flat padding 15/16, chiffre **28 w800** ; la carte « En attente de validation » est intégralement colorée en `warning` (#E65100).
- **Actions rapides (2 colonnes)** : boutons verticaux **58px**, radius 16 — « Nouveau patient » primaire, « Nouveau scan » secondaire ; icône 22 + label 13.5.
- **Item patient (.ks-li)** : padding 14, gap 13 ; avatar carré **42** radius 12 (initiales w700) ; nom 14.5 w600 + « âge · sexe » caption ; ligne de statut (icône 13 colorée + texte 12 w500) ; `ScoreBadge` **40** à droite.
- **Tab bar** : 5 onglets, FAB scan central (cercle 52, remonte -18).

### 9.5 Module Scan — Température (étape 1/3)
- En-tête : barre de progression 6px à 33 % + AppBar « Scan — Étape 1/3 » (réseau masqué).
- Tuile thermomètre **72×72** radius 20, fond `surfaceAccentSoft` (#EAF0FF), icône 36 accent ; titre `t-h` centré.
- Carte température : chiffre **52 w800** tabulaire + suffixe « °C » 26 muted ; padding 22/20.
- Bandeau d'interprétation coloré selon paliers (normal/subfébrile/fièvre/hypothermie) : padding 12/16, radius 12, 14 w600, sur surface sémantique correspondante.
- Séparateur « ou » + bouton caméra thermique (secondaire pleine largeur).
- **Clavier numérique** : grille 3 colonnes, touches **54px** radius 12, texte 21 w600, gap 10 (⌫ = icône delete, fond transparent).
- Footer (sans bordure) : bouton « Suivant » 52px (désactivé si valeur < 30).

### 9.6 Module Scan — Questionnaire (étape 2/3)
- Progression à l'étape 2 ; « Question N sur 11 » en caption centrée.
- Carte question : `minHeight 150`, padding 30/22, texte centré **21px / line-height 1.35** (`text-wrap: balance`), entrée animée ks-anim à chaque question.
- Boutons **OUI / NON 60px** (specs §6.3), gap 12 ; sélection → couleur sémantique pleine + passage **auto** à la question suivante après **230 ms**.
- Footer : « Précédent » (ghost) + « Suivant » (primaire, désactivé tant que pas de réponse).

### 9.7 Résultat Score de risque
- **Carte score** : `borderLeft` **5px** couleur sémantique, fond `*Surface`, padding 22/20, entrée « ks-pop ». Chiffre **54 w800** + « /10 » 26 (opacité .6), libellé `t-h` 19 + emoji.
- Si score ≥ 7 : bloc d'alerte (halo pulsé 32px, icône alertTriangle) « Le médecin est alerté automatiquement », séparé par un trait `couleur+33`.
- Carte détail : 3 lignes (Température / Questionnaire / Vision) avec mini barres de progression accent ; ligne grisée si étape Vision passée.
- **Disclaimer obligatoire** : encart `surfaceInfoSoft` (#F5F6FA), icône alertCircle muted, « Aide à la décision uniquement. Ne remplace pas l'examen clinique du médecin. »
- Popup « +1 pt » (sparkles) en haut-droite, animation float (1.8s) sur `riskLow`.
- Footer : « Soumettre au médecin » (primaire) + « Recommencer le scan » (ghost).

### 9.8 Module Scan — Vision (étape 3/3)
- Viewport caméra : `minHeight 300`, radius 16, fond rayé sombre (#20242E/#262B36) ; ovale guide **170×220** (pointillé blanc → plein turquoise pendant l'analyse), 4 équerres d'angle 26px turquoise ; pastille de statut noire translucide en bas.
- Compte à rebours d'analyse (10 s) ; à la fin : tuile checkCircle 64px + 3 cartes d'indicateurs (tuile 40 radius 11 sur surface sémantique).
- Boutons : « Lancer l'analyse » / « Passer cette étape » (ghost). Disclaimer présent dès le cadrage.

### 9.9 Tableau de bord Médecin
- AppBar avec wordmark + Net + avatar.
- **Carte Points médecin** : dégradé **turquoise** (a → a-d), radius 16, chiffre **26 w800** « 87,5 pts » + « ce mois · 14 validations », pastille « Validateur » (stéthoscope).
- **Onglets** (Disponibles / Mes dossiers / Validés) : 13.5 w600, padding 12/4, soulignement actif **2.5px** accent ; badge d'urgence rouge (18px, radius 9, 11 w700) sur « Disponibles ».
- **Carte dossier** : flat avec `borderLeft` **4px** couleur sémantique, padding 15/16 ; `ScoreBadge` **42** + « profil · âge · sexe » 15 w600 + « Soumis par … — il y a … » caption ; tag « URGENT » (alertTriangle) si score ≥ 7 ; bouton « Prendre en charge » small **42px** pleine largeur.

### 9.10 Détail dossier & Ordonnance (médecin)
- **Dossier** : carte score (borderLeft **5px**, chiffre **48 w800**), carte identité (avatar 44 + 2 vitales sur `surfaceVariant`), liste des signes relevés (icône alertTriangle/checkCircle 17), disclaimer, double CTA (« Valider & rédiger l'ordonnance » / « Référer »).
- **Ordonnance** : en-tête patient + ScoreBadge 38 ; cartes médicament (tuile pilule 36 radius 10 sur #EAF0FF + bouton retirer) ; bouton secondaire « Ajouter un médicament » 46px ; champ « Recommandations » (textarea) ; CTA « Signer & transmettre » + « Aperçu PDF ».
- **OrdonnanceDone** : tuile fileCheck 104px radius 32 sur `riskLowSurface`, « Dossier validé ✓ » `t-display`, « +2,5 pts de validation » en `secondaryDark`.

---

## 10. RÈGLES ABSOLUES POUR CLAUDE CODE

```
RÈGLE 1 — Aucune couleur hardcodée dans les widgets.
  Conforme     : color: KlinikColors.accent
  Non conforme : color: Color(0xFF557CDC)

RÈGLE 2 — Aucune taille de texte hors du système typographique.
  Conforme     : style: KlinikTypography.body()
  Non conforme : TextStyle(fontSize: 14)
  (Les tailles "spéciales" — score 54, temp 52, etc. — passent par KlinikTypography.bigNumber.)

RÈGLE 3 — Aucun espacement hors de la grille 8pt (ou des constantes sémantiques KlinikSpacing).
  Conforme     : SizedBox(height: KlinikSpacing.md)   // 16
  Non conforme : SizedBox(height: 15) / EdgeInsets.all(13)
  Exceptions tolérées car réellement présentes dans les maquettes : gaps de liste 11,
  gaps de formulaire 14 — utiliser KlinikSpacing.listItemGap / .formFieldGap, pas un nombre nu.

RÈGLE 4 — Tap targets ≥ 48dp × 48dp. Boutons scan OUI/NON ≥ 60dp.
  La hauteur 60 des boutons OUI/NON est NON négociable (gants, plein soleil).

RÈGLE 5 — NetworkStatusIndicator présent sur CHAQUE écran possédant une AppBar
  (sauf les écrans de tunnel scan où il est volontairement masqué : étapes 1/3, 2/3, 3/3,
   et les écrans d'authentification — net:false dans les maquettes).

RÈGLE 6 — Tout affichage de score de risque est TOUJOURS accompagné du disclaimer légal :
  « Aide à la décision uniquement. Ne remplace pas l'examen clinique du médecin. »
  (caption, sur fond surfaceInfoSoft #F5F6FA, icône alertCircle muted.)

RÈGLE 7 — Iconographie : lucide_icons UNIQUEMENT. Material/Cupertino/FontAwesome interdits.
  Stroke 2px, linecap/linejoin round, fill none.

RÈGLE 8 — Aucune publicité (AdMob ou autre) sur les écrans :
  scan actif (température, questionnaire, vision), résultat de score, dossier médecin,
  ordonnance, et tout écran d'urgence (score ≥ 7).

RÈGLE 9 — Les couleurs sémantiques de score (#2E7D32 / #E65100 / #C62828 et leurs surfaces)
  ne servent QU'AU score de risque, à ses dérivés directs (bordure gauche de dossier,
  bandeau de température, indicateurs vision) et aux statuts validé/urgent — jamais comme
  couleur décorative arbitraire.

RÈGLE 10 — Les chiffres importants (score, température, stats, points) sont en w800,
  letter-spacing -.03em, fontFeatures: tabularFigures. Ne jamais les rendre en w400/w600.

RÈGLE 11 — La couleur accent (#557CDC) n'est JAMAIS un fond d'écran plein.
  Elle n'apparaît en grande surface que dans les dégradés (carte de points, splash).

RÈGLE 12 — Bordure gauche colorée : 5dp pour les cartes de score (résultat / dossier détail),
  4dp pour les cartes de dossier en liste. Ne pas confondre les deux épaisseurs.

RÈGLE 13 — Carte de points : dégradé bleu (agent) OU turquoise (médecin) selon le rôle.
  Ne pas appliquer le dégradé bleu à un médecin ni l'inverse.

RÈGLE 14 — Feedback tactile obligatoire : scale 0.98 (boutons), 0.95 (touches clavier),
  0.99 (cartes/list items), durée 120 ms.

RÈGLE 15 — Les animations d'entrée n'animent QUE la position/échelle, jamais l'opacité de
  0 → 1 de façon bloquante (pour rester lisibles en capture, impression, reduced-motion).
```

---

*Généré le 03 Juin 2026 par Claude Design à partir des maquettes Klinik-Scan v1.0*
*Projet : Klinik-Scan — Redemona Christ (Ashad) — github.com/Ashad90*
*République Centrafricaine — 2026*
