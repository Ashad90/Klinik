import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/models/app_user.dart';
import '../../../shared/models/pending_user.dart';
import '../../../shared/models/user_role.dart';

/// Flux « Rejoindre une entité » (Jour 4).
///
/// - Demande candidat : session **anonyme** Firebase (uid stable, devient le uid
///   définitif après liaison email/mot de passe à l'activation).
/// - Approbation admin : code d'accès généré **côté client** (pas de Cloud
///   Function tant que Blaze n'est pas actif) et communiqué en personne.
/// - Activation : vérification du code (lecture de sa propre demande), puis
///   `linkWithCredential` convertit la session anonyme en compte email.
class JoinRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  const JoinRepository(this._db, this._auth);

  /// Alphabet du code d'accès — sans caractères ambigus (0, O, 1, I, L).
  static const String _codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  CollectionReference<Map<String, dynamic>> _pending(String entityId) =>
      _db.collection('entities').doc(entityId).collection('pendingUsers');

  /// Session du candidat : réutilise l'utilisateur courant s'il existe, sinon
  /// connexion anonyme. Appelée AVANT la recherche d'entités (les règles
  /// exigent un utilisateur authentifié) puis à la soumission. Exige le réseau
  /// la première fois — attendu (comme la création de compte, c'est une
  /// « première connexion »).
  Future<User> ensureCandidateSession() async {
    final current = _auth.currentUser;
    if (current != null) return current;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  /// Étape 1 — crée la demande `/entities/{id}/pendingUsers/{uid}`
  /// (statut `pending_approval`). Renvoie le uid candidat.
  Future<String> createJoinRequest({
    required String entityId,
    required String nom,
    required String email,
    required String phone,
    required String grade,
  }) async {
    final user = await ensureCandidateSession();
    await _pending(entityId).doc(user.uid).set({
      'nom': nom.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'grade': grade.trim(),
      'status': PendingUser.statusPending,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return user.uid;
  }

  /// Étape 2 (admin) — demandes en attente de l'entité, temps réel.
  Stream<List<PendingUser>> watchPendingRequests(String entityId) {
    return _pending(entityId)
        .where('status', isEqualTo: PendingUser.statusPending)
        .snapshots()
        .map((snap) => [
              for (final d in snap.docs) PendingUser.fromMap(entityId, d.id, d.data()),
            ]);
  }

  /// Étape 2 (admin) — approuve la demande : crée le membre
  /// `/entities/{id}/users/{uid}` + stocke le code d'accès dans la demande,
  /// en une écriture atomique (offline-first). Renvoie le code à communiquer
  /// EN PERSONNE au candidat (email/FCM = Option A, Blaze). Ré-approuver une
  /// demande régénère un code (cas du code expiré).
  Future<String> approveRequest({
    required PendingUser request,
    required UserRole role,
    required String approvedBy,
  }) async {
    final code = generateAccessCode();
    final member = AppUser(
      uid: request.uid,
      entityId: request.entityId,
      role: role,
      nom: request.nom,
      email: request.email,
      phone: request.phone,
    );

    final batch = _db.batch();
    batch.set(
      _db
          .collection('entities')
          .doc(request.entityId)
          .collection('users')
          .doc(request.uid),
      member.toMap(),
    );
    batch.update(_pending(request.entityId).doc(request.uid), {
      'status': PendingUser.statusApproved,
      'assignedRole': role.firestore,
      'accessCode': code,
      'codeExpiresAt':
          Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
      'approvedBy': approvedBy,
      'approvedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return code;
  }

  /// Code 6 caractères alphanumériques sans 0/O/1/I/L (décision 30/05/2026 —
  /// 31^6 ≈ 887 millions de combinaisons sur cet alphabet).
  String generateAccessCode() {
    final rnd = Random.secure();
    return String.fromCharCodes(List.generate(
      6,
      (_) => _codeAlphabet.codeUnitAt(rnd.nextInt(_codeAlphabet.length)),
    ));
  }

  /// Étape 3 — lit la demande du candidat courant (sa propre demande).
  Future<PendingUser?> getOwnRequest(String entityId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final snap = await _pending(entityId).doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return PendingUser.fromMap(entityId, uid, data);
  }

  /// Étape 3 — convertit la session anonyme en compte définitif (email + mot
  /// de passe). Le uid est conservé : le doc membre créé à l'approbation reste
  /// valide. Exige le réseau — attendu (création de compte).
  Future<User> linkEmailPassword({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Aucune session candidate sur cet appareil.');
    }
    final cred = await user.linkWithCredential(
      EmailAuthProvider.credential(email: email.trim(), password: password),
    );
    return cred.user!;
  }
}
