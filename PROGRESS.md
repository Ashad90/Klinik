# PROGRESS.md — Journal de Bord Klinik

> Ce fichier est mis à jour automatiquement par Claude code à la fin de chaque session de travail.
> Claude Code doit lire obligatoirement EN PREMIER ce fichier au début de chaque nouvelle session.
> Sans ce fichier à jour, Claude Code repart de zéro. Avec lui, il reprend exactement où on s'est arrêtés.
> Dernière mise à jour : 11 Juin 2026

---

## ÉTAT ACTUEL DU PROJET

```
Phase         : DÉVELOPPEMENT — Semaine 1 en cours
Jour actuel   : Jour 4 ✅ — Workflow « Rejoindre une entité » complet, vérifié E2E sur émulateur
Décision      : Option B retenue (règles sans custom claims, plan Spark gratuit). Option A (Blaze +
                Cloud Function setUserClaims) RÉSERVÉE jusqu'à ce que le fondateur confirme avoir Blaze.
Reliquat J3   : Custom claims en STAND-BY (décision fondateur 11/06/2026 — pièces manquantes pour
                activer Blaze). À l'activation de Blaze, le fondateur rappellera à Claude Code de
                finir le Jour 3 : Cloud Function setUserClaims (Option A) + email/FCM serveur.
Projet Firebase : klinik-95a79 (provider Anonyme ACTIVÉ — requis flux Rejoindre)
Prochain pas  : Jour 5 — Accueil par rôle & Paramètres de base (plan.md)
```

---

## 👉 PROCHAINE ÉTAPE — COMMENCER ICI (Jour 5 : Accueil par rôle & Paramètres de base)

> Jour 4 TERMINÉ et vérifié E2E (voir Session 12). Suivre `_project/plan.md` § Jour 5 :
> - [H1-H2] Accueil Agent/Infirmier : salutation, carte Points du jour, stats, actions rapides
>   (« Nouveau patient » + « Nouveau scan »), liste récente vide.
> - [H3-H4] Accueil Médecin/Docteur (onglets Disponibles / Mes dossiers / Validés) + Accueil
>   Admin (+ section Gestion de l'entité — le bouton « Demandes d'adhésion » existe déjà,
>   y ajouter le badge du nombre de demandes en attente).
> - [H5-H6] Paramètres de base.
> **Rappel : ne PAS activer Blaze/Cloud Functions/FCM/email serveur sans annonce du fondateur.**

Notes laissées par le Jour 4 :
- **Limitation MVP assumée** : l'activation (étape 3) doit se faire sur le MÊME appareil que la
  demande (session anonyme locale). Multi-appareils → plus tard (avec la connexion multi-appareils).
- **Données de test à nettoyer un jour dans la console** : entités `CliniqueTest`, `CliniqueDemo`
  (+ comptes `admin.demo@klinik.test`, `agent.test@klinik.test`, candidats anonymes,
  demande « Medecin Candidat » approuvée code ZHRJW8 — non activée).
