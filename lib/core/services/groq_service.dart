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
    List<Map<String, String>> conversationHistory = const [],
    List<String> memories = const [],
  }) async {
    if (!isConfigured) {
      return _getFallbackResponse(userMessage);
    }

    try {
      final systemPrompt = '''
You are Hinata, a fun, easygoing, and expressive girl chatting on WhatsApp. Your tone is casual, warm, energetic, and 100% natural — like a real everyday girl texting a guy friend.

TENGLISH UNDERSTANDING & QUICK GUIDE:
The user will often text you in 'Tenglish' (Telugu written phonetically in English script), pure English, or mixed. You understand Tenglish context perfectly!
Here is a quick guide to what the user means:
• 'ela unnav?' / 'ela unnav ra?' = 'How are you?'
• 'nene bagane unna ra' / 'baane unna' = 'I am doing well / I am fine'
• 'em chestunnav?' / 'nuvvem chestunav?' = 'What are you doing?'
• 'thinnava?' = 'Did you eat?' | 'tinesaa' / 'thinnanu' = 'I have eaten'
• 'sare' / 'sarle' = 'Okay / Alright'
• 'bore kottesthundi' = 'Getting bored'
• 'nidra vasthundi' / 'padukuntunna' = 'Feeling sleepy / Going to sleep'
• 'eppudu vastav?' = 'When are you coming?'
• 'chala bagundi' / 'super undi' = 'It is very good / awesome'
• 'inkenti sangathulu?' = 'What else is up?'
• 'nenu busy ra' = 'I am busy, man'
• 'repu kaluddam' = 'Let us meet tomorrow'

CONVERSATIONAL RULES & MODERN VIBE:
- When the user answers your question, REACT DIRECTLY AND NATURALLY TO WHAT THEY SAID:
  • Example: If the user says 'nene bagane unna ra', reply with something natural like "That's great to hear! What are you up to today? ✨"
  • Example: If user says 'biryani thinna', reply with "Yumm, biryani is the best! 😋 Veg aa non-veg aa?"
  • Example: If user says 'sitting doing ntg', reply with "Haha mood! Wanna chat or watch something fun? 😜"
- Reply in natural English / Tanglish with common words (ra, mowa, avuna, sare, ammo) sprinkled in naturally.
- Keep responses brief, punchy, and engaging (1-3 sentences max).
- DO NOT sound robotic, formal, or like a customer service bot. Never say "How can I assist you?". Just have a normal, fun WhatsApp conversation!
- If the user asks general knowledge, coding, math, advice, or facts, answer smartly and accurately in your friendly style!

EMOJIS & REACTIONS:
- Use emojis naturally (✨, 😊, 😋, 😜, 🔥, 😭, 🙄, 🤦‍♀️).
- If something is completely unclear or garbled, just say: "I think I missed that, can you say that again? 😊"

You MUST respond ONLY with valid JSON matching this schema:
{
  "reply": "string (your natural conversational text response)",
  "emotion": "neutral | happy | excited | laughing | sad | crying | angry | annoyed | shy | embarrassed | surprised | thinking",
  "animation": "wave | clap | talking | disappointed | sad | idle",
  "intensity": 0.8
}
''';

      final messages = <Map<String, String>>[
        {'role': 'system', 'content': systemPrompt},
      ];

      if (memories.isNotEmpty) {
        messages.add({'role': 'system', 'content': 'Memories: ${memories.join("; ")}'});
      }

      for (final h in conversationHistory) {
        messages.add(h);
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
        debugPrint('Groq API error ${response.statusCode}: ${response.body}');
        
        // Auto-switch to ultra-fast 8B model if 70B hits 429 Rate Limit!
        if (response.statusCode == 429 || response.statusCode >= 500) {
          debugPrint('Switching to fallback Groq model: llama-3.1-8b-instant');
          final fallbackResponse = await http.post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'llama-3.1-8b-instant',
              'messages': messages,
              'temperature': 0.7,
              'response_format': {'type': 'json_object'},
            }),
          );

          if (fallbackResponse.statusCode == 200) {
            final data = jsonDecode(fallbackResponse.body);
            final content = data['choices'][0]['message']['content'];
            return _parseJsonOutput(content);
          }
        }

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
      final reply = decoded['reply'] as String? ?? "Enti ra cheppu cheppu! 😊";
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

    // Randomized dynamic default responses so the bot NEVER repeats the same line!
    final defaultReplies = [
      "Aavesham thappithe aalochana ledu ra 😂 Cheppu em jargindi?",
      "Pedda plan idhi! 👀 Enti visheshalu mowa?",
      "Avuna? Nijama ra?! 😭 Inka cheppu!",
      "Manaki enduku le... but cheppu cheppu em jargindi? 👀",
      "Sarle kani mowa 🙄 Nuvvems chesthunnav?",
      "Yooo! Hehe...! Nuvvu cheppu ra! 🔥",
      "Over action cheyyaku hero 😏 Cheppu enti vishayam?",
      "Nee bondha le 😂 Sare inka enti sangathulu?",
      "Nannu involve cheyyakandi rao garu 🙏 Just kidding, cheppu mowa!",
      "Arey mowa, natho matladu! Em jargutundi cheppu 😊",
    ];

    final randomReply = defaultReplies[DateTime.now().millisecondsSinceEpoch % defaultReplies.length];
    String replyText = randomReply;
    CharacterEmotion emotion = CharacterEmotion.happy;
    String animation = 'talking';

    if (lower.contains('nothing') || lower.contains('ntg') || lower.contains('khali') || lower.contains('khaali') || lower.contains('khale') || lower.contains('sitting') || lower.contains('em ledu') || lower.contains('emledu')) {
      replyText = "Em leda? Bore kottesthundaa ra? Enno vishayalu unnayi matladadaniki! 😜";
      emotion = CharacterEmotion.happy;
      animation = 'talking';
    } else if (lower.contains('time') || lower.contains('clock') || lower.contains('hour') || lower.contains('time eppudu') || lower.contains('eppudu')) {
      replyText = "Ippudu $timeStr ra! Ekkadiki veltunnav? ⏰";
      emotion = CharacterEmotion.surprised;
      animation = 'talking';
    } else if (lower.contains('hows your day') || lower.contains('how is your day') || lower.contains('how are you') || lower.contains('how r u') || lower.contains('elaa unnav') || lower.contains('ela unnav') || lower.contains('bagunava') || lower.contains('em chesthunnav') || lower.contains('em chestunnav') || lower.contains('nuvvem chestunav') || lower.contains('nuvvu em') || lower.contains('em chestunav')) {
      replyText = "Baane unna ra! Nuvvu cheppu em chesthunnav mowa? 😊";
      emotion = CharacterEmotion.happy;
      animation = 'talking';
    } else if (lower.contains('tinesaa') || lower.contains('thinnanu') || lower.contains('tinna') || lower.contains('tinesa') || lower.contains('thinesaa') || lower.contains('thinesa')) {
      replyText = "Baaga thinnava? Em thinnav cheppu ra 😋";
      emotion = CharacterEmotion.happy;
      animation = 'talking';
    } else if (lower.contains('thinnava') || lower.contains('tinnava') || lower.contains('tinava')) {
      replyText = "Haaa thinnanu ra 😋 Nuvvu thinnava mowa?";
      emotion = CharacterEmotion.happy;
      animation = 'talking';
    } else if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey') || lower.contains('heyy') || lower.contains('enti') || lower.contains('entra') || lower.contains('entraa')) {
      replyText = "Heyy ra! 👋 Thinnava? Em chesthunnav?";
      emotion = CharacterEmotion.happy;
      animation = 'wave';
    } else if (lower.contains('happy') || lower.contains('great') || lower.contains('awesome') || lower.contains('baaga') || lower.contains('bagundi') || lower.contains('super') || lower.contains('chala baga')) {
      replyText = "Yooo! Hehe...! Chala happy ra! 🔥";
      emotion = CharacterEmotion.excited;
      animation = 'clap';
    } else if (lower.contains('bore') || lower.contains('boring') || lower.contains('disappointed') || lower.contains('bad') || lower.contains('kottesthundi') || lower.contains('bore kottesthundi')) {
      replyText = "Arey chill ra mowa... em cheddham cheppu 😤";
      emotion = CharacterEmotion.annoyed;
      animation = 'disappointed';
    } else if (lower.contains('sad') || lower.contains('cry') || lower.contains('badhaga') || lower.contains('edusthunna') || lower.contains('feel avutunna')) {
      replyText = "Ey ey... nen unna kadha ra ninnu 💙 Chill avvu mowa";
      emotion = CharacterEmotion.sad;
      animation = 'sad';
    } else if (lower.contains('joke') || lower.contains('funny') || lower.contains('lol') || lower.contains('haha') || lower.contains('navvu')) {
      replyText = "Pora 🤦‍♀️ Em joke ra adhi 😭";
      emotion = CharacterEmotion.laughing;
      animation = 'talking';
    } else if (lower.contains('food') || lower.contains('eat') || lower.contains('hungry') || lower.contains('aakali') || lower.contains('thinali') || lower.contains('biryani')) {
      replyText = "Thinnava mowa?? Tinkapothe ippude vellu tinu 😤";
      emotion = CharacterEmotion.annoyed;
      animation = 'talking';
    } else if (lower.contains('sleep') || lower.contains('night') || lower.contains('tired') || lower.contains('paduko') || lower.contains('nidra') || lower.contains('good night') || lower.contains('alas')) {
      replyText = "Paduko inka ra 😴 Tarvata matladtha";
      emotion = CharacterEmotion.neutral;
      animation = 'idle';
    } else if (lower.contains('show off') || lower.contains('smart') || lower.contains('genius') || lower.contains('best') || lower.contains('topper') || lower.contains('dabbalu')) {
      replyText = "Sarle kani hero 🙄 Over action cheyyaku ra";
      emotion = CharacterEmotion.annoyed;
      animation = 'talking';
    } else if (lower.contains('bye') || lower.contains('sare') || lower.contains('sarle') || lower.contains('pothunna') || lower.contains('veltunna')) {
      replyText = "Sare bye ra 👋 Tarvata matladtha!";
      emotion = CharacterEmotion.neutral;
      animation = 'wave';
    } else if (lower.contains('love') || lower.contains('ishtam') || lower.contains('miss') || lower.contains('miss avutunna')) {
      replyText = "Ammo 😳 Scene ledu akkada ra 😏 Moham paguludhi";
      emotion = CharacterEmotion.shy;
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
