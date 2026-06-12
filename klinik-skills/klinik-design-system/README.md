# klinik-design-system

[![Klinik-Scan](https://img.shields.io/badge/project-Klinik--Scan-blue)](.)
[![Flutter](https://img.shields.io/badge/framework-Flutter-blue)](https://flutter.dev)
[![Inter Font](https://img.shields.io/badge/font-Inter-black)](https://rsms.me/inter/)
[![Karpathy Method](https://img.shields.io/badge/method-Karpathy--Guidelines-purple)](.)

Système de design complet pour Klinik-Scan Flutter app.
Design tokens, typographie, espacements, composants UI réutilisables.
Optimisé pour Android low-end (2 Go RAM), utilisation terrain en Afrique Centrale.

---

## Philosophie de design

> Concevoir pour les pires conditions : soleil intense, écran poussiéreux,
> agent avec des gants, tablette Android à 80 dollars.

Chaque décision visuelle sert la lisibilité et la rapidité d'action sur le terrain.

---

## Tokens de design

### Couleurs

| Token | Valeur | Usage |
|---|---|---|
| `primary` | #1565C0 | CTAs, AppBar, icônes actives |
| `background` | #F5F7FA | Fond de l'application |
| `surface` | #FFFFFF | Cartes, modals |
| `riskLow` | #2E7D32 | Score 0-3 |
| `riskMedium` | #E65100 | Score 4-6 |
| `riskHigh` | #C62828 | Score 7-10 |

### Typographie

| Style | Taille | Poids | Usage |
|---|---|---|---|
| `display` | 28px | SemiBold | Titres, grands chiffres |
| `heading` | 20px | SemiBold | En-têtes de section |
| `body` | 15px | Regular | Corps de texte |
| `caption` | 12px | Regular | Labels, disclaimers |

### Espacements (grille 8pt)

`xs=4` · `sm=8` · `md=16` · `lg=24` · `xl=32` · `xxl=48` · `xxxl=64`

---

## Composants inclus

- `klinikPrimaryButton` — bouton CTA 52px height
- `klinikSecondaryButton` — bouton outline
- `klinikYesNoButtons` — boutons OUI/NON pour le questionnaire (60px, extra large)
- `klinikRiskScoreCard` — affichage score avec couleur sémantique
- `klinikCard` — conteneur carte avec border et borderRadius
- `klinikInputDecoration` — style unifié pour tous les champs
- `klinikAppBar` — AppBar standard avec NetworkStatusIndicator
- `KlinikScreen` — scaffold de base pour chaque écran

---

## Règles absolues

1. Uniquement les couleurs définies dans `KlinikColors`
2. Uniquement les 4 tailles de texte définies
3. Uniquement les espacements sur la grille 8pt
4. Tap targets minimum 48x48 dp (52+ pour le module scan)
5. NetworkStatusIndicator visible sur chaque écran

---

## Installation

```bash
cp -r klinik-design-system ~/.claude/skills/
```

## Dépendances Flutter requises

```yaml
google_fonts: ^6.1.0
```

---

## Fichiers du skill

```
klinik-design-system/
├── SKILL.md                      # Instructions complètes Claude Code
├── references/
│   └── component-specs.md        # Spécifications détaillées de chaque composant
└── README.md                     # Ce fichier
```

---

**Skill conçu pour Klinik-Scan** — Design system pour application médicale terrain, RCA
