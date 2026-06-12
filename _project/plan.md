# plan.md — Plan de Travail Opérationnel Klinik-Scan

> Feuille de route officielle du projet — lue par Claude Code au début de chaque session.
> Basée sur une disponibilité de **6 heures/jour**, 5 jours/semaine.
> Chaque livrable est **testable et vérifiable** avant de passer à l'étape suivante.
> Dernière mise à jour : 30 mai 2026

---

## RÈGLE D'OR DU PLAN

**Avant de commencer chaque session de travail avec Claude Code :**
1. Lire `PROGRESS.md` pour savoir exactement où tu en es
2. Mettre à jour la section "En cours" dans `PROGRESS.md`
3. Donner à Claude Code le contexte : "Nous en sommes à [Sprint X, Jour Y]"
4. À la fin de chaque session, mettre à jour `PROGRESS.md`

**Un livrable n'est considéré terminé que si :**
- Il fonctionne sur un appareil Android réel (pas seulement l'émulateur)
- Il fonctionne en mode hors ligne
- Il ne produit aucune erreur dans la console Flutter

---

## VUE D'ENSEMBLE — 4 SEMAINES

```
SEMAINE 1 — Fondations (Jours 1-5)
  Monorepo Flutter, Firebase, Auth multi-entités,
  workflow inscription complet, navigation, design system

SEMAINE 2 — Cœur métier (Jours 6-10)
  Module patient, module scan, questionnaire,
  score de risque, système Claim, notifications FCM

SEMAINE 3 — Validation & Documents (Jours 11-15)
  Dashboard médecin, validation, PDF consultation,
  circuit hybride ordonnance, gamification backend

SEMAINE 4 — Finitions & Livraison (Jours 16-20)
  Sons, paramètres, AdMob, mise à jour in-app,
  landing page, tests terrain, APK final
```

---

## SEMAINE 1 — FONDATIONS

### Jour 1 — Setup Monorepo & Firebase (6h)

**Objectif :** L'environnement de développement est 100% fonctionnel.
Claude Code peut commencer à coder sans obstacle technique.

**Tâches :**

```
[H1-H2] Setup monorepo Flutter
  → Créer le projet Flutter avec la structure feature-first :
    lib/core/, lib/features/, lib/shared/
  → Configurer pubspec.yaml avec tous les packages définis dans CLAUDE.md
  → Configurer l'architecture Riverpod (ProviderScope dans main.dart)
  → Configurer GoRouter avec les routes de base

[H3-H4] Configuration Firebase
  → Créer le projet Firebase (Auth, Firestore, Storage, FCM, Remote Config)
  → Intégrer FlutterFire CLI dans le projet
  → Activer Firestore offline persistence (cache illimité)
  → Configurer les règles Firestore initiales (lecture skill klinik-firebase-rules)
  → Configurer Firebase Storage rules

[H5-H6] Design System & Thème
  → Créer lib/core/theme/klinik_colors.dart (tous les tokens couleur)
  → Créer lib/core/theme/klinik_typography.dart (Inter via google_fonts)
  → Créer lib/core/theme/klinik_spacing.dart (grille 8pt)
  → Créer lib/shared/widgets/klinik_button.dart (primary + secondary)
  → Créer lib/shared/widgets/klinik_card.dart
  → Configurer lucide_icons dans pubspec.yaml
```

**✅ Vérification fin Jour 1 :**
- `flutter run` lance l'app sans erreur
- L'app se connecte à Firebase (visible dans la console Firebase)
- Les tokens de couleur s'affichent correctement sur un écran de test

---

### Jour 2 — Splash Screen & Onboarding (6h)

**Objectif :** Le premier écran que voit l'utilisateur est parfait.

**Tâches :**

```
[H1-H2] Splash Screen
  → Écran avec logo centré, fond primary (#1565C0)
  → Vérification token Firebase Auth local
  → Navigation automatique : si token valide → Accueil,
    sinon → Onboarding (si première fois) ou Auth (si déjà vu)
  → Logique onboardingCompleted stockée dans Hive

[H3-H5] Onboarding (4 slides)
  → Slides avec titre + illustration + description
  → Bouton "Suivant" slides 1-3, "Commencer" slide 4
  → Bouton "Passer" coin haut droit (slides 1-3 uniquement)
  → Dots indicateur de progression
  → Animation de transition entre slides (PageView)
  → Stockage onboardingCompleted dans Hive au tap "Commencer"

[H6] Navigation & Tests
  → Tester le flux complet : Splash → Onboarding → Auth
  → Tester le bypass : Splash → Accueil (si token valide)
  → Tester "Passer" → Auth direct
```

**✅ Vérification fin Jour 2 :**
- L'onboarding ne se réaffiche jamais après la première complétion
- Le "Passer" fonctionne depuis les slides 1, 2, 3 uniquement
- La navigation splash → destination correcte fonctionne

---

### Jour 3 — Authentification — Créer une entité (6h)

**Objectif :** Un admin peut créer une nouvelle entité et se connecter.

**Tâches :**

```
[H1-H2] Écran d'authentification (base)
  → Deux options : "Créer une entité" / "Rejoindre une entité"
  → Écran de connexion (email + mot de passe)
  → Firebase Auth login avec persistance locale du token

[H3-H5] Flux "Créer une entité" — Étape 1 & 2
  → Étape 1 : Formulaire entité
    - Sélection type d'entité (cards sélectionnables)
    - Nom de l'entité, pays, ville, adresse
    - Upload logo optionnel (image_picker → Cloudinary)
  → Étape 2 : Compte admin
    - Nom complet, email, téléphone, mot de passe
    - Validation formulaire (email valide, mot de passe fort)
  → Création Firestore : /entities/{entityId} + /users/{uid}
  → Custom claims Firebase : entityId + role = "admin"
  → Email de vérification Firebase Auth envoyé

[H6] Tests & Vérification Firestore
  → Vérifier les documents créés dans Firestore Console
  → Tester la connexion après création de compte
  → Vérifier que le token persiste après fermeture de l'app
```

**✅ Vérification fin Jour 3 :**
- Un admin peut créer une entité et se connecter
- Les documents Firestore sont correctement créés avec entityId
- Le token persiste offline (fermer et rouvrir l'app → auto-connecté)

---

### Jour 4 — Authentification — Rejoindre une entité (6h)

**Objectif :** Le workflow complet d'inscription en 3 étapes fonctionne.

**Tâches :**

```
[H1-H2] Flux "Rejoindre" — Étape 1 : Demande candidat
  → Formulaire : nom, email, téléphone, grade déclaré, recherche entité
  → Recherche entité : barre de recherche → liste Firestore des entités
  → Soumission → document /entities/{entityId}/pendingUsers/{uid}
  → Statut "pending_approval"
  → Écran de confirmation avec message d'attente

[H3-H4] Flux "Rejoindre" — Étape 2 : Approbation admin
  → Admin voit la liste des demandes en attente (badge dans son accueil)
  → Fiche candidat : nom + email + téléphone + grade déclaré
  → Admin assigne le rôle système (dropdown)
  → Tap "Approuver" → Cloud Function déclenchée :
    - Génère code 6 caractères alphanumériques (K7X2M9...)
    - Exclut caractères ambigus (0, O, 1, I, L)
    - Expiration 24h
    - Envoie email automatique au candidat avec le code
    - Notification push FCM au candidat

[H5-H6] Flux "Rejoindre" — Étape 3 : Activation compte
  → Écran "Activer mon compte" : saisie code 6 caractères
  → Vérification code (Cloud Function : valid + non expiré)
  → Si valide : création mot de passe → compte activé → Accueil
  → Si expiré : message + bouton "Contacter l'admin"
  → Admin peut régénérer un code depuis gestion membres
```

**✅ Vérification fin Jour 4 :**
- Le workflow complet Agent → Admin → Activation fonctionne
- L'email avec le code est reçu correctement
- Un code expiré est rejeté avec le bon message
- Le rôle attribué par l'admin est correctement appliqué

---

### Jour 5 — Accueil par rôle & Paramètres de base (6h)

**Objectif :** Chaque rôle voit son écran d'accueil adapté.

**Tâches :**

```
[H1-H2] Accueil Agent / Infirmier
  → AppBar avec NetworkStatusIndicator (point vert/rouge)
  → Salutation contextuelle : "Bonjour, Agent [Prénom]"
  → Carte Points du jour (0 pts au démarrage)
  → Stats du jour : 0 consultations / 0 en attente
  → Actions rapides : "Nouveau patient" + "Nouveau scan"
  → Liste récente vide avec message "Aucun patient pour l'instant"

[H3-H4] Accueil Médecin / Docteur
  → Même structure + onglets : Disponibles / Mes dossiers / Validés
  → Accueil Admin : + section Gestion de l'entité
  → ConnectivityService : détection réseau temps réel
  → NetworkStatusIndicator : vert = online, rouge = offline

[H5-H6] Déconnexion & Navigation globale
  → GoRouter avec redirection basée sur le rôle
  → Déconnexion propre : clear token + clear Hive + retour Auth
  → Deep linking : notification tap → bon écran directement
  → Tests de navigation entre tous les rôles
```

**✅ Vérification fin Jour 5 — LIVRABLE SEMAINE 1 :**
- Splash → Onboarding → Auth → Accueil fonctionne pour tous les rôles
- Le NetworkStatusIndicator change en temps réel (couper le Wi-Fi)
- La déconnexion efface tout proprement
- L'app démarre en 2 secondes maximum sur Android réel

---

## SEMAINE 2 — CŒUR MÉTIER

### Jour 6 — Module Patient (6h)

**Objectif :** Un agent peut créer et gérer des patients, online et offline.

**Tâches :**

```
[H1-H2] Création fiche patient
  → Formulaire : nom, prénom, âge, sexe, photo (optionnelle)
  → Photo : image_picker → compression → stockage local d'abord
  → Écriture Firestore /entities/{entityId}/patients/{id}
  → Fonctionne offline (Firestore cache + SyncQueue pour la photo)
  → Animation de confirmation après création

[H3-H4] Liste des patients
  → Stream Firestore → liste en temps réel
  → Recherche locale : index Hive sur nom + prénom
  → Item patient : photo miniature (initiales si absent), nom,
    âge, sexe, badge score (si scan existant), statut claim
  → Swipe right sur item → "Nouveau scan" pour ce patient
  → Pull to refresh → sync manuelle

[H5-H6] Détail patient & Indicateurs de sync
  → Écran détail : toutes les infos + historique scans
  → Indicateur de sync dans les paramètres :
    SyncQueueService : compteur dossiers en attente
  → Test complet offline : créer patient sans réseau,
    couper Wi-Fi, créer, remettre Wi-Fi → vérifier sync
```

**✅ Vérification fin Jour 6 :**
- Patient créé offline → visible dans la liste offline
- Réseau rétabli → patient apparaît dans Firestore Console
- La recherche locale fonctionne sans réseau

---

### Jour 7 — Module Scan — Température & Questionnaire (6h)

**Objectif :** L'agent peut réaliser un scan complet avec score.

**Tâches :**

```
[H1-H2] Scan Étape 1 — Température
  → Écran saisie température avec clavier numérique
  → Indicateur coloré : <37.5 vert / 37.5-38.5 orange / >38.5 rouge
  → Détection automatique caméra thermique USB-C (si branchée)
    → Substitution automatique de la saisie manuelle
  → Validation : température entre 30°C et 45°C (plage réaliste)
  → Barre de progression : Étape 1 / 3

[H3-H5] Scan Étape 2 — Questionnaire (11 questions)
  → Une question par écran, navigation Précédent / Suivant
  → Boutons OUI / NON : 60px hauteur, `lucide_icons`
  → Barre de progression mise à jour à chaque question
  → Stockage des réponses en mémoire (Map<String, bool>)
  → Champ commentaire libre après la dernière question
  → Récapitulatif des réponses avant soumission

[H6] Calcul du score de risque
  → Algorithme de scoring :
    Température : 0 pt (<37.5) / 1 pt (37.5-38.5) / 2 pts (>38.5)
    Questionnaire : 0.4 pt par OUI (max 4 pts sur 11 questions)
    Score total = Température + Questionnaire (max 6 pts en V1)
    Score normalisé sur 10 (Vision ajoutera 4 pts en V1.1)
  → Écran résultat : score en grand, couleur sémantique, label
```

**✅ Vérification fin Jour 7 :**
- Les 11 questions s'affichent une par une correctement
- Le score calculé est cohérent avec les réponses
- La navigation Précédent / Suivant conserve les réponses

---

### Jour 8 — Score, Soumission & Système Claim (6h)

**Objectif :** Un dossier soumis déclenche correctement le système Claim.

**Tâches :**

```
[H1-H2] Écran résultat & Soumission
  → Score affiché : chiffre 48px + label + détail par catégorie
  → Si score ≥ 7 : son d'alerte urgent (alert_urgent.mp3 embarqué)
  → Animation de points gagnés au tap "Soumettre"
  → Écriture scan dans Firestore : statut "pending_claim"
  → Fonctionnement offline : scan enregistré localement,
    soumission différée dès retour réseau

[H3-H4] Système Claim — Transaction atomique
  → Écriture Firestore atomique (runTransaction) pour le claim
  → Pattern : vérifier statut "pending_claim" → update "claimed"
  → Si race condition (deux médecins en même temps) → exception
    → UI affiche "Dossier déjà pris" gracieusement
  → Mise à jour statut en temps réel via onSnapshot

[H5-H6] Notifications FCM — Claim
  → Score ≥ 7 : FCM broadcast à tous les médecins de l'entité
  → Score 4-6 : FCM broadcast à tous les médecins
  → Score 0-3 : FCM au médecin désigné par round-robin
    → Cloud Function : sélection médecin avec charge minimale
    → Timer 30 min → rotation automatique si pas de claim
  → Notification dossier claimé → autres médecins notifiés
  → Sons embarqués : notify_new_case.mp3, notify_claimed.mp3
```

**✅ Vérification fin Jour 8 :**
- Le claim atomique fonctionne (tester avec 2 appareils simultanément)
- Les notifications FCM arrivent sur l'appareil du médecin
- Le son d'alerte joue bien pour score ≥ 7
- Le statut change en temps réel dans l'accueil médecin

---

### Jour 9 — Dashboard Médecin & Validation (6h)

**Objectif :** Le médecin peut voir, prendre en charge et valider un dossier.

**Tâches :**

```
[H1-H2] Dashboard médecin — Listes de dossiers
  → Onglet "Disponibles" : dossiers pending_claim, tri score décroissant
  → Onglet "Mes dossiers" : dossiers claimés par ce médecin
  → Onglet "Validés" : historique des validations
  → Item dossier : nom patient + âge + score badge + date + agent
  → Bouton "Prendre en charge" inline sur chaque item disponible
  → Badge rouge sur l'onglet "Disponibles" si > 0 dossiers

[H3-H4] Détail dossier & Claim
  → Écran détail : section patient + section scan + score détaillé
  → Bouton sticky bas "Prendre en charge" (pending_claim)
  → Tap → transaction atomique claim → bouton devient "Valider"
  → Si déjà pris → bannière "Pris par Dr. [Nom] — il y a X min"
  → Lecture seule si claimé par un autre

[H5-H6] Formulaire de validation
  → Dropdown conclusion clinique (pathologies RCA)
  → TextArea commentaire libre
  → Checkboxes examens complémentaires
  → Toggle "Référer à une autre entité" + recherche entité
  → Bouton "Valider et générer documents"
  → Écriture validation dans Firestore, statut → "validated"
  → +3.5 pts (médecin) ou +5 pts (docteur) via Cloud Function
  → Notification agent : "✅ Dossier validé par Dr. [Nom]"
  → Son : notify_validation.mp3
```

**✅ Vérification fin Jour 9 :**
- Le médecin voit les dossiers triés par urgence
- Le claim fonctionne et bloque les autres médecins
- La validation met à jour le statut dans Firestore
- L'agent reçoit la notification de validation

---

### Jour 10 — Génération PDF Consultation & Ordonnance (6h)

**Objectif :** Les deux documents PDF sont générés correctement.

**Tâches :**

```
[H1-H2] Template PDF — Formulaire de consultation
  → En-tête : logo entité + nom + date + heure
  → Section patient : nom, âge, sexe, photo miniature
  → Section scan : température, réponses questionnaire, score
  → Conclusion : pathologie, commentaire, examens demandés
  → Signature numérique : nom médecin + grade + horodatage
  → Pied de page : disclaimer légal Klinik-Scan
  → Génération dart:pdf → fichier local → Firebase Storage

[H3-H4] Template PDF — Ordonnance médicale
  → En-tête professionnel : logo + nom entité + adresse + contacts
  → Section patient : nom, prénom, âge, sexe, date
  → Corps prescriptions : DCI + posologie + durée + voie
  → Champ recommandations libres
  → Zone signature blanche réservée : "Signature et cachet du praticien"
  → Pied de page : "À signer et cacheter avant remise au patient"
  → Standard visuel : CHU Bangui / hôpitaux nationaux RCA

[H5-H6] Circuit hybride ordonnance — Upload & Redistribution
  → Bouton "Uploader l'ordonnance signée" après génération
  → Option A : import fichier (FilePicker → PDF ou image)
  → Option B : photo in-app → edge detection → correction perspective
    → compression → aperçu → validation → upload Cloudinary
  → Horodatage serveur + signedBy dans Firestore
  → Notification FCM aux destinataires avec lien téléchargement
  → Son : notify_validation.mp3 pour les destinataires
```

**✅ Vérification fin Jour 10 — LIVRABLE SEMAINE 2 :**
- Les deux PDF sont générés et lisibles sur un lecteur PDF Android
- Le PDF ordonnance a bien la zone blanche pour signature physique
- L'upload via photo fonctionne avec correction de perspective visible
- Les destinataires reçoivent la notification et peuvent télécharger

---

## SEMAINE 3 — GAMIFICATION, ADMIN & SYNCHRONISATION

### Jour 11 — Système de Gamification (6h)

**Objectif :** Les points et badges fonctionnent de bout en bout.

**Tâches :**

```
[H1-H2] Cloud Functions — Calcul des points
  → calculatePoints() : déclenchée après chaque validation Firestore
  → Barème par rôle :
    agent +1 / infirmier +2 / sage-femme +2 /
    médecin +3.5 / docteur +5 / admin +5
  → Écriture dans /entities/{entityId}/users/{uid}/points
  → Règle anti-triche : médecin ne peut pas valider ses propres scans
  → Règle anti-triche : points crédités seulement après validation

[H3-H4] Cloud Functions — Attribution des badges
  → assignBadges() : déclenchée après calculatePoints()
  → Vérification des seuils pour chaque badge
  → Écriture badge dans Firestore + notification FCM
  → Son : badge_earned.mp3 sur l'appareil du bénéficiaire

[H5-H6] Écran "Mes Contributions" dans l'app
  → Carte points en accueil : points aujourd'hui + total mois
  → Écran dédié : total tous temps + ce mois + cette semaine
  → Historique des actions avec points (liste chronologique)
  → Galerie de badges obtenus avec date d'obtention
  → Classement dans l'entité (ma position parmi collègues)
  → Animation points gagnés : "+3.5 pts" en overlay au moment de la validation
```

**✅ Vérification fin Jour 11 :**
- Les points sont crédités après validation (pas avant)
- Un médecin ne peut pas créditer ses propres consultations
- L'animation de points s'affiche correctement
- Le badge "Premier pas" est décerné à la première consultation

---

### Jour 12 — Dashboard Admin & Leaderboard (6h)

**Objectif :** L'admin peut gérer son entité et exporter le classement.

**Tâches :**

```
[H1-H2] Gestion des membres
  → Liste utilisateurs : nom + rôle + points + statut
  → Actions : Approuver (si pending) / Changer rôle / Désactiver
  → Fiche membre : détail + bouton "Renvoyer le code" (si pending)
  → Génération code via Cloud Function (bouton déclenche la CF)
  → Code affiché à l'admin avec copie rapide

[H3-H4] Leaderboard entité
  → Podium visuel top 3 : photos de profil + points + badges
  → Liste complète : rang + nom + rôle + points + badge actif
  → Filtres : tous / agents uniquement / médecins uniquement
  → Sélection de période : ce mois / cette année / tous temps
  → Données lues depuis /entities/{entityId}/users/ agrégées

[H5-H6] Export rapport PDF officiel
  → Template rapport : titre + entité + période + classement
  → Chaque ligne : rang + nom + rôle + points + badges
  → Taux de réactivité médecins (délai moyen de claim)
  → Signature numérique de l'administrateur + date
  → Partage direct (share_plus) ou sauvegarde locale
  → Test du rendu sur imprimante réelle si possible
```

**✅ Vérification fin Jour 12 :**
- L'admin peut approuver un membre depuis la liste
- Le leaderboard se filtre et change de période correctement
- Le PDF rapport est généré et partageable

---

### Jour 13 — Synchronisation & File d'attente (6h)

**Objectif :** La synchronisation offline est robuste et visible.

**Tâches :**

```
[H1-H2] SyncQueueService complet
  → Hive box pour persistance de la queue
  → Méthodes : enqueue(), processPendingQueue(), _processItem()
  → Retry logic : max 5 tentatives, statut failed après
  → FIFO : traitement dans l'ordre de création
  → ValueNotifier<int> pendingCount pour l'UI

[H3-H4] Synchronisation médias
  → Photos patients : stockage local Hive → upload Cloudinary en queue
  → Vidéos patients [V1.1 placeholder] : queue prête mais non activée
  → Ordonnances scannées : upload Cloudinary via queue
  → PDF générés : upload Firebase Storage via queue
  → Compression automatique avant upload (flutter_image_compress)

[H5-H6] UI de synchronisation
  → NetworkStatusIndicator dans toutes les AppBars :
    point vert (online) / rouge (offline) + compteur "X en attente"
  → Section Synchronisation dans Paramètres :
    - "X dossiers en attente d'upload"
    - Date dernière synchronisation réussie
    - Bouton "Synchroniser maintenant"
    - Liste des items en échec (failed) avec bouton retry
  → Test de simulation : créer 5 patients offline,
    vérifier la queue, remettre le réseau, vérifier la sync
```

**✅ Vérification fin Jour 13 :**
- 5 patients créés offline → tous synchronisés après retour réseau
- Le compteur de la queue est précis en temps réel
- Les items en échec sont visibles dans les paramètres
- Aucune perte de données sur 3 cycles offline/online

---

### Jour 14 — Monétisation — Plans & AdMob (6h)

**Objectif :** Le système de plans et les publicités fonctionnent.

**Tâches :**

```
[H1-H2] Gestion des plans dans Firestore
  → Vérification du plan à chaque ouverture de session
  → scanCountThisMonth vs scanLimit : blocage si limite atteinte
  → Écran "Limite atteinte" avec bouton "Passer au plan supérieur"
  → Cloud Function resetMonthlyQuotas() : test de la réinitialisation
  → Remote Config pour les limites par plan

[H3-H4] Écran de gestion abonnement (Admin)
  → Plan actuel + date de renouvellement
  → Barre de progression : scans utilisés / limite du mois
  → Sélection plan cible + méthode de paiement
  → Flux Orange Money : saisie numéro → code USSD → confirmation
    → webhook Cloud Function → mise à jour plan Firestore
  → Stripe : flutter_stripe → PaymentSheet → webhook → mise à jour

[H5-H6] AdMob — Publicités conditionnelles
  → Initialisation conditionnelle selon le plan (switch EntityPlan)
  → Plan Starter : bannière accueil + native liste (1/5) + interstitiel (1/3)
  → Plan Basic : bannière accueil uniquement, fréquence -50%
  → Plans Pro+ : aucune initialisation AdMob
  → Règles : jamais pendant scan actif, jamais score ≥ 7
  → Test sur appareil réel avec unités de test AdMob
```

**✅ Vérification fin Jour 14 :**
- La limite de scans bloque correctement au bon seuil
- Les publicités apparaissent uniquement sur les bons plans
- Les publicités ne perturbent jamais les écrans médicaux critiques

---

### Jour 15 — Mise à jour In-App & Paramètres complets (6h)

**Objectif :** Tous les paramètres fonctionnent. La mise à jour in-app est opérationnelle.

**Tâches :**

```
[H1-H2] Mise à jour in-app (Remote Config)
  → AppUpdateService : vérification version au démarrage
  → Dialog "Mise à jour disponible" : Mettre à jour / Plus tard
  → Mise à jour obligatoire : dialog bloquant (pas de "Plus tard")
  → Pastille dans Paramètres si mise à jour disponible ignorée
  → Redirection vers le Play Store ou APK direct

[H3-H4] Paramètres — Sections complètes
  → Profil : photo (Cloudinary), nom, grade, email/téléphone
  → Mes Contributions : points + badges + historique
  → Notifications : toggle global + toggle par type
  → Sons : toggle global + sélection sonnerie par événement (3 options)
  → Synchronisation : compteur + sync manuelle + historique
  → Mise à jour : version actuelle + vérification manuelle
  → Entité : nom + logo + plan + bouton Déconnexion
  → Langue : sélection FR / EN / ES (flutter_localizations)

[H5-H6] Sons d'alerte — Tous les événements
  → Sons embarqués dans les assets (MP3 courts < 30Ko chacun)
  → alert_urgent.mp3 : alarme 3x répétée
  → notify_new_case.mp3 : son d'attention médecin
  → notify_claimed.mp3 : son discret
  → notify_validation.mp3 : notification douce
  → points_earned.mp3 : son positif court
  → badge_earned.mp3 : son de célébration
  → error_sync.mp3 : son d'erreur distinct
  → Tous fonctionnent offline (fichiers embarqués dans assets/)
```

**✅ Vérification fin Jour 15 — LIVRABLE SEMAINE 3 :**
- La mise à jour in-app bloque correctement si obligatoire
- Tous les sons jouent correctement, même en mode avion
- Le changement de langue fonctionne sans redémarrage
- Tous les paramètres sont sauvegardés et persistent

---

## SEMAINE 4 — FINITIONS & LIVRAISON

### Jour 16 — i18n & Multilinguisme (6h)

**Objectif :** L'application est disponible en français, anglais et espagnol.

**Tâches :**

```
[H1-H3] Internationalisation Flutter
  → Configuration flutter_localizations + intl
  → Création fichiers .arb : app_fr.arb, app_en.arb, app_es.arb
  → Extraction de TOUTES les chaînes UI dans les fichiers .arb
  → Vérification : aucune chaîne hardcodée dans le code Flutter
  → Test : changer la langue → tout l'UI bascule immédiatement

[H4-H6] Traduction & Vérification
  → Traduction complète en anglais (toutes les chaînes)
  → Traduction complète en espagnol (toutes les chaînes)
  → Vérification des PDF : les deux templates gèrent le multilinguisme
  → Test sur appareil réel avec chaque langue
  → Vérification : les noms médicaux (DCI, pathologies) restent
    en français (standard médical international francophone)
```

**✅ Vérification fin Jour 16 :**
- L'app change de langue instantanément depuis les Paramètres
- Aucune chaîne UI reste en français quand l'anglais est sélectionné
- Les PDF incluent la langue de l'interface active

---

### Jour 17 — Landing Page (6h)

**Objectif :** La landing page vitrine est en ligne sur Firebase Hosting.

**Tâches :**

```
[H1-H2] Setup Astro + Tailwind + shadcn
  → Initialiser projet Astro 4.x dans _landing/ du monorepo
  → Configurer Tailwind CSS + shadcn/ui
  → Structure : Hero / Features / Plans / CTA / Footer
  → Responsive : mobile-first (la majorité des visiteurs sont sur mobile)

[H3-H4] Contenu de la landing page
  → Hero : nom app + tagline + captures d'écran réelles de l'app Android
  → Features : 4 différenciateurs clés (Vision, Claim, Offline, Gamification)
  → Plans : tableau des 5 plans avec prix et fonctionnalités
  → CTA : "Télécharger l'app" (lien Play Store) + "Nous contacter"
  → Footer : langue (FR/EN/ES), liens légaux, contact
  → Vidéo démo courte (< 30s, screen recording de l'app)

[H5-H6] Déploiement Firebase Hosting
  → Configuration firebase.json pour le projet Astro
  → Build Astro : npm run build
  → firebase deploy --only hosting
  → Test sur mobile réel : performance + responsive
  → Vérification domaine klinik-scan.com (ou sous-domaine Firebase)
```

**✅ Vérification fin Jour 17 :**
- La landing est accessible en ligne sur l'URL Firebase Hosting
- Elle s'affiche correctement sur mobile Android
- Les 3 langues sont disponibles sur la landing

---

### Jour 18 — Super Admin Dashboard Web (6h)

**Objectif :** Le dashboard propriétaire est en ligne avec les métriques de base.

**Tâches :**

```
[H1-H2] Setup Next.js 14 + Firebase Admin
  → Initialiser projet Next.js 14 (App Router + TypeScript) dans _admin/
  → Configurer Tailwind CSS + shadcn/ui
  → Firebase Admin SDK (credentials serveur via variables d'environnement)
  → Auth : 1 seul compte (Firebase Auth) + 2FA

[H3-H4] Cloud Function aggregateAnalytics()
  → Agrégation horaire → /analytics/global/ et /analytics/revenue/
  → Métriques : users, entités, consultations, validations, plans
  → RÈGLE ABSOLUE : aucune donnée patient dans /analytics/
  → Test : vérifier les données dans Firestore après déclenchement

[H5-H6] Dashboard — Section Vue d'ensemble & Revenus
  → Section 1 : KPIs temps réel (onSnapshot) : users actifs,
    consultations aujourd'hui, validations, taux validation
  → Section 2 : Revenus : MRR, ARR, répartition des plans (donut chart)
  → Graphique MRR sur 12 mois (Recharts)
  → Section 4 : Tableau des entités (nom, plan, users, scans ce mois)
  → Déploiement Firebase Hosting : admin.klinik-scan.com
```

**✅ Vérification fin Jour 18 :**
- Le dashboard est accessible uniquement avec le compte propriétaire
- Les KPIs changent en temps réel quand un scan est soumis dans l'app
- Aucune donnée patient n'est visible dans le dashboard

---

### Jour 19 — Tests terrain & Correction de bugs (6h)

**Objectif :** L'app est stable sur un appareil Android réel dans des conditions terrain.

**Tâches :**

```
[H1-H2] Tests de régression complets
  → Tester chaque flux utilisateur de bout en bout :
    - Inscription admin → création entité
    - Inscription agent → approbation → activation code
    - Consultation complète agent → soumission
    - Claim médecin → validation → PDF
    - Circuit hybride ordonnance (photo in-app)
  → Tester sur le plus vieux et plus lent Android disponible

[H3-H4] Tests offline rigoureux
  → Scénario A : créer 10 patients offline → sync → vérifier Firestore
  → Scénario B : scan soumis offline → médecin notifié à la sync
  → Scénario C : couper réseau en plein claim → vérifier cohérence
  → Scénario D : redémarrer l'app offline → données toujours présentes

[H5-H6] Correction des bugs identifiés
  → Priorité : bugs qui bloquent un flux utilisateur
  → Priorité 2 : bugs d'affichage sur petit écran
  → Priorité 3 : optimisation mémoire (profiler Flutter)
  → Documenter tous les bugs restants dans PROGRESS.md
```

**✅ Vérification fin Jour 19 :**
- Zéro crash sur 2 heures d'utilisation continue
- Zéro perte de données sur 5 cycles offline/online
- L'app reste fluide après 30 minutes d'utilisation

---

### Jour 20 — Build final, APK & Documentation (6h)

**Objectif :** L'APK V1 est prêt à être distribué. La documentation est complète.

**Tâches :**

```
[H1-H2] Build APK Release
  → Configurer la signature APK (keystore)
  → flutter build apk --release --target-platform android-arm64
  → Tester l'APK release sur appareil réel (différent de l'APK debug)
  → Vérifier la taille de l'APK (cible : < 50 MB)
  → Vérifier que ProGuard n'a pas cassé les imports Firebase

[H3-H4] Documentation technique
  → README.md du monorepo : instructions d'installation et build
  → Schéma de la base Firestore (Mermaid diagram)
  → Guide des Cloud Functions : déploiement et configuration
  → Guide des variables d'environnement (.env.example)
  → Guide de contribution pour les futures sessions Claude Code

[H5-H6] Mise à jour PROGRESS.md & Préparation V1.1
  → PROGRESS.md : marquer toutes les tâches V1 comme terminées
  → Documenter les bugs connus non résolus
  → Créer la liste des tâches V1.1 (module Vision, Desktop Windows,
    questionnaire adaptatif, notifications WhatsApp/SMS, timeout claim)
  → Tag Git : v1.0.0 — release MVP
  → Partager l'APK avec les premiers testeurs terrain en RCA
```

**✅ Vérification fin Jour 20 — LIVRABLE FINAL V1 :**
- L'APK release s'installe sur un Android vierge sans erreur
- Toutes les features V1 fonctionnent sur l'APK release
- La documentation permet à un autre développeur de reprendre le projet
- La landing page est en ligne et présente les captures réelles de l'app

---

## TABLEAU DE BORD DU PROJET

### Répartition du temps par domaine

| Domaine | Jours | % du temps |
|---|---|---|
| Infrastructure & Auth | Jours 1-5 | 25% |
| Module Patient & Scan | Jours 6-8 | 15% |
| Médecin & Documents PDF | Jours 9-10 | 10% |
| Gamification & Admin | Jours 11-12 | 10% |
| Sync & Monétisation | Jours 13-15 | 15% |
| i18n & Landing & Dashboard | Jours 16-18 | 15% |
| Tests & Livraison | Jours 19-20 | 10% |

### Features MVP V1 (ce mois)
- ✅ Auth multi-entités avec workflow inscription 3 étapes
- ✅ Module patient offline-first
- ✅ Scan complet (température + questionnaire + score)
- ✅ Système Claim + notifications FCM
- ✅ Dashboard médecin + validation
- ✅ PDF formulaire consultation + ordonnance (circuit hybride)
- ✅ Gamification (points + badges) via Cloud Functions
- ✅ Dashboard admin + leaderboard + rapport PDF
- ✅ Synchronisation offline robuste
- ✅ Plans d'abonnement + AdMob (Starter/Basic)
- ✅ Sons d'alerte embarqués
- ✅ Mise à jour in-app
- ✅ Multilinguisme FR/EN/ES
- ✅ Landing page vitrine
- ✅ Super Admin Dashboard Web (métriques de base)

### Features reportées en V1.1
- ⬜ Module Vision (MediaPipe + analyse faciale)
- ⬜ Capture vidéo 30s patient
- ⬜ Dashboard Desktop Windows
- ⬜ Questionnaire adaptatif par pathologie
- ⬜ Timeout claim (2h) avec re-notification automatique
- ⬜ SMS de secours pour le code d'activation
- ⬜ Notifications WhatsApp + SMS multicanal

---

## INSTRUCTIONS POUR CLAUDE CODE

Au début de chaque session, donner ce contexte à Claude Code :

```
"Je travaille sur Klinik-Scan, une app Flutter d'aide au triage médical
hors ligne pour la République Centrafricaine.

Lis ces fichiers dans l'ordre avant de commencer :
1. CLAUDE.md (règles absolues du projet)
2. _project/PROGRESS.md (où j'en suis aujourd'hui)
3. Le skill correspondant à la tâche du jour :
   - Firebase : klinik-skills/klinik-firebase-rules/SKILL.md
   - UI/Design : klinik-skills/klinik-design-system/SKILL.md
   - Offline   : klinik-skills/klinik-offline-sync/SKILL.md
   - Vision    : klinik-skills/klinik-vision-module/SKILL.md

Aujourd'hui on travaille sur : [SPRINT X — JOUR Y — TÂCHE PRÉCISE]
Voici ce qui est terminé : [liste depuis PROGRESS.md]
Voici ce qui est en cours : [tâche en cours]
Voici les contraintes du jour : [si applicable]"
```

---

*Document créé le : 30 mai 2026*
*Auteur : Redemona Christ (Ashad) — github.com/Ashad90*
*Projet : Klinik-Scan*

---

## ANNEXE — PLAN MARKETING PRODUIT

> Intégré au plan de développement — Actions marketing à réaliser en parallèle du code.

### Avant le lancement (Semaines 1-4 — pendant le développement)

```
[Semaine 1 — Fondations marketing]
  → Rédiger le Brand Voice Guide (5 adjectifs + 20 exemples de microcopy)
  → Lister tous les textes de l'app dans un fichier copy.md
  → Vérifier que chaque texte respecte les 5 adjectifs de la voix

[Semaine 2 — Communication externe]
  → Créer les templates d'email :
    - Email de bienvenue (après création de compte)
    - Email "Rapport d'Impact Mensuel" (automatique le 1er du mois)
    - Email de code d'activation (workflow inscription)
  → Définir le contenu de chaque notification push (ton humain, pas robotique)

[Semaine 3 — Communauté]
  → Rédiger le contenu de la landing page (FR/EN/ES)
  → Préparer les arguments du "Pack Fondateur" (50 entités max)
  → Identifier les 10 premières entités cibles en RCA à contacter

[Semaine 4 — Lancement]
  → Email de pré-lancement aux entités cibles identifiées
  → Préparer les captures d'écran et vidéo démo (< 30s) pour la landing page
  → Activer le Pack Fondateur dès la mise en ligne de l'APK
```

### Après le lancement (Mois 2-6)

```
[Chaque mois — Actions récurrentes]
  → Envoyer le Rapport d'Impact Mensuel à toutes les entités actives
  → Publier le classement mensuel anonymisé (email + notification)
  → Suivre les métriques d'engagement dans le Super Admin Dashboard :
    - Taux de retour à 30 jours (cible : > 80%)
    - Taux de conversion Starter → Basic (cible : > 15%)
    - Score NPS mensuel (Net Promoter Score — enquête courte in-app)

[Trimestre 1 — Objectifs]
  → 20 entités actives en RCA
  → 5 témoignages collectés (texte ou vidéo courte)
  → Premier contact avec une ONG internationale (MSF, UNICEF, Croix-Rouge)

[Trimestre 2 — Objectifs]
  → 50 entités actives (dont 20 sur plan payant)
  → Pack Fondateur complet (50 entités)
  → Première cérémonie virtuelle de remise de badges
  → Rapport d'impact semestriel publié publiquement
```

### KPIs Marketing à suivre dans le Super Admin Dashboard

| Métrique | Définition | Cible 6 mois |
|---|---|---|
| CAC | Coût d'acquisition par entité | < 20$ |
| LTV | Valeur vie d'une entité | > 500$ |
| Churn mensuel | Entités qui annulent | < 5% |
| NPS | Score de recommandation (0-10) | > 7 |
| Taux conversion Starter→Basic | % d'upgrade | > 15% |
| DAU/MAU ratio | Engagement quotidien | > 30% |
| Rapport d'impact ouvert | % emails ouverts | > 60% |


---

## PLAN DE CONTINGENCE

> Cette section définit exactement quoi faire si le temps manque.
> À lire en cas de retard sur le planning prévu.
> Dernière mise à jour : 30 mai 2026

---

### SEUIL DE LANCEMENT ACCEPTABLE — MVP MINIMUM VIABLE

Le seuil suivant définit le strict minimum pour sortir un APK distribuable
aux premiers testeurs terrain, même si toutes les features ne sont pas finies.

**Un APK est considéré lançable si et seulement si les 8 conditions suivantes
sont remplies simultanément :**

```
✅ CONDITION 1 — Authentification fonctionnelle
   Un admin peut créer une entité et se connecter.
   Un agent peut rejoindre via code et se connecter.
   Le token persiste offline (pas de reconnexion à chaque ouverture).

✅ CONDITION 2 — Module patient offline-first
   Créer un patient fonctionne sans réseau.
   La liste des patients s'affiche depuis le cache local.
   La synchronisation s'exécute au retour du réseau.

✅ CONDITION 3 — Scan complet (température + questionnaire + score)
   Les 11 questions s'affichent et se naviguent correctement.
   Le score est calculé et affiché avec la couleur sémantique correcte.
   La soumission enregistre le dossier en Firestore (online ou offline).

✅ CONDITION 4 — Système Claim basique
   Un médecin voit les dossiers disponibles.
   Le claim fonctionne (transaction atomique).
   Le statut change en temps réel.

✅ CONDITION 5 — Validation médecin basique
   Le médecin peut valider un dossier avec un diagnostic.
   L'agent reçoit la notification de validation.

✅ CONDITION 6 — Zéro crash sur les flux principaux
   Aucun crash durant le flux complet :
   Connexion → Créer patient → Scan → Soumettre → Valider.

✅ CONDITION 7 — NetworkStatusIndicator fonctionnel
   Le point vert/rouge change correctement selon l'état réseau.

✅ CONDITION 8 — Design system appliqué
   Les couleurs #557CDC, #59C3C3, #FDFFF5 sont correctement utilisées.
   Les boutons font 52dp de hauteur minimum.
   lucide_icons utilisé sur tous les écrans.
```

**Tout ce qui est en dehors de ces 8 conditions peut être reporté en V1.1.**

---

### FEATURES SACRIFIABLES — PAR ORDRE DE PRIORITÉ DE COUPE

En cas de retard, couper les features dans l'ordre suivant.
La première est la moins douloureuse à couper. La dernière est la plus douloureuse.

#### NIVEAU 1 — Couper sans impact sur le MVP (jours 1-5 de retard)

```
[ ] Super Admin Dashboard Web (Next.js)
    → Impact : Ashad ne voit pas ses statistiques en temps réel
    → Alternative : consulter directement la Firebase Console
    → Reporter en : V1.1

[ ] Landing Page vitrine (Astro)
    → Impact : pas de page de présentation publique au lancement
    → Alternative : une page simple HTML d'une seule page
    → Reporter en : V1.1

[ ] Sons d'alerte personnalisables (choix de sonnerie dans paramètres)
    → Impact : l'utilisateur ne peut pas choisir sa sonnerie
    → Alternative : garder uniquement le son par défaut, non personnalisable
    → Reporter en : V1.1

[ ] Rapport gamification exportable en PDF (Admin)
    → Impact : l'admin ne peut pas exporter le classement
    → Alternative : affichage dans l'app uniquement
    → Reporter en : V1.1

[ ] Circuit hybride ordonnance (scan photo + edge detection)
    → Impact : pas d'upload d'ordonnance signée dans le MVP
    → Alternative : l'ordonnance PDF est générée et téléchargeable seulement
    → Reporter en : V1.1
```

#### NIVEAU 2 — Couper si retard significatif (6-10 jours de retard)

```
[ ] Multilinguisme anglais et espagnol
    → Impact : app uniquement en français au lancement
    → Alternative : placeholder de sélection de langue dans les paramètres
    → Reporter en : V1.1 (les fichiers .arb doivent quand même être préparés)

[ ] Leaderboard entité complet (podium, filtres, périodes)
    → Impact : classement simplifié uniquement (liste sans podium visuel)
    → Alternative : liste simple avec rang + nom + points
    → Reporter en : V1.1

[ ] AdMob publicités plan Basic (version réduite)
    → Impact : plan Basic sans publicités (légèrement moins rentable)
    → Alternative : garder uniquement Starter avec pubs complètes
    → Reporter en : V1.1

[ ] Mise à jour in-app obligatoire (blocage d'accès)
    → Impact : pas de mécanisme de forçage de mise à jour
    → Alternative : notification simple sans blocage
    → Reporter en : V1.1

[ ] Référencement inter-entités (référer patient à une autre entité)
    → Impact : le médecin peut noter "référé" mais sans transfert de dossier
    → Alternative : champ texte libre "Entité de référence" uniquement
    → Reporter en : V1.1
```

#### NIVEAU 3 — Couper seulement en cas de force majeure (> 10 jours de retard)

```
[ ] Génération ordonnance médicale PDF
    → Impact : seul le formulaire de consultation est généré
    → Alternative : l'ordonnance est reportée en V1.1
    → ATTENTION : mentionner explicitement aux testeurs terrain

[ ] Système de gamification complet (badges + Cloud Functions)
    → Impact : les points sont affichés mais pas les badges
    → Alternative : compteur de consultations simple sans badges
    → Reporter en : V1.1

[ ] Paramètres complets (notifications par type, sons par événement)
    → Impact : paramètres simplifiés (toggle global uniquement)
    → Alternative : page paramètres basique avec déconnexion + langue
    → Reporter en : V1.1
```

#### NIVEAU 4 — NE JAMAIS COUPER (ces features définissent le produit)

```
🚫 Le mode hors ligne (offline-first)
   → C'est l'identité de Klinik-Scan. Sans ça, le produit n'existe pas.

🚫 Le score de risque avec couleurs sémantiques
   → C'est la valeur clinique centrale. Sans ça, c'est juste un formulaire.

🚫 Le système Claim (transaction atomique)
   → Sans ça, deux médecins peuvent valider le même dossier — inacceptable.

🚫 Le disclaimer légal "Aide à la décision"
   → Protection légale obligatoire. À afficher partout, toujours.

🚫 L'isolation des données entre entités (règles Firestore)
   → Violation de confidentialité médicale si absent. Jamais négociable.
```

---

### PROTOCOLE DE GESTION DES RETARDS

Si à la fin d'une journée tu as accompli moins de 80% des tâches prévues,
appliquer immédiatement ce protocole :

```
ÉTAPE 1 — Identifier la cause du retard
  → Bug bloquant ?          → Documenter dans PROGRESS.md, demander aide à Claude Code
  → Feature sous-estimée ?  → Réduire le scope selon Niveau 1 ou 2 ci-dessus
  → Problème de compréhension ? → Relire le skill correspondant avant de continuer

ÉTAPE 2 — Ajuster le plan (pas le paniquer)
  Un retard d'1 jour → couper 1 feature de Niveau 1
  Un retard de 2 jours → couper 2 features de Niveau 1
  Un retard de 3 jours → couper 1 feature de Niveau 2
  Un retard > 5 jours → appliquer le seuil de lancement minimum

ÉTAPE 3 — Mettre à jour PROGRESS.md
  Toujours documenter la décision prise et la raison.
  Ne jamais laisser un retard non documenté.

ÉTAPE 4 — Continuer sans culpabilité
  Un MVP imparfait livré vaut infiniment plus
  qu'un produit parfait jamais livré.
  La V1.1 corrigera le reste.
```

---

### DÉCISIONS PRISES EN AVANCE — COMPROMIS ACCEPTABLES

Ces décisions ont été prises maintenant pour éviter de perdre du temps
à les prendre sous pression en cas de retard.

| Situation | Décision acceptée |
|---|---|
| Firebase gratuit quota dépassé | Passer au plan Blaze (pay-as-you-go) — budget max 20$/mois MVP |
| MediaPipe trop lent sur Android 2 Go | Reporter module Vision en V1.1 sans hésitation |
| Orange Money API non disponible en test | Simuler le paiement avec un bouton "Paiement confirmé" pour le MVP |
| Cloudinary limite plan gratuit atteinte | Compression plus agressive (qualité 60%) pour les photos |
| Claude Code génère du code incompatible | Revenir à la version précédente via Git, ne pas patcher sur du code cassé |
| Design system non respecté par Claude Code | Stopper, relire klinik-design-system/SKILL.md, reprendre |

