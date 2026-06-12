import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/services/cloudinary_service.dart';
import '../data/auth_repository.dart';
import '../data/entity_repository.dart';
import '../data/join_repository.dart';
import '../data/pending_join_store.dart';
import '../data/session_store.dart';

// ── Sources Firebase / stockage ───────────────────────────────────────────────
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final secureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

// ── Repositories / services ───────────────────────────────────────────────────
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(firebaseAuthProvider)));

final entityRepositoryProvider =
    Provider<EntityRepository>((ref) => EntityRepository(ref.watch(firestoreProvider)));

final sessionStoreProvider =
    Provider<SessionStore>((ref) => SessionStore(ref.watch(secureStorageProvider)));

final cloudinaryServiceProvider =
    Provider<CloudinaryService>((ref) => const CloudinaryService());

final joinRepositoryProvider = Provider<JoinRepository>(
  (ref) => JoinRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  ),
);

/// Demande d'adhésion mémorisée localement (box Hive ouverte dans `main.dart`).
final pendingJoinStoreProvider = Provider<PendingJoinStore>(
  (ref) => PendingJoinStore(Hive.box(PendingJoinStore.boxName)),
);

/// Session locale courante (uid/entityId/role) lue depuis Secure Storage.
final currentSessionProvider =
    FutureProvider<AuthSession?>((ref) => ref.watch(sessionStoreProvider).read());
