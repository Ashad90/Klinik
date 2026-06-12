---
name: klinik-design-system
description: Use this skill for ALL UI/visual code in Klinik-Scan Flutter app. Covers color tokens, typography scale, spacing system, button styles, card components, form elements, status indicators, and screen-level layout rules. Trigger whenever generating or modifying any Flutter widget, screen, or visual component. This skill overrides any generic Flutter UI decisions.
---

# Klinik-Design-System Skill

## Core Philosophy (Karpathy Method)

Every visual decision in Klinik-Scan must serve one of three users:
- **The agent**: stressed, possibly outdoors, on a cheap Android device, making fast decisions.
- **The doctor**: professional, needs dense information, validates remotely.
- **The patient**: not a direct user but visible on screen — their dignity matters in every photo/video interaction.

Design for the worst conditions: bright sunlight, dusty screen, 2GB RAM device, agent wearing gloves.

---

## Color System (Design Tokens)

### Primary Palette

```dart
// lib/core/theme/klinik_colors.dart

class KlinikColors {
  // Primary — Medical Blue (trust, professionalism)
  static const primary = Color(0xFF1565C0);        // Main actions, AppBar
  static const primaryLight = Color(0xFF5E92F3);   // Hover states, secondary buttons
  static const primaryDark = Color(0xFF003C8F);    // Pressed states
  static const primarySurface = Color(0xFFE8F0FE); // Card backgrounds, chips

  // Semantic — Risk Score Colors
  static const riskLow = Color(0xFF2E7D32);        // Score 0-3 — Green
  static const riskLowSurface = Color(0xFFE8F5E9);
  static const riskMedium = Color(0xFFE65100);     // Score 4-6 — Orange
  static const riskMediumSurface = Color(0xFFFFF3E0);
  static const riskHigh = Color(0xFFC62828);       // Score 7-10 — Red
  static const riskHighSurface = Color(0xFFFFEBEE);

  // Neutral Scale
  static const background = Color(0xFFF5F7FA);     // App background
  static const surface = Color(0xFFFFFFFF);        // Cards, modals
  static const surfaceVariant = Color(0xFFF0F4F8); // Input fields bg
  static const border = Color(0xFFDDE3ED);         // Dividers, borders
  static const textPrimary = Color(0xFF1A1D23);    // 100% opacity — headings
  static const textSecondary = Color(0xFF5A6474);  // 70% opacity — body
  static const textTertiary = Color(0xFF9AA3AF);   // 50% opacity — hints, labels

  // Status Colors
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFE65100);
  static const error = Color(0xFFC62828);
  static const info = Color(0xFF1565C0);

  // Online/Offline Indicator
  static const online = Color(0xFF43A047);
  static const offline = Color(0xFFE53935);
  static const syncing = Color(0xFFFF8F00);
}
```

