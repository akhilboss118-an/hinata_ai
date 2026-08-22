import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../../../core/utils/date_utils.dart';

/// Repository managing Firestore cloud synchronization for conversations and messages
class ChatRepository {
  FirebaseFirestore? _customFirestore;
  final Uuid _uuid = const Uuid();

  ChatRepository({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userConversations(String uid) {
    return _firestore?.collection('users').doc(uid).collection('conversations');
  }

  CollectionReference<Map<String, dynamic>>? _conversationMessages(
      String uid, String conversationId) {
    return _userConversations(uid)?.doc(conversationId).collection('messages');
  }

  /// Gets or creates a conversation for a given dateKey
  Future<Conversation> getOrCreateConversationForDate(String uid, DateTime date) async {
    final dateKey = AppDateUtils.toDateKey(date);
    final convsRef = _userConversations(uid);

    if (convsRef != null) {
      try {
        final query = await convsRef
            .where('dateKey', isEqualTo: dateKey)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          return Conversation.fromMap(doc.data(), doc.id);
        }
      } catch (_) {}
    }

    final conversationId = _uuid.v4();
    final now = DateTime.now();
    final newConv = Conversation(
      conversationId: conversationId,
      title: 'Chat on ${AppDateUtils.formatDisplay(date)}',
      dateKey: dateKey,
      createdAt: now,
      updatedAt: now,
      lastMessagePreview: 'Started conversation with Hinata',
    );

    try {
      await convsRef?.doc(conversationId).set(newConv.toMap());
    } catch (_) {}

    return newConv;
  }

  /// Appends a message to the conversation and updates conversation preview
  Future<void> saveMessage({
    required String uid,
    required String conversationId,
    required ChatMessage message,
  }) async {
    try {
      final messageRef = _conversationMessages(uid, conversationId)?.doc(message.messageId);
      await messageRef?.set(message.toMap());

      await _userConversations(uid)?.doc(conversationId).update({
        'lastMessagePreview': message.text,
        'updatedAt': message.timestamp.toIso8601String(),
      });
    } catch (_) {}
  }

  /// Real-time stream of messages for a given conversation
  Stream<List<ChatMessage>> watchMessages(String uid, String conversationId) {
    final msgsRef = _conversationMessages(uid, conversationId);
    if (msgsRef == null) {
      return Stream.value([]);
    }
    return msgsRef
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Retrieves list of all conversations for the history screen
  Future<List<Conversation>> getConversations(String uid) async {
    final convsRef = _userConversations(uid);
    if (convsRef == null) return [];

    try {
      final snapshot = await convsRef.orderBy('updatedAt', descending: true).get();
      return snapshot.docs
          .map((doc) => Conversation.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
