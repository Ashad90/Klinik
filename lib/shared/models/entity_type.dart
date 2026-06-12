import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Type d'entité de santé — brainstorming.md §2 (Option A, Étape 1).
///
/// Les valeurs `firestore` sont immuables. `icon` (lucide) sert au sélecteur
/// de type dans l'écran de création d'entité.
enum EntityType {
  centreSante('centre_sante', 'Centre de santé', LucideIcons.building),
  ong('ong', 'ONG', LucideIcons.users),
  clinique('clinique', 'Clinique', LucideIcons.stethoscope),
  hopital('hopital', 'Hôpital', LucideIcons.heartPulse),
  dispensaire('dispensaire', 'Dispensaire', LucideIcons.plus);

  const EntityType(this.firestore, this.label, this.icon);

  final String firestore;
  final String label;
  final IconData icon;

  static EntityType fromFirestore(String value) => EntityType.values.firstWhere(
        (t) => t.firestore == value,
        orElse: () => EntityType.centreSante,
      );
}
