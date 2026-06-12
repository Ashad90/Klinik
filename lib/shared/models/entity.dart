import 'package:cloud_firestore/cloud_firestore.dart';

import 'entity_type.dart';

/// Entité de santé — document `/entities/{entityId}`.
/// Champs : klinik-firebase-rules. Le plan démarre à `starter`.
class Entity {
  final String id;
  final String name;
  final EntityType type;
  final String country;
  final String city;
  final String address;
  final String? logoUrl;
  final String plan;
  final String status;
  final String createdBy; // uid de l'admin créateur

  const Entity({
    required this.id,
    required this.name,
    required this.type,
    required this.country,
    required this.city,
    required this.address,
    required this.createdBy,
    this.logoUrl,
    this.plan = 'starter',
    this.status = 'active',
  });

  factory Entity.fromMap(String id, Map<String, dynamic> map) => Entity(
        id: id,
        name: (map['name'] ?? '') as String,
        type: EntityType.fromFirestore((map['type'] ?? '') as String),
        country: (map['country'] ?? '') as String,
        city: (map['city'] ?? '') as String,
        address: (map['address'] ?? '') as String,
        logoUrl: map['logoUrl'] as String?,
        plan: (map['plan'] ?? 'starter') as String,
        status: (map['status'] ?? 'active') as String,
        createdBy: (map['createdBy'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type.firestore,
        'country': country,
        'city': city,
        'address': address,
        'logoUrl': logoUrl,
        'plan': plan,
        'status': status,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
