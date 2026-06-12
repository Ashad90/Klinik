import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/klinik_colors.dart';
import '../../../core/theme/klinik_spacing.dart';
import '../../../core/theme/klinik_typography.dart';
import '../../../shared/models/pending_user.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/klinik_button.dart';
import '../../../shared/widgets/klinik_card.dart';
import '../../../shared/widgets/network_status_indicator.dart';
import '../application/auth_controller.dart';
import '../application/auth_providers.dart';
import '../application/join_controller.dart';

/// Demandes d'adhésion — Jour 4 étape 2 (approbation admin).
///
/// L'admin voit les demandes `pending_approval` de SON entité, assigne le rôle
/// (décision 30/05/2026 : jamais auto-déclaré) et approuve : le membre est créé
/// et un code d'accès 6 caractères (24h) est généré CÔTÉ CLIENT — l'admin le
/// communique en personne (email/FCM = Option A, Blaze).
class PendingRequestsScreen extends ConsumerStatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  ConsumerState<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends ConsumerState<PendingRequestsScreen> {
  /// Rôle choisi par demande (uid → rôle). Défaut : agent.
  final Map<String, UserRole> _roles = {};

  /// Demande en cours d'approbation (spinner sur son bouton uniquement).
  String? _approvingUid;

  Future<void> _approve(PendingUser request) async {
    final role = _roles[request.uid] ?? UserRole.agent;
    setState(() => _approvingUid = request.uid);
    final code = await ref
        .read(joinControllerProvider.notifier)
        .approve(request: request, role: role);
    if (!mounted) return;
    setState(() => _approvingUid = null);

    if (code == null) {
      final error = ref.read(joinControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
      );
      return;
    }
    await _showCodeDialog(request, role, code);
  }

  Future<void> _showCodeDialog(PendingUser request, UserRole role, String code) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: KlinikColors.surfaceLight,
        title: Text('Demande approuvée', style: KlinikTypography.heading()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${request.nom} rejoint votre entité comme ${role.label}.',
              style: KlinikTypography.body(),
            ),
            const SizedBox(height: KlinikSpacing.md),
            Center(
              child: SelectableText(
                code,
                style: KlinikTypography.bigNumber(24, KlinikColors.accent),
              ),
            ),
            const SizedBox(height: KlinikSpacing.md),
            Text(
              'Communiquez ce code en personne au candidat. Valable 24 heures — '
              'ré-approuvez la demande pour générer un nouveau code si besoin.',
              style: KlinikTypography.caption(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Compris',
              style: KlinikTypography.captionStrong(color: KlinikColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(currentSessionProvider);

    return Scaffold(
      backgroundColor: KlinikColors.backgroundLight,
      appBar: AppBar(
        title: Text('Demandes d\'adhésion', style: KlinikTypography.appBarTitle()),
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
          if (session == null || session.role != UserRole.admin) {
            return Center(
              child: Text(
                'Réservé à l\'administrateur de l\'entité.',
                style: KlinikTypography.body(),
              ),
            );
          }
          final requestsAsync = ref.watch(pendingRequestsProvider(session.entityId));
          return requestsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Text(
                'Lecture des demandes impossible. Vérifiez votre connexion.',
                style: KlinikTypography.body(),
              ),
            ),
            data: (requests) {
              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.inbox,
                          size: 34, color: KlinikColors.textTertiary),
                      const SizedBox(height: KlinikSpacing.md),
                      Text('Aucune demande en attente.',
                          style: KlinikTypography.body()),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(KlinikSpacing.screenPaddingH),
                itemCount: requests.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: KlinikSpacing.listItemGap),
                itemBuilder: (context, index) =>
                    _buildRequestCard(requests[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(PendingUser request) {
    final role = _roles[request.uid] ?? UserRole.agent;
    return KlinikCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(request.nom, style: KlinikTypography.bodyStrong()),
          const SizedBox(height: KlinikSpacing.xs),
          Text(request.grade, style: KlinikTypography.caption()),
          const SizedBox(height: KlinikSpacing.sm),
          Row(
            children: [
              const Icon(LucideIcons.mail, size: 14, color: KlinikColors.textTertiary),
              const SizedBox(width: KlinikSpacing.sm),
              Expanded(child: Text(request.email, style: KlinikTypography.caption())),
            ],
          ),
          const SizedBox(height: KlinikSpacing.xs),
          Row(
            children: [
              const Icon(LucideIcons.phone, size: 14, color: KlinikColors.textTertiary),
              const SizedBox(width: KlinikSpacing.sm),
              Text(request.phone, style: KlinikTypography.caption()),
            ],
          ),
          const SizedBox(height: KlinikSpacing.md),
          Text('Rôle système attribué', style: KlinikTypography.captionStrong()),
          const SizedBox(height: KlinikSpacing.sm),
          Wrap(
            spacing: KlinikSpacing.sm,
            runSpacing: KlinikSpacing.sm,
            children: [
              for (final r in UserRole.values)
                KlinikButtonSmall(
                  label: r.label,
                  selected: role == r,
                  onPressed: () => setState(() => _roles[request.uid] = r),
                ),
            ],
          ),
          const SizedBox(height: KlinikSpacing.md),
          KlinikButton(
            label: 'Approuver',
            icon: LucideIcons.check,
            isLoading: _approvingUid == request.uid,
            onPressed: _approvingUid == null ? () => _approve(request) : null,
          ),
        ],
      ),
    );
  }
}
