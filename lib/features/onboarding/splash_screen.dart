import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/klinik_animations.dart';
import '../../core/theme/klinik_colors.dart';
import '../../core/theme/klinik_typography.dart';
import 'onboarding_provider.dart';

/// Splash Screen — DESIGN.md §9.1.
///
/// Fond dégradé radial, logo KMark blanc dans une tuile translucide,
/// wordmark + tagline, spinner. Redirection automatique après 2300 ms
/// (tap n'importe où pour passer immédiatement).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(KlinikAnimations.splash, _go);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _go() {
    if (_navigated || !mounted) return;
    _navigated = true;
    final repo = ref.read(onboardingRepositoryProvider);
    context.go(resolveSplashRoute(repo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _go,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1),
              radius: 1.2,
              colors: [
                KlinikColors.gradientSplashStart,
                KlinikColors.gradientSplashMid,
                KlinikColors.gradientSplashEnd,
              ],
              stops: [0.0, 0.46, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tuile translucide + logo KMark blanc 88px (§9.1)
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: const Color(0x24FFFFFF), // rgba(255,255,255,.14)
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: SvgPicture.asset(
                        'assets/logos/klinik-mark-white.svg',
                        width: 88,
                        height: 88,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Wordmark blanc 42 w800 (§9.1 — taille spéciale maquette)
                    Text(
                      'Klinik',
                      style: GoogleFonts.inter(
                        fontSize: 42,
                        fontWeight: KlinikTypography.weightExtraBold,
                        color: KlinikColors.textOnAccent,
                        letterSpacing: 42 * -0.03,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Baseline UPPERCASE, tracking .16em, blanc 85% (§9.1)
                    Text(
                      'VOTRE SOLUTION DE SUIVI MÉDICAL',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: KlinikTypography.weightMedium,
                        color: const Color(0xD9FFFFFF), // rgba(255,255,255,.85)
                        letterSpacing: 0.16 * 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Spinner blanc — 54px du bord bas (§9.1)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 54,
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        KlinikColors.textOnAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
