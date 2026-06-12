# Klinik-Scan

> Outil d'aide au triage médical **offline-first** pour les agents de santé communautaires
> en zones rurales d'Afrique Centrale — priorité **République Centrafricaine 🇨🇫**.

**Klinik-Scan** est une aide à la décision médicale — **jamais un outil de diagnostic**. Il
permet de créer une fiche patient, réaliser un scan de triage (température + questionnaire
clinique guidé, + analyse visuelle en V1.1), obtenir un score de risque (0–10), transmettre le
dossier à un médecin référent pour validation, et générer les documents médicaux officiels —
le tout en fonctionnant **totalement hors ligne après la première connexion**.

- **Auteur :** Redemona Christ (Ashad) — Développeur Fullstack, [github.com/Ashad90](https://github.com/Ashad90)
- **Pays :** République Centrafricaine (Bangui)
- **Contact :** redemonachrist@gmail.com

---

## Table des matières

- [Le problème](#le-problème)
- [La solution](#la-solution)
- [Les 5 produits Klinik](#les-5-produits-klinik)
- [Différenciateurs](#différenciateurs)
- [Stack technique](#stack-technique)
- [Architecture du projet](#architecture-du-projet)
- [Rôles utilisateurs](#rôles-utilisateurs)
- [Modèle économique](#modèle-économique)
- [Multilinguisme](#multilinguisme)
- [Contraintes non négociables](#contraintes-non-négociables)
- [Démarrage](#démarrage)
- [Configuration Firebase](#configuration-firebase)
- [Commandes de développement](#commandes-de-développement)
- [État actuel](#état-actuel)
- [Confidentialité des données](#confidentialité-des-données)
- [Documentation du projet](#documentation-du-projet)

---

## Le problème

Dans les zones rurales d'Afrique Centrale, des milliers d'agents de santé communautaires
travaillent sans réseau mobile, sans protocole de triage standardisé et sans accès en temps
réel à un médecin référent. Trois problèmes structurels :

1. **Le vide de validation** — un dossier urgent peut attendre des heures sans qu'aucun médecin ne le prenne en charge.
2. **L'absence de reconnaissance du travail terrain** — aucune trace formelle de la contribution des soignants.
3. **L'invisibilité du propriétaire** — pas de tableau de bord pour piloter la croissance et les revenus.

---

## La solution

### Côté utilisateurs (App Flutter)

1. **Créer une fiche patient** en quelques secondes, en mode connecté **ou** hors ligne (architecture dual-mode transparente).
2. **Réaliser un scan de triage** — température (manuelle ou caméra thermique USB-C optionnelle), questionnaire clinique guidé, analyse visuelle assistée (V1.1).
3. **Obtenir un score de risque** (0 à 10) avec code couleur immédiat.
4. **Transmettre le dossier** avec notification simultanée à tous les médecins disponibles de l'entité (système **Claim**).
5. **Valider** et produire les documents médicaux officiels via un **circuit hybride numérique-physique** (PDF généré → signature + cachet manuscrits → numérisation → upload tracé).
6. **Accumuler des points et badges** de reconnaissance à chaque action.

### Côté propriétaire (Super Admin Dashboard Web)

7. Statistiques globales temps réel (utilisateurs, scans, validations, pays, gamification agrégée).
8. Pilotage de la monétisation (abonnements, MRR/ARR, conversion, churn).
9. Surveillance technique (erreurs Firebase, synchronisations en attente, quotas).
10. Gestion des entités clientes (activation, suspension, changement de plan).

> **Le Super Admin n'a jamais accès aux données patients identifiables.** Il ne voit que des
> agrégats anonymisés produits par des Cloud Functions — contrainte appliquée **côté serveur**
> dans les règles Firestore, pas seulement dans l'UI.

---

## Les 5 produits Klinik

| # | Produit | Stack | Cible | Statut |
|---|---|---|---|---|
| 1 | **App Mobile** | Flutter 3.x / Dart 3.x | Agents, infirmiers, médecins, docteurs, admins d'entité (Android API 21+, ≥ 2 Go RAM) | **MVP V1 — en cours** |
| 2 | **Dashboard Desktop** | Flutter Desktop (Windows) | Médecins référents (grand écran) | V1.1 |
| 3 | **Super Admin Dashboard** | Next.js 14 + TypeScript + Tailwind + shadcn/ui | Ashad uniquement | Planifié (`_admin/`) |
| 4 | **Landing Page** | Astro 4.x + Tailwind + shadcn/ui | Présentation publique | Planifié (`_landing/`) |
| 5 | **Cloud Functions** | Node.js 20 + TypeScript | Analytics, gamification, paiements, notifications | Planifié (`functions/`) |

---

## Différenciateurs

1. **Architecture Dual-Mode** — comportement identique online/offline, synchronisation opportuniste automatique, aucune donnée perdue.
2. **Module Vision (V1.1)** — analyse faciale temps réel via caméra RGB (MediaPipe Face Mesh Lite < 2 MB, 100% offline) ; extension caméra thermique USB-C optionnelle (FLIR Lepton, ±0.5°C).
3. **Système Claim** — broadcast à tous les médecins ; premier à prendre en charge = transaction Firestore atomique (impossibilité technique de double traitement).
4. **Documents médicaux PDF** — formulaire de consultation + ordonnance (template conforme aux pratiques centrafricaines), avec circuit hybride numérique-physique pour valeur légale terrain.
5. **Gamification médicale** — points par rôle + badges exportables (rapports officiels pour jurys hospitaliers), calcul **exclusivement côté serveur**.
6. **Ancrage local** — paiement Mobile Money en priorité (Orange/Airtel/MTN/Moov Money), Stripe en secondaire, virement en tertiaire.
7. **Vision propriétaire** — Super Admin Dashboard temps réel sans jamais exposer de données patients identifiables.

---

## Stack technique

> Ne pas dévier de cette stack sans discussion explicite.

| Composant | Technologie | Remarque |
|---|---|---|
| App Mobile | Flutter 3.x / Dart 3.x | Android prioritaire, iOS V1.2 (si seuil 500 users Android) |
| Desktop | Flutter Desktop (Windows) | V1.1 |
| Backend | Firebase (Auth, Firestore, Storage, Remote Config, FCM) | Pas d'autre backend |
| Cloud Functions | Node.js 20 + TypeScript | Dans `functions/` |
| Admin Web | Next.js 14 + TypeScript | Dans `_admin/` |
| Landing Page | Astro 4.x | Dans `_landing/` |
| État global | Riverpod 2.x | Pas de Provider, pas de Bloc, pas de setState global |
| Navigation | GoRouter | Pas de Navigator.push pour les routes nommées |
| IA on-device | MediaPipe Face Mesh Lite + google_mlkit_face_detection | **V1.1** |
| PDF | dart:pdf + printing | **V1.1 — commenté (problème Gradle)** |
| Offline queue | Hive (`hive_flutter`) + connectivity_plus | Pas de SQLite sauf si Hive insuffisant |
| Médias | Cloudinary (upload via `http`) + image_picker | Uploads via SyncQueueService uniquement |
| Storage Firebase | Firebase Storage | PDF médicaux — **V1.1 (plan Blaze requis)** |
| Icônes | `lucide_icons_flutter` (fork) | Un seul package — remplace `lucide_icons` (incompatible Flutter 3.44+) |
| Vectoriel / logos | flutter_svg | Logos KMark (.svg) : splash, auth |
| Fonts | Inter via google_fonts | Un seul font family |
| Audio | audioplayers | Sons embarqués (`assets/sounds/`) |
| Auth tokens | flutter_secure_storage | Jamais SharedPreferences |
| Paiement | flutter_stripe + Mobile Money REST (via Cloud Functions) | Orange / Airtel / MTN / Moov Money |
| Publicités | google_mobile_ads | **V1.1 — commenté (problème Gradle)** |
| i18n | flutter_localizations + intl (.arb) | FR / EN / ES en V1 |

---

## Architecture du projet

Monorepo **feature-first**. Chaque feature est autonome : elle ne doit **jamais** importer
directement depuis une autre feature — passer par `core/` ou `shared/`.

```
klinik/                          ← Racine du monorepo
├── CLAUDE.md                    ← Règles projet pour Claude Code (méthode Karpathy)
├── PROGRESS.md                  ← État réel du projet — source de vérité
├── README.md                    ← Ce fichier
├── Method.md                    ← Procédure de configuration Firebase
├── pubspec.yaml                 ← Packages Flutter
├── firestore.rules              ← Sécurité Firestore (isolation entités, validation immuable)
├── storage.rules                ← Sécurité Firebase Storage
├── firebase.json                ← Config déploiement Firebase
├── _project/                    ← Documentation projet
│   ├── idee.md                  ← Vision globale (source de vérité produit)
│   ├── brainstorming.md         ← Fonctionnalités détaillées
│   ├── plan.md                  ← Plan 20 jours (6h/jour)
│   └── DESIGN.md                ← Tokens visuels — source canonique
├── klinik-skills/               ← Skills Claude Code personnalisés
│   ├── klinik-firebase-rules/   ← Architecture Firebase, sécurité, patterns
│   ├── klinik-vision-module/    ← Module caméra, MediaPipe, métriques
│   ├── klinik-offline-sync/     ← SyncQueue, Hive, ConnectivityService
│   └── klinik-design-system/    ← Tokens couleur, typo, composants
├── _admin/                      ← Super Admin Dashboard (Next.js) [planifié]
├── _landing/                    ← Landing Page (Astro) [planifié]
├── functions/                   ← Cloud Functions Firebase (Node.js) [planifié]
└── lib/
    ├── core/
    │   ├── theme/               # KlinikColors, KlinikTypography, KlinikSpacing,
    │   │                        # KlinikRadius, KlinikShadows, KlinikAnimations, AppTheme
    │   ├── router/              # GoRouter (app_router.dart, route_names.dart)
    │   ├── services/            # ConnectivityService, SyncQueueService, AudioService [à venir]
    │   └── utils/               # Extensions, helpers [à venir]
    ├── features/
    │   ├── onboarding/          # Splash + 4 slides + skip logic (Hive onboardingCompleted)
    │   ├── auth/                # Login, inscription, multi-entités [à venir]
    │   ├── patient/             # Création, liste, recherche locale [à venir]
    │   ├── scan/                # Questionnaire, température (vision V1.1) [à venir]
    │   ├── validation/          # Dashboard médecin, validation, PDF [à venir]
    │   └── settings/            # Profil, notifications, sync [à venir]
    ├── shared/
    │   ├── widgets/             # KlinikButton, KlinikCard, NetworkStatusIndicator
    │   └── models/              # Modèles de données partagés [à venir]
    └── main.dart
```

### Cloud Functions prévues

`aggregateAnalytics` · `calculatePoints` · `assignBadges` · `resetMonthlyQuotas` ·
`orangeMoneyWebhook` · `airtelMoneyWebhook` · `stripeWebhook` ·
`sendWhatsAppNotif` (V2) · `sendSMSNotif` (V2) · `claimTimeoutCheck` (V1.1)

---

## Rôles utilisateurs

| Rôle | Capacités principales | Points |
|---|---|---|
| **Super Admin / Propriétaire** | Pilotage business/technique (Dashboard Web), données agrégées uniquement | — |
| **Administrateur d'entité** | Gestion des membres, approbation inscriptions, codes d'invitation, plan d'abonnement | — |
| **Docteur / Spécialiste** | Claim & validation, PDF consultation + ordonnance, référencement inter-entités, métriques Vision complètes + vidéo | +5 / validation |
| **Médecin généraliste** | Claim & validation, PDF consultation, métriques Vision | +3.5 / validation |
| **Infirmier / Sage-femme** | Création patients, scans complets, soumission dossiers | +2 / consultation validée |
| **Agent de santé communautaire** | Création patients, scans complets, soumission dossiers | +1 / consultation validée |

> Le **rôle système est assigné par l'admin uniquement** (pas auto-déclaré). Code d'accès :
> 6 caractères alphanumériques.

---

## Modèle économique

### Plans d'abonnement

| Plan | Cible | Prix | Scans/mois | Comptes | Pubs |
|---|---|---|---|---|---|
| **Starter** | Dispensaires, petits centres | Gratuit | 100 | 4 (1 admin + 3) | Complètes |
| **Basic** | Centres en croissance | 10 $/mois | 200 | 6 | Réduites |
| **Pro** | Cliniques | 29 $/mois | 500 | 10 | Aucune |
| **Équipe** | Hôpitaux, ONG locales | 79 $/mois | 2 000 | Illimité | Aucune |
| **Entreprise** | Grandes ONG, hôpitaux nationaux | Sur devis | Illimité | Illimité | Aucune |

Nouvelle entité → plan Starter par défaut, avec **6 mois d'essai gratuit sur le plan Pro**.
Facturation mensuelle ou annuelle (−15 % à l'année).

### Sources de revenus

1. **Abonnements SaaS** (revenu principal récurrent).
2. **Publicités AdMob** (plans Starter & Basic uniquement) — jamais pendant un scan, une validation médicale ou un écran d'urgence (score ≥ 7).
3. **Contrats Entreprise** (devis : déploiement, formation, SLA, branding, rapport annuel).

### Paiement — stratégie hybride par marché

Mobile Money prioritaire (**Orange / Airtel / MTN / Moov Money** en XAF/CDF/UGX via Cloud
Functions) → **Stripe** secondaire (ONG internationales) → **virement bancaire** tertiaire
(Entreprise). Aucune clé secrète de paiement dans le code Flutter ; tout passe par une Cloud
Function serveur.

---

## Multilinguisme

| Version | Langues |
|---|---|
| **V1 (MVP)** | Français, Anglais, Espagnol |
| **V2** | + Sango (langue nationale centrafricaine) |

Toutes les chaînes UI externalisées en `.arb` dès la V1. Changement de langue depuis les
Paramètres sans redémarrage.

---

## Contraintes non négociables

1. **Légale** — aide à la décision uniquement. Le mot « diagnostic » est interdit dans toute l'UI (utiliser « observation », « indicateur », « aide à la décision »).
2. **Confidentialité patients** — le Super Admin ne voit jamais de données identifiables (appliqué côté serveur dans les règles Firestore).
3. **Dual-mode réseau** — comportement identique online/offline ; aucun écran bloqué par l'absence de réseau.
4. **Paiement sécurisé** — aucune clé secrète dans le code Flutter ; tout via Cloud Function.
5. **Points & badges** — calcul exclusivement côté serveur.
6. **Validation unique** — un dossier claimé n'est validable que par le médecin l'ayant claimé (transaction atomique).
7. **Isolation des entités** — chaque requête Firestore inclut `/entities/{entityId}/` ; jamais de requête inter-entités.
8. **Performance** — fluide sur Android 2 Go RAM ; modèles IA ≤ 20 MB ; sessions vision ≤ 30 s.

---

## Démarrage

### Prérequis

- Flutter 3.x / Dart SDK `>=3.9.0 <4.0.0`
- Android SDK (API 21+ ; le projet cible compileSdk 36)
- Un projet Firebase (voir [Configuration Firebase](#configuration-firebase))

### Installation

```bash
flutter pub get
flutter run        # Android — cible principale
```

> ⚠️ `lib/firebase_options.dart` doit avoir été généré par `flutterfire configure` pour que
> l'app se connecte à Firebase. Sans cela, l'app tourne hors ligne sans backend.

---

## Configuration Firebase

Procédure complète dans [`Method.md`](Method.md). Résumé :

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure                          # génère lib/firebase_options.dart + google-services.json
firebase use <project-id>
firebase deploy --only firestore:rules         # storage en stand-by V1.1 (plan Blaze requis)
flutter run
```

Activer dans la console : Authentication (Email/Password), Firestore (mode Production),
Storage, FCM, Remote Config.

---

## Commandes de développement

```bash
flutter run                                              # Lancer l'app (Android)
flutter run -d <device-id>                               # Sur un appareil spécifique

# Exemple: 

# Terminal 1
flutter emulators --launch Pixel_7_Pro

# Terminal 2 (après affichage de l'écran Android)
flutter devices          # vérifier l'id
flutter run -d emulator-5554

flutter analyze                                          # Obligatoire avant tout commit
flutter test                                             # Tous les tests
flutter test test/path/to/test_file.dart                # Un seul test
dart run build_runner build --delete-conflicting-outputs # Générer le code Riverpod
dart run build_runner watch --delete-conflicting-outputs # Watch mode
flutter build apk --release                              # Build APK release
flutter clean && flutter pub get                         # Nettoyer le cache
```

**Un livrable est terminé seulement s'il :** fonctionne sur un appareil Android réel,
fonctionne hors ligne, et `flutter analyze` ne produit aucune erreur.

---

## État actuel

> Source de vérité : [`PROGRESS.md`](PROGRESS.md).

**Phase : Développement — Semaine 1.** Jour 2 terminé (code complet).

- ✅ Design System complet (`lib/core/theme/`) + GoRouter (`lib/core/router/`)
- ✅ Widgets partagés : `KlinikButton`, `KlinikCard`, `NetworkStatusIndicator`
- ✅ Feature `onboarding/` : splash, 4 slides, persistance Hive `onboardingCompleted`
- ✅ Règles Firestore déployées ; `firebase_options.dart` généré
- 🔄 Run Android bloqué par l'environnement (réseau Gradle / RAM / dossier OneDrive), **pas par le code**
- ⏭️ Prochain pas : 1 build réussi → vérifier le flux → Jour 3 (Authentification)

---

## Confidentialité des données

- **Isolation totale entre entités** — appliquée au niveau des Firestore Security Rules (côté serveur). Un médecin de l'entité A ne peut jamais accéder aux dossiers de l'entité B.
- **Aucun accès propriétaire aux données patients** — le Super Admin Dashboard ne montre que des agrégats anonymisés.
- **Hébergement** — Google Firebase (GCP, centres ISO 27001), chiffrement en transit (TLS 1.3) et au repos (AES-256). Médias sur Cloudinary avec accès restreint par entité.
- **Conservation** — données patients supprimées dans les 90 jours suivant la résiliation, sur demande de l'admin d'entité.

Politique complète : voir `_project/idee.md` § Politique de Confidentialité.

---

## Documentation du projet

| Fichier | Contenu |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Règles de travail pour Claude Code (méthode Karpathy adaptée) |
| [`PROGRESS.md`](PROGRESS.md) | État réel, journal de bord, décisions — **à lire en premier** |
| [`Method.md`](Method.md) | Procédure de configuration Firebase pas à pas |
| `_project/idee.md` | Vision globale, modèle économique, politique de confidentialité |
| `_project/brainstorming.md` | Fonctionnalités, flux, cas d'usage terrain |
| `_project/plan.md` | Plan de travail 20 jours (6h/jour) |
| `_project/DESIGN.md` | Tokens visuels — source canonique du design |
| `klinik-skills/*/SKILL.md` | Skills par domaine (Firebase, vision, offline-sync, design system) |

---

*Klinik-Scan — Redemona Christ (Ashad) · [github.com/Ashad90](https://github.com/Ashad90) · République Centrafricaine 🇨🇫*
