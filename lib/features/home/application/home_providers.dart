import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/entity.dart';
import '../../auth/application/auth_providers.dart';

/// Entité de la session courante (lecture Firestore, servie depuis le cache
/// local quand hors ligne).
///
/// NOTE (dette d'archi) : réutilise les providers d'infrastructure de
/// `auth/application` (`currentSessionProvider`, `entityRepositoryProvider`).
/// Ils devraient à terme vivre dans `core/` pour éviter l'import inter-feature ;
/// déplacement à discuter (INTERDIT #2 : ne pas restructurer `lib/` sans accord).
final currentEntityProvider = FutureProvider<Entity?>((ref) async {
  final session = await ref.watch(currentSessionProvider.future);
  if (session == null) return null;
  return ref.read(entityRepositoryProvider).getEntity(session.entityId);
});
