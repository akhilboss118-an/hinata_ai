import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_entry.dart';

/// Repository managing user diary entries in Firestore
class DiaryRepository {
  FirebaseFirestore? _customFirestore;

  DiaryRepository({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userDiary(String uid) {
    return _firestore?.collection('users').doc(uid).collection('diary');
  }

  /// Sets or updates diary entry for a specific date
  Future<void> saveDiaryEntry(String uid, DiaryEntry entry) async {
    try {
      await _userDiary(uid)?.doc(entry.dateKey).set(entry.toMap());
    } catch (_) {}
  }

  /// Retrieves diary entry for a specific dateKey
  Future<DiaryEntry?> getDiaryEntry(String uid, String dateKey) async {
    try {
      final doc = await _userDiary(uid)?.doc(dateKey).get();
      if (doc != null && doc.exists && doc.data() != null) {
        return DiaryEntry.fromMap(doc.data()!, dateKey);
      }
    } catch (_) {}
    return null;
  }

  /// Retrieves all diary entries sorted by date
  Future<List<DiaryEntry>> getAllDiaryEntries(String uid) async {
    try {
      final snapshot = await _userDiary(uid)
          ?.orderBy('dateKey', descending: true)
          .get();

      if (snapshot != null) {
        return snapshot.docs
            .map((doc) => DiaryEntry.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}

    return [];
  }
}
