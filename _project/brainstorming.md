# brainstorming.md — Fonctionnalités, Cas d'Usage & Flux Utilisateurs

> Source de vérité pour toutes les fonctionnalités de Klinik-Scan.
> Chaque feature listée ici a un cas d'usage réel sur le terrain.
> Ce fichier est lu par Claude Code avant toute implémentation de feature.
> Dernière mise à jour : 28 mai 2026

---

## STRUCTURE DU DOCUMENT

1. [Carte des fonctionnalités par rôle](#1-carte-des-fonctionnalités-par-rôle)
2. [Flux utilisateurs détaillés](#2-flux-utilisateurs-détaillés)
3. [Écrans & interactions — Agent / Infirmier](#3-écrans--interactions--agent--infirmier)
4. [Écrans & interactions — Médecin / Docteur](#4-écrans--interactions--médecin--docteur)
5. [Écrans & interactions — Admin](#5-écrans--interactions--admin)
6. [Fonctionnalités transversales](#6-fonctionnalités-transversales)
7. [Système de gamification — Points & Badges](#7-système-de-gamification--points--badges)
8. [Système Claim — Workflow de validation sans friction](#8-système-claim--workflow-de-validation-sans-friction)
9. [Module Vision — Détail complet](#9-module-vision--détail-complet)
10. [Cas d'usage terrain — Scénarios réels](#10-cas-dusage-terrain--scénarios-réels)

---

## 1. CARTE DES FONCTIONNALITÉS PAR RÔLE

### Agent de santé / Infirmier / Sage-femme
| Feature | MVP V1 | V1.1 | V2 |
|---|---|---|---|
| Créer une fiche patient | ✅ | | |
| Liste des patients (recherche locale) | ✅ | | |
| Scanner température manuelle | ✅ | | |
| Questionnaire clinique guidé (OUI/NON) | ✅ | | |
| Score de risque automatique | ✅ | | |
| Capture photo du patient | ✅ | | |
| Soumettre dossier + notification médecins | ✅ | | |
| Voir statut claim du dossier (pris en charge ou non) | ✅ | | |
| Notification validation reçue | ✅ | | |
| Son d'alerte score élevé | ✅ | | |
| Mode hors ligne complet | ✅ | | |
| Tableau de bord points personnels | ✅ | | |
| Badges de reconnaissance | ✅ | | |
| Module Vision (analyse faciale) | | ✅ | |
| Capture vidéo 30s du patient | | ✅ | |
| Classement entité (leaderboard) | | ✅ | |
| Interface en sango | | | ✅ |

### Médecin généraliste / Docteur / Spécialiste
| Feature | MVP V1 | V1.1 | V2 |
|---|---|---|---|
| Notification nouveau dossier (tous médecins simultanément) | ✅ | | |
| Claim d'un dossier (prise en charge exclusive) | ✅ | | |
| Liste dossiers disponibles / pris / validés | ✅ | | |
| Voir fiche patient complète | ✅ | | |
| Voir score de risque + détail | ✅ | | |
| Valider diagnostic final | ✅ | | |
| Demander examens complémentaires | ✅ | | |
| Référer le patient à une autre entité | ✅ | | |
| Générer formulaire de consultation PDF | ✅ | | |
| Générer ordonnance médicale PDF | ✅ | | |
| Scanner / photographier ordonnance signée et uploader | ✅ | | |
| Redistribution ordonnance signée aux destinataires | ✅ | | |
| Tableau de bord points personnels | ✅ | | |
| Badges de reconnaissance | ✅ | | |
| Voir métriques Vision | | ✅ | |
| Visionner vidéo patient (Docteur/Spécialiste) | | ✅ | |
| Dashboard statistiques entité | | | ✅ |
| Dashboard Windows Desktop | | ✅ | |

### Admin d'entité
| Feature | MVP V1 | V1.1 | V2 |
|---|---|---|---|
| Créer l'entité (premier compte) | ✅ | | |
| Approuver les nouvelles inscriptions | ✅ | | |
| Gérer les rôles des utilisateurs | ✅ | | |
| Voir tous les dossiers de l'entité | ✅ | | |
| Classement global de l'entité (leaderboard) | ✅ | | |
| Exporter rapport de contribution (PDF/CSV) | ✅ | | |
| Configurer les notifications | ✅ | | |
| Voir la file de synchronisation | ✅ | | |
| Gérer le plan (upgrade) | | ✅ | |
| Branding personnalisé | | | ✅ |

---

## 2. FLUX UTILISATEURS DÉTAILLÉS

### Flux 1 — Première utilisation (Nouveau compte)

```
Launcher Icon (tap utilisateur)
    ↓
Splash Screen (2s max — vérification token local)
    ↓
Onboarding (4 slides)
    ├── Slides 1-3 : bouton "Suivant" (pleine largeur, bas)
    │               bouton "Passer" (TextButton, coin haut droit)
    └── Slide 4    : bouton "Commencer" uniquement (pas de "Passer")
    ↓
Écran Authentification
    ↓ [Deux options présentées comme cards sélectionnables]
    │
    ├── OPTION A — "Créer une nouvelle entité"
    │     ↓
    │     Étape 1 : Informations de l'entité
    │       - Type d'entité (Centre de santé / ONG / Clinique / Hôpital / Dispensaire)
    │       - Nom de l'entité
    │       - Pays + Ville + Adresse
    │       - Logo (upload optionnel)
    │     Étape 2 : Compte administrateur
    │       - Nom complet
    │       - Email professionnel
    │       - Téléphone
    │       - Mot de passe (8 car. min, 1 maj + 1 chiffre)
    │     ↓
    │     Vérification email (lien Firebase Auth envoyé automatiquement)
    │     ↓
    │     Accueil Admin — rôle "admin" assigné automatiquement
    │     (le créateur d'une entité est toujours son premier admin)
    │
    └── OPTION B — "Rejoindre une entité existante"

          ── ÉTAPE 1 : Demande d'inscription (côté candidat) ──

          Formulaire de demande :
            - Nom complet
            - Email professionnel
            - Téléphone
            - Grade médical déclaré (liste déroulante — informatif uniquement)
              ⚠️ Ce grade est une déclaration personnelle.
                 Le rôle système est attribué exclusivement par l'admin.
            - Recherche et sélection de l'entité cible (barre de recherche)
          ↓
          Soumission → statut interne : "pending_approval"
          Écran affiché : "Demande envoyée ✓
                           L'administrateur de [Nom Entité] va examiner
                           votre dossier. Vous serez notifié par email
                           dès que votre compte sera approuvé."

          ── ÉTAPE 2 : Approbation et attribution de rôle (côté admin) ──

          Notification push admin :
            "📋 Nouvelle demande d'inscription — [Nom Candidat]
             Grade déclaré : [Grade] — En attente de votre validation"
          ↓
          Admin consulte la fiche du candidat :
            Nom + email + téléphone + grade déclaré
          ↓
          Admin assigne le rôle système officiel :
            Agent de santé / Infirmier / Sage-femme /
            Médecin généraliste / Docteur/Spécialiste
            ⚠️ L'admin peut assigner un rôle différent du grade déclaré.
               C'est lui le garant de l'intégrité du système de rôles.
          ↓
          Admin tape "Approuver"
          ↓
          ACTIONS AUTOMATIQUES — déclenchées immédiatement, sans action
          supplémentaire de l'admin :
            → Code d'accès généré côté serveur (Cloud Function)
              Format    : 6 caractères alphanumériques majuscules
              Exemple   : K7X2M9 — B4R8PQ — Z2KW5N
              Exclusions: caractères ambigus (0,O,1,I,L) exclus
              Expiration: 24 heures après génération
              Unicité   : 1 code par demande, invalidé après usage
              Sécurité  : 36⁶ ≈ 2,17 milliards de combinaisons
            → Email envoyé automatiquement au candidat :
              Objet : "Klinik-Scan — Votre compte a été approuvé"
              Corps : Nom de l'entité + rôle attribué + code d'accès
                      + instructions d'activation + date d'expiration
            → Notification push si app déjà installée :
              "✅ Votre demande a été approuvée — Consultez votre email"

          ── ÉTAPE 3 : Activation du compte (côté candidat) ──

          L'utilisateur revient dans l'app (ou reçoit la notification)
          ↓
          Écran "Activer mon compte"
            Saisie du code d'accès à 6 caractères reçu par email
          ↓
          SI code valide et non expiré :
            Création du mot de passe personnel
              (8 caractères min, 1 majuscule + 1 chiffre obligatoires)
            ↓
            Compte activé avec le rôle assigné par l'admin
            ↓
            Accueil (écran adapté au rôle attribué)
          ↓
          SI code expiré (> 24h) :
            Message : "Ce code a expiré. Contactez l'administrateur
                       de [Nom Entité] pour recevoir un nouveau code."
            → Admin peut générer un nouveau code depuis
              Gestion membres → fiche membre → "Renvoyer le code"
```

### Flux 2 — Connexion habituelle

```
Splash Screen (logo 2s)
    ↓ [Token local valide → bypass onboarding + auth]
Accueil (rôle détecté automatiquement + points du jour visibles)
```

### Flux 3 — Consultation complète (Agent / Infirmier)

```
Accueil
    ↓ [Bouton "Nouveau patient"]
Formulaire patient (nom, prénom, âge, sexe, photo optionnelle)
    ↓ [Bouton "Enregistrer"]
    ↓ [Bouton "Démarrer le scan"]
Scan — Étape 1 : Température
    ↓
Scan — Étape 2 : Questionnaire (10 questions OUI/NON)
    ↓
Scan — Étape 3 : Module Vision [V1.1] (optionnel, peut être passé)
    ↓
Résultat — Score de risque affiché
    ↓ [Bouton "Soumettre au médecin"]

→ Action automatique au moment de la soumission :
   1. Dossier enregistré (offline ou online)
   2. Statut : "pending_claim"
   3. Notification FCM envoyée à TOUS les médecins de l'entité simultanément
   4. +1 pt (agent) ou +2 pts (infirmier/sage-femme) crédités immédiatement
   5. L'agent voit : "Dossier soumis — En attente d'un médecin disponible"

Accueil → badge points mis à jour
```

### Flux 4 — Système Claim (Médecin / Docteur)

```
Médecin reçoit notification : "🔴 Nouveau dossier urgent — [Patient] score 8/10"
    ↓ [Tap notification]
Détail dossier
    ↓ [Dossier statut "pending_claim" → bouton "Prendre en charge"]
    ├── Tap "Prendre en charge"
    │       → Statut passe à "claimed_by_{uid}"
    │       → Notification aux autres médecins : "Dossier pris en charge par Dr. [Nom]"
    │       → Bouton "Valider le diagnostic" devient disponible
    │
    └── Dossier déjà pris (statut "claimed")
            → Bouton "Prendre en charge" remplacé par "Pris en charge par Dr. [Nom]"
            → Médecin peut lire le dossier mais ne peut pas valider

Formulaire validation
    ├── Conclusion clinique (dropdown pathologies RCA)
    ├── Commentaire libre
    ├── Examens complémentaires (checkboxes)
    └── Référer à une autre entité (toggle + recherche entité)
    ↓ [Bouton "Valider et générer documents"]
    → Statut passe à "validated"
    → +3.5 pts (médecin) ou +5 pts (docteur/spécialiste) crédités
    → Formulaire de consultation PDF généré et distribué immédiatement
    → Ordonnance médicale PDF générée — prête pour impression

Circuit hybride ordonnance (post-validation) :
    ↓ [Impression + signature manuscrite + cachet physique du Docteur]
    ↓ [Bouton "Uploader l'ordonnance signée"]
        ├── Option A : Import fichier (scan de bureau → PDF/image)
        └── Option B : Photo in-app (caméra → correction perspective
                       automatique → compression → upload)
    → Upload Firebase Storage
    → Horodatage serveur + enregistrement auteur upload (traçabilité)
    → Notification aux destinataires :
        "📄 Ordonnance signée disponible — [Patient]"
        - Agent terrain ayant soumis le dossier
        - Médecin consultant (si distinct du Docteur signataire)
    → Destinataires téléchargent → impriment → remettent au patient
```

### Flux 5 — Consultation du tableau de points

```
Accueil (section points visible en permanence)
    ↓ [Tap sur la carte points]
Écran "Mes Contributions"
    ├── Total points cumulés (tous temps)
    ├── Points ce mois
    ├── Points cette semaine
    ├── Historique des actions (consultation X = +1pt, validation Y = +3.5pts...)
    ├── Badges obtenus (affichés avec date d'obtention)
    └── Classement dans l'entité (ma position parmi les collègues)
```

### Flux 6 — Mise à jour in-app

```
Démarrage de l'app
    ↓ [Vérification Firebase Remote Config]
    ├── Pas de mise à jour → démarrage normal
    ├── Mise à jour facultative → Dialog "Mettre à jour / Plus tard"
    └── Mise à jour obligatoire → Dialog bloquant "Mettre à jour maintenant"
```

---

## 3. ÉCRANS & INTERACTIONS — AGENT / INFIRMIER

### 3.1 Splash Screen
- Durée : 2 secondes maximum
- Contenu : Logo Klinik-Scan centré, fond `primary`, nom de l'app
- Action : Vérification token local → navigation automatique

### 3.2 Onboarding (4 slides)

| Slide | Titre | Description |
|---|---|---|
| 1 | "Triage simplifié" | Créez des fiches patients en quelques secondes, même sans réseau |
| 2 | "Scan intelligent" | Questionnaire guidé + analyse visuelle pour évaluer l'état du patient |
| 3 | "Médecin disponible" | Votre dossier est envoyé au premier médecin disponible automatiquement |
| 4 | "Vos contributions comptent" | Chaque consultation vous rapporte des points et des badges de reconnaissance |

- Bouton "Suivant" : pleine largeur, `primary`, en bas
- Bouton "Passer" : TextButton `textTertiary`, coin haut droit
- Dernier slide : bouton "Commencer"
- Logique : `onboardingCompleted` stocké en Hive. Ne se réaffiche jamais.

### 3.3 Accueil Agent / Infirmier
- AppBar : "Klinik-Scan", NetworkStatusIndicator, avatar profil
- Salutation contextuelle : "Bonjour, [Titre] [Prénom]"
  Format par rôle :
  - Agent de santé      → "Bonjour, Agent Marie"
  - Infirmier           → "Bonjour, Infirmier(ère) Jean"
  - Sage-femme          → "Bonjour, Sage-femme Céleste"
  - Médecin généraliste → "Bonjour, Dr. Olivier"
  - Docteur/Spécialiste → "Bonjour, Dr. Aimée"
  - Administrateur      → "Bonjour, Admin [Prénom]"
- **Carte Points du jour** :
  - Points accumulés aujourd'hui
  - Total cumulé du mois
  - Badge actif (si obtenu)
- Stat du jour : X consultations aujourd'hui / Y en attente de validation
- Actions rapides : "Nouveau patient" (primary) + "Nouveau scan" (secondary)
- Liste récente : 5 derniers patients avec statut claim visible
  - 🕐 "En attente d'un médecin" (pending_claim)
  - 👨‍⚕️ "Pris en charge par Dr. [Nom]" (claimed)
  - ✅ "Validé" (validated)

**Règle iconographie — Absolue pour toute l'application :**
Package : `lucide_icons` (pub.dev) — équivalent Flutter de Lucide React.
Même style épuré et cohérent sur tous les écrans.
Aucune icône Material Icons ni Cupertino autorisée dans le projet.
Exemples : `LucideIcons.userPlus`, `LucideIcons.clipboardList`,
`LucideIcons.alertTriangle`, `LucideIcons.checkCircle`,
`LucideIcons.stethoscope`, `LucideIcons.activity`

### 3.4 Module Scan — Questionnaire

**V1 — Questionnaire générique (10 questions fixes) :**
Questions transversales couvrant les pathologies les plus fréquentes
en RCA (paludisme, typhoïde, IRA, diarrhée, neurologique).

**V1.1 — Questionnaire adaptatif (feature planifiée) :**
Ajout d'un "motif de consultation principal" en début de scan
(Paludisme suspecté / Infection respiratoire / Troubles digestifs /
Neurologique / Autre). Le set de questions s'adapte automatiquement
au motif sélectionné. Nécessite une validation clinique préalable
par les médecins référents partenaires avant implémentation.

- Une question par écran (pas de scroll)
- Barre de progression en haut
- Boutons OUI / NON : 60px hauteur, pleine largeur
- **Questions MVP V1 (génériques — 11 questions) :**
  1. Le patient se plaint-il de maux de tête ?
  2. Le patient a-t-il des frissons ?
  2b. Le patient présente-t-il des palpitations cardiaques ?
  3. Le patient se plaint-il de douleurs articulaires ?
  4. Le patient a-t-il vomi récemment ?
  5. Le patient souffre-t-il de diarrhée ?
  6. Le patient se plaint-il de douleurs abdominales ?
  7. Le patient a-t-il du mal à respirer ?
  8. Le patient a-t-il perdu connaissance récemment ?
  9. Le patient est-il confus ou désorienté ?
  10. Le patient a-t-il des convulsions ?

### 3.5 Module Scan — Résultat
- Score affiché en grand (48px), couleur sémantique
- Label : "Risque faible" / "Risque modéré" / "Risque élevé"
- Détail par catégorie : Température / Questionnaire / Vision [V1.1]
- Si score ≥ 7 : son d'alerte urgent + message "Médecins alertés automatiquement"
- Bouton "Soumettre au médecin" → points crédités instantanément
- Animation de points gagnés au moment de la soumission (+1pt ou +2pts)

---

## 4. ÉCRANS & INTERACTIONS — MÉDECIN / DOCTEUR

### 4.1 Accueil Médecin
- AppBar : "Klinik-Scan", NetworkStatusIndicator, avatar profil
- **Carte Points du jour** (identique à l'agent, barème médecin)
- Onglets :
  - "Disponibles" — dossiers `pending_claim` (badge rouge si > 0)
  - "Mes dossiers" — dossiers que j'ai claimés
  - "Validés" — mes validations
- **Item dossier "Disponible" :**
  - Nom patient + âge + sexe
  - Score badge coloré (grand, visible)
  - Date soumission + nom de l'agent
  - Bouton "Prendre en charge" (inline, visible directement)
- **Item dossier "Claimé" :**
  - Même infos + badge "En cours" (bleu)
  - Bouton "Valider" (inline)
- Tri par défaut : score décroissant

### 4.2 Détail dossier — État "pending_claim"
- Section Patient : photo + nom + âge + sexe
- Section Scan : température + questionnaire + score
- Section Vision [V1.1] : métriques + disclaimer
- **Bouton sticky bas :** "Prendre en charge ce dossier" (primary)
- Tap → claim immédiat → bouton devient "Valider le diagnostic"

### 4.3 Détail dossier — État "claimed par un autre médecin"
- Même contenu mais en lecture seule
- Bannière haut : "Pris en charge par Dr. [Nom] — [il y a X minutes]"
- Pas de bouton d'action — lecture seule uniquement

### 4.4 Formulaire de validation
- Conclusion clinique (dropdown pathologies RCA) :
  - Paludisme simple / grave
  - Typhoïde
  - Infection respiratoire aiguë
  - Diarrhée aiguë
  - Malnutrition
  - Anémie
  - Méningite suspectée
  - Autre (champ libre)
- Commentaire : TextArea libre
- Examens complémentaires : checkboxes
- Référer à une autre entité : toggle + champ de recherche entité
- **Bouton "Valider et générer documents"** → points crédités + animation

### 4.5 Documents générés — Phase 1 (numérique, immédiat)

**Document A — Formulaire de consultation PDF**
- En-tête : Logo entité + Nom entité + Date + Heure
- Patient : Nom, âge, sexe, photo miniature
- Scan : Température, questionnaire complet avec réponses, score de risque
- Vision [V1.1] : métriques faciales + niveau de confiance
- Conclusion clinique : pathologie retenue, commentaire, examens demandés
- Signature numérique : Nom médecin + grade + horodatage serveur
- Pied de page : "Document généré par Klinik-Scan — Aide à la décision médicale"
- Distribution : immédiate, tous destinataires via l'application

**Document B — Ordonnance médicale PDF**
- En-tête : Logo entité + Nom + Adresse + Contacts de l'entité
- Patient : Nom, prénom, âge, sexe, date
- Corps : prescriptions structurées par médicament
  - Dénomination Commune Internationale (DCI)
  - Posologie (dose, fréquence, unité)
  - Durée du traitement
  - Voie d'administration
  - Instructions particulières
- Recommandations générales (champ libre)
- Zone signature : espace blanc réservé pour signature manuscrite + cachet
- Pied de page : "À signer et cacheter avant remise au patient"
- Distribution : impression locale uniquement à ce stade

### 4.6 Circuit hybride ordonnance — Phase 2 (physique + redistribution)

```
Impression du PDF ordonnance
    ↓
Signature manuscrite + apposition du cachet physique du Docteur
    ↓
Numérisation du document authentifié
    ├── Option A : Scanner de bureau
    │     → Import fichier PDF ou image (JPEG/PNG)
    │     → Upload direct via bouton "Uploader l'ordonnance signée"
    │
    └── Option B : Photo in-app (sans scanner)
          → Ouverture caméra en mode document
          → Détection automatique des bords du document (edge detection)
          → Correction de perspective (redressement automatique)
          → Compression (qualité suffisante pour lecture/impression)
          → Aperçu avant upload — bouton "Valider" ou "Reprendre"
    ↓
Upload Cloudinary (médias) ou Firebase Storage (PDF finaux) :
  path Cloudinary : klinik/{entityId}/ordonnances/{ordonnanceId}_signed
  path Firebase Storage : entities/{entityId}/pdfs/{ordonnanceId}_signed.pdf
  → Horodatage serveur (champ : signedAt)
  → Enregistrement uid du Docteur ayant uploadé (champ : signedBy)
  → Les deux versions conservées : PDF original + document signé scanné
    (traçabilité complète, auditable en cas de litige)
    ↓
Notification push aux destinataires :
  "📄 Ordonnance signée disponible — [Nom Patient]"
  Destinataires :
    - Agent terrain ayant soumis le dossier initial
    - Médecin consultant (si rôle distinct du Docteur signataire)
    ↓
Téléchargement par les destinataires
    ↓
Impression locale → remise physique de l'ordonnance au patient
```

**Pourquoi ce circuit hybride est documenté comme obligatoire :**
En RCA et dans les pays voisins, une ordonnance médicale n'est acceptée
par les pharmaciens et les familles de patients que si elle porte une
signature manuscrite et un cachet physique du praticien. La signature
numérique seule n'a pas de valeur légale ni de reconnaissance culturelle
dans l'écosystème de santé actuel. Ce workflow est la réponse pragmatique
à cette réalité, sans attendre une évolution réglementaire.

---

## 5. ÉCRANS & INTERACTIONS — ADMIN

### 5.1 Accueil Admin
- Même accueil que médecin + section "Gestion de l'entité"
- **Carte Classement entité** : top 3 contributeurs du mois (agents + médecins)
- Carte membres : N actifs / N en attente

### 5.2 Gestion des membres
- Liste utilisateurs : nom + rôle + points cumulés + statut
- Actions : Approuver / Changer rôle / Désactiver
- Bouton "Générer code d'invitation" (valable 24h)

### 5.3 Leaderboard entité (Admin)
- Classement tous rôles confondus (ou filtrable par rôle)
- Podium visuel top 3 (avec photos de profil)
- Liste complète avec rang + nom + rôle + points + badges
- Période : ce mois / cette année / tous temps
- **Bouton "Exporter rapport PDF"** → document officiel pour comité médical
  - Titre : "Rapport de contribution — [Nom entité] — [Période]"
  - Classement complet avec points et badges
  - Signé par l'administrateur

---

## 6. FONCTIONNALITÉS TRANSVERSALES

### 6.1 Sons d'alerte (embarqués — fonctionnent offline)

| Événement | Son | Fichier |
|---|---|---|
| Score ≥ 7 (urgent) | Alarme courte répétée 3x | `alert_urgent.mp3` |
| Nouveau dossier disponible (médecin) | Son attention | `notify_new_case.mp3` |
| Dossier claimé par un autre médecin | Son discret | `notify_claimed.mp3` |
| Validation reçue (agent) | Notification douce | `notify_validation.mp3` |
| Points gagnés | Son positif court | `points_earned.mp3` |
| Badge obtenu | Son célébration | `badge_earned.mp3` |
| Erreur de synchronisation | Son distinct court | `error_sync.mp3` |

### 6.2 Notifications Push (FCM)

| Déclencheur | Destinataire | Contenu |
|---|---|---|
| Nouveau scan soumis (score ≥ 7) | TOUS les médecins de l'entité | "🔴 Urgent — [Patient] score 8/10 — Disponible" |
| Nouveau scan soumis (score 4-6) | TOUS les médecins de l'entité | "🟡 [Patient] en attente — Score 5/10" |
| Nouveau scan soumis (score 0-3) | 1 médecin désigné par **rotation équitable (round-robin)** basée sur la charge active — le médecin ayant le moins de dossiers claimés en cours reçoit la notification. Si aucun claim dans les 30 minutes, rotation automatique vers le médecin suivant dans la file circulaire. | "🟢 [Patient] soumis — Score 2/10 — À votre tour" |
| Dossier claimé | Autres médecins de l'entité | "👨‍⚕️ Dossier [Patient] pris par Dr. [Nom]" |
| Diagnostic validé | Agent ayant soumis | "✅ Dossier [Patient] validé par Dr. [Nom]" |
| Badge obtenu | Utilisateur concerné | "🏅 Félicitations ! Vous avez obtenu le badge [Nom]" |
| Mise à jour disponible | Tous | "Nouvelle version de Klinik-Scan disponible" |

### 6.3 Paramètres

**Section Profil** : photo, nom, grade, email/téléphone

**Section Mes Contributions** (nouveau) :
- Total points cumulés
- Badges obtenus (galerie)
- Historique des actions avec points

**Section Notifications** :
- Toggle global + toggle par type

**Section Sons** :
- Toggle global + choix sonnerie par événement

**Section Synchronisation** :
- X dossiers en attente + bouton "Sync maintenant"
- Date dernière synchronisation

**Section Mise à jour** :
- Version actuelle + vérification

**Section Entité** :
- Nom + logo + plan + déconnexion

---

## 7. SYSTÈME DE GAMIFICATION — POINTS & BADGES

### 7.1 Barème des points par rôle

| Rôle | Action récompensée | Points |
|---|---|---|
| Agent de santé | 1 consultation soumise et validée | +1 pt |
| Infirmier | 1 consultation soumise et validée | +2 pts |
| Sage-femme | 1 consultation soumise et validée | +2 pts |
| Médecin généraliste | 1 diagnostic validé | +3.5 pts |
| Docteur / Spécialiste | 1 validation avec photo + vidéo patient | +5 pts |
| Administrateur | 1 validation de diagnostic final | +5 pts |

**Règle importante :** les points de l'agent/infirmier ne sont crédités
qu'après validation du dossier par un médecin. Cela évite les soumissions
de dossiers vides juste pour accumuler des points.

### 7.2 Système de Badges

| Badge | Condition | Rôle cible |
|---|---|---|
| 🌱 Premier pas | 1ère consultation soumise | Agent / Infirmier |
| ⭐ Actif | 10 consultations validées | Agent / Infirmier |
| 🔥 Engagé | 50 consultations validées | Agent / Infirmier |
| 💎 Champion | 100 consultations validées | Agent / Infirmier |
| 🏆 Pilier de santé | 500 consultations validées | Agent / Infirmier |
| 🩺 Validateur | 10 diagnostics validés | Médecin / Docteur |
| 🎯 Expert clinique | 50 diagnostics validés | Médecin / Docteur |
| 🦾 Référence médicale | 200 diagnostics validés | Médecin / Docteur |
| ⚡ Réactif | Claim en moins de 5 min (10 fois) | Médecin / Docteur |
| 🌍 Contributeur RCA | Actif 6 mois consécutifs | Tous |

### 7.3 Règles anti-triche

1. Les points ne sont jamais attribués avant la validation finale du médecin.
2. Un médecin ne peut pas valider ses propres consultations.
3. Un administrateur ne peut pas modifier les points manuellement.
4. Le système de points est en lecture seule pour tous les utilisateurs.
5. Les badges sont calculés côté serveur (Cloud Functions) — jamais côté client.

### 7.4 Rapport exportable pour comités médicaux

L'admin peut générer un PDF officiel contenant :
- Classement de l'entité sur la période choisie
- Points et badges de chaque membre
- Nombre de consultations et validations
- Taux de réactivité des médecins (délai moyen de claim)
- Signature numérique de l'administrateur

Ce rapport est conçu pour être présenté aux jurys hospitaliers et comités
médicaux lors des évaluations annuelles du personnel de santé.

---

## 8. SYSTÈME CLAIM — WORKFLOW DE VALIDATION SANS FRICTION

### 8.1 Problème résolu
Sans système de claim, quand 5 médecins reçoivent la même notification,
deux comportements néfastes apparaissent :
- **Syndrome du spectateur** : chacun attend que l'autre s'en occupe → dossier non traité.
- **Double traitement** : deux médecins valident le même dossier → contradiction.

### 8.2 Règles du système Claim

1. **Notification simultanée** : dès qu'un dossier est soumis, TOUS les médecins
   et docteurs de l'entité reçoivent la notification en même temps.

2. **Premier arrivé, premier servi** : le premier médecin qui tape "Prendre en
   charge" claim le dossier. Cette action est atomique côté Firestore
   (transaction — pas de race condition possible).

3. **Visibilité immédiate** : dès le claim, tous les autres médecins voient
   le dossier passer de "Disponible" à "Pris en charge par Dr. [Nom]".
   Notification push aux autres : "Dossier pris en charge — plus d'action requise."

4. **Unicité de validation** : une fois claimé, seul le médecin ayant claimé
   peut valider. Même l'admin ne peut pas override sans raison documentée.

5. **Timeout de claim** (V1.1) : si un médecin claime mais ne valide pas dans
   les 2 heures, le dossier repasse en "Disponible" et tous les médecins
   sont re-notifiés. Le médecin initial reçoit un rappel avant le timeout.

### 8.3 Implémentation Firestore (pattern atomique)

```dart
// Transaction atomique — evite la race condition
Future<bool> claimDossier(String entityId, String scanId, String medicId) async {
  final ref = FirebaseFirestore.instance
      .collection('entities').doc(entityId)
      .collection('scans').doc(scanId);

  return FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(ref);
    final currentStatus = snapshot.data()?['status'];

    // Vérification : le dossier est encore disponible
    if (currentStatus != 'pending_claim') {
      throw Exception('Dossier déjà pris en charge');
    }

    // Claim atomique
    transaction.update(ref, {
      'status': 'claimed',
      'claimedBy': medicId,
      'claimedAt': FieldValue.serverTimestamp(),
    });
    return true;
  });
}
```

### 8.4 Statuts d'un dossier (cycle de vie complet)

```
[draft]          → Scan en cours de création par l'agent
    ↓
[pending_claim]  → Soumis, notification envoyée à tous les médecins
    ↓
[claimed]        → Pris en charge par un médecin (exclusif)
    ↓
[validated]      → Diagnostic validé, PDF généré (état final)
    ↓
[referred]       → Validé + patient référé à l'hôpital (état final)

Exception :
[pending_claim]  → (timeout 2h) → [pending_claim] + re-notification
```

---

## 9. MODULE VISION — DÉTAIL COMPLET

### Positionnement UX
- Étape 3 optionnelle du scan (après température et questionnaire)
- L'agent voit : caméra + overlay guide + 3 indicateurs résultat
- Le médecin voit : métriques brutes + confidence level + vidéo

### Interface caméra (Agent)
- Overlay guide : silhouette ovale — "Placez le visage dans le cadre"
- Countdown : 10 secondes d'analyse
- Feedback : "Visage détecté ✓" / "Trop sombre" / "Bougez moins"
- Option "Passer cette étape" toujours disponible

### Résultats agent (3 indicateurs simples)
| Indicateur | Normal | Attention | Alerte |
|---|---|---|---|
| Yeux — Symétrie | Symétrique | — | Asymétrie détectée |
| Pâleur | Normal | Légère pâleur | Pâleur marquée |
| Niveau d'éveil | Éveillé | Somnolent | Très somnolent |

Disclaimer obligatoire : *"Analyse visuelle indicative. Ne remplace pas l'examen clinique."*

### Contribution au score
```
Score total (0–10)
= Température    (0–2 pts)
+ Questionnaire  (0–4 pts)
+ Vision         (0–4 pts, max 40%)
```

---

## 10. CAS D'USAGE TERRAIN — SCÉNARIOS RÉELS

### Scénario A — Dispensaire isolé, zéro réseau, claim différé
*Marie, agent de santé à Bossangoa, reçoit un enfant de 6 ans avec fièvre.*
1. Elle crée la fiche patient et réalise le scan en 3 minutes. Score : 8/10. Son d'alerte urgent.
2. Elle soumet. L'app confirme : "Dossier enregistré. Médecins alertés dès que le réseau revient."
3. 6 heures plus tard, réseau disponible 10 minutes. Sync automatique.
4. Tous les médecins de l'entité reçoivent : "🔴 Urgent — Enfant 6 ans, score 8/10."
5. Dr. Olivier claim en premier. Les autres reçoivent : "Pris par Dr. Olivier."
6. Dr. Olivier valide en 2 minutes : paludisme grave, référer à l'hôpital.
7. Marie reçoit la notification. **+1 pt crédité sur son compteur.**
8. Dr. Olivier reçoit **+3.5 pts**.

### Scénario B — Hôpital avec 3 médecins, dossier urgent
*Trois médecins sont connectés. Un dossier score 9/10 arrive.*
1. Les 3 médecins reçoivent la notification simultanément.
2. Dr. Aimée tape "Prendre en charge" en premier (2 secondes après la notif).
3. Les deux autres voient instantanément : "Pris en charge par Dr. Aimée."
4. Dr. Aimée valide en 3 minutes. **+3.5 pts. Badge "Réactif" en cours d'obtention.**
5. L'agent reçoit la confirmation. Son patient est pris en charge.

### Scénario C — Fin de mois, rapport pour le jury hospitalier
*L'admin de l'Hôpital de Bangui prépare l'évaluation annuelle du personnel.*
1. Elle ouvre le Leaderboard de l'entité.
2. Elle voit : Marie (agent) — 127 pts — Badge "Engagé". Dr. Aimée — 312 pts — Badge "Expert clinique".
3. Elle génère le rapport PDF officiel pour le comité médical.
4. Le comité désigne Marie "Meilleure agente de santé communautaire de l'année."
5. **Pour la première fois, le travail de Marie sur le terrain est reconnu formellement.**

### Scénario D — Nouvelle entité ONG, déploiement rapide
*Une ONG déploie Klinik-Scan dans 3 nouveaux dispensaires en RCA.*
1. L'admin crée l'entité et génère 3 codes d'invitation.
2. Chaque agent crée son compte avec le code. Approbation admin en 1 tap.
3. En 10 minutes, 3 agents sont opérationnels, hors ligne, prêts à consulter.
4. Dès le premier scan soumis, les médecins de l'ONG reçoivent la notification.
5. Le système de claim garantit qu'aucun dossier ne reste sans réponse.

---

*Document créé le : 28 mai 2026*
*Mis à jour le : 30 mai 2026 — Workflow inscription sécurisé, code 6 caractères,
rôle admin-only, questionnaire adaptatif V1.1, lucide_icons, round-robin
notifications, Cloudinary, templates PDF Canva/dart:pdf, frissons/palpitations
séparés, salutation contextuelle par rôle*
*Auteur : Redemona Christ (Ashad) — github.com/Ashad90*
*Projet : Klinik-Scan*

---

## 11. SUPER ADMIN DASHBOARD — VUE PROPRIÉTAIRE (Next.js Web)

> Ce dashboard est exclusivement réservé à Ashad (propriétaire de Klinik-Scan).
> Il n'est pas accessible depuis l'app Flutter.
> Il ne contient jamais de données patients identifiables.
> URL : admin.klinik-scan.com (hébergé Firebase Hosting)

### 11.1 Accès et sécurité

- **1 seul compte** : le compte propriétaire Ashad (Firebase Auth)
- **Authentification** : email + mot de passe + 2FA obligatoire
- **Règles Firestore** : lecture autorisée uniquement si `request.auth.uid == OWNER_UID`
- **Données lues** : collections `/analytics/` et `/entities/` (métadonnées uniquement)
- **Données jamais lues** : `/patients/`, `/scans/validations/`, photos, vidéos, diagnostics

### 11.2 Structure du dashboard — Sections

#### Section 1 — Vue d'ensemble (temps réel)
Indicateurs clés mis à jour en temps réel via Firestore `onSnapshot` :

| Métrique | Description | Mise à jour |
|---|---|---|
| Utilisateurs actifs maintenant | Connectés dans les 5 dernières minutes | Temps réel |
| Utilisateurs inscrits total | Tous comptes créés | Temps réel |
| Entités actives | Entités avec au moins 1 user actif ce mois | Quotidien |
| Consultations aujourd'hui | Scans soumis depuis minuit | Temps réel |
| Consultations ce mois | Total du mois en cours | Temps réel |
| Validations aujourd'hui | Diagnostics validés depuis minuit | Temps réel |
| Score moyen global | Moyenne de tous les scores de risque | Quotidien |
| Taux de validation | % dossiers validés vs soumis | Temps réel |

#### Section 2 — Monétisation & Revenus

| Métrique | Description |
|---|---|
| MRR (Monthly Recurring Revenue) | Revenus abonnements du mois en cours |
| ARR (Annual Recurring Revenue) | Projection annuelle basée sur MRR |
| Chiffre d'affaires total | Cumulé depuis le lancement |
| Abonnements actifs par plan | Nombre d'entités par plan (Starter/Pro/Équipe/Entreprise) |
| Taux de conversion | Starter → Pro → Équipe |
| Taux de churn | Entités ayant annulé ce mois |
| Revenus publicités (AdMob) | Revenus bannières plan Starter ce mois |
| Paiements en attente | Factures non réglées |

Graphiques :
- Courbe MRR sur 12 mois glissants
- Répartition des plans (donut chart)
- Revenus par méthode de paiement (Mobile Money / Stripe / Virement)
- Revenus par pays (carte Afrique Centrale)

#### Section 3 — Géographie & Croissance

- Carte interactive Afrique Centrale
- Nombre d'entités par pays (point sur la carte, taille proportionnelle)
- Nombre de consultations par pays ce mois
- Pays avec la plus forte croissance

#### Section 4 — Entités clientes (liste)

Tableau des entités avec :
- Nom de l'entité + type + pays
- Plan actuel + date d'expiration
- Nombre d'utilisateurs actifs
- Nombre de consultations ce mois
- Statut (actif / suspendu / en attente de paiement)
- Actions : Changer plan / Suspendre / Contacter

**Données jamais affichées dans ce tableau :**
noms de patients, diagnostics, photos, scores individuels de patients.

#### Section 5 — Santé technique

| Métrique | Seuil d'alerte |
|---|---|
| Taux d'erreur Firebase | > 1% → alerte orange, > 5% → alerte rouge |
| Synchronisations en échec | > 50 en queue → alerte |
| Usage Firestore (lectures/écritures) | > 80% quota gratuit → alerte |
| Usage Firebase Storage | > 80% quota → alerte |
| Latence moyenne API | > 2s → alerte |
| FCM delivery rate | < 90% → alerte |

#### Section 6 — Publicités AdMob

- Revenus AdMob ce mois / ce jour
- Nombre d'impressions
- eCPM moyen (revenu pour 1000 impressions)
- Entités sur plan Starter (potentiel publicitaire)
- Graphique revenus publicitaires sur 6 mois

### 11.3 Architecture technique du Super Admin Dashboard

```
_admin-dashboard/          ← dossier séparé du monorepo Flutter
├── app/
│   ├── dashboard/         ← Vue d'ensemble
│   ├── monetisation/      ← Revenus, abonnements
│   ├── entites/           ← Gestion entités clientes
│   ├── geographie/        ← Carte et stats pays
│   ├── technique/         ← Santé Firebase
│   └── publicites/        ← Stats AdMob
├── lib/
│   ├── firebase/          ← Firebase Admin SDK config
│   └── analytics/         ← Agrégation des données
└── package.json
```

### 11.4 Collection Firestore dédiée aux analytics (anonymisée)

Pour alimenter le dashboard sans toucher aux données patients, une Cloud Function
agrège les données chaque heure dans une collection `/analytics/` :

```
/analytics/
  /global/
    - activeUsersNow, totalUsers, totalEntities
    - consultationsToday, consultationsThisMonth
    - validationsToday, avgRiskScore
    - updatedAt

  /revenue/
    - mrrUSD, arrUSD, totalRevenueUSD
    - planCounts: { starter, pro, equipe, enterprise }
    - churnThisMonth, conversionRate
    - adMobRevenueThisMonth
    - updatedAt

  /countries/{countryCode}/
    - entityCount, activeUsers, consultationsThisMonth
    - updatedAt

  /technical/
    - firestoreReadCount, firestoreWriteCount
    - storageUsedGB, fcmDeliveryRate
    - errorRate, avgLatencyMs
    - updatedAt
```

**Règle absolue :** La Cloud Function qui alimente `/analytics/` ne copie jamais
de données patients. Elle ne compte que des chiffres.

---

## 12. MONÉTISATION — DÉTAIL COMPLET

### 12.1 Publicités AdMob (Plans Starter et Basic)

**Plan Starter — publicités complètes :**

| Emplacement | Type | Fréquence |
|---|---|---|
| Bas de l'écran d'accueil | Bannière 320x50 | Permanente |
| Entre deux patients dans la liste | Bannière native | 1 item sur 5 |
| Après la soumission d'un scan | Interstitiel plein écran | 1 fois sur 3 soumissions |

**Plan Basic — publicités réduites :**

| Emplacement | Type | Fréquence |
|---|---|---|
| Bas de l'écran d'accueil | Bannière 320x50 | Fréquence réduite de 50% |
| Entre deux patients dans la liste | Supprimée | — |
| Après la soumission d'un scan | Supprimée | — |

**Règles absolues (tous plans confondus) :**
- Jamais pendant un scan actif ou sur l'écran de résultat du score de risque.
- Jamais sur les écrans de validation médicale, de génération PDF, d'ordonnance.
- Jamais sur les écrans d'urgence (score ≥ 7).
- Plans Pro, Équipe, Entreprise : aucune publicité, aucune initialisation AdMob.
- Uniquement des publicités contextuelles santé (médicaments génériques,
  équipements médicaux, formations médicales, mutuelles santé).
- L'utilisateur peut masquer une pub individuelle via le bouton "×".

**Intégration Flutter :**
```dart
// Initialisation AdMob conditionnelle selon le plan
switch (entityPlan) {
  case EntityPlan.starter:
    await MobileAds.instance.initialize();
    AdConfig.setFrequency(full: true);   // tous les emplacements actifs
    break;
  case EntityPlan.basic:
    await MobileAds.instance.initialize();
    AdConfig.setFrequency(full: false);  // bannière accueil uniquement, 50%
    break;
  default:
    break; // Pro, Équipe, Entreprise : aucune pub
}
```

### 12.2 Paiements Mobile Money — Orange Money

**Flux de paiement Orange Money :**
```
Entité choisit plan Pro (29$/mois)
    ↓
Conversion USD → XAF au taux du jour (affichée à l'écran)
    ↓
Saisie numéro Orange Money de l'entité
    ↓
Appel API Orange Money → génération d'un code USSD
    ↓
L'admin de l'entité compose le code USSD sur son téléphone
    ↓
Confirmation Orange Money → webhook reçu par Cloud Function Firebase
    ↓
Cloud Function met à jour le plan de l'entité dans Firestore
    ↓
Remote Config rafraîchi → accès Pro débloqué immédiatement
```

**API Orange Money (appel REST depuis Cloud Function) :**
```javascript
// Cloud Function — initier un paiement Orange Money
const response = await fetch('https://api.orange.com/orange-money-webpay/dev/v1/webpayment', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${ORANGE_ACCESS_TOKEN}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    merchant_key: ORANGE_MERCHANT_KEY,
    currency: 'XAF',
    order_id: `klinik_${entityId}_${Date.now()}`,
    amount: amountXAF,
    return_url: 'https://klinik-scan.com/payment/success',
    cancel_url: 'https://klinik-scan.com/payment/cancel',
    notif_url: 'https://us-central1-klinik-scan.cloudfunctions.net/orangeWebhook',
  }),
});
```

### 12.3 Paiements Mobile Money — Airtel Money

Même logique qu'Orange Money, API différente :
```javascript
// Airtel Money API endpoint
const AIRTEL_API = 'https://openapi.airtel.africa/merchant/v1/payments/';
// Webhook pour confirmation de paiement
// Cloud Function : airtelWebhook
```

### 12.4 Paiements carte internationale — Stripe

**Cible :** ONG internationales (MSF, UNICEF, Croix-Rouge).
Ces entités ont des cartes bancaires Visa/Mastercard en USD ou EUR.

**Intégration Flutter :**
```dart
// Initialisation Stripe
Stripe.publishableKey = STRIPE_PUBLISHABLE_KEY;

// Création PaymentIntent via Cloud Function (jamais côté client)
final paymentIntent = await CloudFunctions.httpsCallable('createStripePayment')
    .call({'amount': amountUSD * 100, 'currency': 'usd', 'entityId': entityId});

// Présentation du formulaire de paiement
await Stripe.instance.presentPaymentSheet();
```

**Règle Stripe obligatoire :** Le `PaymentIntent` est toujours créé côté serveur
(Cloud Function). Jamais de clé secrète Stripe dans le code Flutter.

### 12.5 Contrats Entreprise (paiement manuel)

Pour les Ministères de la Santé et grandes ONG :
- Devis envoyé par email (PDF généré par l'admin dashboard)
- Virement bancaire ou chèque
- L'admin Ashad active manuellement le plan Entreprise via le Super Admin Dashboard
- Facturation annuelle (pas mensuelle)

### 12.6 Gestion des plans dans Firestore

```
/entities/{entityId}
  - plan: "starter" | "pro" | "equipe" | "enterprise"
  - planExpiresAt: Timestamp
  - planActivatedAt: Timestamp
  - paymentMethod: "orange_money" | "airtel_money" | "stripe" | "manual"
  - scanCountThisMonth: int  (réinitialisé le 1er du mois par Cloud Function)
  - scanLimit: int           (100 / 500 / 2000 / -1 pour illimité)
```

**Vérification du plan à chaque session :**
```dart
// Dans AuthService, après connexion
final entity = await entityRepository.getEntity(entityId);
if (entity.scanCountThisMonth >= entity.scanLimit && entity.plan != 'enterprise') {
  // Afficher écran "Limite atteinte — Passer au plan supérieur"
}
```

### 12.7 Écran de gestion abonnement (dans l'app, côté Admin d'entité)

- Plan actuel + date de renouvellement
- Nombre de scans utilisés / limite du mois (barre de progression)
- Bouton "Passer au plan supérieur"
  - Sélection du plan cible
  - Sélection méthode de paiement (Orange Money / Airtel / Carte)
  - Confirmation + traitement
- Historique des paiements (date + montant + méthode + statut)
- Bouton "Télécharger facture" (PDF auto-généré)

---

*Document mis à jour le : 28 mai 2026*
*Ajouts : Super Admin Dashboard (Section 11) + Monétisation complète (Section 12)*
*Auteur : Redemona Christ (Ashad) — github.com/Ashad90*
*Projet : Klinik-Scan — Ikoue*
