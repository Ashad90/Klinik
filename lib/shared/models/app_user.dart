import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

/// Utilisateur — document `/entities/{entityId}/users/{uid}`.
/// Champs : klinik-firebase-rules.
class AppUser {
  final String uid;
  final String entityId;
  final UserRole role;
  final String nom;
  final String email;
  final String phone;

  const AppUser({
    required this.uid,
    required this.entityId,
    required this.role,
    required this.nom,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'entityId': entityId,
        'role': role.firestore,
        'nom': nom,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
