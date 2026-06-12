import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/klinik_colors.dart';
import '../../../core/theme/klinik_radius.dart';
import '../../../core/theme/klinik_spacing.dart';
import '../../../core/theme/klinik_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/entity_type.dart';
import '../../../shared/widgets/klinik_button.dart';
import '../../../shared/widgets/klinik_text_field.dart';
import '../application/auth_controller.dart';

/// Création d'une entité — DESIGN.md §9.3 (flux « Créer une entité »).
///
/// Deux étapes dans un PageView : (1) informations de l'entité + logo optionnel,
/// (2) compte administrateur. Soumission → entité + admin créés, session amorcée.
/// Tunnel d'authentification : pas d'AppBar Material ni d'indicateur réseau.
class CreateEntityScreen extends ConsumerStatefulWidget {
  const CreateEntityScreen({super.key});

  @override
  ConsumerState<CreateEntityScreen> createState() => _CreateEntityScreenState();
}

class _CreateEntityScreenState extends ConsumerState<CreateEntityScreen> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  // Étape 1 — entité
  EntityType? _type;
  final _entityName = TextEditingController();
  final _country = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  File? _logo;

  // Étape 2 — compte admin
  final _adminNom = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  int _step = 0;

  @override
  void dispose() {
    _entityName.dispose();
    _country.dispose();
    _city.dispose();
    _address.dispose();
    _adminNom.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (picked != null) setState(() => _logo = File(picked.path));
    } catch (_) {
      // Sélecteur indisponible — le logo est optionnel, on ignore silencieusement.
    }
  }

  void _next() {
    if (_type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez le type d\'entité.')),
      );
      return;
    }
    if (!_step1Key.currentState!.validate()) return;
    setState(() => _step = 1);
  }

  void _back() {
    if (_step == 1) {
      setState(() => _step = 0);
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    if (!_step2Key.currentState!.validate()) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .createEntity(
          type: _type!,
          entityName: _entityName.text,
          country: _country.text,
          city: _city.text,
          address: _address.text,
          logoFile: _logo,
          adminNom: _adminNom.text,
          email: _email.text,
          phone: _phone.text,
          password: _password.text,
        );
    if (success && mounted) context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    ref.listen(authControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authErrorMessage(next.error!))));
      }
    });

    return Scaffold(
      backgroundColor: KlinikColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _Header(step: _step, onBack: isLoading ? null : _back),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: KlinikSpacing.screenPaddingH,
                ),
                child: _step == 0 ? _buildStep1() : _buildStep2(),
              ),
            ),
            _Footer(
              step: _step,
              isLoading: isLoading,
              onNext: _next,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Type d\'entité', style: KlinikTypography.bodyStrong()),
          const SizedBox(height: KlinikSpacing.sm),
          Wrap(
            spacing: KlinikSpacing.sm,
            runSpacing: KlinikSpacing.sm,
            children: [
              for (final type in EntityType.values)
                _TypeTile(
                  type: type,
                  selected: _type == type,
                  onTap: () => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: KlinikSpacing.lg),
          KlinikTextField(
            label: 'Nom de l\'entité',
            controller: _entityName,
            validator: (v) => Validators.requiredField(v, champ: 'Le nom'),
            textInputAction: TextInputAction.next,
            icon: LucideIcons.building,
          ),
          const SizedBox(height: KlinikSpacing.formFieldGap),
          KlinikTextField(
            label: 'Pays',
            controller: _country,
            validator: (v) => Validators.requiredField(v, champ: 'Le pays'),
            textInputAction: TextInputAction.next,
            icon: LucideIcons.globe,
          ),
          const SizedBox(height: KlinikSpacing.formFieldGap),
          KlinikTextField(
            label: 'Ville',
            controller: _city,
            validator: (v) => Validators.requiredField(v, champ: 'La ville'),
            textInputAction: TextInputAction.next,
            icon: LucideIcons.mapPin,
          ),
          const SizedBox(height: KlinikSpacing.formFieldGap),
          KlinikTextField(
            label: 'Adresse',
            controller: _address,
            validator: (v) => Validators.requiredField(v, champ: 'L\'adresse'),
            textInputAction: TextInputAction.done,
            icon: LucideIcons.map,
          ),
          const SizedBox(height: KlinikSpacing.lg),
          _LogoPicker(logo: _logo, onTap: _pickLogo),
          const SizedBox(height: KlinikSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Compte administrateur', style: KlinikTypography.bodyStrong()),
          const SizedBox(height: KlinikSpacing.sm),
          Text(
            'Vous serez l\'administrateur de cette entité.',
            style: KlinikTypography.caption(),
          ),
          const SizedBox(height: KlinikSpacing.lg),
          KlinikTextField(
            label: 'Nom complet',
            controller: _adminNom,
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
            label: 'Mot de passe',
            controller: _password,
            validator: Validators.password,
            obscure: true,
            textInputAction: TextInputAction.done,
            icon: LucideIcons.lock,
          ),
          const SizedBox(height: KlinikSpacing.lg),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int step;
  final VoidCallback? onBack;

  const _Header({required this.step, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KlinikSpacing.sm,
        KlinikSpacing.sm,
        KlinikSpacing.screenPaddingH,
        KlinikSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              LucideIcons.chevronLeft,
              color: KlinikColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              'Créer une entité',
              style: KlinikTypography.appBarTitle(),
            ),
          ),
          Text('Étape ${step + 1} sur 2', style: KlinikTypography.caption()),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final int step;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _Footer({
    required this.step,
    required this.isLoading,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KlinikSpacing.screenPaddingH,
        KlinikSpacing.footerPadding,
        KlinikSpacing.screenPaddingH,
        KlinikSpacing.md,
      ),
      child: step == 0
          ? KlinikButton(
              label: 'Suivant',
              icon: LucideIcons.arrowRight,
              onPressed: onNext,
            )
          : KlinikButton(
              label: 'Créer l\'entité',
              icon: LucideIcons.check,
              isLoading: isLoading,
              onPressed: isLoading ? null : onSubmit,
            ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final EntityType type;
  final bool selected;
  final VoidCallback onTap;

  const _TypeTile({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? KlinikColors.accent : KlinikColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? KlinikColors.surfaceAccentSoft
              : KlinikColors.surfaceVariant,
          borderRadius: BorderRadius.circular(KlinikRadius.btn),
          border: Border.all(
            color: selected ? KlinikColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 18, color: color),
            const SizedBox(width: KlinikSpacing.sm),
            Text(
              type.label,
              style: KlinikTypography.captionStrong(
                color: color,
              ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoPicker extends StatelessWidget {
  final File? logo;
  final VoidCallback onTap;

  const _LogoPicker({required this.logo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: KlinikColors.surfaceVariant,
          borderRadius: BorderRadius.circular(KlinikRadius.btn),
          border: Border.all(color: KlinikColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            if (logo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(KlinikRadius.iconTileSm),
                child: Image.file(
                  logo!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(
                LucideIcons.imagePlus,
                size: 22,
                color: KlinikColors.textTertiary,
              ),
            const SizedBox(width: KlinikSpacing.md),
            Expanded(
              child: Text(
                logo != null
                    ? 'Logo sélectionné · toucher pour changer'
                    : 'Ajouter un logo (optionnel)',
                style: KlinikTypography.captionStrong(
                  color: KlinikColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
