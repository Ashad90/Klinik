import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/klinik_colors.dart';
import '../../../core/theme/klinik_radius.dart';
import '../../../core/theme/klinik_spacing.dart';
import '../../../core/theme/klinik_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/public_entity.dart';
import '../../../shared/widgets/klinik_button.dart';
import '../../../shared/widgets/klinik_card.dart';
import '../../../shared/widgets/klinik_text_field.dart';
import '../application/auth_controller.dart';
import '../application/join_controller.dart';

/// Rejoindre une entité — DESIGN.md §9.3, Jour 4 étape 1 (demande candidat).
///
/// Le candidat saisit ses informations, recherche son entité dans l'annuaire
/// public `/publicEntities`, puis soumet sa demande : session anonyme Firebase
/// + écriture `/entities/{id}/pendingUsers/{uid}` (statut `pending_approval`).
/// L'entité visée est mémorisée localement pour l'activation (étape 3).
class JoinEntityScreen extends ConsumerStatefulWidget {
  const JoinEntityScreen({super.key});

  @override
  ConsumerState<JoinEntityScreen> createState() => _JoinEntityScreenState();
}

class _JoinEntityScreenState extends ConsumerState<JoinEntityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _grade = TextEditingController();
  final _entity = TextEditingController();

  bool _submitted = false;
  String _query = '';
  PublicEntity? _selected;

  @override
  void dispose() {
    _nom.dispose();
    _email.dispose();
    _phone.dispose();
    _grade.dispose();
    _entity.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(joinControllerProvider.notifier).submitRequest(
          entity: _selected!,
          nom: _nom.text,
          email: _email.text,
          phone: _phone.text,
          grade: _grade.text,
        );
    if (!mounted) return;
    if (ok) {
      setState(() => _submitted = true);
    } else {
      final error = ref.read(joinControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlinikColors.backgroundLight,
      body: SafeArea(
        child: _submitted ? _buildConfirmation() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: KlinikSpacing.screenPaddingH,
        vertical: KlinikSpacing.md,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              onPressed: () => context.pop(),
              icon: const Icon(LucideIcons.chevronLeft, color: KlinikColors.textPrimary),
            ),
            const SizedBox(height: KlinikSpacing.sm),
            Text('Rejoindre une entité', style: KlinikTypography.display()),
            const SizedBox(height: KlinikSpacing.sm),
            Text(
              'Envoyez votre demande à un centre de santé. L\'administrateur vous '
              'communiquera un code d\'accès après approbation.',
              style: KlinikTypography.body(),
            ),
            const SizedBox(height: KlinikSpacing.lg),
            KlinikTextField(
              label: 'Nom complet',
              controller: _nom,
              validator: (v) => Validators.requiredField(v, champ: 'Le nom'),
              textInputAction: TextInputAction.next,
              icon: LucideIcons.user,
            ),
            const SizedBox(height: KlinikSpacing.formFieldGap),
            KlinikTextField(
              label: 'Email',
              controller: _email,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              icon: LucideIcons.mail,
            ),
            const SizedBox(height: KlinikSpacing.formFieldGap),
            KlinikTextField(
              label: 'Téléphone',
              controller: _phone,
              validator: Validators.phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              icon: LucideIcons.phone,
            ),
            const SizedBox(height: KlinikSpacing.formFieldGap),
            KlinikTextField(
              label: 'Grade / fonction',
              controller: _grade,
              validator: (v) => Validators.requiredField(v, champ: 'Le grade'),
              textInputAction: TextInputAction.next,
              icon: LucideIcons.stethoscope,
            ),
            const SizedBox(height: KlinikSpacing.formFieldGap),
            KlinikTextField(
              label: 'Rechercher votre entité (nom)',
              controller: _entity,
              validator: (_) =>
                  _selected == null ? 'Sélectionnez une entité dans la liste.' : null,
              textInputAction: TextInputAction.done,
              icon: LucideIcons.building,
              onChanged: (v) => setState(() {
                _query = v;
                _selected = null;
              }),
            ),
            _buildSearchResults(),
            const SizedBox(height: KlinikSpacing.lg),
            KlinikButton(
              label: 'Envoyer ma demande',
              icon: LucideIcons.send,
              isLoading: ref.watch(joinControllerProvider).isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: KlinikSpacing.md),
          ],
        ),
      ),
    );
  }

  /// Résultats de recherche sous le champ entité : liste tappable, ou rappel
  /// de l'entité sélectionnée. Aucune requête sous 2 caractères.
  Widget _buildSearchResults() {
    final selected = _selected;
    if (selected != null) {
      return Padding(
        padding: const EdgeInsets.only(top: KlinikSpacing.sm),
        child: Row(
          children: [
            const Icon(LucideIcons.check, size: 16, color: KlinikColors.secondary),
            const SizedBox(width: KlinikSpacing.sm),
            Expanded(
              child: Text(
                '${selected.name} — ${selected.city}',
                style: KlinikTypography.captionStrong(color: KlinikColors.secondary),
              ),
            ),
          ],
        ),
      );
    }
    if (_query.trim().length < 2) return const SizedBox.shrink();

    final results = ref.watch(entitySearchProvider(_query));
    return results.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(KlinikSpacing.md),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.only(top: KlinikSpacing.sm),
        child: Text(
          'Recherche impossible. Vérifiez votre connexion.',
          style: KlinikTypography.caption(color: KlinikColors.error),
        ),
      ),
      data: (entities) {
        if (entities.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: KlinikSpacing.sm),
            child: Text('Aucune entité trouvée.', style: KlinikTypography.caption()),
          );
        }
        return Column(
          children: [
            for (final e in entities)
              Padding(
                padding: const EdgeInsets.only(top: KlinikSpacing.sm),
                child: KlinikCard(
                  padding: const EdgeInsets.all(KlinikSpacing.md),
                  showShadow: false,
                  onTap: () => setState(() {
                    _selected = e;
                    _entity.text = e.name;
                    _query = '';
                  }),
                  child: Row(
                    children: [
                      Icon(e.type.icon, size: 19, color: KlinikColors.accent),
                      const SizedBox(width: KlinikSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.name, style: KlinikTypography.bodyStrong()),
                            Text(
                              '${e.type.label} · ${e.city}',
                              style: KlinikTypography.caption(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KlinikSpacing.screenPaddingH),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: KlinikColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(KlinikRadius.sheet),
            ),
            child: const Icon(LucideIcons.clock, size: 34, color: KlinikColors.secondary),
          ),
          const SizedBox(height: KlinikSpacing.lg),
          Text('Demande envoyée', style: KlinikTypography.display(), textAlign: TextAlign.center),
          const SizedBox(height: KlinikSpacing.sm),
          KlinikCard(
            backgroundColor: KlinikColors.surfaceInfoSoft,
            showShadow: false,
            child: Text(
              'Votre demande est en attente d\'approbation. Dès que l\'administrateur '
              'l\'aura validée, il vous communiquera un code d\'accès pour activer '
              'votre compte.',
              style: KlinikTypography.body(),
            ),
          ),
          const Spacer(),
          KlinikButton(
            label: 'J\'ai reçu mon code · Activer',
            icon: LucideIcons.keyRound,
            onPressed: () => context.go(RouteNames.activate),
          ),
          const SizedBox(height: KlinikSpacing.sm),
          KlinikButton.ghost(
            label: 'Retour à l\'accueil',
            onPressed: () => context.go(RouteNames.authChoice),
          ),
          const SizedBox(height: KlinikSpacing.lg),
        ],
      ),
    );
  }
}
