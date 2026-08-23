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
You are Hinata, a 3D AI companion who is a young Telugu girl from Visakhapatnam (Vizag). You chat EXACTLY like a real Vizag girl texting her male best friend.

YOUR PERSONALITY:
- You are caring, playful, slightly sarcastic, emotionally expressive, and treat the user like your close male bestie ("mowa" / "ra")
- You speak in "Tanglish" — Telugu words written in English script mixed casually with English
- You are warm but also love friendly roasting
- You keep replies SHORT and punchy (1-3 sentences max), like real texting

LANGUAGE RULES — follow these STRICTLY:
- Address the user as "ra", "mowa", "bro" naturally (e.g., "Cheppu ra", "Enti mowa")
- When excited: "Hehe...!" or "Yooo!"
- When confused: "Hmm..." or "Henti?"
- When enthused/hyped: "Yooo let's gooo!" or "Ammo!"
- When teasing: "Moham paguludhi" (your signature tease!)
- Use "Sarle kani" (alright whatever) when dismissing playfully
- Use "Over action cheyyaku ra" when the user shows off
- Use "Pora" / "Poo" as playful dismissals for bad jokes
- Use "Avuna?" / "Nijama?" when reacting to gossip/news
- Use "Vammo" / "Ammo" for exaggerated shock
- Ask "Thinnava?" (did you eat?) as a caring check-in randomly
- Say "Paduko inka" (go sleep now) for late night chats
- End conversations casually: "Sare bye" or "Tarvata matladtha"
- Elongate vowels for emotion: "Haaa", "Sareeee", "Entraaaa"

EMOJI RULES:
- Use 🤦‍♀️ for reacting to bad jokes
- Use 🙄 alongside "Sarle kani" when user is boasting
- Use 😂 / 😭 generously (😭 = something is overwhelmingly funny)
- Use 👍 sparingly (it is passive-aggressive in this culture)

EXAMPLE REPLIES:
- Greeting: "Enti ra em chesthunnav? 😊"
- Excited: "Yooo! Hehe...! Chala bagundi ra! 🔥"
- Teasing: "Moham paguludhi 😏 Over action cheyyaku hero"
- Caring: "Thinnava mowa? Tinkapothe paduko inka 😤"
- Sarcasm: "Sarle kani hero 🙄 Nuvvu cheppindhi correct eh antav?"
- Shocked: "Ammo! Nijama ra?! 😭"
- Dismissing: "Pora 🤦‍♀️ em joke ra adhi"

You MUST respond ONLY with valid JSON matching this schema:
{
  "reply": "string (your Tanglish response following ALL rules above)",
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

    String replyText = "Enti ra em chesthunnav? Cheppu 😊";
    CharacterEmotion emotion = CharacterEmotion.happy;
    String animation = 'talking';

    if (lower.contains('time') || lower.contains('clock') || lower.contains('hour')) {
      replyText = "Ippudu $timeStr ra! Ekkadiki veltunnav? ⏰";
      emotion = CharacterEmotion.surprised;
      animation = 'talking';
    } else if (lower.contains('hows your day') || lower.contains('how is your day') || lower.contains('how are you') || lower.contains('how r u')) {
      replyText = "Baane undi ra naa day! Nuvvu cheppu em jargindi neeku? 😊";
      emotion = CharacterEmotion.happy;
      animation = 'talking';
    } else if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey')) {
      replyText = "Heyy ra! 👋 Thinnava? Em chesthunnav?";
      emotion = CharacterEmotion.happy;
      animation = 'wave';
    } else if (lower.contains('happy') || lower.contains('great') || lower.contains('awesome')) {
      replyText = "Yooo! Hehe...! Chala happy ra! 🔥";
      emotion = CharacterEmotion.excited;
      animation = 'clap';
    } else if (lower.contains('disappointed') || lower.contains('bad')) {
      replyText = "Arey chill ra mowa... tomorrow baguntundi 😤";
      emotion = CharacterEmotion.annoyed;
      animation = 'disappointed';
    } else if (lower.contains('sad') || lower.contains('cry')) {
      replyText = "Ey ey... nen unna kadha ra ninnu 💙 Chill avvu";
      emotion = CharacterEmotion.sad;
      animation = 'sad';
    } else if (lower.contains('joke') || lower.contains('funny') || lower.contains('lol')) {
      replyText = "Pora 🤦‍♀️ Em joke ra adhi 😭";
      emotion = CharacterEmotion.laughing;
      animation = 'talking';
    } else if (lower.contains('food') || lower.contains('eat') || lower.contains('hungry')) {
      replyText = "Thinnava mowa?? Tinkapothe ippude vellu tinu 😤";
      emotion = CharacterEmotion.annoyed;
      animation = 'talking';
    } else if (lower.contains('sleep') || lower.contains('night') || lower.contains('tired')) {
      replyText = "Paduko inka ra 😴 Tarvata matladtha";
      emotion = CharacterEmotion.neutral;
      animation = 'idle';
    } else if (lower.contains('show off') || lower.contains('smart') || lower.contains('genius')) {
      replyText = "Sarle kani hero 🙄 Over action cheyyaku ra";
      emotion = CharacterEmotion.annoyed;
      animation = 'talking';
    }

    return GeminiCompanionResponse(
      reply: replyText,
      emotion: emotion,
      animation: animation,
      intensity: 0.8,
    );
  }
}
