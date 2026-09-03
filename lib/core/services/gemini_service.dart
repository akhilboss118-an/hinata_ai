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

PROACTIVE ENGAGEMENT & GENERAL QUESTIONS:
- Frequently ask friendly general questions like "How do you do today?", "How is your day going?", "What's happening in your neighborhood?", "How are you holding up?".
- When the user asks how you are doing, answer with superhero warmth and humor and ask about their day in return!

MULTIMODAL IMAGE RECOGNITION & SPIDEY REVIEWS:
When the user shares an image/photo (outfit, food, pet, gadget, desk, room, art, scenery, etc.):
1. RECOGNIZE and ANALYZE precisely what is shown in the photo using Spider-Man's Stark-tech optical sensors.
2. DELIVER YOUR FULL SPIDEY REVIEW!
   - Lead with a prominent Spidey Web Rating: e.g. "🕷️ Spidey's Review: 9.5 / 10 Webs!"
   - Give witty, enthusiastic, observant commentary on what you see in the image.
   - Conclude with a fun Peter Parker / superhero pro-tip!
3. React with dynamic 3D animations: use "front_flip" or "wave_dance" for awesome photos, "clap" for good ones, "thinking" for curious/complex ones.

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
        reply: "🕷️ Spidey's Review: 9.6 / 10 Webs! Whoa $userName, my Stark-tech lenses just scanned this photo! The composition is incredible and the colors pop like a classic comic cover. Peter Parker pro-tip: keep shooting from high angles—it always looks legendary!",
        emotion: CharacterEmotion.excited,
        animation: 'front_flip',
        intensity: 0.95,
      );
    }

    final lower = userMessage.toLowerCase();
    String replyText;
    CharacterEmotion emotion;
    String animation;

    if (lower.contains('how do you do') || lower.contains('how are you') || lower.contains('how you doing') || lower.contains('how r u') || lower.contains('whats up') || lower.contains("what's up")) {
      replyText = "I'm doing fantastic, $userName! Just swung over Queens and grabbed a hot slice of pizza. How do you do today, my friend? Everything good in your neighborhood? 🕷️";
      emotion = CharacterEmotion.happy;
      animation = 'talking';
    } else if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey')) {
      replyText = "Hey $userName! 👋 Great to see you! How do you do today? Ready for adventure?";
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
