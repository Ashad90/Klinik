---
name: klinik-firebase-rules
description: Use this skill for ALL Firebase/Firestore operations in Klinik-Scan. Covers multi-entity data architecture, security rules by role, offline persistence patterns, Firestore queries, Firebase Auth token management, Firebase Storage rules, and FCM setup. Trigger whenever writing, reading, or modifying any Firebase-related code in the project.
---

# Klinik-Firebase-Rules Skill

## Core Philosophy (Karpathy Method)

Every Firebase operation in Klinik-Scan must satisfy three non-negotiable constraints simultaneously:
1. **Multi-entity isolation** — data from entity A is never accessible by entity B, ever.
2. **Offline-first** — every read and write must work without network, syncing when connectivity returns.
3. **Role-based access** — agents, médecins, and admins have strictly defined permissions, enforced server-side.

Never assume the network exists. Never trust the client for role validation. Never share data across entities.

---

## Project Firestore Architecture

### Collection Structure (Strict — Do Not Deviate)

```
/publicEntities/{entityId}        [annuaire public — recherche « Rejoindre » (Jour 4)]
  Fields: name, nameLower (clé de recherche préfixe), city, type
  AUCUNE donnée sensible. Écrit dans le MÊME batch que la création d'entité.
  Lisible par tout utilisateur authentifié (y compris session anonyme du candidat).

/entities/{entityId}
  Fields: name, type, logoUrl, plan, createdAt, createdBy (uid), status (active/suspended)

  /pendingUsers/{uid}             [demandes d'adhésion — uid = session anonyme du candidat]
    Fields: nom, email, phone, grade, status (pending_approval|approved|rejected),
            createdAt, assignedRole, accessCode (6 car., sans 0/O/1/I/L),
            codeExpiresAt (24h), approvedBy, approvedAt

  /users/{uid}
    Fields: role (agent|medecin|admin), nom, grade, phone, tokenFCM, entityId, approvedAt, approvedBy

  /patients/{patientId}
    Fields: nom, prenom, age, sexe, photoBase64, photoUrl, createdBy, createdAt, entityId

  /scans/{scanId}
    Fields: patientId, temperature, symptomes (map), scoreRisque (0-10), status
            (pending_review|validated|referred), createdBy, createdAt, entityId
            visionMetrics (map): { pupilRatio, scleralSaturation, blinkRate, palleurScore }

  /validations/{validationId}
    Fields: scanId, patientId, diagnosticFinal, commentaire, examensComplementaires (array),
            referred (bool), validatedBy, validatedAt, entityId, pdfUrl

  /syncQueue/{queueId}  [local only - not synced]
    Fields: operation, collection, docId, data, createdAt, attempts
```

### Entity Types Enum
```dart
enum EntityType { centreSante, ong, clinique, hopital, dispensaire }
```

### User Roles Enum
```dart
enum UserRole { agent, medecin, admin }
```

---

## Firestore Security Rules — Membership Model (Option B, current — no custom claims)

