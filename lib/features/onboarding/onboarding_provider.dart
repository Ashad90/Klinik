import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/router/route_names.dart';

/// Accès au flag `onboardingCompleted` stocké localement dans Hive.
///
/// Offline-first : la lecture/écriture est purement locale, jamais réseau.
/// La box est ouverte au démarrage dans `main.dart`.
class OnboardingRepository {
  static const String boxName = 'klinik_prefs';
  static const String _kCompleted = 'onboardingCompleted';

  final Box _box;
  const OnboardingRepository(this._box);

  bool get isCompleted => _box.get(_kCompleted, defaultValue: false) as bool;

  Future<void> markCompleted() => _box.put(_kCompleted, true);
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(Hive.box(OnboardingRepository.boxName));
});

/// Détermine la route cible à la fin du splash.
///
/// Règles (brainstorming.md §3.1 / plan.md Jour 2) :
/// - token Firebase valide → Accueil (bypass onboarding + auth)
/// - sinon, onboarding jamais vu → Onboarding
/// - sinon → Authentification
///
/// L'accès à FirebaseAuth est protégé : si Firebase n'est pas configuré,
/// l'app reste fonctionnelle hors ligne et redirige selon le flag local.
String resolveSplashRoute(OnboardingRepository repo) {
  User? user;
  try {
    user = FirebaseAuth.instance.currentUser;
  } catch (_) {
    user = null;
  }

  if (user != null) {
    // Session anonyme = candidat « Rejoindre » en attente d'activation (Jour 4).
    // Jamais l'accueil (aucune session locale) — direction l'écran d'activation.
    if (user.isAnonymous) return RouteNames.activate;
    return RouteNames.home;
  }
  if (!repo.isCompleted) return RouteNames.onboarding;
  return RouteNames.authChoice;
}
