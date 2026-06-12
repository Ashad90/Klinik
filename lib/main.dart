import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(OnboardingRepository.boxName);

  await _initFirebase();

  runApp(const ProviderScope(child: KlinikApp()));
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Offline persistence illimitée — OBLIGATOIRE Klinik-Scan
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Persistance locale du token d'authentification
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } catch (e) {
    // Firebase pas encore configuré — exécuter : flutterfire configure
    // L'app fonctionne en mode hors ligne jusqu'à la configuration.
    debugPrint('[Klinik] Firebase non configuré : $e');
    debugPrint('[Klinik] Exécuter : dart pub global activate flutterfire_cli && flutterfire configure');
  }
}

class KlinikApp extends ConsumerWidget {
  const KlinikApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Klinik',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('es'),
      ],
      locale: const Locale('fr'),
    );
  }
}
