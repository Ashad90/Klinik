import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/klinik_colors.dart';
import '../../core/theme/klinik_radius.dart';
import '../../core/theme/klinik_typography.dart';

/// Champ de saisie standard — DESIGN.md §6.4 (label flottant, fond
/// surfaceVariant, bordure accent au focus). Gère le toggle afficher/masquer
/// pour les mots de passe (icônes lucide eye / eyeOff).
class KlinikTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscure;
  final IconData? icon;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;

  const KlinikTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscure = false,
    this.icon,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<KlinikTextField> createState() => _KlinikTextFieldState();
}

class _KlinikTextFieldState extends State<KlinikTextField> {
  late bool _hidden = widget.obscure;

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(KlinikRadius.btn),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _hidden,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      style: KlinikTypography.body(color: KlinikColors.textPrimary),
      cursorColor: KlinikColors.accent,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: KlinikColors.surfaceVariant,
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, size: 19, color: KlinikColors.textTertiary)
            : null,
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _hidden ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 19,
                  color: KlinikColors.textTertiary,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: KlinikTypography.body(color: KlinikColors.textTertiary),
        floatingLabelStyle: KlinikTypography.captionStrong(color: KlinikColors.accent),
        border: _border(Colors.transparent, 1.5),
        enabledBorder: _border(Colors.transparent, 1.5),
        focusedBorder: _border(KlinikColors.accent, 1.5),
        errorBorder: _border(KlinikColors.error, 1.5),
        focusedErrorBorder: _border(KlinikColors.error, 1.5),
        errorStyle: KlinikTypography.caption(color: KlinikColors.error),
      ),
    );
  }
}
