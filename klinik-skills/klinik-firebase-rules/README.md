# klinik-firebase-rules

[![Klinik-Scan](https://img.shields.io/badge/project-Klinik--Scan-blue)](.)
[![Firebase](https://img.shields.io/badge/stack-Firebase-orange)](https://firebase.google.com)
[![Flutter](https://img.shields.io/badge/framework-Flutter-blue)](https://flutter.dev)
[![Karpathy Method](https://img.shields.io/badge/method-Karpathy--Guidelines-purple)](.)

Skill Claude Code dédié à toute l'architecture Firebase de Klinik-Scan.
Couvre la séparation multi-entités, les règles de sécurité Firestore, les rôles utilisateurs,
la persistance offline, FCM, Firebase Storage et Remote Config.

---

## Périmètre de ce skill

Ce skill est la **référence absolue** pour tout code Firebase dans Klinik-Scan.
Claude Code doit consulter ce skill avant d'écrire la moindre ligne liée à :

- Firestore (lecture, écriture, requêtes, streams)
- Firebase Auth (token, custom claims, persistance)
- Firebase Storage (upload photos, vidéos)
- Firebase Cloud Messaging (topics, notifications)
- Firebase Remote Config (mises à jour in-app)

---

## Principes fondamentaux

| Principe | Règle |
|---|---|
| Isolation des entités | Aucune donnée ne traverse les frontières d'une entité |
| Offline-first | Toute opération doit fonctionner sans réseau |
| Role enforcement | Les rôles sont validés côté serveur (custom claims + rules) |
| Repository pattern | Jamais d'appel Firestore direct depuis les widgets |
| Immutabilité médicale | Les validations ne sont jamais supprimées |

---

## Structure de données Firestore

```
/entities/{entityId}
  /users/{uid}
  /patients/{patientId}
  /scans/{scanId}
  /validations/{validationId}
```

Chaque document enfant contient un champ `entityId` pour les requêtes de sécurité.

---

## Rôles utilisateurs

| Rôle | Permissions |
|---|---|
| `agent` | Créer patients, créer scans, voir ses propres dossiers |
| `medecin` | Voir tous les scans de l'entité, valider, générer PDF |
| `admin` | Tout + gérer les utilisateurs, approuver inscriptions |

---

## Installation

```bash
# Copier dans le dossier skills de Claude Code
cp -r klinik-firebase-rules ~/.claude/skills/

# Ou référencer dans CLAUDE.md
# skills: [klinik-firebase-rules]
```

---

## Fichiers du skill

```
klinik-firebase-rules/
├── SKILL.md              # Instructions complètes pour Claude Code
├── references/
│   └── firestore-patterns.md   # Patterns avancés et exemples de requêtes
└── README.md             # Ce fichier
```

---

## Méthode Karpathy appliquée

Ce skill suit les principes Karpathy-Guidelines :
- **Contraintes explicites** avant le code
- **Patterns répétables** que Claude Code peut appliquer mécaniquement
- **Règles non négociables** clairement identifiées
- **Exemples concrets** de code plutôt que de la théorie abstraite

---

## Compatibilité

| Technologie | Version |
|---|---|
| Flutter | 3.x+ |
| Firebase SDK (Flutter) | 3.x+ |
| Firestore | v1 rules |
| Dart | 3.x+ |

---

**Skill conçu pour Klinik-Scan** — Application d'aide au triage médical, République Centrafricaine
