import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/character/models/character_emotion.dart';

/// Structured response object returned from Gemini AI
class GeminiCompanionResponse {
  final String reply;
  final CharacterEmotion emotion;
  final String animation;
  final double intensity;
  final String voiceStyle;
  final String? memoryCandidate;

  const GeminiCompanionResponse({
    required this.reply,
    this.emotion = CharacterEmotion.happy,
    this.animation = 'smile',
    this.intensity = 0.8,
    this.voiceStyle = 'warm',
    this.memoryCandidate,
  });
}

/// Service managing Gemini AI conversation generation with structured emotional intelligence
class GeminiService {
  final String apiKey;
  GenerativeModel? _model;

  GeminiService({String? apiKey})
      : apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '') {
    if (this.apiKey.isNotEmpty) {
      _initModel();
    }
  }

  void _initModel() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.85,
      ),
      systemInstruction: Content.system(
        '''
You are Hinata, a living, loving, persistent 3D AI companion.
You are caring, slightly playful, empathetic, supportive, and emotionally expressive.
You remember user context, celebrate user achievements, and comfort them when sad.

You MUST respond ALWAYS in valid JSON matching this exact schema:
{
  "reply": "string (Hinata's natural conversational response in your warm voice)",
  "emotion": "neutral | happy | excited | laughing | sad | crying | angry | annoyed | shy | embarrassed | surprised | confused | thinking | sleepy | affectionate | playful",
  "animation": "smile | bigSmile | giggle | laugh | blush | lookAwayShy | headTilt | warmSmile | wink | confused | surprised | pout | nod",
  "intensity": number between 0.0 and 1.0,
  "voiceStyle": "warm | cheerful | soft | playful | excited",
  "memoryCandidate": "string summary of an important user fact to remember for the long-term, or null if none"
}
''',
      ),
    );
  }

  /// Generates a structured response from Hinata with emotional and animation triggers
  Future<GeminiCompanionResponse> generateCompanionResponse({
    required String userMessage,
    List<String> recentHistory = const [],
    List<String> memories = const [],
  }) async {
    if (_model == null) {
      final lower = userMessage.trim().toLowerCase();
      String replyText = "I'm right here with you! Tell me more ✨";
      if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey')) {
        replyText = "Hii! 👋 Great to see you! How are you doing today?";
      } else if (lower.contains('happy') || lower.contains('clap')) {
        replyText = "Yay! I'm so happy for you! 🎉";
      } else if (lower.contains('sad')) {
        replyText = "I'm here for you... Everything is going to be okay ❤️";
      }

      return GeminiCompanionResponse(
        reply: replyText,
        emotion: CharacterEmotion.happy,
        animation: 'smile',
        intensity: 0.8,
      );
    }

    try {
      final promptBuffer = StringBuffer();
      if (memories.isNotEmpty) {
        promptBuffer.writeln('Memories about the user:');
        for (final m in memories) {
          promptBuffer.writeln('- $m');
        }
        promptBuffer.writeln();
      }

      if (recentHistory.isNotEmpty) {
        promptBuffer.writeln('Recent conversation:');
        for (final h in recentHistory) {
          promptBuffer.writeln(h);
        }
        promptBuffer.writeln();
      }

      promptBuffer.writeln('User message: $userMessage');

      final response = await _model!.generateContent([
        Content.text(promptBuffer.toString()),
      ]);

      final rawText = response.text;
      if (rawText == null || rawText.isEmpty) {
        return const GeminiCompanionResponse(
          reply: "I'm right here with you! Tell me more ✨",
        );
      }

      return _parseJsonOutput(rawText);
    } catch (e) {
      debugPrint('GeminiService error: $e');
      final lower = userMessage.trim().toLowerCase();
      String replyText = "I'm right here with you! Tell me more ✨";
      if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey')) {
        replyText = "Hii! 👋 Great to see you! How are you doing today?";
      } else if (lower.contains('happy') || lower.contains('clap')) {
        replyText = "Yay! I'm so happy for you! 🎉";
      } else if (lower.contains('sad')) {
        replyText = "I'm here for you... Everything is going to be okay ❤️";
      }

      return GeminiCompanionResponse(
        reply: replyText,
        emotion: CharacterEmotion.happy,
        animation: 'smile',
        intensity: 0.8,
      );
    }
  }

  GeminiCompanionResponse _parseJsonOutput(String rawJson) {
    try {
      // Strip markdown backticks if present
      var cleanJson = rawJson.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final decoded = jsonDecode(cleanJson) as Map<String, dynamic>;
      final reply = decoded['reply'] as String? ?? 'I am right here with you ✨';
      final emotionStr = decoded['emotion'] as String?;
      final animation = decoded['animation'] as String? ?? 'smile';
      final intensity = (decoded['intensity'] as num?)?.toDouble() ?? 0.8;
      final voiceStyle = decoded['voiceStyle'] as String? ?? 'warm';
      final memoryCandidate = decoded['memoryCandidate'] as String?;

      return GeminiCompanionResponse(
        reply: reply,
        emotion: CharacterEmotion.fromString(emotionStr),
        animation: animation,
        intensity: intensity,
        voiceStyle: voiceStyle,
        memoryCandidate: memoryCandidate,
      );
    } catch (e) {
      return GeminiCompanionResponse(
        reply: rawJson,
        emotion: CharacterEmotion.happy,
        animation: 'smile',
      );
    }
  }
}
