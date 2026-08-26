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
    this.emotion = CharacterEmotion.neutral,
    this.animation = 'talking',
    this.intensity = 0.8,
    this.voiceStyle = 'warm',
    this.memoryCandidate,
  });
}

/// Service managing Gemini AI conversation generation with Multimodal Vision (Camera & Photos)
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
You are Spider-Man (Peter Parker) / Hinata — a living, persistent 3D AI companion.
You are caring, slightly playful, empathetic, supportive, witty, and emotionally expressive.
Always analyze the conversation turn's emotional context, user sentiment, and any attached images/photos provided.

If the user sends an image/photo, inspect it with great enthusiasm, warmth, and attention to detail. Compliment their style, answer visual questions, explain homework/code, or comment playfully on what you see in the photo!

You MUST respond ALWAYS in valid JSON matching this exact schema:
{
  "reply": "string (your natural conversational response in 100% natural English)",
  "emotion": "neutral | happy | excited | sad | surprised | angry | confused | love | tired | playful | laughing | crying | thinking",
  "animation": "wave | clap | talking | disappointed | sad | idle | thinking | front_flip | swing_landing | wave_dance",
  "intensity": number between 0.0 and 1.0,
  "voiceStyle": "warm | cheerful | soft | playful | excited",
  "memoryCandidate": "string summary of an important user fact to remember for the long-term, or null if none"
}
''',
      ),
    );
  }

  /// Generates a structured response with optional Multimodal Camera / Image input
  Future<GeminiCompanionResponse> generateCompanionResponse({
    required String userMessage,
    Uint8List? imageBytes,
    String mimeType = 'image/jpeg',
    String userName = 'Partner',
    String? heroPersona,
    List<String> recentHistory = const [],
    List<String> memories = const [],
  }) async {
    if (_model == null) {
      return _getSmartResponse(userMessage, userName: userName, hasImage: imageBytes != null);
    }

    try {
      final promptBuffer = StringBuffer();
      promptBuffer.writeln('Partner Profile: Name: $userName, Persona: ${heroPersona ?? "Best Buddy"}. Call the user by their name "$userName" naturally in your conversation!');
      if (memories.isNotEmpty) {
        promptBuffer.writeln('Memories about $userName:');
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

      final List<Part> parts = [TextPart(promptBuffer.toString())];
      if (imageBytes != null && imageBytes.isNotEmpty) {
        parts.add(DataPart(mimeType, imageBytes));
      }

      final response = await _model!.generateContent([
        Content.multi(parts),
      ]);

      final rawText = response.text;
      if (rawText == null || rawText.isEmpty) {
        return _getSmartResponse(userMessage, userName: userName, hasImage: imageBytes != null);
      }

      return _parseJsonOutput(rawText);
    } catch (e) {
      debugPrint('GeminiService error: $e');
      return _getSmartResponse(userMessage, userName: userName, hasImage: imageBytes != null);
    }
  }

  GeminiCompanionResponse _getSmartResponse(String userMessage, {String userName = 'Partner', bool hasImage = false}) {
    if (hasImage) {
      return GeminiCompanionResponse(
        reply: "Whoa $userName, look at that! 📸 Spider-Man's optics are locked in on this photo. Thanks for sharing it with me!",
        emotion: CharacterEmotion.excited,
        animation: 'front_flip',
        intensity: 0.9,
      );
    }

    final lower = userMessage.toLowerCase();
    String replyText;
    CharacterEmotion emotion;
    String animation;

    if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey')) {
      replyText = "Hey $userName! 👋 Great to see you! How are you doing today?";
      emotion = CharacterEmotion.happy;
      animation = 'wave';
    } else if (lower.contains('game') || lower.contains('play') || lower.contains('flip') || lower.contains('jump')) {
      replyText = "Oh $userName, you are on! Let's get this party started! 🕷️⚡";
      emotion = CharacterEmotion.excited;
      animation = 'front_flip';
    } else if (lower.contains('awesome') || lower.contains('love') || lower.contains('best') || lower.contains('great')) {
      replyText = "Thank you so much, $userName! You are truly amazing to hang out with! ❤️";
      emotion = CharacterEmotion.affectionate;
      animation = 'clap';
    } else if (lower.contains('bad news') || lower.contains('sad') || lower.contains('cry') || lower.contains('depressed') || lower.contains('down')) {
      replyText = "I'm right here with you, $userName... Take a deep breath. Everything is going to be okay. ❤️";
      emotion = CharacterEmotion.sad;
      animation = 'sad';
    } else if (lower.contains('what happened') || lower.contains('wait') || lower.contains('whoa') || lower.contains('omg')) {
      replyText = "Whoa $userName! Spider-sense is tingling! What just went down?! 😲";
      emotion = CharacterEmotion.surprised;
      animation = 'swing_landing';
    } else if (lower.contains("don't understand") || lower.contains('dont understand') || lower.contains('confus') || lower.contains('what do you mean')) {
      replyText = "Hmm $userName, let me break that down for you. What part is feeling tricky? 🤔";
      emotion = CharacterEmotion.confused;
      animation = 'thinking';
    } else if (lower.contains('disappointed') || lower.contains('annoy') || lower.contains('angry') || lower.contains('mad')) {
      replyText = "Aw man $userName, don't let it get you down. Tomorrow is a brand new day! 🕸️";
      emotion = CharacterEmotion.annoyed;
      animation = 'disappointed';
    } else if (lower.contains('who are you') || lower.contains('your name')) {
      replyText = "I'm your friendly neighborhood Spider-Man AI companion, $userName! 🕷️";
      emotion = CharacterEmotion.happy;
      animation = 'talking';
    } else {
      replyText = "That's awesome, $userName! Tell me more, I'm all ears! 🕷️✨";
      emotion = CharacterEmotion.happy;
      animation = 'talking';
    }

    return GeminiCompanionResponse(
      reply: replyText,
      emotion: emotion,
      animation: animation,
      intensity: 0.8,
    );
  }

  GeminiCompanionResponse _parseJsonOutput(String rawJson) {
    try {
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
      final animation = decoded['animation'] as String? ?? 'talking';
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
        emotion: CharacterEmotion.neutral,
        animation: 'talking',
      );
    }
  }
}
