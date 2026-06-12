# Firestore Advanced Patterns — Klinik-Scan

## Pagination des listes de patients

```dart
// Charger les 20 premiers patients
Query buildPatientQuery(String entityId, {DocumentSnapshot? lastDoc}) {
  var query = FirebaseFirestore.instance
      .collection('entities')
      .doc(entityId)
      .collection('patients')
      .orderBy('createdAt', descending: true)
      .limit(20);

  if (lastDoc != null) {
    query = query.startAfterDocument(lastDoc);
  }
  return query;
}
```

## Scans en attente de validation

```dart
Stream<List<Scan>> watchPendingScans(String entityId) {
  return FirebaseFirestore.instance
      .collection('entities')
      .doc(entityId)
      .collection('scans')
      .where('status', isEqualTo: 'pending_review')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Scan.fromMap(d.data())).toList());
}
```

## Recherche locale patients (offline-friendly)

Ne pas utiliser les requêtes Firestore pour la recherche texte.
Utiliser un index local avec Hive ou SQLite pour la recherche.
Firestore ne supporte pas la recherche full-text.

```dart
// Pattern correct : cache local pour la recherche
class LocalPatientIndex {
  static final Box<PatientLocal> _box = Hive.box('patients_index');

  static void index(Patient patient) {
    _box.put(patient.id, PatientLocal(
      id: patient.id,
      searchKey: '${patient.nom} ${patient.prenom}'.toLowerCase(),
    ));
  }

  static List<String> search(String query) {
    return _box.values
        .where((p) => p.searchKey.contains(query.toLowerCase()))
        .map((p) => p.id)
        .toList();
  }
}
```

## Batch write pour scan + mise à jour statut patient

```dart
Future<void> submitScanWithPatientUpdate(
  String entityId,
  Scan scan,
  String patientId,
) async {
  final batch = FirebaseFirestore.instance.batch();
  final db = FirebaseFirestore.instance;

  // Écrire le scan
  final scanRef = db
      .collection('entities').doc(entityId)
      .collection('scans').doc(scan.id);
  batch.set(scanRef, scan.toMap());

  // Mettre à jour la date du dernier scan du patient
  final patientRef = db
      .collection('entities').doc(entityId)
      .collection('patients').doc(patientId);
  batch.update(patientRef, {'lastScanAt': FieldValue.serverTimestamp()});

  await batch.commit(); // Works offline — queued automatically
}
```
