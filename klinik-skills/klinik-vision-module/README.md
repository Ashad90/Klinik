# klinik-vision-module

[![Klinik-Scan](https://img.shields.io/badge/project-Klinik--Scan-blue)](.)
[![MediaPipe](https://img.shields.io/badge/AI-MediaPipe%20Face%20Mesh-green)](https://mediapipe.dev)
[![Flutter](https://img.shields.io/badge/framework-Flutter-blue)](https://flutter.dev)
[![Karpathy Method](https://img.shields.io/badge/method-Karpathy--Guidelines-purple)](.)

Skill Claude Code pour le module d'analyse visuelle de Klinik-Scan.
Détection des métriques faciales cliniques via caméra standard Android/iOS :
asymétrie pupillaire, pâleur sclérale, ictère, niveau d'éveil.

---

## Mission de ce module

> Transformer la caméra d'un smartphone Android bas de gamme en assistant d'observation clinique visuelle, fonctionnant hors ligne, sur des appareils à 2 Go de RAM, en République Centrafricaine.

Le module ne diagnostique jamais. Il observe, mesure, et transmet des données au médecin.

---

## Métriques détectées

| Métrique | Méthode | Pertinence clinique |
|---|---|---|
| Asymétrie pupillaire | MediaPipe Iris landmarks | Anisocorie > 20% = signal neurologique |
| Pâleur sclérale | Analyse HSL zone sclérale | Anémie, faible hémoglobine |
| Score ictère | Analyse teinte H (hue) sclérale | Ictère = atteinte hépatique possible |
| Fréquence de clignement | Eye Aspect Ratio (EAR) | < 10/min = léthargie, fièvre élevée |

---

## Contribution au score de risque

```
Score total (0-10) = Questionnaire (0-4) + Température (0-2) + Vision (0-4)
```

La vision contribue **au maximum 40%** du score.
Le questionnaire clinique et la température restent dominants.

---

## Contraintes légales intégrées

- Disclaimer médical affiché à chaque résultat
- Terminologie "indicateur" — jamais "diagnostic"
- Niveau de confiance toujours visible
- Métriques masquées si confiance < 50%

---

## Architecture Flutter

```
lib/features/scan/vision/
├── vision_module.dart
├── face_detector_service.dart
├── pupil_analyzer.dart
├── scleral_analyzer.dart
├── blink_analyzer.dart
├── vision_metrics.dart
└── vision_score_adapter.dart
```

---

## Contraintes de performance

| Contrainte | Valeur |
|---|---|
| Taille modèle max | 20 MB |
| FPS d'analyse | 5 fps (200ms/frame) |
| Durée session max | 30 secondes |
| Mémoire max | 150 MB |
| RAM cible appareil | 2 GB Android |

---

## Installation

```bash
cp -r klinik-vision-module ~/.claude/skills/
```

---

## Fichiers du skill

```
klinik-vision-module/
├── SKILL.md                        # Instructions complètes Claude Code
├── references/
│   └── mediapipe-landmarks.md      # Référence des landmarks faciaux utilisés
└── README.md                       # Ce fichier
```

---

**Skill conçu pour Klinik-Scan** — Module vision : assistant d'observation clinique visuelle
