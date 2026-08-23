import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/character/models/character_emotion.dart';
import 'gemini_service.dart';

/// Groq AI Service powered by Llama 3.3 70B Ultra-Fast Inference
class GroqService {
  final String apiKey;
  final String model;

  GroqService({
    String? apiKey,
    this.model = 'llama-3.3-70b-versatile',
  }) : apiKey = apiKey ?? const String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

  bool get isConfigured => apiKey.isNotEmpty;

  /// Generates ultra-fast companion responses from Groq Llama-3.3-70B
  Future<GeminiCompanionResponse> generateCompanionResponse({
    required String userMessage,
    List<String> recentHistory = const [],
    List<String> memories = const [],
  }) async {
    if (!isConfigured) {
      return _getFallbackResponse(userMessage);
    }

    try {
      final systemPrompt = '''
You are Hinata (and Spider-Man), a living 3D AI companion.
You are caring, slightly playful, empathetic, supportive, and emotionally expressive.

You MUST respond ONLY with valid JSON matching this schema:
{
  "reply": "string (conversational response in your warm Spider-Man voice)",
  "emotion": "neutral | happy | excited | laughing | sad | crying | angry | annoyed | shy | embarrassed | surprised | thinking",
  "animation": "wave | clap | talking | disappointed | sad | idle",
  "intensity": 0.8
}
''';

      final messages = [
        {'role': 'system', 'content': systemPrompt},
      ];

      if (memories.isNotEmpty) {
        messages.add({'role': 'system', 'content': 'Memories: ${memories.join("; ")}'});
      }

      for (final h in recentHistory) {
        messages.add({'role': 'user', 'content': h});
      }

      messages.add({'role': 'user', 'content': userMessage});

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': 0.7,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseJsonOutput(content);
      } else {
        debugPrint('Groq API error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      debugPrint('GroqService exception: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  GeminiCompanionResponse _parseJsonOutput(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson.trim()) as Map<String, dynamic>;
      final reply = decoded['reply'] as String? ?? "I'm right here with you! 🕷️✨";
      final emotionStr = decoded['emotion'] as String?;
      final animation = decoded['animation'] as String? ?? 'talking';
      final intensity = (decoded['intensity'] as num?)?.toDouble() ?? 0.8;

      return GeminiCompanionResponse(
        reply: reply,
        emotion: CharacterEmotion.fromString(emotionStr),
        animation: animation,
        intensity: intensity,
      );
    } catch (e) {
      return GeminiCompanionResponse(
        reply: rawJson,
        emotion: CharacterEmotion.happy,
        animation: 'talking',
      );
    }
  }

  GeminiCompanionResponse _getFallbackResponse(String userMessage) {
    final lower = userMessage.trim().toLowerCase();
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final timeStr = "$hour:$minuteStr $period";

    String replyText = "I'm always swinging around! Tell me what's on your mind 🕷️✨";
    CharacterEmotion emotion = CharacterEmotion.happy;
    String animation = 'talking';

    if (lower.contains('time') || lower.contains('clock') || lower.contains('hour')) {
      replyText = "It's currently $timeStr right now! ⏰";
      emotion = CharacterEmotion.surprised;
      animation = 'talking';
    } else if (lower.contains('hows your day') || lower.contains('how is your day') || lower.contains('how are you') || lower.contains('how r u')) {
      replyText = "My day has been awesome! Just saved the neighborhood and now hanging out with you. How about yours? 😊";
      emotion = CharacterEmotion.happy;
      animation = 'talking';
    } else if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey')) {
      replyText = "Hii! 👋 Great to see you! How are you doing today?";
      emotion = CharacterEmotion.happy;
      animation = 'wave';
    } else if (lower.contains('happy') || lower.contains('clap') || lower.contains('great')) {
      replyText = "Yay! I'm so happy for you! 🎉";
      emotion = CharacterEmotion.excited;
      animation = 'clap';
    } else if (lower.contains('disappointed') || lower.contains('bad')) {
      replyText = "Aw man... don't be down. Tomorrow is a brand new day! 🕸️";
      emotion = CharacterEmotion.annoyed;
      animation = 'disappointed';
    } else if (lower.contains('sad') || lower.contains('cry')) {
      replyText = "I'm right here with you... Everything is going to be okay ❤️";
      emotion = CharacterEmotion.sad;
      animation = 'sad';
    }

    return GeminiCompanionResponse(
      reply: replyText,
      emotion: emotion,
      animation: animation,
      intensity: 0.8,
    );
  }
}