> **Source de vérité = `firestore.rules` à la racine.** Le modèle ci-dessous y est déployé.
>
> **Appartenance SANS custom claims (plan Spark gratuit).** L'appartenance à une entité
> est dérivée de l'**existence du document utilisateur** `/entities/{entityId}/users/{uid}`
> (via `exists()`/`get()` — lectures privilégiées dans les règles, non soumises aux règles
> cibles → pas de récursion), et non d'un claim `request.auth.token.entityId`. Le rôle est lu
> dans ce même document. Raison : les custom claims exigent une Cloud Function (plan Blaze),
> différé. Voir « Custom Claims (Option A) » plus bas pour la bascule quand Blaze sera actif.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() { return request.auth != null; }

    function isMember(entityId) {
      return isAuthenticated() &&
        exists(/databases/$(database)/documents/entities/$(entityId)/users/$(request.auth.uid));
    }
    function memberRole(entityId) {
      return get(/databases/$(database)/documents/entities/$(entityId)/users/$(request.auth.uid)).data.role;
    }
    function hasRole(entityId, role) { return isMember(entityId) && memberRole(entityId) == role; }
    function isAdminOfEntity(entityId) { return hasRole(entityId, 'admin'); }
    // Vrai compte (email) — l'auth anonyme ne sert qu'au flux « Rejoindre »
    function isNotAnonymous() { return request.auth.token.firebase.sign_in_provider != 'anonymous'; }

    match /publicEntities/{entityId} {  // annuaire public minimal (recherche Jour 4)
      allow read:   if isAuthenticated();
      // Écrit par le créateur dans le batch de création (getAfter = état post-batch) ou l'admin
      allow create, update: if isAdminOfEntity(entityId) ||
        getAfter(/databases/$(database)/documents/entities/$(entityId)).data.createdBy == request.auth.uid;
      allow delete: if false;
    }

    match /entities/{entityId} {
      allow read:   if isMember(entityId);
      allow create: if isAuthenticated() && isNotAnonymous();  // 1er utilisateur crée l'entité
      allow update: if isAdminOfEntity(entityId);
      allow delete: if false;

      match /users/{uid} {
        allow read:   if isMember(entityId);
        // admin ajoute un membre (approbation), OU créateur d'entité dans son batch
        // de création (getAfter). JAMAIS d'auto-ajout libre (faille colmatée 11/06/2026).
        allow create: if isAdminOfEntity(entityId) ||
          (request.auth.uid == uid &&
           getAfter(/databases/$(database)/documents/entities/$(entityId)).data.createdBy == request.auth.uid);
        // self-update SANS changer son rôle (anti-escalade agent → admin)
        allow update: if isAdminOfEntity(entityId) ||
          (request.auth.uid == uid && request.resource.data.role == resource.data.role);
        allow delete: if isAdminOfEntity(entityId);
      }

      match /pendingUsers/{uid} {       // candidat = pas encore membre (session anonyme OK)
        allow read:   if isAdminOfEntity(entityId) || request.auth.uid == uid;
        allow create: if isAuthenticated() && request.auth.uid == uid &&
          request.resource.data.status == 'pending_approval';
        allow update, delete: if isAdminOfEntity(entityId);
      }

      match /patients/{patientId} {
        allow read:   if isMember(entityId);
        allow create: if hasRole(entityId,'agent') || hasRole(entityId,'medecin') || hasRole(entityId,'admin');
        allow update: if isMember(entityId);
        allow delete: if isAdminOfEntity(entityId);
      }

      match /scans/{scanId} {
        allow read:   if isMember(entityId);
        allow create: if hasRole(entityId,'agent') || hasRole(entityId,'medecin') || hasRole(entityId,'admin');
        allow update: if isMember(entityId) &&
          (hasRole(entityId,'medecin') || hasRole(entityId,'admin') ||
          (hasRole(entityId,'agent') && resource.data.status == 'pending_claim'));
        allow delete: if isAdminOfEntity(entityId);
      }

      match /validations/{validationId} {   // archives médicales — jamais supprimées
        allow read:   if isMember(entityId);
        allow create: if hasRole(entityId,'medecin') || hasRole(entityId,'admin');
        allow update: if hasRole(entityId,'medecin') || hasRole(entityId,'admin');
        allow delete: if false;
      }
    }

    match /analytics/{document=**} { allow read, write: if false; } // Admin SDK only
  }
}
```

---

## Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /entities/{entityId}/{allPaths=**} {
      allow read: if request.auth != null && request.auth.token.entityId == entityId;
      allow write: if request.auth != null && request.auth.token.entityId == entityId
                   && request.resource.size < 10 * 1024 * 1024; // 10MB max
    }
  }
}
```

---

## Flutter Firebase Initialization (main.dart pattern)

```dart
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline persistence — REQUIRED for Klinik-Scan
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Auth persistence
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
}
```

---

## Custom Claims — Entity & Role Injection (Option A — RÉSERVÉ, nécessite Blaze)

