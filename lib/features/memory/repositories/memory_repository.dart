import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/memory_item.dart';

/// Repository managing user long-term memories in Firestore
class MemoryRepository {
  final FirebaseFirestore? _customFirestore;
  final Uuid _uuid = const Uuid();

  MemoryRepository({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userMemories(String uid) {
    return _firestore?.collection('users').doc(uid).collection('memories');
  }

  /// Adds a new memory item
  Future<void> addMemory({
    required String uid,
    required String content,
    String category = 'general',
    int importance = 3,
  }) async {
    final memoryId = _uuid.v4();
    final item = MemoryItem(
      memoryId: memoryId,
      content: content,
      category: category,
      importance: importance,
      createdAt: DateTime.now(),
    );
    try {
      await _userMemories(uid)?.doc(memoryId).set(item.toMap());
    } catch (_) {}
  }

  /// Retrieves all memories for prompt context injection or user viewing
  Future<List<MemoryItem>> getMemories(String uid) async {
    try {
      final snapshot = await _userMemories(uid)
          ?.orderBy('importance', descending: true)
          .get();

      if (snapshot != null) {
        return snapshot.docs
            .map((doc) => MemoryItem.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  /// Deletes a memory item
  Future<void> deleteMemory(String uid, String memoryId) async {
    try {
      await _userMemories(uid)?.doc(memoryId).delete();
    } catch (_) {}
  }

  /// Clears all memories for the user
  Future<void> clearAllMemories(String uid) async {
    try {
      final snapshot = await _userMemories(uid)?.get();
      if (snapshot != null) {
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (_) {}
  }
}
