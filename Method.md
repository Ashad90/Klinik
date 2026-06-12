# Method.md — Procédure de configuration Firebase

> À lire après redémarrage du terminal.
> Exécuter les commandes dans l'ordre exact ci-dessous.
> Toutes les commandes se lancent depuis le dossier racine du projet : `E:\Klinik`

---

## Contexte

Le projet Flutter Klinik est prêt (Jour 1 terminé).
Firebase a été créé dans la console mais n'est pas encore lié au projet Flutter.
Ce fichier guide la configuration complète.

---

## ÉTAPE 0 — Se placer dans le bon dossier

Ouvrir le terminal et naviguer vers le projet :

```bash
cd "E:\Klinik"
```

---

## ÉTAPE 1 — Se connecter à Firebase CLI

```bash
firebase login
```

- Un navigateur s'ouvre → se connecter avec le compte Google lié à ta console Firebase.
- Si déjà connecté, la commande affiche ton email et termine. Passer à l'étape 2.

---

## ÉTAPE 2 — Installer FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

- Installe l'outil qui va lier Flutter à Firebase.
- Si déjà installé, la commande met à jour la version. Passer à l'étape 3.

---

## ÉTAPE 3 — Lier le projet Flutter à Firebase

```bash
flutterfire configure
```

**Ce que fait cette commande :**
- Affiche la liste de tes projets Firebase → sélectionner `klinik-scan` (ou le nom exact de ton projet)
- Sélectionner la plateforme : **Android** (cocher avec espace, valider avec Entrée)
- Génère automatiquement deux fichiers :
  - `lib/firebase_options.dart` → remplace le stub, contient tes vraies clés
  - `android/app/google-services.json` → requis pour Android

**Résultat attendu :**
```
✓ Firebase configuration file lib/firebase_options.dart generated successfully
```

---

## ÉTAPE 4 — Associer le projet pour le déploiement des règles

```bash
firebase use <ton-project-id>
```

Remplacer `<ton-project-id>` par l'ID visible dans la console Firebase :
- Aller sur console.firebase.google.com
- Cliquer sur ton projet → l'ID apparaît sous le nom du projet (ex: `klinik-scan-ab1c2`)

Exemple :
```bash
firebase use klinik-scan-ab1c2
```

**Résultat attendu :**
```
Now using project klinik-scan-ab1c2
```

---

## ÉTAPE 5 — Déployer les règles de sécurité

```bash
firebase deploy --only firestore:rules,storage
```

**Ce que fait cette commande :**
- Déploie `firestore.rules` → sécurité des données patients/entités
- Déploie `storage.rules` → sécurité des fichiers PDF et ordonnances

**Résultat attendu :**
```
✓ Deploy complete!
```

---

## ÉTAPE 6 — Vérifier que tout fonctionne

```bash
flutter run
```

- L'app doit se lancer sur l'émulateur ou l'appareil Android connecté.
- L'écran de test du design system doit s'afficher (couleurs, boutons, cartes).
- Dans la console Firebase → Firestore → une collection peut être créée manuellement pour tester.

---

## ÉTAPE 7 — Activer Firestore offline persistence (console Firebase)

Dans la console Firebase :
1. Aller dans **Firestore Database**
2. Si le mode est "Test", les règles déployées à l'étape 5 prennent le dessus.
3. Vérifier que les règles affichées correspondent à `firestore.rules`.

---

## Récapitulatif des commandes (copier-coller)

```bash
cd "E:\Klinik"
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
firebase use <ton-project-id>
firebase deploy --only firestore:rules,storage
flutter run
```

---

## En cas de problème

| Problème | Solution |
|---|---|
| `firebase: command not found` | Installer Firebase CLI : `npm install -g firebase-tools` |
| `flutterfire: command not found` | Ajouter le PATH : `export PATH="$PATH":"$HOME/.pub-cache/bin"` |
| `flutterfire configure` ne trouve pas le projet | Vérifier que tu es connecté avec `firebase login` d'abord |
| `flutter run` plante sur Firebase | Normal si étape 3 pas encore faite — vérifier que `lib/firebase_options.dart` ne contient plus `PLACEHOLDER` |
| Règles refusent les écritures | Vérifier que l'utilisateur est bien authentifié et que `entityId` est dans ses custom claims |

---

## Après cette procédure

Une fois toutes les étapes faites, revenir dans Claude Code et dire :
> **"Firebase configuré, on continue avec le Jour 2."**

Claude Code reprendra exactement au Jour 2 : Splash Screen + Onboarding.

---

*Créé le 04 juin 2026 — Klinik-Scan*
