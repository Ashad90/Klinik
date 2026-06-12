import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/app_user.dart';
import '../../../shared/models/entity.dart';
import '../../../shared/models/public_entity.dart';

/// Accès Firestore aux entités et à leurs utilisateurs.
/// Toujours scoppé par `entityId` (isolation multi-entités — règle absolue).
class EntityRepository {
  final FirebaseFirestore _db;
  const EntityRepository(this._db);

  /// Identifiant d'entité généré localement (pas d'aller-retour réseau).
  String newEntityId() => _db.collection('entities').doc().id;

  /// Lit une entité par son id. Offline-first : Firestore sert le cache local
  /// quand l'appareil est hors ligne. Renvoie `null` si introuvable.
  Future<Entity?> getEntity(String entityId) async {
    final snap = await _db.collection('entities').doc(entityId).get();
    final data = snap.data();
    if (data == null) return null;
    return Entity.fromMap(snap.id, data);
  }

  /// Crée l'entité + le document utilisateur admin + la fiche publique
  /// (annuaire de recherche `/publicEntities`) en une écriture atomique.
  ///
  /// Offline-first : si l'appareil est hors ligne, le batch est mis en file par
  /// Firestore et `commit()` se résout dès l'écriture dans le cache local.
  Future<void> createEntityWithAdmin({
    required Entity entity,
    required AppUser admin,
  }) async {
    final entityRef = _db.collection('entities').doc(entity.id);
    final userRef = entityRef.collection('users').doc(admin.uid);
    final publicRef = _db.collection('publicEntities').doc(entity.id);

    final batch = _db.batch();
    batch.set(entityRef, entity.toMap());
    batch.set(userRef, admin.toMap());
    batch.set(
      publicRef,
      PublicEntity(
        id: entity.id,
        name: entity.name,
        city: entity.city,
        type: entity.type,
      ).toMap(),
    );
    await batch.commit();
  }

  /// Recherche d'entités par préfixe de nom (insensible à la casse) dans
  /// l'annuaire public `/publicEntities` — lisible par tout utilisateur
  /// authentifié, y compris la session anonyme d'un candidat (Jour 4).
  Future<List<PublicEntity>> searchEntities(String query, {int limit = 10}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final snap = await _db
        .collection('publicEntities')
        .orderBy('nameLower')
        .startAt([q])
        .endAt(['$q\uf8ff'])
        .limit(limit)
        .get();
    return [for (final d in snap.docs) PublicEntity.fromMap(d.id, d.data())];
  }
}
