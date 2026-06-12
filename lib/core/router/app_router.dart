import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/activate_account_screen.dart';
import '../../features/auth/presentation/auth_choice_screen.dart';
import '../../features/auth/presentation/create_entity_screen.dart';
import '../../features/auth/presentation/join_entity_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/pending_requests_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Authentification (Jour 3) — tunnel net:false, pas d'indicateur réseau.
      GoRoute(
        path: RouteNames.authChoice,
        builder: (context, state) => const AuthChoiceScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.createEntity,
        builder: (context, state) => const CreateEntityScreen(),
      ),
      // Flux « Rejoindre une entité » (Jour 4) — demande candidat + activation.
      GoRoute(
        path: RouteNames.joinEntity,
        builder: (context, state) => const JoinEntityScreen(),
      ),
      GoRoute(
        path: RouteNames.activate,
        builder: (context, state) => const ActivateAccountScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      // Approbation des demandes d'adhésion (Jour 4) — admin uniquement.
      GoRoute(
        path: RouteNames.pendingRequests,
        builder: (context, state) => const PendingRequestsScreen(),
      ),
    ],
  );
});
