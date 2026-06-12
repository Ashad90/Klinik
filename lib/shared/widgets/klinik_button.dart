import 'package:flutter/material.dart';
import '../../core/theme/klinik_colors.dart';
import '../../core/theme/klinik_typography.dart';
import '../../core/theme/klinik_animations.dart';
import '../../core/theme/klinik_radius.dart';

enum KlinikButtonVariant { primary, secondary, ghost }

class KlinikButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final KlinikButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const KlinikButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = KlinikButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  const KlinikButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  }) : variant = KlinikButtonVariant.secondary;

  const KlinikButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  }) : variant = KlinikButtonVariant.ghost;

  @override
  State<KlinikButton> createState() => _KlinikButtonState();
}

class _KlinikButtonState extends State<KlinikButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _pressed = true);
    }
  }

  void _handleTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _handleTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? KlinikAnimations.tapScale : 1.0,
        duration: KlinikAnimations.tap,
        child: _ButtonContent(
          label: widget.label,
          variant: widget.variant,
          icon: widget.icon,
          isLoading: widget.isLoading,
          fullWidth: widget.fullWidth,
          enabled: enabled,
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final KlinikButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool enabled;

  const _ButtonContent({
    required this.label,
    required this.variant,
    required this.icon,
    required this.isLoading,
    required this.fullWidth,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color foreground;
    final Border? border;

    if (!enabled) {
      bg = KlinikColors.surfaceVariant;
      foreground = KlinikColors.textTertiary;
      border = null;
    } else {
      switch (variant) {
        case KlinikButtonVariant.primary:
          bg = KlinikColors.accent;
          foreground = KlinikColors.textOnAccent;
          border = null;
        case KlinikButtonVariant.secondary:
          bg = Colors.transparent;
          foreground = KlinikColors.accent;
          border = Border.all(color: KlinikColors.accent, width: 1.5);
        case KlinikButtonVariant.ghost:
          bg = Colors.transparent;
          foreground = KlinikColors.accent;
          border = null;
      }
    }

    return Container(
      width: fullWidth ? double.infinity : null,
      height: 52,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KlinikRadius.btn),
        border: border,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null && !isLoading) ...[
            Icon(icon, size: 19, color: foreground),
            const SizedBox(width: 8),
          ],
          if (isLoading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: foreground,
                strokeWidth: 2,
              ),
            )
          else
            Text(
              label,
              style: KlinikTypography.bodyStrong(color: foreground),
            ),
        ],
      ),
    );
  }
}

// Bouton pill compact (38dp, radius 100) — actions secondaires, filtres
class KlinikButtonSmall extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool selected;

  const KlinikButtonSmall({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.selected = false,
  });

  @override
  State<KlinikButtonSmall> createState() => _KlinikButtonSmallState();
}

class _KlinikButtonSmallState extends State<KlinikButtonSmall> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color bg = widget.selected ? KlinikColors.accent : KlinikColors.surfaceVariant;
    final Color fg = widget.selected ? KlinikColors.textOnAccent : KlinikColors.textSecondary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? KlinikAnimations.tapScale : 1.0,
        duration: KlinikAnimations.tap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: KlinikTypography.captionStrong(color: fg).copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
