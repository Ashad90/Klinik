# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Adapté des guidelines Andrej Karpathy pour un projet Flutter/Dart/Firebase.
> Projet : Application d'aide au triage médical — République Centrafricaine.
> Auteur du projet : Redemona Christ (Ashad)
> Dernière mise à jour : 11/06/2026

---

## PREMIÈRE ACTION OBLIGATOIRE

**Avant toute chose, lire `PROGRESS.md` à la racine du projet.**
Ce fichier est l'état réel du projet. Il prime sur toute autre source d'état.
Sans lui, Claude Code repart de zéro sur un projet déjà avancé.

**Avant de commencer chaque tâche donnée, il faut activer le skill compatible de cette tâche dans le dossier "klinik-skills", mais aussi rechercher dans mon OS et choisir le skill parfait pour le type de la tâche que tu vas réaliser, afin de booster les capacités de claude code (toi).


---

## Commandes Token Visuelle de l'application

Fetch this design file, read its readme, and implement the relevant aspects of the design. https://api.anthropic.com/v1/design/h/uE1p0e403Yv38IK3E-HjHA?open_file=Klinik-Scan%2FKlinik+-+Prototype.html
Implement: Klinik-Scan/Klinik - Prototype.html

## CONTEXTE DU PROJET

**Klinik-Scan** est un outil d'aide au triage médical pour agents de santé communautaires
en zones rurales d'Afrique Centrale (priorité RCA). Il fonctionne offline-first sur Android/iOS
(Flutter) avec un dashboard Smartphone/Tablette/Windows Desktop (V1.1) pour le médecin référent.

**Contrainte absolue :** Le réseau n'existe pas. L'app doit fonctionner totalement hors ligne
après la première connexion. Toute feature qui suppose un réseau disponible est une erreur
d'architecture.

**Contrainte légale absolue :** Klinik-Scan est une aide à la décision, jamais un outil de
diagnostic. Aucun code, message UI, commentaire ou log ne doit suggérer le contraire.

---

## CONFIGURATION FIREBASE (déjà faite — ne pas refaire)

Projet Firebase : **`klinik-95a79`**. `flutterfire configure` a été exécuté :
`lib/firebase_options.dart` est le fichier réel (plus un stub) et l'app parle à Firebase live
(auth + Firestore vérifiés E2E sur émulateur). Procédure de référence : `Method.md` à la racine.

- Règles Firestore déployées : **Option B, sans custom claims** (plan Spark gratuit).
  L'appartenance est dérivée de l'existence du doc `/entities/{entityId}/users/{uid}`
  (helpers `isMember`/`hasRole`/`isAdminOfEntity`), pas de `request.auth.token.entityId`.
- Redéployer les règles : `firebase deploy --only firestore:rules --project klinik-95a79`.
- **Ne PAS activer Blaze / Cloud Functions / FCM / email serveur / Storage** tant que le
  fondateur ne l'a pas annoncé (Option A réservée). `storage.rules` existe mais n'est pas
  déployé (Storage = V1.1, Blaze requis).

---

## COMMANDES DE DÉVELOPPEMENT

```bash
# Lancer l'app (Android — cible principale)
flutter run

# Lancer sur un appareil spécifique
flutter run -d <device-id>

# Analyser le code (obligatoire avant tout commit)
flutter analyze

# Lancer les tests
flutter test

# Lancer un seul test
flutter test test/path/to/test_file.dart

# Build APK release
flutter build apk --release

# Nettoyer le cache Flutter
flutter clean && flutter pub get
```

> **Riverpod sans codegen.** Bien que `riverpod_annotation` / `riverpod_generator` /
> `build_runner` soient dans `pubspec.yaml`, le code actuel n'utilise PAS `@riverpod` :
> tous les providers sont déclarés à la main (`final fooProvider = Provider<Foo>((ref) => …)`).
> Il n'y a aucun fichier `*.g.dart`. Suivre cette convention manuelle, ou ne migrer
> vers le codegen qu'après discussion. (`dart run build_runner build --delete-conflicting-outputs`
> n'est utile que si l'on introduit `@riverpod`.)