- Code mort/obsolète repéré (non touché — règle chirurgicale) : commentaire périmé sur les custom
  claims dans `home_screen.dart` (~l.49) ; log trompeur « Firebase non configuré » dans `main.dart`
  (c'est `setPersistence()` qui jette UnimplementedError sur Android — inoffensif).

---

## CE QUI EST TERMINÉ ✅

### Documentation (Phase 0 — complétée)
- [x] `CLAUDE.md` — Instructions Claude Code (méthode Karpathy adaptée Flutter)
- [x] `_project/idee.md` — Vision globale complète du projet
- [x] `_project/brainstorming.md` — Fonctionnalités, flux, cas d'usage terrain
- [x] `_project/plan.md` — Plan de travail 20 jours (6h/jour)
- [x] `_project/DESIGN.md` — Token complet des maquettes et Design de l'application (6h/jour): couleurs, style, typography, interface...
- [x] `_project/PROGRESS.md` — Ce fichier

### Skills personnalisés (Phase 0 — complétés)
- [x] `klinik-skills/klinik-firebase-rules/` — Architecture Firebase, sécurité, patterns
- [x] `klinik-skills/klinik-vision-module/` — Module caméra, MediaPipe, métriques
- [x] `klinik-skills/klinik-offline-sync/` — Sync queue, Hive, ConnectivityService
- [x] `klinik-skills/klinik-design-system/` — Tokens couleur, typographie, composants

### Semaine 1 — Jour 1 (04 juin 2026 ✅)
- [x] `pubspec.yaml` — `lucide_icons: ^0.257.0` ajouté, toutes dépendances résolues
- [x] Structure feature-first : `lib/core/`, `lib/features/`, `lib/shared/`
- [x] `lib/core/theme/klinik_colors.dart` — 100% tokens DESIGN.md (couleurs fondatrices, gradients)
- [x] `lib/core/theme/klinik_typography.dart` — Inter, échelle complète + styles prédéfinis
- [x] `lib/core/theme/klinik_spacing.dart` — Grille 8pt + constantes sémantiques maquettes
- [x] `lib/core/theme/klinik_radius.dart` — 5 rayons + variantes ponctuelles
- [x] `lib/core/theme/klinik_shadows.dart` — card/sm/md/pointsAgent/pointsMedecin/fab
- [x] `lib/core/theme/klinik_animations.dart` — 11 durées + courbes + scales feedback tactile
- [x] `lib/core/theme/app_theme.dart` — ThemeData Material 3 (couleurs, typo, inputs, AppBar…)
- [x] `lib/core/router/route_names.dart` — Toutes les routes nommées V1
- [x] `lib/core/router/app_router.dart` — GoRouter + écran de test design system (temporaire Jour 1)
- [x] `lib/shared/widgets/klinik_button.dart` — Primary / Secondary / Ghost + KlinikButtonSmall
- [x] `lib/shared/widgets/klinik_card.dart` — KlinikCard standard + tappable (scale 0.99)
- [x] `lib/shared/widgets/network_status_indicator.dart` — Online/Offline/Syncing + animation pulse
- [x] `lib/firebase_options.dart` — Stub compilable (remplacer par `flutterfire configure`)
- [x] `lib/main.dart` — ProviderScope + GoRouter + Firebase init + locales FR/EN/ES
- [x] `firestore.rules` — Règles complètes (isolation entités, rôles, validation immuable)
- [x] `storage.rules` — Règles Storage (PDFs, ordonnances, logos)
- [x] `firebase.json` — Config déploiement Firebase
- [x] `flutter analyze` — 0 erreur, 0 warning (1 info pré-existant : nom package capital)

---

### Semaine 1 — Jour 2 (04 juin 2026 ✅ code complet)
- [x] `lib/features/onboarding/onboarding_provider.dart` — Repository Hive (`onboardingCompleted`) + `resolveSplashRoute()`
- [x] `lib/features/onboarding/splash_screen.dart` — Dégradé radial, logo SVG blanc 88px, wordmark + tagline, spinner, auto-redirect 2300ms + tap-to-skip
- [x] `lib/features/onboarding/onboarding_screen.dart` — PageView 4 slides, dots animés 8→24px, bouton 52px, « Passer » slides 1-3
- [x] `lib/core/router/app_router.dart` — Routes `/` (splash) + `/onboarding` branchées ; placeholders `/auth` et `/home` (écran test Jour 1 retiré)
- [x] `lib/main.dart` — Ouverture box Hive `klinik_prefs` au démarrage
- [x] `pubspec.yaml` — `flutter_svg` + `lucide_icons_flutter` ajoutés ; section `flutter.assets:` déclarée (logos/images/sounds)
- [x] `test/widget_test.dart` — 3 tests verts (persistance flag + redirection splash)
- [x] `flutter analyze` — 0 erreur (info pré-existante nom package)

---

### Semaine 1 — Jour 2 (suite Session 5 — 05 juin 2026 ✅ RUN RÉUSSI)
- [x] Build Android débloqué : `android/gradle.properties` (`kotlin.incremental=false`),
      `android/build.gradle.kts` (override compileSdk 36 en `afterEvaluate` + garde `state.executed`)
- [x] **App lancée et vérifiée** sur émulateur Pixel 7 Pro (Splash → Onboarding → `/auth`)
- [x] Splash natif Klinik : `klinik_splash_logo.xml`, `colors.xml`, `values-v31` + `values-night-v31`,
      `launch_background` (base/v21/v23) — fini le logo Flutter au démarrage
- [x] Icône de lancement officielle (depuis `laucher_icon.svg`) : icône adaptative
      (`mipmap-anydpi-v26/ic_launcher[_round].xml` + `ic_launcher_foreground/monochrome.xml`) +
      PNG legacy 5 densités (Pillow) + `android:roundIcon` au manifest

### Semaine 1 — Jour 3 (05 juin 2026 ✅ code complet — Authentification)

**Couche données (déjà posée en amont) :** modèles `AppUser`/`Entity`/`EntityType`/`UserRole`,
`Validators`, `AuthRepository`, `EntityRepository.createEntityWithAdmin` (batch atomique
offline-first), `SessionStore`/`AuthSession` (Secure Storage — remplace les custom claims différés),
`auth_providers.dart`, `CloudinaryService`, `KlinikTextField`.

**Couche présentation (cette session) :**
- [x] `lib/features/auth/application/auth_controller.dart` — `AsyncNotifier` (sans codegen) :
      `signIn()` + `createEntity()` (signUp → upload logo best-effort → batch `/entities/{id}` +
      `/users/{uid}` → session locale → email de vérif best-effort) + `authErrorMessage()` (mapping FR)
- [x] `lib/features/auth/presentation/auth_choice_screen.dart` — DESIGN §9.3 (2 cartes Créer/Rejoindre,
      tuiles 52px, lien « Se connecter »)
- [x] `lib/features/auth/presentation/login_screen.dart` — DESIGN §9.4 (KMark 56 + wordmark 30,
      email/mot de passe, signIn → /home)
- [x] `lib/features/auth/presentation/create_entity_screen.dart` — flux 2 étapes (entité + logo
      optionnel via `image_picker` / compte admin), sélecteur de type, footer Suivant/Créer
- [x] `lib/core/router/app_router.dart` — routes réelles `/auth`, `/auth/login`, `/auth/create` +
      placeholder `/auth/join` (Jour 4) ; placeholder `/auth` retiré
- [x] `flutter analyze` — 0 erreur, 0 warning (info pré-existant : nom package capital)
- [x] `flutter test` — 3 tests verts (aucune régression)

**Vérification émulateur (Session 7) :**
- [x] `flutter build apk --debug` ✅ (~235s, cache chaud ; warnings KGP non bloquants)
- [x] APK installé + lancé (`adb install -r` + `am start com.klinik.klinik/.MainActivity`)
- [x] Capture d'écran : l'app rend bien l'écran **AuthChoice** (KMark, 2 cartes Créer/Rejoindre,
      lien « Se connecter ») → flux Splash → Onboarding (déjà vu) → `/auth` OK.
- [ ] Reste à tester interactivement : création d'entité (formulaire 2 étapes) → écriture Firestore → /home.

**Outils émulateur (`tools/`) :**
- `show_emulator.ps1` — affiche/repositionne à la demande la fenêtre de l'émulateur (process
  `qemu-system-*`) si elle démarre hors écran (cause du « écran caché »).
- `watch_emulator.ps1` — watcher d'arrière-plan (poll 2s) : corrige automatiquement chaque
  nouvelle fenêtre d'émulateur hors écran. **Auto-démarré au logon** via le lanceur VBS
  `…\Start Menu\Programs\Startup\KlinikShowEmulator.vbs` (tâche planifiée impossible sans droits
  admin → méthode dossier Démarrage, équivalente). Actif dans la session courante.
- `adb` / `emulator` ajoutés au **PATH utilisateur** (`…\Android\Sdk\platform-tools` et `…\emulator`).
  Effectif dans les nouveaux terminaux.

**Redéploiement (mises à jour utilisateur des écrans auth/splash) :** rebuild + reinstall + relaunch ;
capture d'écran confirme le rendu de l'écran « Créer une entité — Étape 1/2 » (sélecteur 5 types,
champs, logo optionnel, bouton Suivant).

### Semaine 1 — Jour 4 (11 juin 2026 ✅ VÉRIFIÉ E2E — « Rejoindre une entité »)

**Règles Firestore (déployées sur klinik-95a79) :**
- [x] `/publicEntities/{id}` — annuaire public minimal {name, nameLower, city, type} pour la
      recherche, lisible par tout authentifié (y compris session anonyme), écrit dans le batch
      de création d'entité (`getAfter` post-batch). Backfill fait pour les entités de test.
