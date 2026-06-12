# klinik-offline-sync

[![Klinik-Scan](https://img.shields.io/badge/project-Klinik--Scan-blue)](.)
[![Firestore](https://img.shields.io/badge/database-Firestore%20Offline-orange)](https://firebase.google.com)
[![Flutter](https://img.shields.io/badge/framework-Flutter-blue)](https://flutter.dev)
[![Karpathy Method](https://img.shields.io/badge/method-Karpathy--Guidelines-purple)](.)

Skill Claude Code pour la gestion offline-first et la synchronisation de Klinik-Scan.
Architecture complète : queue de synchronisation, détection réseau, upload différé des médias,
indicateurs de statut, et résolution des conflits.

---

## Philosophie

> Dans les zones rurales de RCA, l'absence de réseau est la norme, pas l'exception.
> Klinik-Scan doit fonctionner aussi bien dans un dispensaire isolé de Bossangoa
> qu'à l'hôpital de Bangui avec une connexion 4G.

---

## Architecture de synchronisation

```
Écriture → Firestore Cache (immédiat, offline)
         → SyncQueue (médias uniquement)
              ↓ réseau disponible
         → Firestore Cloud (auto)
         → Firebase Storage (via SyncQueue)
```

---

## Composants principaux

| Composant | Responsabilité |
|---|---|
| `ConnectivityService` | Détection état réseau, broadcast events |
| `SyncQueueService` | File d'attente persistante (Hive), retry logic |
| `NetworkStatusIndicator` | Widget AppBar : point vert/rouge + compteur |
| `SyncStatusWidget` | Écran Paramètres : détail de la file d'attente |

---

## Règles de synchronisation

| Opération | Mécanisme |
|---|---|
| Créer/modifier un document | Firestore offline cache (automatique) |
| Uploader une photo | SyncQueue → Firebase Storage |
| Uploader une vidéo | SyncQueue → Firebase Storage |
| Supprimer un média | SyncQueue |

---

## Comportement offline garanti

- Créer un patient → immédiat, zéro réseau requis
- Créer un scan → immédiat, zéro réseau requis
- Voir la liste des patients → depuis le cache local
- Valider un dossier (médecin) → immédiat, sync automatique dès réseau
- Photos et vidéos → stockées localement, uploadées dès que possible

---

## Installation

```bash
cp -r klinik-offline-sync ~/.claude/skills/
```

## Dépendances Flutter requises

```yaml
connectivity_plus: ^5.0.2
hive_flutter: ^1.1.0
```

---

## Fichiers du skill

```
klinik-offline-sync/
├── SKILL.md                     # Instructions complètes Claude Code
├── references/
│   └── sync-scenarios.md        # Scénarios de test offline détaillés
└── README.md                    # Ce fichier
```

---

**Skill conçu pour Klinik-Scan** — Offline-first pour les zones sans connectivité d'Afrique Centrale
