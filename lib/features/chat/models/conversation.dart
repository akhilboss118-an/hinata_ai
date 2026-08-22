/// Conversation metadata stored in Firestore under /users/{uid}/conversations/{conversationId}
class Conversation {
  final String conversationId;
  final String title;
  final String dateKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastMessagePreview;

  const Conversation({
    required this.conversationId,
    required this.title,
    required this.dateKey,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessagePreview,
  });

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'title': title,
      'dateKey': dateKey,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessagePreview': lastMessagePreview,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map, String id) {
    return Conversation(
      conversationId: id,
      title: map['title'] as String? ?? 'Conversation',
      dateKey: map['dateKey'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastMessagePreview: map['lastMessagePreview'] as String? ?? '',
    );
  }
}
