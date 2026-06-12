import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/klinik_colors.dart';
import '../../../core/theme/klinik_radius.dart';
import '../../../core/theme/klinik_spacing.dart';
import '../../../core/theme/klinik_typography.dart';
import '../../../shared/widgets/klinik_card.dart';

/// Écran de choix d'authentification — DESIGN.md §9.3.
///
/// Deux cartes tappables (Créer / Rejoindre une entité) + lien de connexion.
/// Tunnel d'authentification : pas d'AppBar ni d'indicateur réseau (net:false).
class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlinikColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KlinikSpacing.screenPaddingH,
          ),
          child: Column(
            children: [
              const Spacer(),
              SvgPicture.asset(
                'assets/logos/klinik-mark.svg',
                width: 64,
                height: 64,
              ),
              const SizedBox(height: KlinikSpacing.lg),
              Text('Bienvenue sur Klinik', style: KlinikTypography.display()),
              const SizedBox(height: KlinikSpacing.sm),
              Text(
                'Créez votre structure de santé ou rejoignez une entité existante.',
                textAlign: TextAlign.center,
                style: KlinikTypography.body(),
              ),
              const SizedBox(height: KlinikSpacing.xl),
              _ChoiceCard(
                icon: LucideIcons.building,
                tint: KlinikColors.accent,
                title: 'Créer une entité',
                subtitle: 'Enregistrez votre centre de santé, clinique ou ONG.',
                onTap: () => context.push(RouteNames.createEntity),
              ),
              const SizedBox(height: KlinikSpacing.cardGridGap),
              _ChoiceCard(
                icon: LucideIcons.userPlus,
                tint: KlinikColors.secondary,
                title: 'Rejoindre une entité',
                subtitle: 'Veuillez demander votre code d\'accès.',
                onTap: () => context.push(RouteNames.joinEntity),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push(RouteNames.login),
                child: Text(
                  'J\'ai déjà un compte · Se connecter',
                  style: KlinikTypography.captionStrong(
                    color: KlinikColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: KlinikSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KlinikCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 96 - 36,
        ), // minHeight 96 hors padding
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KlinikRadius.iconTileXl),
              ),
              child: Icon(icon, size: 24, color: tint),
            ),
            const SizedBox(width: KlinikSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: KlinikTypography.bodyStrong()),
                  const SizedBox(height: 2),
                  Text(subtitle, style: KlinikTypography.caption()),
                ],
              ),
            ),
            const SizedBox(width: KlinikSpacing.sm),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: KlinikColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
