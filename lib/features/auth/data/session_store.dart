import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../shared/models/user_role.dart';

/// Session locale amorcée après création/connexion : `uid`, `entityId`, `role`.
///
/// Stockée dans Flutter Secure Storage (jamais SharedPreferences — règle
/// klinik-firebase-rules). Permet de reconstruire l'état de session sans dépendre
/// des custom claims Firebase (déférés jusqu'à l'activation du plan Blaze).
class AuthSession {
  final String uid;
  final String entityId;
  final UserRole role;

  const AuthSession({
    required this.uid,
    required this.entityId,
    required this.role,
  });
}

class SessionStore {
  final FlutterSecureStorage _storage;
  const SessionStore(this._storage);

  static const String _kUid = 'klinik_uid';
  static const String _kEntityId = 'klinik_entity_id';
  static const String _kRole = 'klinik_role';

  Future<void> save(AuthSession session) async {
    await _storage.write(key: _kUid, value: session.uid);
    await _storage.write(key: _kEntityId, value: session.entityId);
    await _storage.write(key: _kRole, value: session.role.firestore);
  }

  Future<AuthSession?> read() async {
    final uid = await _storage.read(key: _kUid);
    final entityId = await _storage.read(key: _kEntityId);
    final role = await _storage.read(key: _kRole);
    if (uid == null || entityId == null || role == null) return null;
    return AuthSession(
      uid: uid,
      entityId: entityId,
      role: UserRole.fromFirestore(role),
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _kUid);
    await _storage.delete(key: _kEntityId);
    await _storage.delete(key: _kRole);
  }
}
