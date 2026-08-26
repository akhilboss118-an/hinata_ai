import '../../character/models/character_emotion.dart';

/// Message entity stored in Firestore and LocalStorage
class ChatMessage {
  final String messageId;
  final String sender; // 'user' | 'hinata'
  final String text;
  final DateTime timestamp;
  final CharacterEmotion emotion;
  final String? animation;
  final double intensity;
  final String? audioUrl;
  final String? imageBase64;

  const ChatMessage({
    required this.messageId,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.emotion = CharacterEmotion.neutral,
    this.animation,
    this.intensity = 0.5,
    this.audioUrl,
    this.imageBase64,
  });

  bool get isUser => sender == 'user';
  bool get isHinata => sender == 'hinata';
  bool get hasImage => imageBase64 != null && imageBase64!.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'emotion': emotion.name,
      'animation': animation,
      'intensity': intensity,
      'audioUrl': audioUrl,
      'imageBase64': imageBase64,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      messageId: id,
      sender: map['sender'] as String? ?? 'hinata',
      text: map['text'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      emotion: CharacterEmotion.fromString(map['emotion'] as String?),
      animation: map['animation'] as String?,
      intensity: (map['intensity'] as num?)?.toDouble() ?? 0.5,
      audioUrl: map['audioUrl'] as String?,
      imageBase64: map['imageBase64'] as String?,
    );
  }
}
