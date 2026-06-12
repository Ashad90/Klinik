import 'package:flutter/material.dart';
import '../../core/theme/klinik_colors.dart';
import '../../core/theme/klinik_shadows.dart';
import '../../core/theme/klinik_radius.dart';
import '../../core/theme/klinik_animations.dart';

class KlinikCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool showShadow;
  final Color? backgroundColor;

  const KlinikCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.showBorder = true,
    this.showShadow = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return _TappableCard(
        padding: padding,
        onTap: onTap!,
        showBorder: showBorder,
        showShadow: showShadow,
        backgroundColor: backgroundColor,
        child: child,
      );
    }

    return _CardContainer(
      padding: padding,
      showBorder: showBorder,
      showShadow: showShadow,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}

class _TappableCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onTap;
  final bool showBorder;
  final bool showShadow;
  final Color? backgroundColor;

  const _TappableCard({
    required this.child,
    required this.onTap,
    this.padding,
    this.showBorder = true,
    this.showShadow = true,
    this.backgroundColor,
  });

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? KlinikAnimations.cardTapScale : 1.0,
        duration: KlinikAnimations.tap,
        child: _CardContainer(
          padding: widget.padding,
          showBorder: widget.showBorder,
          showShadow: widget.showShadow,
          backgroundColor: widget.backgroundColor,
          child: widget.child,
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showBorder;
  final bool showShadow;
  final Color? backgroundColor;

  const _CardContainer({
    required this.child,
    this.padding,
    this.showBorder = true,
    this.showShadow = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? KlinikColors.surfaceLight,
        borderRadius: BorderRadius.circular(KlinikRadius.card),
        border: showBorder
            ? Border.all(color: KlinikColors.border, width: 1)
            : null,
        boxShadow: showShadow ? KlinikShadows.card : null,
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }
}
