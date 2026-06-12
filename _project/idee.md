# idee.md — Vision Globale du Projet Klinik

> Document de référence — Ne pas modifier sans discussion avec l'auteur du projet.
> Ce fichier est la source de vérité de tout le projet Klinik-Scan.
> Dernière mise à jour : 29 mai 2026

---

## Auteur & Identité

| Champ | Valeur |
|---|---|
| Nom complet | Redemona Christ |
| Pseudo | Ashad |
| Profil | Développeur Fullstack Junior — spécialité Frontend & Mobile |
| Employeur | Ikoue — [ikoue.com](https://ikoue.com) |
| Rôle chez Ikoue | Référant & Développeur |
| GitHub | [github.com/Ashad90](https://github.com/Ashad90) |
| Pays | République Centrafricaine 🇨🇫 |

---

## Le Problème — Pourquoi ce projet existe

En République Centrafricaine et dans les pays voisins d'Afrique Centrale,
des milliers d'agents de santé communautaires travaillent chaque jour dans des
conditions extrêmes : dispensaires isolés, absence totale de réseau mobile,
équipements médicaux limités, formation insuffisante.

Ces agents doivent prendre des décisions de triage sans outil numérique,
sans protocole standardisé, et sans pouvoir consulter un médecin référent
en temps réel.

Trois problèmes structurels aggravent la situation :

**Problème 1 — Le vide de validation.**
Quand un agent soumet un dossier urgent, aucun système ne garantit qu'un
médecin va le prendre en charge rapidement. Les dossiers urgents peuvent
attendre des heures sans réponse.

**Problème 2 — L'absence de reconnaissance du travail terrain.**
Les agents qui font un travail exceptionnel n'ont aucune trace formelle
de leur contribution. Pas de statistiques, pas de valorisation, pas
d'incentive. Les comités médicaux n'ont aucun outil pour identifier
et récompenser les meilleurs soignants.

**Problème 3 — L'invisibilité du propriétaire sur son propre produit.**
Sans tableau de bord propriétaire, le créateur de l'application ne peut
pas piloter sa croissance, détecter les problèmes en temps réel, suivre
ses revenus, ni prendre des décisions business éclairées.

**Klinik-Scan existe pour résoudre ces trois problèmes.**

---

## La Solution — Ce que Klinik fait concrètement

### Côté utilisateurs (App Flutter)

1. **Créer une fiche patient** en quelques secondes, dans tous les modes de
   connectivité. L'architecture est **dual-mode** :
   - **Mode connecté** : toutes les écritures sont persistées simultanément
     en local (Firestore cache) et synchronisées immédiatement vers le cloud.
   - **Mode hors ligne** : toutes les écritures sont persistées localement
     dans le cache Firestore et dans la SyncQueue Hive. Dès que la
     connectivité est détectée, la synchronisation s'exécute automatiquement
     en arrière-plan, de manière silencieuse et sans interruption de l'UX.
   L'utilisateur ne doit jamais avoir à gérer manuellement cette distinction.

2. **Réaliser un scan de triage** — température (manuelle ou via caméra
   thermique USB-C si disponible), questionnaire clinique guidé, et analyse
   visuelle assistée par caméra (pâleur, ictère, pupilles, éveil).

3. **Obtenir un score de risque** (0 à 10) avec code couleur immédiat.

4. **Transmettre le dossier** avec notification simultanée à tous les médecins
   disponibles de l'entité — système Claim pour garantir la prise en charge.
   - **V1** : notification exclusivement via l'application (FCM push).
   - **V2** : notification multicanal — application + WhatsApp Business API
     + SMS (via Twilio ou Africa's Talking selon le pays).

5. **Valider un diagnostic final** et produire les documents médicaux officiels
   via un **circuit hybride numérique-physique** en deux phases :

   **Phase 1 — Génération numérique (in-app) :**
   Le Docteur/Spécialiste génère deux documents PDF distincts depuis l'application :
   - **Formulaire de consultation** : résumé complet du dossier (anamnèse, score
     de risque, métriques vision, conclusion clinique, examens demandés). Signé
     numériquement (nom, grade, entité, horodatage serveur). Distribué
     immédiatement aux parties concernées via l'application.
   - **Ordonnance médicale** : template structuré conforme aux pratiques
     centrafricaines (en-tête entité, données patient, prescriptions en DCI,
     posologie, durée, voie d'administration, recommandations). Généré en PDF,
     prêt à l'impression.

   **Phase 2 — Authentification physique et redistribution (circuit hybride) :**
   L'ordonnance médicale suit un workflow complémentaire obligatoire pour
   acquérir sa valeur légale et culturelle sur le terrain :

   ```
   Impression du PDF ordonnance
       ↓
   Signature manuscrite + apposition du cachet physique du Docteur
       ↓
   Numérisation du document authentifié — deux options :
     Option A : Scanner de bureau → fichier PDF/image uploadé via l'app
     Option B : Photo smartphone via l'app → correction automatique de
                perspective (edge detection), compression, qualité
                suffisante pour lecture et impression
       ↓
   Upload Firebase Storage → horodatage serveur + enregistrement
   de l'auteur de l'upload (traçabilité complète du circuit)
       ↓
   Notification automatique de disponibilité aux destinataires :
     - Agent terrain ayant soumis le dossier initial
     - Médecin consultant (si rôle distinct du Docteur signataire)
       ↓
   Téléchargement par les destinataires → impression → remise au patient
   ```

   **Pourquoi ce circuit hybride est non négociable :**
   En République Centrafricaine et dans les pays voisins, la signature
   numérique seule n'a pas de valeur légale ni de reconnaissance culturelle
   dans le système de santé actuel. Pharmaciens, agents et familles de
   patients n'acceptent qu'une ordonnance portant une signature manuscrite
   et un cachet physique. Le circuit hybride est la réponse pragmatique
   à cette réalité terrain, sans attendre une évolution réglementaire.

   **Traçabilité garantie :**
   Le système conserve les deux versions du document (PDF généré + document
   signé scanné/photographié) avec leurs horodatages respectifs. En cas de
   litige, la chaîne de custody est complète et auditable.

   Le Docteur/Spécialiste peut également **référer le patient** à une autre
   entité médicale enregistrée dans Klinik-Scan, avec transfert d'une copie
   anonymisée du dossier vers l'entité d'accueil.

6. **Accumuler des points et badges** de reconnaissance à chaque action.

### Côté propriétaire (Super Admin Dashboard Web)

7. **Voir en temps réel** les statistiques globales de l'application :
   utilisateurs actifs, consultations, scans, validations, pays actifs,
   et les données de gamification (classement global des meilleurs
   contributeurs par rôle — agents, infirmiers, médecins, docteurs —
   sous forme agrégée et anonymisée).

8. **Piloter la monétisation** : abonnements actifs par plan, chiffre
   d'affaires en cours / mensuel / annuel, taux de conversion, taux de churn.

9. **Surveiller la santé technique** : taux d'erreur Firebase, synchronisations
   en attente, usage quota, alertes système.

10. **Gérer les entités clientes** : activation, suspension, changement de plan,
    confirmation de paiement manuel pour les contrats Entreprise.

**Ce que le Super Admin Dashboard ne fait PAS :**
Il ne donne jamais accès aux données privées des patients (noms, prénoms,
photos, diagnostics, scores individuels). Il ne consulte que des agrégats
statistiques anonymisés produits par des Cloud Functions serveur.
La confidentialité des données patients est absolue et non contournable,
même pour le propriétaire de l'application. Cette contrainte est appliquée
au niveau des règles de sécurité Firestore (server-side), pas uniquement
dans l'interface.

---

## Les 5 Produits de Klinik

```
1. App Mobile Flutter (Android prioritaire / iOS en V1.1)
   → Agents, infirmiers, médecins, docteurs, admins d'entité
   → Cible matérielle : Android ≥ 2 Go RAM, API level 21+

2. Dashboard Desktop Flutter (Windows) [V1.1]
   → Médecins référents avec grand écran
   → Même codebase Flutter, layout adaptatif

3. Super Admin Dashboard Web (Next.js 14 + TypeScript)
   → Ashad uniquement — pilotage business, technique et monétisation
   → Données agrégées anonymisées uniquement

4. Landing Page vitrine (Astro + Tailwind CSS + shadcn)
   → Présentation publique de Klinik-Scan aux entités clientes
   → Captures d'écran réelles de l'app, vidéos démo courtes,
     plans tarifaires, CTA inscription, liens stores

5. Cloud Functions Firebase (Node.js + TypeScript)
   → Agrégation analytics anonymisés pour le Super Admin Dashboard
   → Système de points et badges (calcul serveur uniquement)
   → Webhooks de paiement (Orange Money, Airtel Money, Stripe)
   → Notifications multicanal V2 (WhatsApp, SMS)
```

---

## Le Différenciateur — Ce qui rend Klinik unique

### 1. Architecture Dual-Mode (Online / Offline transparent)
L'application adopte une stratégie **offline-first avec synchronisation
opportuniste** : le comportement est identique pour l'utilisateur quel que
soit l'état du réseau. En présence de connectivité, les données sont
persistées simultanément en local et dans le cloud. En absence de réseau,
les données sont persistées localement et synchronisées automatiquement
dès la détection de connectivité. Aucune action manuelle de l'utilisateur
n'est requise. Aucune donnée n'est perdue.

### 2. Module Vision — Assistant d'observation clinique visuelle
Via la caméra RGB standard du smartphone, analyse faciale temps réel :
asymétrie pupillaire, pâleur/ictère scléraux, niveau d'éveil, expressions
faciales de douleur. Modèle embarqué (MediaPipe Face Mesh Lite, < 2MB),
fonctionne entièrement hors ligne, sans aucune dépendance réseau.

**Extension caméra thermique (optionnelle) :**
Pour les entités disposant d'une caméra thermique connectée (FLIR Lepton
ou équivalent, connexion USB-C, coût estimé 300$–500$ par unité),
l'application détecte automatiquement le périphérique et substitue
la mesure thermique à la saisie manuelle de température, avec une
précision de ±0.5°C. Cette option est transparente : l'app fonctionne
normalement sans ce périphérique.

### 3. Système Claim — Validation sans friction ni oubli
Notification simultanée broadcast à tous les médecins de l'entité.
Premier médecin à prendre en charge = transaction Firestore atomique
(pattern optimistic locking). Impossibilité technique de double traitement.
Visibilité immédiate pour tous les autres médecins dès le claim.

**Roadmap notifications :**
- **V1** : FCM push notification in-app uniquement.
- **V2** : Notification multicanal — FCM + WhatsApp Business API
  (via Meta Business API) + SMS (via Africa's Talking pour l'Afrique
  Centrale ou Twilio pour couverture internationale).

### 4. Documents médicaux PDF — Formulaire de consultation + Ordonnance
Le Docteur/Spécialiste peut générer deux documents PDF distincts,
signés numériquement (nom, grade, cachet d'entité, date/heure) :

- **Formulaire de consultation** : résumé complet du dossier patient
  (anamnèse, score, métriques vision, diagnostic, examens demandés).
  Exportable, téléchargeable, imprimable.

- **Ordonnance médicale** : template structuré conforme aux pratiques
  médicales centrafricaines — en-tête entité, informations patient,
  prescriptions médicamenteuses (DCI, posologie, durée, voie
  d'administration), recommandations, signature et cachet.
  Exportable, téléchargeable, imprimable.

**Référencement inter-entités :**
Le Docteur/Spécialiste peut référer un patient à une autre entité
enregistrée dans Klinik-Scan. La référence génère une notification
à l'entité d'accueil et transfère une copie anonymisée du dossier
(sans les données vision brutes) vers cette entité.

### 5. Gamification médicale — Motiver par la reconnaissance
Points par rôle, badges exportables, rapports officiels pour jurys
hospitaliers. Première plateforme de santé numérique en Afrique Centrale
à valoriser formellement la contribution des soignants de terrain.
Calcul des points exclusivement côté serveur (Cloud Functions) —
aucune manipulation possible côté client.

### 6. Ancrage local profond — Mobile Money en priorité
La stack de paiement est conçue pour le marché réel, pas pour le marché
idéal. Orange Money et Airtel Money sont les méthodes primaires car elles
couvrent 90% des entités locales en Afrique Centrale. Stripe est la méthode
secondaire pour les ONG internationales. Le virement bancaire manuel est
la méthode tertiaire pour les contrats Entreprise.

### 7. Vision propriétaire complète
Super Admin Dashboard offrant une vue temps réel complète sur le business
(MRR, ARR, utilisateurs, entités, pays, gamification agrégée) sans jamais
exposer de données patients identifiables.

---

## Hiérarchie des rôles utilisateurs

```
Super Admin / Propriétaire
(Ashad — Super Admin Dashboard Web, accès exclusif)
    ↓
Administrateur d'entité
(Gestion des membres, approbation des inscriptions,
 génération codes d'invitation, supervision des stats de l'entité,
 gestion du plan d'abonnement, export rapport gamification)
    ↓
Docteur / Spécialiste
(Claim et validation des dossiers, génération formulaire de consultation PDF,
 génération ordonnance médicale PDF, référencement vers une autre entité,
 accès aux métriques Vision complètes + vidéo patient, +5 pts/validation)
    ↓
Médecin généraliste
(Claim et validation des dossiers, génération formulaire de consultation PDF,
 accès aux métriques Vision, +3.5 pts/validation)
    ↓
Infirmier / Sage-femme
(Création patients, réalisation scans complets, soumission dossiers,
 +2 pts/consultation validée par médecin)
    ↓
Agent de santé communautaire
(Création patients, réalisation scans complets, soumission dossiers,
 +1 pt/consultation validée par médecin)
```

---

## Multilinguisme

**V1 (MVP) — 3 langues supportées simultanément :**

| Langue | Justification |
|---|---|
| Français | Langue officielle RCA, langue principale des soignants locaux |
| Anglais | ONG internationales (MSF, UNICEF, IRC, IMC) |
| Espagnol | ONG latino-américaines, Croix-Rouge hispanique, expansion future |

**V2 — Ajout prévu :**
- Sango (langue nationale centrafricaine) — agents de terrain à faible
  niveau de scolarisation en français.

**Implémentation technique :**
Internationalisation via le package Flutter `flutter_localizations` +
`intl`. Toutes les chaînes de caractères sont externalisées dans des
fichiers `.arb` dès la V1. Le changement de langue est possible depuis
les Paramètres sans redémarrage de l'application.

---

## Public Cible

### Utilisateurs de l'app
| Rôle | Profil | Besoin principal |
|---|---|---|
| Agent de santé | Terrain, sans réseau | Outil simple, rapide, guidé |
| Infirmier / Sage-femme | Formation moyenne, poste fixe | Outil complet, efficace |
| Médecin généraliste | Peut être distant | Validation rapide, vue d'ensemble |
| Docteur / Spécialiste | Expert, haut niveau de responsabilité | Métriques Vision, ordonnances, référencement |
| Admin d'entité | Responsable du centre | Gestion, supervision, abonnement |

### Entités clientes (clients payants)
- Centres de santé ruraux
- Dispensaires isolés
- ONG médicales nationales et internationales (MSF, UNICEF, Croix-Rouge)
- Cliniques et hôpitaux de district
- Ministères de la Santé d'Afrique Centrale

### Zone géographique
**Priorité V1 :** République Centrafricaine
**Extension V2 :** Cameroun, Congo-Brazzaville, RDC, Tchad, Gabon, Uganda, Guinée Équatoriale
**Extension V3 :** Soudan (étude réglementaire préalable requise)

---

## Modèle Économique Complet

### Plans d'abonnement (5 niveaux)

| Plan | Cible | Prix | Scans/mois | Comptes users | Publicités |
|---|---|---|---|---|---|
| **Starter** | Dispensaires, petits centres | Gratuit | 100 | 4 (1 admin + 3) | Oui |
| **Basic** | Centres de santé en croissance | 10$/mois | 200 | 6 (1 admin + 5) | Non |
| **Pro** | Cliniques | 29$/mois | 500 | 10 (1 admin + 9) | Non |
| **Équipe** | Hôpitaux, ONG locales | 79$/mois | 2 000 | Illimité | Non |
| **Entreprise** | Grandes ONG, hôpitaux nationaux | Sur devis | Illimité | Illimité | Non |

**Notes importantes :**
- Le plan Starter est activé par défaut pour toute nouvelle entité,
  avec une **période d'essai gratuite de 6 mois** sur le plan Pro
  (accès complet sans publicités ni limites réduites).
- À l'expiration de la période d'essai, l'entité est automatiquement
  rétrogradée vers le plan Starter sauf upgrade explicite.
- Le plan Basic est positionné comme **premier niveau payant accessible**
  pour les petites structures souhaitant supprimer les publicités et
  dépasser la limite de 100 scans, sans engagement vers le plan Pro.
- La facturation est mensuelle ou annuelle (remise 15% sur l'annuel).

### Sources de revenus

**Source 1 — Abonnements SaaS (revenu principal, récurrent)**
Paiement mensuel ou annuel par entité.
Revenus prévisibles et scalables avec la croissance du nombre d'entités.

**Source 2 — Publicités AdMob (revenu passif, plans Starter et Basic)**
Bannières contextuelles santé (médicaments génériques, équipements,
formations médicales, mutuelles santé). Régie : Google AdMob,
intégration Flutter native (`google_mobile_ads`).

Politique par plan :
- **Plan Starter** : publicités complètes — bannière permanente en bas
  d'écran d'accueil, native dans la liste patients (1 sur 5 items),
  interstitiel après soumission de scan (1 fois sur 3).
- **Plan Basic** : publicités réduites — bannière en bas d'écran d'accueil
  uniquement (fréquence réduite de 50%), suppression des interstitiels
  et des bannières natives dans les listes.
- **Plans Pro, Équipe, Entreprise** : aucune publicité, aucune bannière.
  Suppression totale dès l'upgrade vers le plan Pro.

Règles absolues (tous plans confondus) :
- Jamais pendant un scan actif ou sur l'écran de résultat du score.
- Jamais sur les écrans de validation médicale ou de génération PDF.
- Jamais sur les écrans d'urgence (score ≥ 7).

**Source 3 — Contrats Entreprise (revenu élevé, ponctuel)**
Tarification sur devis pour Ministères de la Santé et grandes ONG.
Inclut : déploiement accompagné, formation des équipes, SLA garanti,
support prioritaire, branding personnalisé, rapport annuel officiel.

### Stack de paiement — Stratégie hybride par marché

| Méthode | Technologie | Marché cible | Devise |
|---|---|---|---|
| **Orange Money** *(prioritaire)* | Orange Money API REST | RCA, Cameroun, Congo-B | XAF (FCFA) |
| **Airtel Money** *(prioritaire)* | Airtel Africa API REST | RCA, RDC, Tchad | XAF / CDF |
| **MTN Money** *(prioritaire)* | MTN MoMo API REST | Cameroun, Congo-B, RDC, Uganda | XAF / UGX |
| **Moov Money** *(prioritaire)* | Moov Africa API REST | Tchad, Gabon, Guinée Équatoriale | XAF |
| **Stripe** *(secondaire)* | flutter_stripe + Cloud Functions | ONG internationales | USD / EUR |
| **Virement bancaire** *(tertiaire)* | Manuel + confirmation Super Admin | Contrats Entreprise | Toutes devises |

**Règles d'implémentation obligatoires :**
- Les paiements Orange Money et Airtel Money sont initiés depuis l'app
  Flutter via appel REST à une Cloud Function (jamais appel direct API
  depuis le client — sécurité des credentials).
- Le `PaymentIntent` Stripe est toujours créé côté serveur (Cloud Function).
  La clé secrète Stripe n'apparaît jamais dans le code Flutter.
- La mise à jour du plan dans Firestore est toujours déclenchée par un
  webhook Cloud Function après confirmation du prestataire de paiement.
  Jamais mise à jour côté client uniquement.
- Le quota de scans (`scanCountThisMonth`) est réinitialisé le 1er de
  chaque mois par une Cloud Function planifiée (Cloud Scheduler).

---

## Architecture Complète des Produits

### App Mobile Flutter
```
Stack        : Flutter 3.x / Dart 3.x
Plateformes  : Android (prioritaire, API 21+, ≥ 2 Go RAM)
               iOS (V1.2, déployé uniquement si le seuil de 500 utilisateurs Android
               actifs est atteint — décision basée sur les métriques du Super Admin Dashboard)
Backend      : Firebase (Auth, Firestore, FCM, Remote Config)
               + Cloudinary (médias : photos patients, vidéos, ordonnances scannées)
               + Firebase Storage (documents PDF médicaux uniquement)
État global  : Riverpod 2.x (AsyncNotifier, StateNotifier)
Navigation   : GoRouter
Icônes       : lucide_icons (pub.dev — équivalent Flutter de Lucide React,
               style épuré et cohérent — utilisé sur tous les écrans)
IA on-device : MediaPipe Face Mesh Lite (< 2MB, offline)
               google_mlkit_face_detection
PDF          : dart:pdf + printing
               (2 templates : formulaire consultation + ordonnance)
Paiement     : flutter_stripe
               + Orange Money REST (via Cloud Functions)
               + MTN MoMo REST (via Cloud Functions)
               + Moov Africa REST (via Cloud Functions)
               + Airtel Money REST (via Cloud Functions)
Stockage     : Cloudinary SDK (médias : photos, vidéos, ordonnances scannées)
               Firebase Storage (PDF médicaux : consultation + ordonnances)
Offline      : Firestore offline persistence (cache illimité)
               + Hive (SyncQueue médias + état local)
               + connectivity_plus (détection réseau)
Publicités   : google_mobile_ads (plan Starter uniquement)
i18n         : flutter_localizations + intl (.arb files)
               Langues V1 : français, anglais, espagnol
Périphériques: Caméra thermique USB-C (FLIR Lepton — détection auto,
               optionnelle, substitution température manuelle)
```

### Super Admin Dashboard Web
```
Stack        : Next.js 14 (App Router) + TypeScript
UI           : Tailwind CSS + shadcn/ui
Charts       : Recharts
Backend      : Firebase Admin SDK (Node.js via API Routes)
Auth         : Firebase Auth — 1 seul compte (propriétaire Ashad)
               + protection 2FA obligatoire
Hébergement  : Firebase Hosting (gratuit jusqu'à 10 Go/mois)
Données      : Collection Firestore /analytics/ uniquement
               (agrégats anonymisés produits par Cloud Functions)
Temps réel   : Firestore onSnapshot listeners
Accès        : admin.klinik-scan.com (domaine dédié)
```

### Landing Page
```
Stack        : Astro 4.x + Tailwind CSS + shadcn/ui
Hébergement  : Firebase Hosting
Contenu      : Captures d'écran réelles de l'app mobile (Android/iOS)
               Vidéos démo courtes (< 30s, format WebM/MP4)
               Plans tarifaires interactifs (5 plans)
               Témoignages d'entités clientes
               CTA inscription (lien vers l'app ou formulaire contact)
               Liens de téléchargement (Google Play Store, App Store)
               Disponible en : français, anglais, espagnol
```

### Cloud Functions Firebase
```
Runtime      : Node.js 20 + TypeScript
Fonctions    :
  - aggregateAnalytics()     : agrégation horaire → /analytics/
  - calculatePoints()        : calcul points gamification après validation
  - assignBadges()           : attribution badges selon seuils atteints
  - resetMonthlyQuotas()     : réinitialisation quotas scans (1er du mois)
  - orangeMoneyWebhook()     : confirmation paiement Orange Money
  - airtelMoneyWebhook()     : confirmation paiement Airtel Money
  - stripeWebhook()          : confirmation paiement Stripe
  - sendWhatsAppNotif()      : notifications WhatsApp [V2]
  - sendSMSNotif()           : notifications SMS [V2]
  - claimTimeoutCheck()      : re-notification si claim non validé en 2h [V1.1]
```

---

## Contraintes Non Négociables

1. **Légale** — Aide à la décision uniquement. Jamais de diagnostic automatique.
   Le mot "diagnostic" est interdit dans toute interface utilisateur.
   Utiliser "observation", "indicateur", "aide à la décision".

2. **Confidentialité patients** — Le Super Admin ne voit jamais de données
   patients identifiables. Cette contrainte est appliquée au niveau des
   règles Firestore (server-side), pas seulement dans l'UI.

3. **Dual-mode réseau** — L'application est identique en comportement
   online et offline. Aucun écran ne doit être bloqué par l'absence de réseau.

4. **Paiement sécurisé** — Aucune clé secrète de paiement dans le code Flutter.
   Tout appel API de paiement passe par une Cloud Function serveur.

5. **Points et badges** — Calcul exclusivement côté serveur (Cloud Functions).
   Aucune attribution de points possible côté client.

6. **Validation unique** — Un dossier claimé ne peut être validé que par
   le médecin ayant effectué le claim. Unicité garantie par transaction
   Firestore atomique.

7. **Publicités** — Plan Starter : publicités complètes. Plan Basic :
   publicités réduites (bannière uniquement, fréquence -50%, pas
   d'interstitiels). Plans Pro et supérieurs : zéro publicité.
   Dans tous les cas : jamais pendant un scan actif, jamais sur les
   écrans de validation médicale, jamais sur les écrans d'urgence.

8. **Multilinguisme** — Toutes les chaînes UI externalisées en fichiers .arb
   dès la V1. Ajout de langue sans modification du code source.

9. **Performance** — L'application doit être fluide sur Android 2 Go RAM.
   Aucun modèle IA embarqué ne dépasse 20 MB. Sessions d'analyse vision
   limitées à 30 secondes.

---

## Vision à Long Terme

**Dans 1 an :** 10+ centres de santé en RCA. Premier partenariat ONG
internationale. Premiers badges remis lors d'une cérémonie médicale officielle.
Intégration WhatsApp + SMS (V2) opérationnelle.

**Dans 3 ans :** 5 pays d'Afrique Centrale couverts (Cameroun, RDC, Congo-B,
Tchad, Uganda). Le système de points devient une référence RH formelle.
Orange Money, MTN Money, Moov Money et Airtel Money opérationnels.
iOS disponible si seuil 500 utilisateurs Android atteint.

**Dans 5 ans :** Référence des outils de triage communautaire en Afrique
francophone et hispanophone. Module de formation intégré. Annuaire officiel
des meilleurs soignants reconnus par les institutions médicales nationales.
Intégration Sango complète pour les agents à faible scolarisation.

---

*Document créé le : 28 mai 2026*
*Mis à jour le : 30 mai 2026 — Ajout : iOS conditionnel V1.2 (seuil 500 users),
Cloudinary pour médias, MTN Money + Moov Money, extension géographique V2/V3,
lucide_icons Flutter, questionnaire adaptatif V1.1, workflow inscription sécurisé
(code 6 caractères alphanumériques, rôle assigné par admin uniquement)*
*Auteur : Redemona Christ (Ashad) — github.com/Ashad90*
*Projet : Klinik*

---

## Stratégie Marketing Produit — Klinik

> Section ajoutée le 30 mai 2026 — Vision marketing intégrée au produit.

### Les 3 Objectifs Fondamentaux

**Objectif de Mission (Pourquoi Klinik existe)**
Sauver des vies en donnant aux soignants d'Afrique Centrale les outils
numériques qu'ils méritent — offline, simples, reconnaissants de leur travail.

**Objectif Business (Ce que Klinik doit accomplir)**
Atteindre 100 entités actives dans 3 pays d'Afrique Centrale dans les
18 premiers mois, avec un MRR de 3 000$ et un taux de rétention > 80%.

**Objectif Produit (Ce que le produit doit faire concrètement)**
Réduire le temps de triage médical de 45 minutes à moins de 5 minutes
pour un agent de santé communautaire non spécialisé, sans connexion internet.

---

### Brand Voice — La Voix de Klinik

Klinik parle comme un collègue bienveillant et compétent.
Cinq adjectifs définissent chaque message dans l'application :

**Bienveillant** — L'app encourage, ne critique jamais.
**Clair** — Zéro jargon technique. Tout doit être compris en 3 secondes.
**Professionnel** — Inspire confiance aux ONG, médecins, Ministères.
**Encourageant** — Chaque action de l'utilisateur est valorisée.
**Africain** — Ancré dans le contexte culturel centrafricain et africain.

Exemples de microcopy conformes à cette voix :
- "Excellent travail. Le dossier est entre de bonnes mains." (après soumission)
- "Votre travail est sauvegardé. Envoi automatique dès le retour du réseau." (offline)
- "Marie vient de gagner 1 point. Chaque consultation compte." (gamification)
- "Ce mois-ci, votre équipe a fait une différence pour 47 patients." (rapport mensuel)

---

### Communication Interne (In-App)

Tout ce que Klinik-Scan dit à l'utilisateur pendant l'usage :
- Microcopy bienveillant sur chaque écran (voir Brand Voice)
- Animations de célébration à chaque moment de succès (scan soumis, badge obtenu)
- Sons d'alerte et de confirmation adaptés au contexte terrain
- Messages d'état réseau rassurants (jamais alarmistes)
- Rapport de gamification mensuel in-app

### Communication Externe (Hors App)

Tout ce que Klinik-Scan dit au monde quand l'utilisateur n'est pas connecté :
- Notifications push contextuelles et humaines (pas de notifications robotiques)
- Email "Rapport d'Impact Mensuel" automatique envoyé le 1er de chaque mois
- PDF de gamification exportable = outil marketing authentique pour les comités médicaux
- Landing page vitrine en FR/EN/ES
- Présence future sur LinkedIn et Twitter/X pour la communauté medtech africaine

---

### Stratégie de Communauté — L'Appartenance Klinik

Klinik n'est pas seulement une application. C'est une communauté
de soignants africains qui comptent, qui sont vus, et qui sont reconnus.

Actions concrètes :
- Classement mensuel anonymisé des meilleurs contributeurs par pays
  (communication externe, email + notification)
- Badge "Pionnier Klinik-Scan" pour les 50 premières entités fondatrices
- Cérémonie annuelle de remise des badges (physique ou virtuelle)
  en partenariat avec les Ministères de la Santé
- Rapport d'impact annuel Klinik-Scan publié publiquement
  (données anonymisées, nombre de patients triés, pays couverts)

---

### Stratégie d'Engagement — "Je reviens avec plaisir"

L'engagement dans Klinik-Scan ne se mesure pas au temps passé dans l'app
(contexte médical oblige) mais à la fréquence de retour et à la satisfaction
après chaque usage. Chaque flux utilisateur se termine par un moment de fierté.

Moments de fierté intégrés dans chaque flux :
- Après scan soumis : animation discrète + message valorisant
- Après validation médecin reçue : notification chaleureuse avec nom du médecin
- Après badge obtenu : écran de célébration 3 secondes (full screen)
- Après rapport mensuel reçu : récapitulatif de l'impact personnel du mois


---

## Politique de Confidentialité et Traitement des Données de Santé

> Cette section est destinée à être copiée-collée par Claude Code dans les
> écrans "Politique de confidentialité" et "Conditions d'utilisation" de
> l'application Klinik-Scan, et dans le pied de page de la landing page.
> Dernière mise à jour : 30 mai 2026

---

### POLITIQUE DE CONFIDENTIALITÉ — KLINIK

**Version 1.0 — Entrée en vigueur : à la date de lancement de l'application**

#### 1. Identité du responsable de traitement

Klinik est développé et maintenu par Redemona Christ (ci-après "Ashad"),
Développeur Fullstack Freelancer basé en République Centrafricaine (Bangui). 
*Contact* :
- Tél : (+236) 72 37 63 74 / 70 90 96 64
- Email : redemonachrist@gmail.com 
- Github : github.com/Ashad90

#### 2. Nature des données collectées

Klinik collecte deux catégories de données distinctes :

**Données des professionnels de santé (utilisateurs de l'application) :**
Nom complet, grade médical, adresse email, numéro de téléphone, photo de profil
(optionnelle), nom de l'entité médicale d'appartenance, historique des consultations
réalisées et des validations effectuées (à des fins de gamification uniquement).

**Données médicales des patients triés :**
Prénom, nom, âge, sexe, photographie (optionnelle, avec consentement explicite),
température corporelle, réponses au questionnaire clinique, score de risque calculé,
métriques d'observation visuelle (V1.1), conclusion clinique du médecin validateur,
ordonnances médicales générées.

#### 3. Finalités du traitement

Les données sont collectées et traitées exclusivement aux fins suivantes :
- Permettre le triage médical assisté par l'application
- Faciliter la validation des dossiers par les médecins référents
- Générer les documents médicaux (formulaire de consultation, ordonnance)
- Calculer les points de gamification des professionnels de santé
- Permettre la synchronisation hors ligne des données

#### 4. Isolation stricte entre entités — Garantie fondamentale

**Klinik garantit l'isolation totale et technique des données entre entités.**
Les données d'une entité médicale (dispensaire, hôpital, ONG, clinique) ne sont
jamais accessibles, consultables, partagées ou transférées vers une autre entité,
quelle qu'en soit la raison. Cette isolation est appliquée au niveau des règles
de sécurité de la base de données (Firestore Security Rules), côté serveur,
indépendamment de toute interface utilisateur.

Chaque entité dispose d'un espace de données hermétiquement cloisonné.
Un médecin d'une entité A ne peut jamais accéder aux dossiers de l'entité B.

#### 5. Confidentialité vis-à-vis du propriétaire de l'application

**Le propriétaire et développeur de Klinik (Redemona Christ) n'a accès
à aucune donnée identifiable des patients.**

Le tableau de bord d'administration accessible au développeur (Super Admin Dashboard)
ne présente exclusivement que des données agrégées et anonymisées : nombre total de
consultations, nombre d'entités actives, statistiques de performance technique,
données de facturation. Aucun nom de patient, aucun diagnostic, aucune photo,
aucun résultat clinique n'est jamais visible dans ce tableau de bord.
Cette contrainte est appliquée techniquement au niveau serveur et ne peut
être contournée par aucune action administrative.

#### 6. Hébergement et sécurité des données

Les données sont hébergées sur les serveurs de Google Firebase (infrastructure
Google Cloud Platform), localisés dans des centres de données certifiés ISO 27001.
Les transmissions sont chiffrées en transit (HTTPS/TLS 1.3). Les données au repos
sont chiffrées par Firebase selon les standards AES-256.

Les médias (photos, vidéos, ordonnances scannées) sont hébergés sur Cloudinary,
avec des politiques d'accès restreint par entité.

#### 7. Durée de conservation

Les données médicales des patients sont conservées pendant la durée d'activité
de l'entité sur la plateforme, puis supprimées dans les 90 jours suivant la
résiliation de l'abonnement, sur demande explicite de l'administrateur de l'entité.

#### 8. Droits des utilisateurs

Tout professionnel de santé utilisant Klinik-Scan dispose des droits suivants
concernant ses propres données personnelles (pas les données patients) :
droit d'accès, droit de rectification, droit à l'effacement, droit à la portabilité.
Ces droits s'exercent en contactant l'administrateur de l'entité ou directement
le développeur via les coordonnées mentionnées à l'article 1.

#### 9. Avertissement légal — Aide à la décision uniquement

Klinik est un outil d'aide à la décision médicale. Il ne constitue en aucun
cas un dispositif médical certifié, un outil de diagnostic automatique, ou un
substitut à l'examen clinique d'un professionnel de santé qualifié. Toute décision
médicale reste sous l'entière responsabilité du professionnel de santé habilité.
Le score de risque calculé par l'application est un indicateur orientatif qui
doit toujours être interprété par un médecin dans son contexte clinique global.

#### 10. Modifications de la politique

Le Développeur se réserve le droit de modifier cette politique. Toute modification
substantielle sera notifiée aux administrateurs des entités via l'application
avec un préavis de 30 jours.

---

*Politique rédigée conformément aux principes du RGPD européen et du droit
applicable en République Centrafricaine en matière de protection des données
personnelles de santé.*

