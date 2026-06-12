import 'entity_type.dart';

/// Fiche publique minimale d'une entité — document `/publicEntities/{entityId}`.
///
/// Sert uniquement à la recherche du flux « Rejoindre une entité » (Jour 4).
/// AUCUNE donnée sensible : le document complet `/entities/{id}` reste réservé
/// aux membres. Écrite dans le même batch que la création de l'entité.
/// Champs : klinik-firebase-rules.
class PublicEntity {
  final String id;
  final String name;
  final String city;
  final EntityType type;

  const PublicEntity({
    required this.id,
    required this.name,
    required this.city,
    required this.type,
  });

  factory PublicEntity.fromMap(String id, Map<String, dynamic> map) => PublicEntity(
        id: id,
        name: (map['name'] ?? '') as String,
        city: (map['city'] ?? '') as String,
        type: EntityType.fromFirestore((map['type'] ?? '') as String),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameLower': name.toLowerCase(), // clé de recherche par préfixe
        'city': city,
        'type': type.firestore,
      };
}
