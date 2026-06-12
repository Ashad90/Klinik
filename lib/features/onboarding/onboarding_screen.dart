import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/klinik_animations.dart';
import '../../core/theme/klinik_colors.dart';
import '../../core/theme/klinik_radius.dart';
import '../../core/theme/klinik_spacing.dart';
import '../../core/theme/klinik_typography.dart';
import '../../shared/widgets/klinik_button.dart';
import 'onboarding_provider.dart';

/// Données d'un slide d'onboarding. Textes : brainstorming.md §3.2.
class _Slide {
  final String image;
  final String title;
  final String description;
  const _Slide(this.image, this.title, this.description);
}

const List<_Slide> _slides = [
  _Slide(
    'assets/images/onbording-slide-1.jpg',
    'Triage simplifié',
    'Créez des fiches patients en quelques secondes, même sans réseau.',
  ),
  _Slide(
    'assets/images/onboarding-scann.jpg',
    'Scan intelligent',
    'Questionnaire guidé + analyse visuelle pour évaluer l\'état du patient.',
  ),
  _Slide(
    'assets/images/onboarding-med-disponible.jpg',
    'Médecin disponible',
    'Votre dossier est envoyé au premier médecin disponible automatiquement.',
  ),
  _Slide(
    'assets/images/onbording-gamification.jpg',
    'Vos contributions comptent',
    'Chaque consultation vous rapporte des points et des badges de reconnaissance.',
  ),
];

/// Onboarding — DESIGN.md §9.2.
///
/// 4 slides (PageView), dots animés, bouton plein largeur 52px,
/// « Passer » discret en haut à droite (slides 1-3 uniquement).
/// Le flag `onboardingCompleted` est écrit dans Hive au « Commencer »
/// comme au « Passer » : l'onboarding ne se réaffiche jamais ensuite.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingRepositoryProvider).markCompleted();
    if (mounted) context.go(RouteNames.authChoice);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: KlinikAnimations.normal,
        curve: KlinikAnimations.standard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlinikColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
                  ),
                ),
                _Dots(count: _slides.length, active: _index),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KlinikSpacing.screenPaddingH,
                    0,
                    KlinikSpacing.screenPaddingH,
                    KlinikSpacing.lg,
                  ),
                  child: KlinikButton(
                    label: _isLast ? 'Commencer' : 'Suivant',
                    icon: _isLast ? LucideIcons.check : LucideIcons.arrowRight,
                    onPressed: _next,
                  ),
                ),
              ],
            ),
            // « Passer » — slides 1-3 uniquement (§9.2)
            if (!_isLast)
              Positioned(
                top: KlinikSpacing.sm,
                right: KlinikSpacing.md,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Passer',
                    style: KlinikTypography.caption(
                      color: KlinikColors.textTertiary,
                    ).copyWith(
                      fontSize: 13,
                      fontWeight: KlinikTypography.weightSemiBold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KlinikSpacing.screenPaddingH,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image illustrative : h380, radius 22, ombre, cover (§9.2)
          Container(
            height: 380,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D28375A), // rgba(40,55,90,.30)
                  blurRadius: 32,
                  offset: Offset(0, 16),
                  spreadRadius: -16,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(slide.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: KlinikSpacing.xl),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: KlinikTypography.display(),
          ),
          const SizedBox(height: KlinikSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: KlinikTypography.body(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicateur de progression — DESIGN.md §6 (dotSize 8 → dotActiveWidth 24).
class _Dots extends StatelessWidget {
  final int count;
  final int active;
  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool isActive = i == active;
        return AnimatedContainer(
          duration: KlinikAnimations.normal,
          curve: KlinikAnimations.standard,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? KlinikColors.accent : KlinikColors.border,
            borderRadius: BorderRadius.circular(KlinikRadius.pill),
          ),
        );
      }),
    );
  }
}
