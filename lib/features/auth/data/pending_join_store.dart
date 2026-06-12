import 'package:hive_flutter/hive_flutter.dart';

/// Mémorise localement la demande d'adhésion en cours sur l'appareil du
/// candidat : l'activation (étape 3) doit retrouver l'entité visée.
///
/// Hive (données non sensibles — pas de token). La box `klinik_prefs` est
/// ouverte au démarrage dans `main.dart`. L'activation se fait sur le MÊME
/// appareil que la demande (session anonyme) — limitation MVP documentée.
class PendingJoinStore {
  static const String boxName = 'klinik_prefs';
  static const String _kEntityId = 'pendingJoinEntityId';
  static const String _kEntityName = 'pendingJoinEntityName';

  final Box _box;
  const PendingJoinStore(this._box);

  Future<void> save({required String entityId, required String entityName}) async {
    await _box.put(_kEntityId, entityId);
    await _box.put(_kEntityName, entityName);
  }

  String? get entityId => _box.get(_kEntityId) as String?;
  String? get entityName => _box.get(_kEntityName) as String?;

  Future<void> clear() async {
    await _box.delete(_kEntityId);
    await _box.delete(_kEntityName);
  }
}
