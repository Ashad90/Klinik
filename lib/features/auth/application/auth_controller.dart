import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/app_user.dart';
import '../../../shared/models/entity.dart';
import '../../../shared/models/entity_type.dart';
import '../../../shared/models/user_role.dart';
import '../data/session_store.dart';
import 'auth_providers.dart';

/// Orchestration des flux d'authentification (Jour 3) : connexion et création
/// d'une entité avec son compte admin.
///
/// Pas de codegen Riverpod (convention du projet) — `AsyncNotifierProvider`
/// déclaré à la main. L'état porte le `loading`/`error` ; les écrans lisent
/// `isLoading` pour le spinner et écoutent l'erreur via `ref.listen`.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

/// Email du compte qui vient d'être créé — pré-rempli sur l'écran de connexion
/// après la création d'une entité. Remis à `null` une fois consommé.
final justCreatedEmailProvider = StateProvider<String?>((ref) => null);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Connexion email/mot de passe. La session locale (entityId/role) doit déjà
  /// exister sur cet appareil — amorcée lors de la création de l'entité. La
  /// connexion multi-appareils (récupération de l'entité distante) relève du
  /// Jour 4+. Renvoie `true` si la connexion a réussi.
  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);

      final session = await ref.read(sessionStoreProvider).read();
      // La session locale doit appartenir au compte qui se connecte — sinon on
      // réutiliserait l'entité/rôle d'un AUTRE utilisateur de cet appareil.
      if (session == null || session.uid != user.uid) {
        throw const AuthFailure(
          'Aucune session sur cet appareil. La connexion multi-appareils arrive prochainement.',
        );
      }
    });
    if (!state.hasError) ref.invalidate(currentSessionProvider);
    return !state.hasError;
  }

  /// Crée le compte admin Firebase Auth, puis l'entité + son document
  /// utilisateur admin en une écriture atomique, et amorce la session locale.
  ///
  /// La création de compte exige le réseau (première connexion) — c'est attendu.
  /// L'upload du logo et l'email de vérification sont best-effort : ils
  /// n'invalident jamais la création. Renvoie `true` si l'entité a été créée.
  Future<bool> createEntity({
    required EntityType type,
    required String entityName,
    required String country,
    required String city,
    required String address,
    required File? logoFile,
    required String adminNom,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final entityRepo = ref.read(entityRepositoryProvider);
      final sessionStore = ref.read(sessionStoreProvider);
      final cloudinary = ref.read(cloudinaryServiceProvider);

      final user = await authRepo.signUp(email: email, password: password);

      String? logoUrl;
      if (logoFile != null) {
        logoUrl = await cloudinary.uploadImage(logoFile, folder: 'entities/logos');
      }

      final entityId = entityRepo.newEntityId();
      final entity = Entity(
        id: entityId,
        name: entityName.trim(),
        type: type,
        country: country.trim(),
        city: city.trim(),
        address: address.trim(),
        logoUrl: logoUrl,
        createdBy: user.uid,
      );
      final admin = AppUser(
        uid: user.uid,
        entityId: entityId,
        role: UserRole.admin,
        nom: adminNom.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );

      // Écriture atomique — offline-first (Firestore met en file si hors ligne).
      await entityRepo.createEntityWithAdmin(entity: entity, admin: admin);

      // Session locale : reconstruit l'état sans dépendre des custom claims.
      await sessionStore.save(
        AuthSession(uid: user.uid, entityId: entityId, role: UserRole.admin),
      );

      // Email de vérification — best-effort, ne bloque jamais la création.
      try {
        await authRepo.sendEmailVerification();
      } catch (_) {}
    });
    if (!state.hasError) {
      // Parcours voulu : compte créé → page de connexion → accueil. On déconnecte
      // pour que la connexion soit un vrai test des identifiants ; la session
      // locale (entityId/role) est conservée pour permettre cette connexion.
      ref.read(justCreatedEmailProvider.notifier).state = email.trim();
      try {
        await ref.read(authRepositoryProvider).signOut();
      } catch (_) {}
    }
    return !state.hasError;
  }

  /// Déconnexion complète : Firebase Auth + effacement de la session locale.
  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {}
    await ref.read(sessionStoreProvider).clear();
    ref.invalidate(currentSessionProvider);
  }
}

/// Erreur métier d'authentification avec message déjà localisé.
class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);
}

/// Traduit une erreur d'authentification en message français présentable.
String authErrorMessage(Object error) {
  if (error is AuthFailure) return error.message;
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'network-request-failed':
        return 'Connexion requise pour cette action. Vérifiez votre réseau.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      default:
        return 'Erreur d\'authentification (${error.code}).';
    }
  }
  return 'Une erreur est survenue. Réessayez.';
}
