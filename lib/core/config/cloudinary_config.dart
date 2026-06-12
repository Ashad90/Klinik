/// Configuration Cloudinary (upload non signé depuis le client).
///
/// À RENSEIGNER avant d'utiliser l'upload de médias :
///   Dashboard Cloudinary → Settings → Upload → "Upload presets"
///   → créer un preset NON SIGNÉ (unsigned) → copier son nom ici.
///   `cloudName` = le nom de cloud affiché en haut du dashboard.
///
/// Le cloud name et un preset non signé sont des valeurs publiques (conçues
/// pour un usage côté client) — pas de secret ici. Peuvent aussi être injectés
/// au build via --dart-define=CLOUDINARY_CLOUD_NAME=... / _UPLOAD_PRESET=...
class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '', // ← coller le cloud name ici si pas via --dart-define
  );

  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: '', // ← coller le nom du preset non signé ici
  );

  static bool get isConfigured =>
      cloudName.isNotEmpty && uploadPreset.isNotEmpty;
}