- [x] **Faille colmatée** : `users create` n'autorise plus l'auto-ajout libre (admin OU créateur
      d'entité via `getAfter`) ; `users update` self interdit de changer son propre rôle ;
      `pendingUsers create` force `status == 'pending_approval'` ; `entities create` réservé
      aux comptes non-anonymes.
- [x] `klinik-skills/klinik-firebase-rules/SKILL.md` mis à jour simultanément (schéma + règles).

**Couche données / application :**
- [x] `shared/models/public_entity.dart` + `shared/models/pending_user.dart`
- [x] `EntityRepository.searchEntities()` (préfixe `nameLower`, limite 10) + fiche publique
      ajoutée au batch `createEntityWithAdmin`
- [x] `auth/data/join_repository.dart` — `ensureCandidateSession()` (signInAnonymously),
      `createJoinRequest`, `watchPendingRequests`, `approveRequest` (batch atomique : membre +
      code 6 car. sans 0/O/1/I/L + expiration 24h), `getOwnRequest`, `linkEmailPassword`
- [x] `auth/data/pending_join_store.dart` — entité visée mémorisée dans Hive `klinik_prefs`
- [x] `auth/application/join_controller.dart` — `JoinController` (AsyncNotifier manuel) :
      `submitRequest` / `approve` / `activate` + `entitySearchProvider` + `pendingRequestsProvider`
- [x] `auth_controller.signIn` — vérifie désormais `session.uid == user.uid` (anti-réutilisation
      de la session d'un AUTRE utilisateur de l'appareil)
- [x] `resolveSplashRoute` — session anonyme → `/auth/activate` (jamais `/home`)

**UI :**
- [x] `join_entity_screen` — recherche d'entités branchée (résultats tappables, sélection ✓,
      validation), soumission réelle → écran « Demande envoyée »
- [x] `activate_account_screen` — vérification code (statut/code/expiration) → liaison
      email/mot de passe (uid conservé) → session locale → `/home`
- [x] `pending_requests_screen` (NOUVEAU, route `/home/requests`) — liste temps réel des
      demandes, chips de rôle, Approuver → dialog code (SelectableText + consigne 24h)