> **Build Android (machine actuelle).** Le run a été débloqué via deux fichiers de config
> (aucun code Dart) — voir `PROGRESS.md` § Session 5. Points durs : `kotlin.incremental=false`
> dans `android/gradle.properties` (projet sur `E:\`, cache Pub sur `C:\` → caches incrémentaux
> cross-disque impossibles), et override `compileSdk = 36` par sous-projet en `afterEvaluate`
> (avec garde `state.executed`) dans `android/build.gradle.kts`. Toolchain : Gradle 9.1 + AGP 9.0.
> `flutter run` se détache si lancé sans terminal interactif ; relancer l'APK installé via
> `adb shell am start -n com.klinik.klinik/.MainActivity`.

**Livrable considéré terminé seulement si :**
- Fonctionne sur un appareil Android réel (pas seulement l'émulateur)
- Fonctionne en mode hors ligne
- `flutter analyze` ne produit aucune erreur

---

## STACK TECHNIQUE (ne pas dévier sans discussion)

| Composant | Technologie | Remarque |
|---|---|---|
| App Mobile | Flutter 3.x / Dart 3.x | Android prioritaire, iOS secondaire (V1.2) |
| Desktop | Flutter Desktop (Windows) | V1.1 — pas dans le MVP V1 |
| Backend | Firebase (Auth, Firestore, Storage, Remote Config, FCM) | Pas d'autre backend |
| Cloud Functions | Node.js (Firebase Functions) | Dans `functions/` |
| Admin Web | Next.js | Dans `_admin/` — Super Admin uniquement |
| Landing Page | Astro | Dans `_landing/` |
| État global | Riverpod 2.x | Pas de Provider, pas de Bloc, pas de setState global |
| Navigation | GoRouter | Pas de Navigator.push direct pour les routes nommées |
| IA On-Device | MediaPipe Face Mesh Lite + google_mlkit_face_detection | **V1.1 — pas dans le MVP V1** |
| PDF | dart:pdf + printing | **V1.1 — commenté dans pubspec (problème Gradle)** |
| Offline queue | Hive (`hive_flutter`) + connectivity_plus | Pas de SQLite sauf si Hive insuffisant |
| Médias (photos/vidéos) | Cloudinary (upload via `http`) + image_picker | Uploads via SyncQueueService uniquement |
| Storage Firebase | Firebase Storage | PDF médicaux uniquement — **V1.1 (plan Blaze requis)** |
| Icônes | `lucide_icons_flutter` (fork) | Un seul package d'icônes — pas de Material Icons. Le fork remplace `lucide_icons` (incompatible Flutter 3.44+) |
| Vectoriel / logos | flutter_svg | Logos KMark (.svg) : splash, écrans auth |
| Fonts | Inter via google_fonts | Un seul font family |
| Audio | audioplayers | Sons embarqués (`assets/sounds/`) via AudioService |
| Auth tokens | flutter_secure_storage | Jamais SharedPreferences |
| Paiement | flutter_stripe | Abonnements agents de santé |
| Publicités | google_mobile_ads | **V1.1 — commenté dans pubspec (problème Gradle)** |

---

## ARCHITECTURE DU PROJET (feature-first — ne pas modifier sans discussion)

```
klinik/                         ← Racine du monorepo
├── CLAUDE.md                   ← Ce fichier
├── PROGRESS.md                 ← État réel du projet — lire EN PREMIER
├── pubspec.yaml                ← Packages Flutter
├── firestore.rules             ← Règles sécurité Firestore (isolation entités, validation immuable)
├── storage.rules               ← Règles Firebase Storage
├── firebase.json               ← Config déploiement Firebase
├── _project/                   ← Documentation projet
│   ├── idee.md                 ← Vision globale
│   ├── brainstorming.md        ← Fonctionnalités détaillées
│   ├── plan.md                 ← Plan 20 jours (6h/jour)
│   └── DESIGN.md               ← Tokens visuels — source canonique
├── klinik-skills/              ← Skills personnalisés (voir section ci-dessous)
├── tools/                      ← Scripts machine (show_emulator.ps1 / watch_emulator.ps1 :
│                                 fenêtre émulateur hors écran)
├── _admin/                     ← Super Admin Dashboard (Next.js) — non encore créé (V1.1)
├── _landing/                   ← Landing Page (Astro) — non encore créé
├── functions/                  ← Cloud Functions Firebase (Node.js) — non encore créé
└── lib/
    ├── core/
    │   ├── theme/              # KlinikColors, KlinikTypography, KlinikSpacing,
    │   │                       # KlinikRadius, KlinikShadows, KlinikAnimations, AppTheme
    │   ├── router/             # GoRouter configuration (app_router.dart, route_names.dart)
    │   ├── config/             # CloudinaryConfig
    │   ├── services/           # CloudinaryService (ConnectivityService, SyncQueueService,
    │   │                       # AudioService : à venir)
    │   └── utils/              # Validators, extensions, helpers
    ├── features/
    │   ├── auth/               # Login, inscription, multi-entités
    │   │   ├── data/           #   Repositories (AuthRepository, EntityRepository, SessionStore)
    │   │   ├── application/    #   auth_providers.dart + AuthController + JoinController
    │   │   └── presentation/   #   AuthChoice, Login, CreateEntity, JoinEntity, ActivateAccount,
    │   │                       #   PendingRequests (approbation admin)
    │   ├── onboarding/         # 4 slides, skip logic (fichiers plats)
    │   ├── home/               # Accueil minimal (entité + rôle + déconnexion)
    │   ├── patient/            # Création, liste, recherche locale — À VENIR
    │   ├── scan/               # Questionnaire, température (vision en V1.1) — À VENIR
    │   ├── validation/         # Dashboard médecin, validation, PDF — À VENIR
    │   └── settings/           # Profil, notifications, sync, mise à jour — À VENIR
    ├── shared/
    │   ├── widgets/            # KlinikButton, KlinikCard, KlinikTextField, NetworkStatusIndicator
    │   └── models/             # Modèles partagés (AppUser, Entity, EntityType, UserRole)
    └── main.dart
```

**Couches internes d'une feature (convention établie par `auth/`) :**
- `data/` — repositories : seule couche autorisée à toucher Firestore/Auth/Secure Storage.
  Chaque repository reçoit ses dépendances par constructeur (`const Repo(this._db)`), jamais via
  `BuildContext` ni de singleton global.
- `application/` — providers Riverpod (`*_providers.dart`) qui câblent les sources Firebase
  (`firebaseAuthProvider`, `firestoreProvider`, `secureStorageProvider`) aux repositories/services.
- racine de la feature ou `presentation/` — écrans et widgets de la feature.
- `onboarding/` est encore en fichiers plats (`*_screen.dart`, `*_provider.dart`) ; toute nouvelle
  feature suit le découpage `data/` + `application/` ci-dessus.

**Patterns d'architecture confirmés par le code :**
- **Session sans custom claims.** Les custom claims Firebase sont déférés (plan Blaze requis).
  La session (`uid`, `entityId`, `role`) est amorcée à l'inscription/connexion et stockée dans
  Flutter Secure Storage via `SessionStore` (`AuthSession`). `currentSessionProvider` la relit.
  Côté règles Firestore, l'appartenance est dérivée du doc `/entities/{id}/users/{uid}`
  (Option B — voir section Configuration Firebase).
- **Isolation multi-entités.** Tout document vit sous `/entities/{entityId}/…`
  (ex. `EntityRepository.createEntityWithAdmin` écrit `entities/{id}` + `entities/{id}/users/{uid}`
  via un `batch().commit()` atomique). Aucune query ne traverse une frontière `entityId`.
- **Offline-first.** Les écritures Firestore (y compris les `batch`) se résolvent sur le cache
  local hors ligne — ne pas attendre le réseau ni afficher d'erreur.
- **Cloudinary** : `core/services/cloudinary_service.dart` + `core/config/cloudinary_config.dart`
  (médias). PDF médicaux → Firebase Storage (V1.1).

**État actuel — la source de vérité reste `PROGRESS.md`.** Au dernier point : Jour 3 terminé —
parcours auth vérifié E2E sur émulateur (création d'entité → Login → Home avec entité + rôle),
règles Option B déployées, lectures Firestore débloquées. Jour 4 en cours : les écrans
« Rejoindre une entité » (`join_entity_screen`, `activate_account_screen`) existent mais leurs
backends sont des `TODO(jour4)`.

**Règle stricte :** chaque feature est autonome. Une feature ne doit jamais importer
directement depuis une autre feature. Passer par `core/` ou `shared/` si besoin.

---

## SKILLS À CHARGER (lire avant tout travail sur le domaine correspondant)

Ces fichiers sont dans `klinik-skills/` à la racine du projet.
Claude Code DOIT les lire avant d'écrire du code dans leur domaine.

| Domaine | Skill à lire |
|---|---|
| Firestore, Firebase Auth, FCM, Storage | `klinik-skills/klinik-firebase-rules/SKILL.md` |
| Caméra, analyse faciale, MediaPipe, vision | `klinik-skills/klinik-vision-module/SKILL.md` |
| Offline, synchronisation, réseau, Hive | `klinik-skills/klinik-offline-sync/SKILL.md` |
| Tout widget, couleur, typo, écran Flutter | `klinik-skills/klinik-design-system/SKILL.md` |

**Priorité des tokens visuels :** `_project/DESIGN.md` fait foi sur `klinik-design-system/SKILL.md`
en cas de divergence de valeurs. La maquette prime toujours.

---

## ÉTAT ACTUEL DU PROJET

> ⚠️ Cette section n'est pas maintenue ici. Lire **`PROGRESS.md`** à la racine.
> Ce fichier est mis à jour par le développeur après chaque session de travail.

### Décisions prises (ne pas revenir dessus sans discussion)
- Riverpod 2.x choisi pour la gestion d'état (pas Bloc, pas Provider)
- GoRouter pour la navigation — deep linking natif, redirection basée sur rôle
- Feature-first folder structure — chaque feature autonome
- VisionMetrics contribue max 40% du score de risque total
- Module Vision reporté en V1.1 (pas dans le MVP V1) — prioriser la stabilité du core
- iOS reporté en V1.2 si seuil 500 utilisateurs Android atteint
- Cloudinary pour les médias (photos, vidéos, ordonnances scannées) — uploads via SyncQueueService
- Firebase Storage uniquement pour les PDF médicaux
- `lucide_icons_flutter` (fork) comme package d'icônes unique
- Code d'accès 6 caractères alphanumériques (pas 4 chiffres) — 2,17 milliards de combinaisons
- Rôle système assigné par l'admin uniquement (pas auto-déclaré)
- Questions frissons et palpitations séparées (correctitude clinique)

---

## RÈGLES COMPORTEMENTALES (Karpathy — conservées intégralement)

### 1. Réfléchir avant de coder

**Ne pas supposer. Ne pas cacher la confusion. Exposer les compromis.**

Avant d'implémenter :
- Énoncer les hypothèses explicitement. En cas d'incertitude, demander.
- Si plusieurs interprétations existent, les présenter — ne pas choisir silencieusement.
- Si une approche plus simple existe, le dire. Repousser si justifié.
- Si quelque chose est flou, s'arrêter. Nommer ce qui est confus. Demander.

### 2. Simplicité d'abord

**Code minimum qui résout le problème. Rien de spéculatif.**

- Pas de features au-delà de ce qui a été demandé.
- Pas d'abstractions pour du code à usage unique.
- Pas de "flexibilité" ou "configurabilité" non demandées.
- Pas de gestion d'erreurs pour des scénarios impossibles.
- Si tu écris 200 lignes et que ça pourrait tenir en 50, réécris.

Se demander : "Un senior engineer dirait-il que c'est trop compliqué ?" Si oui, simplifier.

### 3. Modifications chirurgicales

**Toucher uniquement ce qui est nécessaire. Ne nettoyer que son propre désordre.**

Lors de la modification de code existant :
- Ne pas "améliorer" le code adjacent, les commentaires ou le formatage.
- Ne pas refactoriser ce qui n'est pas cassé.
- Respecter le style existant, même si on ferait différemment.
- Si du code mort non lié est remarqué, le mentionner — ne pas le supprimer.

Quand les changements créent des orphelins :
- Supprimer les imports/variables/fonctions que TES changements ont rendus inutilisés.
- Ne pas supprimer le code mort préexistant sauf si demandé.

Le test : chaque ligne modifiée doit se tracer directement à la demande.

### 4. Exécution orientée objectifs

**Définir les critères de succès. Boucler jusqu'à vérification.**

Transformer les tâches en objectifs vérifiables :
- "Ajouter la validation" → "Écrire des tests pour les entrées invalides, puis les faire passer"
- "Corriger le bug" → "Écrire un test qui le reproduit, puis le faire passer"
- "Refactoriser X" → "S'assurer que les tests passent avant et après"

Pour les tâches multi-étapes, énoncer un plan bref :
```
1. [Étape] → vérifier : [contrôle]
2. [Étape] → vérifier : [contrôle]
3. [Étape] → vérifier : [contrôle]
```

---

## RÈGLES SPÉCIFIQUES KLINIK-SCAN (non négociables)

### Firebase & Données

- **Jamais** d'appel Firestore direct depuis un widget ou un controller.
  Toujours passer par le Repository pattern défini dans `klinik-firebase-rules`.
- **Jamais** de requête qui traverse les frontières d'une entité (`entityId`).
  Chaque query Firestore doit inclure le chemin `/entities/{entityId}/`.
- **Jamais** de suppression de validations. Archiver uniquement.
- Les tokens d'authentification sont stockés dans Flutter Secure Storage.
  Jamais dans SharedPreferences.

### Offline

- **Jamais** de toast d'erreur pour une écriture offline.
  Firestore gère les writes offline silencieusement — ne pas interférer.
- **Jamais** de blocage UI en attente d'une confirmation Firestore.
- Les uploads de médias (photos, vidéos) passent **toujours** par `SyncQueueService`.
  Jamais d'upload direct Cloudinary ou Firebase Storage.

### Module Vision (V1.1 uniquement)

- Les métriques visuelles sont des **indicateurs**, jamais des **diagnostics**.
  Le mot "diagnostic" est interdit dans tout code du module vision.
- La confiance (`overallConfidence`) doit toujours être affichée avec les métriques.
- Si `overallConfidence < 0.5`, les métriques ne sont pas affichées à l'agent.
  Afficher à la place : *"Repositionnez le visage face à la caméra."*
- Le disclaimer médical est obligatoire sur chaque écran affichant des métriques vision.

### Design & UI

- **Jamais** de couleur hardcodée en hexadécimal dans un widget.
  Toujours utiliser `KlinikColors.*`.
- **Jamais** de fontSize qui ne correspond pas aux 4 tailles définies dans `KlinikTypography`.
- **Jamais** de spacing qui ne soit pas sur la grille 8pt (`KlinikSpacing.*`).
- `NetworkStatusIndicator` est présent sur chaque écran avec une AppBar.
  Ne jamais le retirer.
- Tap targets minimum **48x48 dp**. **52dp** pour les boutons du module scan.

### État global

- **Jamais** de `setState` pour un état partagé entre plusieurs widgets.
  Utiliser Riverpod (`StateNotifier`, `AsyncNotifier`, `Provider`).
- **Jamais** de `BuildContext` passé à un service ou repository.
- Les providers Riverpod sont définis dans le fichier `*_provider.dart`
  de chaque feature, pas dans les widgets.

### Refactoring

- Ne jamais refactoriser une feature qui fonctionne sans que ce soit
  explicitement demandé.
- Ne jamais changer les règles Firestore sans en discuter d'abord.
- Ne jamais changer le schéma de données Firestore sans mettre à jour
  simultanément le skill `klinik-firebase-rules`.

---

## INTERDITS ABSOLUS

Ces actions nécessitent une discussion explicite avant toute implémentation :

1. Ajouter un package non listé dans la section Stack Technique.
2. Modifier la structure des dossiers `lib/`.
3. Changer le schéma Firestore (`/entities/{entityId}/...`).
4. Modifier les règles de sécurité Firestore.
5. Ajouter un backend autre que Firebase.
6. Implémenter le Dashboard Windows Desktop ou le Module Vision (réservés à la V1.1).
7. Utiliser `setState` pour de l'état global.
8. Écrire du code qui suppose une connexion réseau disponible sans fallback offline.

---

## FORMAT DE RÉPONSE ATTENDU

Pour toute tâche de développement, Claude Code structure sa réponse ainsi :

```
## Hypothèses
[Ce que j'assume sur la demande]

## Plan
1. [Étape] → vérifier : [contrôle]
2. [Étape] → vérifier : [contrôle]

## Implémentation
[Code]

## Ce qui n'a PAS été fait (et pourquoi)
[Features proches mais non demandées, explicitement écartées]
```

---

> **Ces guidelines fonctionnent si :** moins de diffs inutiles, moins de réécritures
> dues à la sur-ingénierie, et les questions de clarification viennent avant
> l'implémentation plutôt qu'après les erreurs.
>
> — Adapté de Andrej Karpathy pour Klinik-Scan
