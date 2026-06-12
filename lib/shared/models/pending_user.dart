import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

/// Demande d'adhésion — document `/entities/{entityId}/pendingUsers/{uid}`.
///
/// `uid` = session (anonyme) du candidat, qui devient le uid définitif après
/// liaison email/mot de passe à l'activation. Champs : klinik-firebase-rules.
class PendingUser {
  static const String statusPending = 'pending_approval';
  static const String statusApproved = 'approved';

  final String uid;
  final String entityId;
  final String nom;
  final String email;
  final String phone;
  final String grade;
  final String status;
  final UserRole? assignedRole; // posé par l'admin à l'approbation
  final String? accessCode; // 6 caractères, sans 0/O/1/I/L
  final DateTime? codeExpiresAt; // 24h après l'approbation

  const PendingUser({
    required this.uid,
    required this.entityId,
    required this.nom,
    required this.email,
    required this.phone,
    required this.grade,
    this.status = statusPending,
    this.assignedRole,
    this.accessCode,
    this.codeExpiresAt,
  });

  factory PendingUser.fromMap(String entityId, String uid, Map<String, dynamic> map) {
    final role = map['assignedRole'] as String?;
    return PendingUser(
      uid: uid,
      entityId: entityId,
      nom: (map['nom'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      grade: (map['grade'] ?? '') as String,
      status: (map['status'] ?? statusPending) as String,
      assignedRole: role == null ? null : UserRole.fromFirestore(role),
      accessCode: map['accessCode'] as String?,
      codeExpiresAt: (map['codeExpiresAt'] as Timestamp?)?.toDate(),
    );
  }
}