- [x] `home_screen` — bouton « Demandes d'adhésion » (admin uniquement)
- [x] Provider Firebase **Anonyme activé** (via API admin Identity Toolkit — pas d'action console)

**Vérifications :**
- [x] `flutter analyze` 0 erreur · `flutter test` 3/3 verts
- [x] **E2E candidat sur émulateur** : Rejoindre → recherche « clinik » → ClinikB → demande
      envoyée → (approbation) → code + mot de passe → **Home « ClinikB · Agent de santé »** ✅
- [x] **E2E admin sur émulateur** : Home admin → Demandes d'adhésion → demande affichée temps
      réel → rôle Médecin → Approuver → **dialog code ZHRJW8** ; vérifié côté serveur :
      `users/{uid}` créé role=medecin, `pendingUsers` approved + code + expiration ✅
- [x] Règles candidat validées indépendamment (REST avec idToken anonyme : création
      `pendingUsers` acceptée, statut forcé pending_approval)

---

## EN COURS 🔄

```
Rien de bloquant. Le run Android fonctionne sur l'émulateur Pixel 7 Pro.
Builds suivants rapides (tout en cache ~/.gradle). Prêt pour Jour 5 (Accueil par rôle).

⚠️ flutter run se DÉTACHE ici (lancé sans terminal interactif → stdout redirigé) :
   il quitte après le 1er lancement et ferme l'app. Pour du hot-reload, lancer
   `flutter run -d emulator-5554` dans un VRAI terminal. Sinon, relancer l'APK
   installé directement : `adb shell am start -n com.klinik.klinik/.MainActivity`.

⚠️ Émulateur (Session 12) : réseau qui gèle après longue uptime → redémarrer avec
   `-dns-server 8.8.8.8`. Et après tout redémarrage, l'émulateur peut recharger un
   VIEUX snapshot quickboot (rollback APK + données) → toujours réinstaller l'APK.
```

---

## BLOQUÉ ❌

```
Rien pour l'instant — Firebase Firestore configuré et prêt.
Firebase Storage en stand-by (V1.1) — plan Blaze requis, pas de carte actuellement.
```

---

## CONFIGURATION FIREBASE REQUISE (action manuelle — une seule fois)

```
Étape 1 — Créer le projet Firebase
  → console.firebase.google.com → "Ajouter un projet" → nom : klinik-scan
  → Activer : Authentication (Email/Password), Firestore, Storage, FCM, Remote Config
  → Firestore : mode Production (les règles firestore.rules seront déployées)

Étape 2 — Installer FlutterFire CLI
  ! dart pub global activate flutterfire_cli

Étape 3 — Configurer le projet Flutter
  ! flutterfire configure
  → Sélectionner le projet klinik-scan
  → Plateforme : Android (+ iOS si disponible)
  → Cela génère lib/firebase_options.dart (remplace le stub)
  → Cela ajoute google-services.json dans android/app/

Étape 4 — Déployer les règles de sécurité Firestore
  ! firebase deploy --only firestore:rules
  (Storage en stand-by jusqu'à V1.1 — plan Blaze requis)

Étape 5 — Vérifier la connexion
  ! flutter run
  → L'app doit apparaître dans la Firebase Console → Authentication → Users
  → Firestore doit apparaître dans Data
```

---

## DÉCISIONS PRISES (ne pas revenir dessus sans discussion)

| Date | Décision | Raison |
|---|---|---|
| 30 mai 2026 | Riverpod 2.x pour la gestion d'état (pas Bloc, pas Provider) | Meilleure intégration async, moins de boilerplate |
| 30 mai 2026 | GoRouter pour la navigation | Deep linking natif, redirection basée sur rôle |
| 30 mai 2026 | Feature-first folder structure | Chaque feature autonome, facilite le travail avec Claude Code |
| 30 mai 2026 | Cloudinary pour les médias (photos, vidéos, ordonnances scannées) | Transformations auto, meilleure gestion des images |
| 30 mai 2026 | Firebase Storage uniquement pour les PDF médicaux | Meilleure intégration avec les règles Firestore |
| 30 mai 2026 | lucide_icons (pub.dev) comme package d'icônes unique | Cohérence avec le style Lucide React du background Frontend |
| 30 mai 2026 | Code d'accès 6 caractères alphanumériques (pas 4 chiffres) | Sécurité : 2,17 milliards de combinaisons vs 10 000 |
| 30 mai 2026 | Rôle système assigné par l'admin uniquement (pas auto-déclaré) | Intégrité du système de validation et de gamification |
| 30 mai 2026 | Round-robin pour notifications score 0-3 (pas aléatoire) | Distribution équitable basée sur la charge réelle |
| 30 mai 2026 | Module Vision reporté en V1.1 (pas dans le MVP V1) | Trop complexe pour 1 mois — prioriser la stabilité du core |
| 30 mai 2026 | iOS reporté en V1.2 si seuil 500 utilisateurs Android atteint | Valider le marché Android d'abord (90% du marché africain) |
| 30 mai 2026 | Questions frissons et palpitations séparées (pas combinées) | Correctitude clinique — deux symptômes distincts |
| 04 juin 2026 | Firebase Storage reporté à V1.1 (déploiement en stand-by) | Pas de plan Blaze disponible (pas de carte Visa) — PDFs médicaux en V1.1 |
| 04 juin 2026 | `lucide_icons_flutter` (fork) remplace `lucide_icons` | lucide_icons 0.257 incompatible Flutter 3.44 (IconData final). Fork maintenu, respecte RÈGLE 7. ⚠️ Mettre à jour la stack CLAUDE.md |
| 04 juin 2026 | `flutter_svg` ajouté à la stack | Rendu des logos KMark (.svg). Splash = `klinik-mark-white.svg`, écrans clairs = `klinik-mark.svg`. ⚠️ Mettre à jour la stack CLAUDE.md |
| 04 juin 2026 | « Passer » l'onboarding écrit aussi `onboardingCompleted` | Cohérent avec « ne se réaffiche jamais » — l'utilisateur ne doit pas être renvoyé à l'onboarding après l'avoir sauté |
| 05 juin 2026 | `kotlin.incremental=false` dans `android/gradle.properties` | Projet sur `E:\`, cache Pub sur `C:\` → compilateur Kotlin incrémental échoue (« different roots ») entre 2 disques |
| 05 juin 2026 | Override compileSdk 36 en `afterEvaluate` + garde `state.executed` (pas `projectsEvaluated`) | `projectsEvaluated` est trop tard (DSL AGP verrouillé) ; certains sous-projets déjà évalués interdisent `afterEvaluate` sans la garde |
| 05 juin 2026 | Icône de lancement = fond BLANC + « K » bleu/teal (`laucher_icon.svg`) | C'est l'asset officiel demandé ; pensé pour une tuile claire (le K coloré ne ressort pas sur fond bleu) |
| 05 juin 2026 | Splash natif = couleur pleine `#557CDC` + icône (pas de dégradé) | L'API SplashScreen Android 12 ne gère qu'une couleur de fond + une icône ; raccord propre vers le dégradé du splash Flutter |
| 11 juin 2026 | **Custom claims (Jour 3) en STAND-BY officiel jusqu'à l'activation du plan Blaze** | Décision du fondateur : pièces nécessaires à l'activation de Blaze pas encore réunies. Une fois Blaze disponible, le fondateur rappellera de finir le Jour 3 (Option A : Cloud Function `setUserClaims` + email/FCM serveur). En attendant : SessionStore + règles Option B |
| 11 juin 2026 | Recherche d'entités via collection publique `/publicEntities` (name, nameLower, city, type) | Validé par le fondateur (vs assouplir la lecture de `/entities`) : fidèle au principe d'isolation — le doc entité complet (adresse, plan, statut, createdBy) reste réservé aux membres |
| 11 juin 2026 | Candidat « Rejoindre » = **auth anonyme + linkWithCredential** à l'activation | Validé par le fondateur : uid stable dès la demande, zéro changement d'UI, mot de passe à l'étape 3 comme prévu au plan. Limitation assumée : activation sur le même appareil que la demande |
| 11 juin 2026 | **Failles règles colmatées dans le même déploiement** (auto-ajout membre/admin, auto-promotion de rôle, entités par compte anonyme, statut pendingUsers forcé) | Validé par le fondateur. Découvert pendant la préparation Jour 4 : `users create` permettait à tout authentifié de se faire admin de n'importe quelle entité |
| 11 juin 2026 | `signIn` exige `session.uid == user.uid` | Sans ce contrôle, un utilisateur se connectant sur l'appareil d'un autre héritait de l'entité/rôle de ce dernier (session locale d'autrui) |

---

## BUGS CONNUS

```
Aucun bug ouvert. (Session 12 : faille règles « auto-ajout membre/admin » et réutilisation
de session d'autrui dans signIn — découverts ET corrigés le 11/06/2026.)
Anomalie non reproduite : un lancement après `pm clear` a sauté l'onboarding (1 occurrence).
```

---

## JOURNAL DES SESSIONS

### Session 12 — 11 juin 2026 — Jour 4 COMPLET : workflow « Rejoindre une entité » E2E

**Fait :**
- **Décision fondateur consignée** : custom claims = reliquat Jour 3 en STAND-BY jusqu'à Blaze
  (le fondateur rappellera). 3 décisions d'architecture validées par questionnaire :
  `/publicEntities`, auth anonyme + liaison, colmatage des failles règles dans le même déploiement.
- **Règles Firestore v3 déployées** : annuaire public `/publicEntities`, `users create` verrouillé
  (admin OU créateur via `getAfter`), anti-auto-promotion de rôle, `pendingUsers create` à statut
  forcé, `entities create` non-anonyme. SKILL firebase-rules synchronisé.
- **Backends Jour 4 complets** (détail § Semaine 1 — Jour 4) : recherche, demande (session
  anonyme), approbation admin (code client 6 car., batch atomique), activation
  (vérif code/expiration → `linkWithCredential` → session → /home).
- **Provider Anonyme activé par API** (Identity Toolkit admin, token CLI Firebase) — pas d'action
  console nécessaire.
- **E2E double vérifié sur émulateur** (captures) : parcours candidat complet ClinikB (Home
  « Agent de santé ») + parcours admin complet (écran Demandes d'adhésion → rôle Médecin →
  dialog code ZHRJW8 ; writes vérifiés côté serveur sous les vraies règles).
- `flutter analyze` 0 erreur · `flutter test` 3/3 verts.

