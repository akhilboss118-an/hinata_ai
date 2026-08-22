/// Long-term memory entity stored in Firestore under /users/{uid}/memories/{memoryId}
class MemoryItem {
  final String memoryId;
  final String content;
  final String category;
  final int importance;
  final DateTime createdAt;

  const MemoryItem({
    required this.memoryId,
    required this.content,
    this.category = 'personal',
    this.importance = 3,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'memoryId': memoryId,
      'content': content,
      'category': category,
      'importance': importance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MemoryItem.fromMap(Map<String, dynamic> map, String id) {
    return MemoryItem(
      memoryId: id,
      content: map['content'] as String? ?? '',
      category: map['category'] as String? ?? 'personal',
      importance: map['importance'] as int? ?? 3,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
