---
name: klinik-offline-sync
description: Use this skill for ALL offline-first and synchronization logic in Klinik-Scan. Covers Firestore offline persistence configuration, local sync queue management, network state detection, media upload queue, conflict resolution, and sync status UI indicators. Trigger whenever writing code related to network state, data persistence, sync status, or any operation that must work without internet.
---

# Klinik-Offline-Sync Skill

## Core Philosophy (Karpathy Method)

In Klinik-Scan, offline is the default state — not an edge case.
The application must behave identically whether online or offline.
The only difference the user should notice is the color of a small status dot.

**Three cardinal rules:**
1. **Never block the user** because of missing connectivity. Ever.
2. **Never lose data.** A scan created offline must eventually reach the cloud, even after 72 hours.
3. **Never surprise the user.** Show clearly what is synced, what is pending, what failed.

---

## Network Layer Architecture

### ConnectivityService

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _controller.stream;
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;

    _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      _controller.add(_isOnline);

      if (!wasOnline && _isOnline) {
        // Just came online — trigger sync
        SyncQueueService().processPendingQueue();
      }
    });
  }
}
```

---

## Sync Queue Architecture

### SyncQueueItem Model

```dart
enum SyncOperation { create, update, deleteMedia, uploadMedia }
enum SyncStatus { pending, inProgress, failed, completed }

class SyncQueueItem {
  final String id;
  final SyncOperation operation;
  final String collection;
  final String entityId;
  final String docId;
  final Map<String, dynamic> data;
  final String? mediaLocalPath;   // for media uploads
  final String? mediaRemotePath;  // destination in Firebase Storage
  final SyncStatus status;
  final int attempts;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final String? errorMessage;

  const SyncQueueItem({
    required this.id,
    required this.operation,
    required this.collection,
    required this.entityId,
    required this.docId,
    required this.data,
    this.mediaLocalPath,
    this.mediaRemotePath,
    this.status = SyncStatus.pending,
    this.attempts = 0,
    required this.createdAt,
    this.lastAttemptAt,
    this.errorMessage,
  });

  static const int maxAttempts = 5;
  bool get canRetry => attempts < maxAttempts && status != SyncStatus.completed;
}
```

### SyncQueueService

```dart
class SyncQueueService {
  static final SyncQueueService _instance = SyncQueueService._internal();
  factory SyncQueueService() => _instance;
  SyncQueueService._internal();

  // Hive box for local persistence of queue
  late Box<Map> _queueBox;
  final _pendingCount = ValueNotifier<int>(0);
  ValueNotifier<int> get pendingCount => _pendingCount;

  Future<void> initialize() async {
    _queueBox = await Hive.openBox('sync_queue');
    _refreshPendingCount();
  }

  // Add item to queue — always succeeds immediately
  Future<void> enqueue(SyncQueueItem item) async {
    await _queueBox.put(item.id, item.toMap());
    _refreshPendingCount();

    // Try immediately if online
    if (ConnectivityService().isOnline) {
      unawaited(processPendingQueue());
    }
  }

  // Process all pending items
  Future<void> processPendingQueue() async {
    final pending = _queueBox.values
        .map((m) => SyncQueueItem.fromMap(Map<String, dynamic>.from(m)))
        .where((item) => item.canRetry)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // FIFO

    for (final item in pending) {
      if (!ConnectivityService().isOnline) break; // stop if offline again
      await _processItem(item);
    }
    _refreshPendingCount();
  }

  Future<void> _processItem(SyncQueueItem item) async {
    try {
      switch (item.operation) {
        case SyncOperation.create:
        case SyncOperation.update:
          await _syncDocument(item);
          break;
        case SyncOperation.uploadMedia:
          await _uploadMedia(item);
          break;
        case SyncOperation.deleteMedia:
          await _deleteMedia(item);
          break;
      }
      await _queueBox.delete(item.id); // Remove on success
    } catch (e) {
      // Update attempt count and error
      await _queueBox.put(item.id, item.copyWith(
        attempts: item.attempts + 1,
        lastAttemptAt: DateTime.now(),
        errorMessage: e.toString(),
        status: item.attempts + 1 >= SyncQueueItem.maxAttempts
            ? SyncStatus.failed
            : SyncStatus.pending,
      ).toMap());
    }
  }