**Bloqué / Problème rencontré :**
- Réseau de l'émulateur gelé en cours de session (logins suspendus sans réponse, SocketException
  errno 103) → résolu par redémarrage de l'émulateur avec `-dns-server 8.8.8.8`.
- ⚠️ Piège émulateur : lancé avec `-no-snapshot-save`, il a rechargé au redémarrage le snapshot
  du 5 juin (état appareil ROLLBACK : ancien APK + ancienne session). Réinstaller l'APK après
  tout redémarrage d'émulateur, ou lancer sans `-no-snapshot-save`.
- Bug attrapé pendant l'E2E : la recherche tournait AVANT la session anonyme → lecture refusée.
  Fix : `ensureCandidateSession()` await dans `entitySearchProvider`.

**Décision prise :**
- Voir tableau DÉCISIONS (5 nouvelles lignes du 11 juin 2026).

**Bugs découverts :**
- Faille de sécurité pré-existante dans les règles déployées (auto-ajout membre/admin) — colmatée.
- `signIn` réutilisait la session locale d'un autre utilisateur — corrigé (`session.uid == user.uid`).
- Anomalie non reproduite : un lancement après `pm clear` a sauté l'onboarding (une seule fois).

**Prochain pas :**
- Jour 5 : Accueil par rôle (Agent / Médecin / Admin + badge demandes) & Paramètres de base.

---

### Session 11 — 05 juin 2026 — Déblocage lectures Firestore (Option B, sans custom claims)

**Fait :**
- **Option B implémentée et déployée** (décision du fondateur : Option B maintenant, Option A/Blaze
  plus tard sur annonce). Les règles dérivent l'appartenance de l'**existence du doc**
  `/entities/{entityId}/users/{uid}` (helpers `isMember`/`memberRole`/`hasRole(entityId,role)`/
  `isAdminOfEntity`) au lieu du claim `token.entityId`. `exists()`/`get()` = lectures privilégiées
  → pas de récursion. **Aucun changement de code app ni de schéma** (le doc user est déjà écrit par
  `EntityRepository.createEntityWithAdmin`).
- `firestore.rules` réécrit + `klinik-skills/klinik-firebase-rules/SKILL.md` mis à jour (modèle
  Option B documenté ; section Custom Claims marquée « Option A — réservé, nécessite Blaze »).
- Déployé : `firebase deploy --only firestore:rules --project klinik-95a79` → compilé + released OK.
- **Vérifié E2E sur émulateur** : création entité « ClinikB » → Login (email pré-rempli) → connexion
  → **Home affiche « Connecté à ClinikB » + Administrateur** (avant : « — » / PERMISSION_DENIED).
  La lecture de l'entité passe désormais.

**Bloqué :** aucun. Email/FCM/génération de code serveur restent en Option A (Blaze).

**Prochain pas :** Jour 4 — brancher la recherche d'entités + écriture `pendingUsers` (maintenant
possibles sous les nouvelles règles), puis le flux code/activation (code communiqué en personne par
l'admin tant que Blaze n'est pas actif).

---

### Session 10 — 05 juin 2026 — Correctif fond de l'icône de lancement (launcher)

**Fait :**
- Diagnostic : icône adaptative valide (rendu cercle propre en « Infos appli ») ; le carré
  pointillé du dock était un **cache launcher périmé** (réinstallations répétées), pas un bug.
  Le vrai point : le **fond de l'icône était blanc** → fade et incohérent avec le splash bleu.
- Fix (fond du launcher = identité splash) :
  - `values/colors.xml` : `ic_launcher_background` `#FFFFFFFF` → **`#FF557CDC`** (bleu de marque).
  - `drawable/ic_launcher_foreground.xml` : « K » passé en **blanc + teal** (`#FFFFFF` barre +
    diagonale haute, `#7FDADA` diagonale basse) pour ressortir sur le fond bleu (comme le splash).
  - PNG legacy (`mipmap-{m,h,xh,xxh,xxxh}dpi/ic_launcher[_round].png`) régénérées via Pillow :
    fond bleu (carré arrondi / cercle) + K blanc/teal centré, assorties à l'icône adaptative.
- Vérifié : « Infos sur l'appli » → **cercle bleu + K blanc/teal centré**. (Annule la décision
  « fond blanc » de Session 5, à la demande du fondateur : le K blanc ressort sur le bleu.)

**Bloqué :** aucun. **Décision règles/Blaze (Session 8) toujours en attente.**

**Prochain pas :** trancher règles/Blaze pour débloquer lectures + finir les backends Jour 4.

---

### Session 9 — 05 juin 2026 — Correctif splash natif (K rogné/décentré)

**Fait :**
- Bug : sur Android 12+ (émulateur), le « K » du splash natif était **rogné et décentré** —
  l'artwork remplissait le viewport et dépassait le cercle de masque du SplashScreen API.
- Fix (1 fichier, `drawable/klinik_splash_logo.xml`) : `<group>` corrigé pour centrer le K en
  (50,50) — centre visuel (54.25,50), `pivotY 53.25→50`, `translateY -3.25→0` — et le réduire
  (`scale 0.9→0.7`) pour qu'il tienne dans le cercle ~2/3 (rayon visuel ≈ 29.5/50). Tracés inchangés.
- Couvre aussi le pré-Android 12 : `launch_background-v23` réutilise ce drawable centré.
- Vérifié : capture du splash natif → **K parfaitement centré et complet** sur fond `#557CDC`.

**Bloqué :** aucun. **Décision règles/Blaze (Session 8) toujours en attente.**

**Prochain pas :** trancher règles/Blaze pour débloquer lectures + finir les backends Jour 4.

---

### Session 8 — 05 juin 2026 — Parcours auth réel testé E2E + Home minimal + blocage claims

**Fait :**
- Parcours **création → Login → Home** implémenté : à la création d'entité, on déconnecte +
  pré-remplit l'email (`justCreatedEmailProvider`) → l'utilisateur se connecte → `/home`.
  (`auth_controller` : signIn invalide `currentSessionProvider` ; createEntity signOut + email ;
  `signOut()` complet pour la déconnexion. `Entity.fromMap`, `EntityType.fromFirestore`,
  `EntityRepository.getEntity` ajoutés.)
- **Home minimal réel** (`features/home/`) : entité + rôle + déconnexion, AppBar + indicateur
  réseau (RÈGLE 5). Remplace le placeholder `/home`.
