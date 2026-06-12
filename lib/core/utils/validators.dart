/// Validateurs de formulaire — purement locaux (offline), messages en français.
///
/// Règles mot de passe : brainstorming.md §2 (8 caractères min, 1 majuscule,
/// 1 chiffre). Utilisés par les formulaires d'authentification (Jour 3+).
class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _upper = RegExp(r'[A-Z]');
  static final RegExp _digit = RegExp(r'[0-9]');

  static String? requiredField(String? value, {String champ = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) return '$champ est requis.';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'email est requis.';
    if (!_email.hasMatch(value.trim())) return 'Adresse email invalide.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis.';
    if (value.length < 8) return 'Au moins 8 caractères.';
    if (!_upper.hasMatch(value)) return 'Au moins une majuscule.';
    if (!_digit.hasMatch(value)) return 'Au moins un chiffre.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le téléphone est requis.';
    final digits = value.replaceAll(RegExp(r'[\s()+-]'), '');
    if (digits.length < 6 || !_digit.hasMatch(digits)) return 'Numéro invalide.';
    return null;
  }
}
