import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinata_ai/features/character/models/character_emotion.dart';

void main() {
  group('Gemini AI Companion Structured Response Tests', () {
    test('Correctly parses valid structured JSON response', () {
      const jsonString = '''
      {
        "reply": "I am so proud of you! Let's celebrate! ✨",
        "emotion": "happy",
        "animation": "smile",
        "intensity": 0.9,
        "voiceStyle": "cheerful",
        "memoryCandidate": "User completed Flutter companion milestone"
      }
      ''';

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final emotion = CharacterEmotion.fromString(decoded['emotion'] as String?);

      expect(decoded['reply'], "I am so proud of you! Let's celebrate! ✨");
      expect(emotion, CharacterEmotion.happy);
      expect(decoded['animation'], 'smile');
      expect(decoded['intensity'], 0.9);
      expect(decoded['memoryCandidate'], 'User completed Flutter companion milestone');
    });

    test('Gracefully falls back to neutral for unknown emotion strings', () {
      const unknownEmotion = 'super_quantum_joy';
      final emotion = CharacterEmotion.fromString(unknownEmotion);
      expect(emotion, CharacterEmotion.neutral);
    });

    test('Handles markdown-wrapped JSON gracefully', () {
      const wrappedJson = '''
      ```json
      {
        "reply": "Aww, don't worry, I am here for you ❤️",
        "emotion": "shy",
        "animation": "blush",
        "intensity": 0.7,
        "voiceStyle": "warm",
        "memoryCandidate": null
      }
      ```
      ''';

      var clean = wrappedJson.trim();
      if (clean.startsWith('```json')) clean = clean.substring(7);
      if (clean.endsWith('```')) clean = clean.substring(0, clean.length - 3);
      clean = clean.trim();

      final decoded = jsonDecode(clean) as Map<String, dynamic>;
      expect(decoded['reply'], "Aww, don't worry, I am here for you ❤️");
      expect(CharacterEmotion.fromString(decoded['emotion'] as String?), CharacterEmotion.shy);
    });
  });
}
