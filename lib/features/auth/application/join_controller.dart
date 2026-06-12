import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pending_user.dart';
import '../../../shared/models/public_entity.dart';
import '../../../shared/models/user_role.dart';
import '../data/session_store.dart';
import 'auth_controller.dart';
import 'auth_providers.dart';

/// Orchestration du flux « Rejoindre une entité » (Jour 4) : demande candidat,
/// approbation admin, activation par code.
///
/// Pas de codegen Riverpod (convention du projet) — `AsyncNotifierProvider`
/// déclaré à la main, même contrat que `authControllerProvider` (les écrans
/// lisent `isLoading` et mappent l'erreur via `authErrorMessage`).
final joinControllerProvider =
    AsyncNotifierProvider<JoinController, void>(JoinController.new);

/// Résultats de recherche d'entités (étape 1) pour la requête saisie.
/// En dessous de 2 caractères, pas de requête Firestore.
final entitySearchProvider = FutureProvider.autoDispose
    .family<List<PublicEntity>, String>((ref, query) async {
  if (query.trim().length < 2) return const [];
  // Les règles exigent un utilisateur authentifié pour lire l'annuaire public :
  // la session (anonyme) du candidat est amorcée dès la première recherche.
  await ref.watch(joinRepositoryProvider).ensureCandidateSession();
  return ref.watch(entityRepositoryProvider).searchEntities(query);
});

/// Demandes en attente d'une entité (écran approbation admin), temps réel.
final pendingRequestsProvider = StreamProvider.autoDispose
    .family<List<PendingUser>, String>(
  (ref, entityId) => ref.watch(joinRepositoryProvider).watchPendingRequests(entityId),
);

class JoinController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Étape 1 — soumet la demande (session anonyme) et mémorise l'entité visée
  /// sur l'appareil (nécessaire à l'activation). Renvoie `true` si envoyée.
  Future<bool> submitRequest({
    required PublicEntity entity,
    required String nom,
    required String email,
    required String phone,
    required String grade,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(joinRepositoryProvider).createJoinRequest(
            entityId: entity.id,
            nom: nom,
            email: email,
            phone: phone,
            grade: grade,
          );
      await ref
          .read(pendingJoinStoreProvider)
          .save(entityId: entity.id, entityName: entity.name);
    });
    return !state.hasError;
  }

  /// Étape 2 (admin) — approuve une demande avec le rôle choisi. Renvoie le
  /// code d'accès généré (à communiquer EN PERSONNE — email/FCM = Blaze),
  /// ou `null` en cas d'échec.
  Future<String?> approve({
    required PendingUser request,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    String? code;
    state = await AsyncValue.guard(() async {
      final session = await ref.read(sessionStoreProvider).read();
      if (session == null) {
        throw const AuthFailure('Session administrateur introuvable.');
      }
      code = await ref.read(joinRepositoryProvider).approveRequest(
            request: request,
            role: role,
            approvedBy: session.uid,
          );
    });
    return state.hasError ? null : code;
  }

  /// Étape 3 — vérifie le code, convertit la session anonyme en compte email
  /// (le uid est conservé), amorce la session locale puis nettoie la demande
  /// mémorisée. Renvoie `true` si le compte est activé.
  Future<bool> activate({required String code, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final store = ref.read(pendingJoinStoreProvider);
      final entityId = store.entityId;
      if (entityId == null) {
        throw const AuthFailure(
          'Aucune demande trouvée sur cet appareil. L\'activation se fait sur '
          'l\'appareil qui a envoyé la demande.',
        );
      }

      final joinRepo = ref.read(joinRepositoryProvider);
      final request = await joinRepo.getOwnRequest(entityId);
      if (request == null) {
        throw const AuthFailure('Demande introuvable. Envoyez une nouvelle demande.');
      }
      if (request.status != PendingUser.statusApproved) {
        throw const AuthFailure(
          'Votre demande n\'a pas encore été approuvée par l\'administrateur.',
        );
      }
      if (request.accessCode != code.trim().toUpperCase()) {
        throw const AuthFailure('Code incorrect. Vérifiez auprès de votre administrateur.');
      }
      final expiry = request.codeExpiresAt;
      if (expiry != null && DateTime.now().isAfter(expiry)) {
        throw const AuthFailure(
          'Code expiré. Demandez à votre administrateur de ré-approuver votre demande.',
        );
      }

      final user = await joinRepo.linkEmailPassword(
        email: request.email,
        password: password,
      );
      await ref.read(sessionStoreProvider).save(AuthSession(
            uid: user.uid,
            entityId: entityId,
            role: request.assignedRole ?? UserRole.agent,
          ));
      await store.clear();
    });
    if (!state.hasError) ref.invalidate(currentSessionProvider);
    return !state.hasError;
  }
}