- **TEST E2E réel sur émulateur** (piloté via `adb input`, Firebase live) : création compte
  `admin1780675510@klinik.test` / `Klinik2026` → compte Firebase + entité Firestore créés →
  redirection Login (email pré-rempli) → connexion → **Home « Accueil » affiché** (rôle
  Administrateur, « En ligne »). ✅ Parcours validé de bout en bout.
- `flutter analyze` 0 problème ; rebuild + redéploiement OK.

**Jour 4 démarré — écrans (présentation, sans dépendance à la décision règles/Blaze) :**
- `join_entity_screen.dart` (étape 1) : formulaire candidat (nom, email, tél, grade, entité) +
  écran de confirmation « Demande envoyée » → bouton vers Activation. Vérifié rendu sur émulateur.
- `activate_account_screen.dart` (étape 3) : saisie code 6 caractères (majuscules, alphanum,
  hint K7X2M9) + mot de passe. Vérifié rendu sur émulateur.
- Routes `/auth/join` (réelle) et `/auth/activate` câblées ; placeholder `/auth/join` retiré ;
  `_PlaceholderScreen` supprimé (plus aucun usage) + imports orphelins nettoyés.
- ⚠️ Backends en attente de la décision règles/Blaze : recherche d'entités, écriture
  `pendingUsers`, génération/vérification du code, approbation admin (marqués TODO(jour4)).

**Bloqué / Problème rencontré (IMPORTANT) :**
- **Lecture Firestore refusée** : logcat → `PERMISSION_DENIED, Missing or insufficient permissions`
  sur `entities/{id}`. Cause : les règles déployées exigent `request.auth.token.entityId`
  (custom claim) via `belongsToEntity()`, MAIS l'app ne pose jamais ce claim (différé Blaze).
  → La création passe (règles `create` sans claim) mais **toute lecture protégée échoue**
  (nom d'entité, et plus tard patients/scans). Le Home affiche « — » pour l'entité.
- Conséquence : **Jour 4 (Rejoindre)** est doublement bloqué — il dépend de Cloud Functions
  (génération code/email/FCM → Blaze) ET d'une recherche d'entités impossible sous ces règles.

**Décision à prendre (architecturale — voir INTERDIT #3/#4, à valider avec le fondateur) :**
- **Option A** — Activer **Blaze** + Cloud Function `setUserClaims` (pose `token.entityId`/`role`).
  Conforme au design actuel des règles et du skill. Coût/carte requis.
- **Option B** — **Réécrire les règles sans custom claims** : dériver l'appartenance via un
  document Firestore (ex. `/userEntities/{uid}` = entityId, ou lecture du doc user). Fonctionne
  sur le plan **Spark gratuit**, sans Cloud Functions. Nécessite de modifier règles (+ schéma).

**Bugs découverts :**
- Aucun bug code. Le « blocage » est une incohérence de conception règles ↔ claims (connue,
  conséquence du report Blaze) que le Home a fait remonter.

**Prochain pas :**
- Trancher A ou B. Puis débloquer les lectures et reprendre Jour 4.
- (Données de test à nettoyer dans la console Firebase si besoin : user + entité ci-dessus.)

---

### Session 6 — 05 juin 2026 — Jour 3 : Authentification (couche présentation)

**Fait :**
- Audit du Jour 3 : la couche données était entièrement posée (modèles, repositories, session,
  providers, validators, Cloudinary), rien de l'UI n'était commencé. Reprise à la présentation.
- `AuthController` (`AsyncNotifier`, sans codegen — convention projet) : `signIn()` et `createEntity()`.
  `createEntity` enchaîne signUp Firebase → upload logo (best-effort, non bloquant) → `newEntityId()` →
  écriture atomique `batch` `/entities/{id}` + `/entities/{id}/users/{uid}` (offline-first) → `SessionStore.save`
  → email de vérification (best-effort, try/catch). Mapping erreurs FR (`authErrorMessage`).
- 3 écrans : `AuthChoiceScreen` (§9.3), `LoginScreen` (§9.4), `CreateEntityScreen` (flux 2 étapes
  via PageView interne : entité + logo optionnel `image_picker`, puis compte admin). 100% tokens
  KlinikColors/Typography/Spacing/Radius, aucune couleur hex hardcodée, boutons 52px.
- Router câblé : `/auth` → AuthChoice, `/auth/login` → Login, `/auth/create` → CreateEntity,
  `/auth/join` → placeholder Jour 4.
- `flutter analyze` 0 erreur · `flutter test` 3/3 verts.

**Bloqué / Problème rencontré :**
- Aucun. (Non vérifié sur émulateur cette session — build lourd ; analyze + tests verts.)

**Décision prise :**
- Custom claims (tâche plan Jour 3) remplacés par `SessionStore` local (Secure Storage) — décision
  déjà actée (plan Blaze requis pour les claims). Le splash auto-connecte via `currentUser`.
- `LoginScreen` autonome : connexion possible uniquement si une session locale existe déjà sur
  l'appareil (cas après création). Le multi-appareils (récupérer l'entité distante) est reporté au Jour 4.
- Omis du Login (hors scope Jour 3, éviteraient du UI mort) : « mot de passe oublié » et sélecteur
  de langue FR/EN/ES de la maquette §9.4. Écrans Activate/SetPassword (§9.3) → Jour 4.

**Bugs découverts :**
- Aucun.

**Prochain pas :**
- Vérifier sur émulateur : création d'entité → documents Firestore (`entities/{id}` + `users/{uid}`)
  → redirection /home → token persiste (rouvrir = auto-connecté). Puis Jour 4 (Rejoindre une entité).

---

### Session 5 — 05 juin 2026 — Run Android débloqué + Splash natif + Icône de lancement

**Fait :**
- **Build Android DÉBLOQUÉ** (3 obstacles en cascade, 2 fichiers de config, aucun code Dart) :
  1. `Could not close incremental caches… different roots` → projet sur `E:\`, cache Pub sur
     `C:\` : le compilateur Kotlin incrémental ne peut pas calculer un chemin relatif entre 2
     disques. **Fix** : `kotlin.incremental=false` dans `android/gradle.properties`.
  2. `file_picker is currently compiled against android-34` (lifecycle exige 36) : l'override
     compileSdk était dans `gradle.projectsEvaluated` → trop tard, DSL AGP verrouillé,
     `setCompileSdk` jetait en silence. **Fix** : override déplacé en `afterEvaluate` PAR
     sous-projet dans `android/build.gradle.kts`, via méthode `compileSdkVersion(int)`.
  3. `Cannot run afterEvaluate when project already evaluated` (`:app` déjà évalué). **Fix** :
     garde `if (state.executed) forceCompileSdk36() else afterEvaluate { … }`.
  - Diagnostic décisif : lancer Gradle EN DIRECT (`gradlew :file_picker:checkDebugAarMetadata`,
    `JAVA_HOME` = JBR Android Studio) — boucle ~5s, montre les logs que `flutter run` filtre.
  - Toolchain constatée : **Gradle 9.1 + AGP 9.0** (très récent, DSL strict).
- **App lancée et vérifiée** sur émulateur Pixel 7 Pro : Splash → Onboarding → `/auth` (placeholder
  Jour 3). Navigation GoRouter + persistance Hive `onboardingCompleted` OK.
- **Splash natif corrigé** (affichait encore le logo Flutter sur fond noir) → fond bleu Klinik
  `#557CDC` + « K » blanc/teal. Fichiers : `drawable/klinik_splash_logo.xml` (vector depuis
  `klinik-mark-white.svg`), `values/colors.xml` (`klinik_splash_bg`), `values-v31/styles.xml`
  + `values-night-v31/styles.xml` (SplashScreen API Android 12+), `drawable[-v21]/launch_background.xml`
  (fond bleu pré-12), `drawable-v23/launch_background.xml` (bleu + K, Android 6-11).
  ⚠️ `values-night-v31` est ESSENTIEL : `-night` prime sur `-v31`, l'émulateur (API récente + dark
  mode) résout ce fichier-là.
