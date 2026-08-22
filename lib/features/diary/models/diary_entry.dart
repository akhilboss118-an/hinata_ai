/// Diary entry entity stored in Firestore under /users/{uid}/diary/{dateKey}
class DiaryEntry {
  final String dateKey;
  final String mood;
  final String summary;
  final List<String> highlights;
  final DateTime createdAt;

  const DiaryEntry({
    required this.dateKey,
    required this.mood,
    required this.summary,
    this.highlights = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'mood': mood,
      'summary': summary,
      'highlights': highlights,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map, String dateKey) {
    return DiaryEntry(
      dateKey: dateKey,
      mood: map['mood'] as String? ?? 'Happy',
      summary: map['summary'] as String? ?? '',
      highlights: (map['highlights'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