### 60/30/10 Application
- **60%** → `background` (#F5F7FA) and `surface` (#FFFFFF)
- **30%** → `textPrimary`, `textSecondary`, borders
- **10%** → `primary` (#1565C0) for CTAs, icons, active states only

---

## Typography Scale

```dart
// lib/core/theme/klinik_typography.dart

class KlinikTypography {
  static const fontFamily = 'Inter';
  // Inter is loaded via google_fonts package:
  // GoogleFonts.inter(...)

  // Scale — 4 sizes max (Karpathy rule: keep it simple)
  static const double displaySize = 28.0;   // Screen titles, big numbers
  static const double headingSize = 20.0;   // Section headers, card titles
  static const double bodySize = 15.0;      // Body text, descriptions
  static const double captionSize = 12.0;   // Labels, hints, disclaimers

  // Weights — 2 max
  static const FontWeight semiBold = FontWeight.w600;  // Titles, CTAs
  static const FontWeight regular = FontWeight.w400;   // Body, secondary

  // Predefined TextStyles
  static TextStyle display({Color? color}) => GoogleFonts.inter(
    fontSize: displaySize, fontWeight: semiBold,
    color: color ?? KlinikColors.textPrimary, height: 1.2,
  );

  static TextStyle heading({Color? color}) => GoogleFonts.inter(
    fontSize: headingSize, fontWeight: semiBold,
    color: color ?? KlinikColors.textPrimary, height: 1.3,
  );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
    fontSize: bodySize, fontWeight: regular,
    color: color ?? KlinikColors.textSecondary, height: 1.5,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
    fontSize: captionSize, fontWeight: regular,
    color: color ?? KlinikColors.textTertiary, height: 1.4,
  );

  // Special: risk score number
  static TextStyle riskScore(Color color) => GoogleFonts.inter(
    fontSize: 48, fontWeight: semiBold, color: color,
    fontFeatures: [const FontFeature.tabularFigures()],
  );
}
```

---

## Spacing System (8-Point Grid)

```dart
class KlinikSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Screen horizontal padding
  static const double screenPadding = 20.0;

  // Card internal padding
  static const double cardPadding = 20.0;

  // Between list items
  static const double listItemGap = 12.0;

  // Between form fields
  static const double formFieldGap = 16.0;
}
```

---

## Border Radius System

```dart
class KlinikRadius {
  static const double sm = 8.0;    // Chips, tags
  static const double md = 12.0;   // Buttons, input fields
  static const double lg = 16.0;   // Cards
  static const double xl = 20.0;   // Bottom sheets, modals
  static const double full = 100.0; // Pills, circular buttons
}
```

---

## Button Components

### Primary Button (CTA)
```dart
// Minimum touch target: 52px height (accessibility for gloves)
Widget klinikPrimaryButton({
  required String label,
  required VoidCallback? onPressed,
  bool isLoading = false,
  IconData? icon,
}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: KlinikColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: KlinikColors.border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KlinikRadius.md),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label, style: KlinikTypography.body(color: Colors.white)
                  .copyWith(fontWeight: KlinikTypography.semiBold)),
            ]),
    ),
  );
}
```

### Secondary Button
```dart
Widget klinikSecondaryButton({required String label, required VoidCallback? onPressed}) {
  return SizedBox(
    width: double.infinity, height: 52,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: KlinikColors.primary,
        side: const BorderSide(color: KlinikColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KlinikRadius.md),
        ),
      ),
      child: Text(label, style: KlinikTypography.body(color: KlinikColors.primary)
          .copyWith(fontWeight: KlinikTypography.semiBold)),
    ),
  );
}
```

### YES/NO Buttons (Scan Questionnaire — extra large)
```dart
// These buttons are specifically for the scan questionnaire
// Designed for quick tapping, high visibility
Row klinikYesNoButtons({
  required bool? selected,
  required Function(bool) onChanged,
}) {
  return Row(children: [
    Expanded(child: _answerButton('OUI', true, selected, onChanged,
        activeColor: KlinikColors.riskLow)),
    const SizedBox(width: 12),
    Expanded(child: _answerButton('NON', false, selected, onChanged,
        activeColor: KlinikColors.textPrimary)),
  ]);
}

Widget _answerButton(String label, bool value, bool? selected,
    Function(bool) onChanged, {required Color activeColor}) {
  final isSelected = selected == value;
  return GestureDetector(
    onTap: () => onChanged(value),
    child: Container(
      height: 60, // Extra large for field conditions
      decoration: BoxDecoration(
        color: isSelected ? activeColor : KlinikColors.surfaceVariant,
        borderRadius: BorderRadius.circular(KlinikRadius.md),
        border: Border.all(
          color: isSelected ? activeColor : KlinikColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Center(child: Text(label, style: KlinikTypography.heading(
        color: isSelected ? Colors.white : KlinikColors.textSecondary,
      ))),
    ),
  );
}
```

---

## Risk Score Display Component

```dart
Widget klinikRiskScoreCard(int score) {
  final Color color;
  final Color surface;
  final String label;

  if (score <= 3) {
    color = KlinikColors.riskLow;
    surface = KlinikColors.riskLowSurface;
    label = 'Risque faible';
  } else if (score <= 6) {
    color = KlinikColors.riskMedium;
    surface = KlinikColors.riskMediumSurface;
    label = 'Risque modéré';
  } else {
    color = KlinikColors.riskHigh;
    surface = KlinikColors.riskHighSurface;
    label = 'Risque élevé';
  }

  return Container(
    padding: const EdgeInsets.all(KlinikSpacing.lg),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(KlinikRadius.lg),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(children: [
      Text('$score/10', style: KlinikTypography.riskScore(color)),
      const SizedBox(width: KlinikSpacing.md),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: KlinikTypography.heading(color: color)),
        Text('Score de risque calculé', style: KlinikTypography.caption()),
      ]),
    ]),
  );
}
```

---

## Card Component

```dart
Widget klinikCard({required Widget child, VoidCallback? onTap, Color? color}) {
  return Material(
    color: color ?? KlinikColors.surface,
    borderRadius: BorderRadius.circular(KlinikRadius.lg),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KlinikRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(KlinikSpacing.cardPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KlinikRadius.lg),
          border: Border.all(color: KlinikColors.border, width: 1),
        ),
        child: child,
      ),
    ),
  );
}
```

---

## Input Field Style

```dart
InputDecoration klinikInputDecoration({
  required String label,
  String? hint,
  IconData? prefixIcon,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: KlinikColors.textTertiary) : null,
    suffix: suffix,
    filled: true,
    fillColor: KlinikColors.surfaceVariant,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: KlinikSpacing.md, vertical: KlinikSpacing.md),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(KlinikRadius.md),
      borderSide: const BorderSide(color: KlinikColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(KlinikRadius.md),
      borderSide: const BorderSide(color: KlinikColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(KlinikRadius.md),
      borderSide: const BorderSide(color: KlinikColors.primary, width: 2),
    ),
    labelStyle: KlinikTypography.caption(color: KlinikColors.textSecondary),
    hintStyle: KlinikTypography.body(color: KlinikColors.textTertiary),
  );
}
```

---

## AppBar Standard

```dart
AppBar klinikAppBar({
  required String title,
  List<Widget>? actions,
  bool showBack = true,
}) {
  return AppBar(
    backgroundColor: KlinikColors.surface,
    elevation: 0,
    scrolledUnderElevation: 1,
    surfaceTintColor: Colors.transparent,
    shadowColor: KlinikColors.border,
    title: Text(title, style: KlinikTypography.heading()),
    leading: showBack ? const BackButton(color: KlinikColors.textPrimary) : null,
    actions: [
      const NetworkStatusIndicator(), // Always present
      if (actions != null) ...actions,
      const SizedBox(width: KlinikSpacing.sm),
    ],
  );
}
```

---

## Screen Layout Template

```dart
// Every screen in Klinik-Scan follows this scaffold
class KlinikScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlinikColors.background,
      appBar: klinikAppBar(title: title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KlinikSpacing.screenPadding),
          child: body,
        ),
      ),
      bottomNavigationBar: bottomAction != null
          ? Container(
              padding: EdgeInsets.only(
                left: KlinikSpacing.screenPadding,
                right: KlinikSpacing.screenPadding,
                bottom: MediaQuery.of(context).padding.bottom + KlinikSpacing.md,
                top: KlinikSpacing.md,
              ),
              decoration: BoxDecoration(
                color: KlinikColors.surface,
                border: Border(top: BorderSide(color: KlinikColors.border)),
              ),
              child: bottomAction,
            )
          : null,
    );
  }
}
```

---

## Design Rules — Never Break These

1. **Never use a color not defined in KlinikColors.** No hardcoded hex values in widgets.
2. **Never use a font size not in the typography scale.** Only the 4 defined sizes.
3. **Never use spacing values not on the 8-point grid.** Use KlinikSpacing constants.
4. **All tap targets minimum 48x48 dp.** Use 52+ for critical actions in scan module.
5. **Never hide the NetworkStatusIndicator.** It must be visible on every screen with an AppBar.
6. **Risk score always displayed with color + label + number.** Never just a number alone.
7. **Medical disclaimers use captionSize + textTertiary.** Never hidden, never small enough to be invisible.