- **Icône de lancement officielle** depuis `assets/logos/laucher_icon.svg` (remplace le logo Flutter) :
  icône adaptative Android 8+ (`mipmap-anydpi-v26/ic_launcher[_round].xml`, fond blanc +
  `drawable/ic_launcher_foreground.xml` vector K + `ic_launcher_monochrome.xml` pour icônes
  thématiques Android 13+) ; PNG legacy 5 densités (mdpi→xxxhdpi, carrés + ronds) générés via
  un script Pillow (dessin direct de la géométrie du K, supersampling ×4). `android:roundIcon`
  ajouté au manifest. Vérifié dans le tiroir/dock : cercle blanc + K bleu/teal.

**Bloqué / Problème rencontré :**
- Aucun blocage restant. (Tout l'historique « SDK manuel » de la Session 4 reste acquis.)

**Décision prise :**
- `kotlin.incremental=false` assumé (projet et cache Pub sur disques différents E:\ / C:\).
- Icône adaptative = fond BLANC + K bleu/teal (couleurs de `laucher_icon.svg`, pensé pour tuile
  claire), pas fond bleu + K blanc (qui exigerait l'autre asset).
- Splash natif = couleur pleine + icône (l'API Android 12 ne fait pas de dégradé) ; le bleu plein
  `#557CDC` assure le raccord vers le dégradé du splash Flutter.

**Bugs découverts :**
- Aucun bug code. Tous les obstacles étaient environnementaux (cross-disque, toolchain AGP 9).

**Prochain pas :**
- Jour 3 : Authentification (écran `/auth` réel, multi-entités, code d'accès 6 caractères).

---

### Session 4 — 04 juin 2026 — Réparation environnement build Android (SDK + mémoire)

**Fait :**
- Diagnostic complet de la chaîne de build Android (whack-a-mole résolu) :
  - `sdkmanager` inutilisable sur ce réseau (échec parsing/téléchargement manifestes)
  - Téléchargement MANUEL via BITS + installation des platforms : android-36 (base), 35 (base), 34 et 33 (variantes "ext")
  - build-tools 36.0.0 installé (Google ne sert plus les base 33/34, seulement "ext")
  - Correctif clé : `package.xml` de android-33/34 réécrit → `path="platforms;android-XX"` + `<base-extension>true</base-extension>` (sinon AGP les voit comme `android-XX-extN` et ne trouve pas la base)
  - `android/build.gradle.kts` : override `compileSdk = 36` sur tous les sous-projets via `gradle.projectsEvaluated`
  - `android/gradle.properties` : `-Xmx8G→2G`, `MaxMetaspaceSize 4G→1G` (RAM machine ≈13,9 Go, ~0,5 Go libre → daemon tué en OOM)
- Résultat : le build TRAVERSE désormais tout le SDK et compile l'app + plugins

**Bloqué / Problème rencontré :**
- 1er build complet a duré **54 min** (RAM saturée → swap disque permanent)
- ÉCHEC FINAL = **RÉSEAU** : Gradle ne télécharge pas les dépendances Maven/Google
  (firebase-*-interop, play-services-*, kotlin-stdlib-jdk7/8) — coupures intermittentes
  vers dl.google.com / repo.maven.apache.org

**Décision prise :**
- NE PAS réinstaller Android Studio (ce n'est pas la cause — toolchain OK, build compile)
- Acquis SDK consignés dans la section EN COURS (ne JAMAIS refaire)

**Bugs découverts :**
- Aucun bug code — tout est environnemental (réseau + RAM + dossier OneDrive)

**Prochain pas :**
1. Déplacer le projet `OneDrive\Desktop\Klinik` → `C:\dev\Klinik` (Defender+sync ralentissent)
2. Fermer Android Studio + navigateur (libérer ≥3-4 Go RAM)
3. Connexion stable → `flutter run -d emulator-5554` (1 build suffit, ensuite cache ~/.gradle = builds hors ligne)
4. Vérifier le flux Splash → Onboarding → /auth → puis Jour 3 (Authentification)

---

### Session 3 — 04 juin 2026 — Jour 2 : Splash Screen + Onboarding

**Fait :**
- Feature `onboarding/` créée : provider Hive, splash screen, onboarding 4 slides
- Splash §9.1 : dégradé radial, logo `klinik-mark-white.svg` 88px en tuile translucide, wordmark 42px + tagline, spinner, redirection auto 2300ms (tap pour passer)
- Onboarding §9.2 : PageView 4 slides (textes officiels brainstorming §3.2), dots animés, bouton plein largeur 52px (lucide arrowRight / check), « Passer » slides 1-3
- Logique de redirection : token Firebase → /home ; sinon onboarding non vu → /onboarding ; sinon → /auth
- `flutter_svg` + `lucide_icons_flutter` ajoutés ; assets déclarés dans pubspec
- app_router : écran de test Jour 1 retiré, vraies routes + placeholders /auth /home
- 3 tests unitaires (flag Hive + resolveSplashRoute) — verts
- flutter analyze : 0 erreur

**Bloqué / Problème rencontré :**
- `flutter run` échoue : Platform SDK android-36 manquant (à installer via SDK Manager)

**Décision prise :**
- flutter_svg + lucide_icons_flutter ajoutés (voir tableau décisions) ; « Passer » marque l'onboarding complété

**Bugs découverts :**
- Aucun

**Prochain pas :**
- Installer Android SDK Platform 36 → vérifier le flux sur émulateur → Jour 3 (Authentification)

---

### Session 2 — 04 juin 2026 (suite) — Firebase Configuration + SDK Android Setup

**Fait :**
- `flutterfire configure` ✅ — Généré `lib/firebase_options.dart` avec app IDs
- `firebase deploy --only firestore:rules` ✅ — Règles Firestore déployées avec succès
- Créé `firestore.indexes.json` (vide pour MVP)
- Commenté packages V1.1 : lucide_icons, google_mobile_ads, pdf, printing, camera
- Remplacé lucide_icons par Material Icons (Icons.check_circle, etc.) dans app_router.dart
- Corrigé pubspec.yaml — cupertino_icons temporaire pour MVP
- Créé structure Android minimale : AndroidManifest.xml, MainActivity.kt, styles.xml
- Créé `android/local.properties` avec SDK et NDK paths
- Créé `android/app/build.gradle` moderne (Gradle plugins déclaratifs)
- Configuré NDK 28.2.13676358, compileSdk 36, buildToolsVersion 36.1.0
- **flutter doctor** : tout OK (Android toolchain, Emulator, SDK 36.1.0)

**Bloqué / Problème rencontré :**
- **Platform SDK android-36 manquant** — Gradle ne trouve pas l'API 36 dans le SDK
- Dépendances Kotlin (future breaking change, non-bloquant pour maintenant)

**Décision prise :**
- Lucide_icons remplacé temporairement par Material Icons (V1.1 réintroduira lucide_icons une fois compatible)
- Packages V1.1 (google_mobile_ads, pdf, printing, camera) commentés dans pubspec.yaml
- NDK 28.2.13676358 configuré (installé et trouvé)

**Bugs découverts :**
- Aucun bug code — tous les problèmes sont d'infrastructure SDK Android
- lucide_icons 0.257.0 incompatible avec Flutter 3.44.1 (IconData is final)
- google_mobile_ads 5.3.1/6.0.0 incompatible avec certaines versions Gradle

**Prochain pas :**
- Installer Platform SDK android-36 (voir instructions ci-dessous)
- Jour 2 : SplashScreen + Onboarding (en attente de SDK Android fix)

---

### Session 0 — 30 mai 2026 — Documentation complète
**Fait :**
- Création complète de tous les fichiers de documentation
- 4 skills personnalisés créés et documentés
- CLAUDE.md adapté de la méthode Karpathy pour Flutter/Firebase
- Plan de 20 jours structuré (6h/jour)

**Décision prise :**
- Toute la documentation est finalisée et prête pour le développement

**Prochain pas :**
- Documentation complète, maquettes validées, prêt à coder.

---

### Session 1 — 04 juin 2026 — Jour 1 : Setup Monorepo + Design System
**Fait :**
- Structure feature-first complète créée (lib/core/, lib/features/, lib/shared/)
- 7 fichiers de thème : KlinikColors, KlinikTypography, KlinikSpacing, KlinikRadius, KlinikShadows, KlinikAnimations, AppTheme
- GoRouter configuré avec écran de test du design system (temporaire)
- 3 widgets partagés : KlinikButton, KlinikCard, NetworkStatusIndicator
- main.dart avec ProviderScope + Firebase init (try/catch stub) + localisation
- firebase_options.dart stub compilable (à remplacer par flutterfire configure)
- firestore.rules + storage.rules + firebase.json complets et prêts au déploiement
- lucide_icons ^0.257.0 ajouté dans pubspec.yaml
- flutter analyze : 0 erreur, 0 warning

**Bloqué / Problème rencontré :**
- Firebase pas encore connecté : nécessite flutterfire configure (action manuelle)
- Voir section FIREBASE CI-DESSOUS pour les étapes exactes

**Décision prise :**
- Aucune nouvelle décision

**Bugs découverts :**
- Aucun

**Prochain pas :**
- Jour 2 : SplashScreen + Onboarding (4 slides) + logique Hive onboardingCompleted

---

## TEMPLATE — À COPIER-COLLER POUR CHAQUE SESSION

```markdown
### Session [N] — [Date] — [Sujet]
**Fait :**
- 

**Bloqué / Problème rencontré :**
- 

**Décision prise :**
- 

**Bugs découverts :**
- 

**Prochain pas :**
- 
```

---

## ARCHITECTURE DES FICHIERS DU PROJET (rappel pour Claude Code)

```
klinik-scan/                    ← Racine du monorepo
├── CLAUDE.md                   ← À lire EN PREMIER
├── pubspec.yaml                ← Packages Flutter
├── _project/                   ← Documentation projet
│   ├── idee.md                 ← Vision globale
│   ├── brainstorming.md        ← Fonctionnalités détaillées
│   ├── plan.md                 ← Plan 20 jours
│   ├── PROGRESS.md             ← Ce fichier — état actuel
│   └── DESIGN.md               ← Tokens visuels générés par claude design
├── klinik-skills/              ← Skills personnalisés
│   ├── klinik-firebase-rules/  ← Règles Firebase
│   ├── klinik-vision-module/   ← Module caméra
│   ├── klinik-offline-sync/    ← Synchronisation offline
│   └── klinik-design-system/   ← Design tokens & composants
├── lib/                        ← Code Flutter
│   ├── core/                   ← Thème, router, services globaux
│   ├── features/               ← Features (auth, patient, scan...)
│   └── shared/                 ← Widgets et modèles partagés
├── _admin/                     ← Super Admin Dashboard (Next.js)
├── _landing/                   ← Landing Page (Astro): bientôt disponible
└── functions/                  ← Cloud Functions Firebase (Node.js)
```

---

*Auteur : Redemona Christ (Ashad) — github.com/Ashad90*
*Projet : Klinik*
