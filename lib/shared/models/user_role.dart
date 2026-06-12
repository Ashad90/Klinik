/// Rôle système d'un utilisateur — assigné par l'admin uniquement.
///
/// Source : klinik-firebase-rules (enum agent|medecin|admin). Le créateur d'une
/// entité est toujours `admin`. Les valeurs `firestore` sont immuables (clé de
/// sécurité des règles Firestore).
enum UserRole {
  agent('agent', 'Agent de santé'),
  medecin('medecin', 'Médecin'),
  admin('admin', 'Administrateur');

  const UserRole(this.firestore, this.label);

  final String firestore;
  final String label;

  static UserRole fromFirestore(String value) => UserRole.values.firstWhere(
        (r) => r.firestore == value,
        orElse: () => UserRole.agent,
      );
}
