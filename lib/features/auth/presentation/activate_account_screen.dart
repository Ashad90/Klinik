import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/klinik_colors.dart';
import '../../../core/theme/klinik_radius.dart';
import '../../../core/theme/klinik_spacing.dart';
import '../../../core/theme/klinik_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/klinik_button.dart';
import '../../../shared/widgets/klinik_text_field.dart';
import '../application/auth_controller.dart';
import '../application/join_controller.dart';

/// Activer mon compte — DESIGN.md §9.3 (Activate + SetPassword), Jour 4 étape 3.
///
/// L'agent saisit le code d'accès 6 caractères reçu de l'admin (communiqué en
/// personne — email/FCM = Option A, Blaze), puis définit son mot de passe.
/// La vérification lit sa propre demande `/pendingUsers/{uid}` (code, statut,
/// expiration), puis `linkWithCredential` convertit la session anonyme en
/// compte email — même appareil que la demande (limitation MVP).
class ActivateAccountScreen extends ConsumerStatefulWidget {
  const ActivateAccountScreen({super.key});

  @override
  ConsumerState<ActivateAccountScreen> createState() => _ActivateAccountScreenState();
}

class _ActivateAccountScreenState extends ConsumerState<ActivateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(joinControllerProvider.notifier).activate(
          code: _code.text,
          password: _password.text,
        );
    if (!mounted) return;
    if (ok) {
      context.go(RouteNames.home);
    } else {
      final error = ref.read(joinControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
      );
    }
  }

  String? _validateCode(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Le code est requis.';
    if (value.length != 6) return 'Le code comporte 6 caractères.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlinikColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: KlinikSpacing.screenPaddingH,
            vertical: KlinikSpacing.xl,
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
                const SizedBox(height: KlinikSpacing.md),
                Text('Activer mon compte', style: KlinikTypography.display()),
                const SizedBox(height: KlinikSpacing.sm),
                Text(
                  'Saisissez le code d\'accès à 6 caractères communiqué par votre administrateur, '
                  'puis choisissez votre mot de passe.',
                  style: KlinikTypography.body(),
                ),
                const SizedBox(height: KlinikSpacing.xl),
                TextFormField(
                  controller: _code,
                  validator: _validateCode,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                    _UpperCaseFormatter(),
                  ],
                  style: KlinikTypography.bigNumber(24, KlinikColors.textPrimary),
                  cursorColor: KlinikColors.accent,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'K7X2M9',
                    filled: true,
                    fillColor: KlinikColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KlinikRadius.btn),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KlinikRadius.btn),
                      borderSide: const BorderSide(color: KlinikColors.accent, width: 1.5),
                    ),
                  ),
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
                KlinikButton(
                  label: 'Activer mon compte',
                  icon: LucideIcons.check,
                  isLoading: ref.watch(joinControllerProvider).isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: KlinikSpacing.md),
                TextButton(
                  onPressed: () => context.go(RouteNames.authChoice),
                  child: Text(
                    'Retour à l\'accueil',
                    style: KlinikTypography.captionStrong(color: KlinikColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Force la saisie en majuscules (codes d'accès insensibles à la casse).
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
