# Component Specifications — Klinik-Scan Design System

## Splash Screen
- Background: `primary` (#1565C0)
- Logo: blanc, centré, 120x120px
- Nom app: `display` style, blanc, dessous du logo, spacing lg
- Loader: CircularProgressIndicator blanc, bas d'écran
- Durée: 2 secondes max, puis navigation auto

## Onboarding (4 slides)
- Background: `surface`
- Illustration: SVG ou PNG, 280x280px, centré, margin top xxxl
- Titre: `heading` style, `textPrimary`, centré, padding horizontal xl
- Description: `body` style, `textSecondary`, centré, max 2 lignes
- Dots indicateur: 8px, `border` inactif, `primary` actif, spacing sm
- Bouton "Suivant": `klinikPrimaryButton`, margin horizontal screenPadding
- Bouton "Passer" / "Skip": TextButton, `textTertiary`, coin haut droit
- Dernier slide: bouton "Commencer" à la place de "Suivant"

## Écran de connexion
- AppBar: absent (fullscreen)
- Logo + nom: haut de l'écran, padding top xxl
- Formulaire: card centrée, padding cardPadding
- Champs: email/téléphone + mot de passe, style `klinikInputDecoration`
- Bouton connexion: `klinikPrimaryButton`
- Lien inscription: TextButton `primary` en bas
- Erreur: SnackBar avec background `error`

## Écran d'accueil (Agent)
- AppBar: titre "Klinik-Scan", NetworkStatusIndicator, icône profil
- Salutation: "Bonjour, [Nom]" en `heading`
- Stat rapide: card `klinikCard` — nombre de scans aujourd'hui
- Actions rapides: 2 boutons larges — "Nouveau patient" + "Nouveau scan"
- Liste récente: 5 derniers patients, `klinikCard` par item

## Écran de scan — Questionnaire
- Progress bar: `primary`, haut de l'écran, hauteur 4px
- Question: `heading` style, `textPrimary`, padding md
- Boutons réponse: `klinikYesNoButtons` (60px hauteur)
- Navigation: "Précédent" (ghost) | "Suivant" (primary)
- Score final: `klinikRiskScoreCard` plein écran avec animation d'apparition

## Dashboard médecin
- Liste dossiers à valider: badge rouge avec count sur l'onglet
- Item dossier: card avec nom patient, âge, score coloré, date, bouton "Valider"
- Écran validation: score + vision metrics + questionnaire + bouton "Valider le diagnostic"
- Dropdown diagnostic: liste de pathologies courantes en RCA (paludisme, typhoïde, etc.)