> ⚠️ **Non actif.** Le projet utilise actuellement le modèle d'appartenance par doc
> (Option B, ci-dessus), sur le plan Spark gratuit. Les custom claims ci-dessous exigent une
> Cloud Function (plan Blaze). À activer **uniquement** quand le fondateur confirme avoir Blaze.
> La bascule consistera à : déployer cette Function, puis remplacer `isMember`/`memberRole`
> dans les règles par les helpers basés sur `request.auth.token.entityId`/`role`.

After user creation, set custom claims via Firebase Admin SDK (Cloud Function):

```javascript
// Cloud Function: setUserClaims
exports.setUserClaims = functions.firestore
  .document('entities/{entityId}/users/{uid}')
  .onWrite(async (change, context) => {
    const userData = change.after.data();
    if (!userData) return;

    await admin.auth().setCustomUserClaims(context.params.uid, {
      entityId: context.params.entityId,
      role: userData.role,
    });
  });
```

In Flutter, force token refresh after claim update:
```dart
await FirebaseAuth.instance.currentUser?.getIdToken(true);
```

---

## Repository Pattern (Dart — Use for ALL Firestore Access)

Never call Firestore directly from widgets or controllers. Always use the Repository pattern:

```dart
abstract class PatientRepository {
  Future<void> createPatient(Patient patient);
  Stream<List<Patient>> watchPatients(String entityId);
  Future<Patient?> getPatientById(String patientId, String entityId);
  Future<void> updatePatient(Patient patient);
}

class FirestorePatientRepository implements PatientRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String entityId;

  FirestorePatientRepository(this.entityId);

  @override
  Future<void> createPatient(Patient patient) async {
    await _db
        .collection('entities')
        .doc(entityId)
        .collection('patients')
        .doc(patient.id)
        .set(patient.toMap());
    // Works offline — Firestore queues the write automatically
  }

  @override
  Stream<List<Patient>> watchPatients(String entityId) {
    return _db
        .collection('entities')
        .doc(entityId)
        .collection('patients')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Patient.fromMap(d.data())).toList());
  }
}
```

---

## FCM Setup — Topics Pattern

Subscribe agents and médecins to entity-specific topics:

```dart
// Subscribe on login
Future<void> subscribeToEntityTopics(String entityId, String role) async {
  await FirebaseMessaging.instance
      .subscribeToTopic('entity_${entityId}_alerts');

  if (role == 'medecin' || role == 'admin') {
    await FirebaseMessaging.instance
        .subscribeToTopic('entity_${entityId}_validations');
  }
}

// Unsubscribe on logout
Future<void> unsubscribeFromEntityTopics(String entityId) async {
  await FirebaseMessaging.instance
      .unsubscribeFromTopic('entity_${entityId}_alerts');
  await FirebaseMessaging.instance
      .unsubscribeFromTopic('entity_${entityId}_validations');
}
```

---

## Firebase Remote Config — In-App Update Pattern

```dart
class AppUpdateService {
  final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  Future<UpdateStatus> checkForUpdate(String currentVersion) async {
    await _config.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _config.fetchAndActivate();

    final latestVersion = _config.getString('latest_version');
    final isMandatory = _config.getBool('update_mandatory');
    final storeUrl = _config.getString('store_url');

    return UpdateStatus(
      hasUpdate: latestVersion != currentVersion,
      isMandatory: isMandatory,
      latestVersion: latestVersion,
      storeUrl: storeUrl,
    );
  }
}
```

---

## Critical Rules — Never Break These

1. **Never query across entities.** Every Firestore query must include the `entityId` path.
2. **Never store sensitive data in Local Storage / SharedPreferences.** Use Flutter Secure Storage for tokens.
3. **Never bypass the Repository layer** to call Firestore directly from UI code.
4. **Never delete validations.** They are medical records — mark as archived instead.
5. **Always handle offline errors silently.** Firestore offline writes are queued — never show error to user for offline writes.
6. **Always compress images before upload.** Max 1MB in Firestore documents, use Firebase Storage for full images.