  Future<void> _syncDocument(SyncQueueItem item) async {
    await FirebaseFirestore.instance
        .collection('entities').doc(item.entityId)
        .collection(item.collection).doc(item.docId)
        .set(item.data, SetOptions(merge: true));
  }

  Future<void> _uploadMedia(SyncQueueItem item) async {
    if (item.mediaLocalPath == null) return;
    final file = File(item.mediaLocalPath!);
    if (!await file.exists()) return;

    final ref = FirebaseStorage.instance.ref(item.mediaRemotePath!);
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    // Update the document with the remote URL
    await FirebaseFirestore.instance
        .collection('entities').doc(item.entityId)
        .collection(item.collection).doc(item.docId)
        .update({'photoUrl': url, 'photoBase64': FieldValue.delete()});
  }

  void _refreshPendingCount() {
    _pendingCount.value = _queueBox.values
        .map((m) => SyncQueueItem.fromMap(Map<String, dynamic>.from(m)))
        .where((item) => item.status == SyncStatus.pending)
        .length;
  }
}
```

---

## Offline-First Write Pattern

Every data write in the app must follow this pattern:

```dart
// CORRECT pattern — agent creates a scan offline
Future<void> createScan(Scan scan, String entityId) async {
  // Step 1: Save to Firestore (works offline via cache)
  await FirebaseFirestore.instance
      .collection('entities').doc(entityId)
      .collection('scans').doc(scan.id)
      .set(scan.toMap());

  // Step 2: If has media, queue media upload separately
  if (scan.photoLocalPath != null) {
    await SyncQueueService().enqueue(SyncQueueItem(
      id: 'media_${scan.id}',
      operation: SyncOperation.uploadMedia,
      collection: 'scans',
      entityId: entityId,
      docId: scan.id,
      data: {},
      mediaLocalPath: scan.photoLocalPath,
      mediaRemotePath: 'entities/$entityId/scans/${scan.id}/photo.jpg',
      createdAt: DateTime.now(),
    ));
  }
  // No error handling needed — Firestore handles offline writes internally
}
```

---

## Network Status Widget

Small indicator always visible in the AppBar:

```dart
class NetworkStatusIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().onConnectivityChanged,
      initialData: ConnectivityService().isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
              ),
            ),
            const SizedBox(width: 4),
            ValueListenableBuilder<int>(
              valueListenable: SyncQueueService().pendingCount,
              builder: (_, count, __) {
                if (count == 0) return const SizedBox();
                return Text(
                  '$count en attente',
                  style: const TextStyle(fontSize: 10, color: Colors.orange),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
```

---

## Sync Status Screen (Settings)

The settings screen shows the full sync queue status:

```dart
class SyncStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SyncQueueService().pendingCount,
      builder: (_, pendingCount, __) {
        return ListTile(
          leading: Icon(
            pendingCount == 0 ? Icons.cloud_done : Icons.cloud_upload,
            color: pendingCount == 0 ? Colors.green : Colors.orange,
          ),
          title: const Text('Synchronisation'),
          subtitle: Text(
            pendingCount == 0
                ? 'Tout est synchronisé'
                : '$pendingCount dossier(s) en attente de synchronisation',
          ),
          trailing: pendingCount > 0
              ? TextButton(
                  onPressed: () => SyncQueueService().processPendingQueue(),
                  child: const Text('Sync maintenant'),
                )
              : null,
        );
      },
    );
  }
}
```

---

## Conflict Resolution Strategy

Klinik-Scan uses **last-write-wins** with server timestamps for all documents.
This is acceptable because:
- Agents write patient data and scans (no overlap with médecin writes)
- Médecins only write validations (new documents, no conflict possible)
- Admins manage users (rare, human coordination expected)

Exception — **validations are append-only**. Never overwrite. Create a new validation document if correction needed.

---

## Critical Rules — Never Break These

1. **Never show an error toast for offline writes.** Firestore handles them silently.
2. **Never block the UI** waiting for a Firestore write to confirm.
3. **Media uploads go through the SyncQueue** — never directly, to handle offline correctly.
4. **The sync queue is persisted in Hive** — it survives app restarts and device reboots.
5. **Maximum 5 retry attempts** per queue item before marking as failed. Alert admin on failure.
6. **Always display pending count** in settings — users must know what hasn't synced yet.
