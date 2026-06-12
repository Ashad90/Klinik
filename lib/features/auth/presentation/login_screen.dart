import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/klinik_colors.dart';
import '../../../core/theme/klinik_spacing.dart';
import '../../../core/theme/klinik_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/klinik_button.dart';
import '../../../shared/widgets/klinik_text_field.dart';
import '../application/auth_controller.dart';

/// Écran de connexion — DESIGN.md §9.4.
///
/// KMark + wordmark, email + mot de passe, connexion Firebase Auth.
/// Tunnel d'authentification : pas d'AppBar ni d'indicateur réseau (net:false).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pré-remplit l'email après une création de compte (parcours création → login).
    final created = ref.read(justCreatedEmailProvider);
    if (created != null) {
      _email.text = created;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé. Connectez-vous pour continuer.'),
          ),
        );
        ref.read(justCreatedEmailProvider.notifier).state = null;
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);
    if (success && mounted) context.go(RouteNames.home);
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
                const SizedBox(height: KlinikSpacing.xl),
                Center(
                  child: SvgPicture.asset(
                    'assets/logos/klinik-mark.svg',
                    width: 56,
                    height: 56,
                  ),
                ),
                const SizedBox(height: KlinikSpacing.md),
                Center(
                  child: Text(
                    'Klinik',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: KlinikTypography.weightExtraBold,
                      color: KlinikColors.textPrimary,
                      letterSpacing: 30 * -0.03,
                    ),
                  ),
                ),
                const SizedBox(height: KlinikSpacing.xs),
                Center(
                  child: Text(
                    'Connectez-vous à votre compte',
                    style: KlinikTypography.body(),
                  ),
                ),
                const SizedBox(height: KlinikSpacing.xl),
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
                  label: 'Mot de passe',
                  controller: _password,
                  validator: (v) =>
                      Validators.requiredField(v, champ: 'Le mot de passe'),
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  icon: LucideIcons.lock,
                ),
                const SizedBox(height: KlinikSpacing.lg),
                KlinikButton(
                  label: 'Se connecter',
                  icon: LucideIcons.logIn,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submit,
                ),
                const SizedBox(height: KlinikSpacing.md),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.push(RouteNames.createEntity),
                  child: Text(
                    'Pas encore de compte ? Créer un compte',
                    style: KlinikTypography.captionStrong(
                      color: KlinikColors.accent,
                    ),
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
