import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/klinik_colors.dart';
import '../../../core/theme/klinik_spacing.dart';
import '../../../core/theme/klinik_typography.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/klinik_button.dart';
import '../../../shared/widgets/klinik_card.dart';
import '../../../shared/widgets/network_status_indicator.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/application/auth_providers.dart';
import '../application/home_providers.dart';

/// Accueil minimal — confirme la connexion (entité + rôle) et permet la
/// déconnexion. Placeholder en attendant l'« Accueil par rôle » du Jour 5.
/// AppBar présente → indicateur réseau obligatoire (RÈGLE 5).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentSessionProvider);
    final entityAsync = ref.watch(currentEntityProvider);

    return Scaffold(
      backgroundColor: KlinikColors.backgroundLight,
      appBar: AppBar(
        title: Text('Accueil', style: KlinikTypography.appBarTitle()),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: KlinikSpacing.md),
            child: NetworkStatusIndicator(),
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            Center(child: Text('Erreur de session.', style: KlinikTypography.body())),
        data: (session) {
          if (session == null) {
            return Center(
              child: Text('Aucune session active.', style: KlinikTypography.body()),
            );
          }
          // NOTE : la lecture de l'entité échoue tant que les custom claims
          // (`token.entityId`) ne sont pas posés — les règles exigent
          // `belongsToEntity`. Voir PROGRESS.md § blocage claims/Blaze.
          final entityName = entityAsync.when(
            data: (e) => e?.name ?? '—',
            loading: () => '…',
            error: (_, __) => '—',
          );
          return Padding(
            padding: const EdgeInsets.all(KlinikSpacing.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: KlinikSpacing.lg),
                KlinikCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Connecté à', style: KlinikTypography.caption()),
                      const SizedBox(height: 4),
                      Text(entityName, style: KlinikTypography.heading()),
                      const SizedBox(height: KlinikSpacing.md),
                      Row(
                        children: [
                          Icon(LucideIcons.user, size: 18, color: KlinikColors.accent),
                          const SizedBox(width: KlinikSpacing.sm),
                          Text(session.role.label, style: KlinikTypography.bodyStrong()),
                        ],
                      ),
                    ],
                  ),
                ),
                // Gestion de l'entité (admin) — approbation des demandes (Jour 4).
                if (session.role == UserRole.admin) ...[
                  const SizedBox(height: KlinikSpacing.md),
                  KlinikButton(
                    label: 'Demandes d\'adhésion',
                    icon: LucideIcons.userPlus,
                    onPressed: () => context.push(RouteNames.pendingRequests),
                  ),
                ],
                const Spacer(),
                KlinikButton.secondary(
                  label: 'Se déconnecter',
                  icon: LucideIcons.logOut,
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) context.go(RouteNames.authChoice);
                  },
                ),
                const SizedBox(height: KlinikSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }
}
