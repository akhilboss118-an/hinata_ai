import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/memory_item.dart';

/// Repository managing user long-term memories in Local Storage + Firestore
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

  String _localKey(String uid) => 'hinata_memory_vault_$uid';

  /// Adds a new memory item to Local Storage and Firestore
  Future<MemoryItem> addMemory({
    required String uid,
    required String content,
    String category = 'personal',
    int importance = 3,
  }) async {
    final memoryId = _uuid.v4();
    final item = MemoryItem(
      memoryId: memoryId,
      content: content.trim(),
      category: category,
      importance: importance,
      createdAt: DateTime.now(),
    );

    // 1. Save to SharedPreferences immediately (guaranteed persistent)
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getMemories(uid);
      // Avoid exact duplicate memories
      if (!existing.any((m) => m.content.toLowerCase() == item.content.toLowerCase())) {
        existing.insert(0, item);
        final encoded = jsonEncode(existing.map((m) => m.toMap()).toList());
        await prefs.setString(_localKey(uid), encoded);
      }
    } catch (_) {}

    // 2. Sync to Firestore
    try {
      await _userMemories(uid)?.doc(memoryId).set(item.toMap());
    } catch (_) {}

    return item;
  }

  /// Automatically parses user chat text and extracts memory candidates
  Future<MemoryItem?> autoExtractAndSaveMemory({
    required String uid,
    required String text,
  }) async {
    final clean = text.trim();
    if (clean.length < 4) return null;
    final lower = clean.toLowerCase();

    String? extractedFact;
    String category = 'personal';
    int importance = 3;

    final nameMatch = RegExp(r"\b(?:my name is|i am called|call me|i'm)\s+([a-zA-Z]{2,20})\b", caseSensitive: false).firstMatch(clean);
    final likeMatch = RegExp(r"\b(?:i really like|i like|i love|my favorite)\s+(.+)", caseSensitive: false).firstMatch(clean);
    final dislikeMatch = RegExp(r"\b(?:i hate|i dislike|i don't like)\s+(.+)", caseSensitive: false).firstMatch(clean);
    final workMatch = RegExp(r"\b(?:i work as|i am a|i work at)\s+(.+)", caseSensitive: false).firstMatch(clean);
    final studyMatch = RegExp(r"\b(?:i am studying|i study|i am learning)\s+(.+)", caseSensitive: false).firstMatch(clean);
    final cityMatch = RegExp(r"\b(?:i live in|i am from|i'm from)\s+(.+)", caseSensitive: false).firstMatch(clean);
    final rememberMatch = RegExp(r"\b(?:remember that|please remember|don't forget that)\s+(.+)", caseSensitive: false).firstMatch(clean);

    if (nameMatch != null && !lower.contains('happy') && !lower.contains('sad') && !lower.contains('tired') && !lower.contains('fine')) {
      final name = nameMatch.group(1);
      extractedFact = "User's name is $name";
      category = 'identity';
      importance = 5;
    } else if (rememberMatch != null) {
      extractedFact = rememberMatch.group(1)?.trim();
      category = 'important';
      importance = 5;
    } else if (likeMatch != null) {
      final item = likeMatch.group(1)?.trim();
      extractedFact = "User loves/likes $item";
      category = 'preference';
      importance = 4;
    } else if (dislikeMatch != null) {
      final item = dislikeMatch.group(1)?.trim();
      extractedFact = "User dislikes $item";
      category = 'preference';
      importance = 3;
    } else if (workMatch != null) {
      final item = workMatch.group(1)?.trim();
      extractedFact = "User works as $item";
      category = 'work';
      importance = 4;
    } else if (studyMatch != null) {
      final item = studyMatch.group(1)?.trim();
      extractedFact = "User is studying $item";
      category = 'study';
      importance = 4;
    } else if (cityMatch != null) {
      final item = cityMatch.group(1)?.trim();
      extractedFact = "User lives in / is from $item";
      category = 'location';
      importance = 3;
    }

    if (extractedFact != null && extractedFact.isNotEmpty) {
      return await addMemory(
        uid: uid,
        content: extractedFact,
        category: category,
        importance: importance,
      );
    }
    return null;
  }

  /// Retrieves all memories from Local Storage & Firestore
  Future<List<MemoryItem>> getMemories(String uid) async {
    final List<MemoryItem> memories = [];

    // 1. Try local storage first
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localKey(uid));
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        memories.addAll(list.map((m) => MemoryItem.fromMap(m as Map<String, dynamic>, m['memoryId'] as String? ?? '')));
      }
    } catch (_) {}

    // 2. Try Firestore to merge if available
    try {
      final snapshot = await _userMemories(uid)
          ?.orderBy('createdAt', descending: true)
          .get();

      if (snapshot != null && snapshot.docs.isNotEmpty) {
        final cloudMemories = snapshot.docs
            .map((doc) => MemoryItem.fromMap(doc.data(), doc.id))
            .toList();

        for (final cm in cloudMemories) {
          if (!memories.any((m) => m.memoryId == cm.memoryId)) {
            memories.add(cm);
          }
        }
      }
    } catch (_) {}

    return memories;
  }

  /// Deletes a memory item
  Future<void> deleteMemory(String uid, String memoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getMemories(uid);
      existing.removeWhere((m) => m.memoryId == memoryId);
      await prefs.setString(_localKey(uid), jsonEncode(existing.map((m) => m.toMap()).toList()));
    } catch (_) {}

    try {
      await _userMemories(uid)?.doc(memoryId).delete();
    } catch (_) {}
  }

  /// Clears all memories for the user
  Future<void> clearAllMemories(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localKey(uid));
    } catch (_) {}

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
