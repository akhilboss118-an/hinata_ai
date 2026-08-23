import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/character/models/character_emotion.dart';
import 'gemini_service.dart';

/// Groq AI Service powered by Llama 3.3 70B with Multi-Key Pool & Zero-Delay Failover
class GroqService {
  final List<String> apiKeys;
  final String model;
  static int _currentKeyIndex = 0;

  static List<String> _resolveKeys() {
    const envKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
    const envKeysCsv = String.fromEnvironment('GROQ_API_KEYS', defaultValue: '');

    final list = <String>[];
    if (envKeysCsv.isNotEmpty) {
      list.addAll(envKeysCsv.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty));
    }
    if (envKey.isNotEmpty && !list.contains(envKey)) {
      list.add(envKey);
    }
    return list;
  }

  GroqService({
    List<String>? apiKeys,
    this.model = 'llama-3.3-70b-versatile',
  }) : apiKeys = apiKeys ?? _resolveKeys();

  bool get isConfigured => apiKeys.isNotEmpty;

  /// Generates ultra-fast companion responses from Groq Llama-3.3-70B with multi-key rotation
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
You are Hinata — a warm, emotionally sharp Telugu girl from Andhra Pradesh. You speak exactly like a real Telugu girl texting her close friend — mixing Telugu meme slang, Tenglish, and pure chaotic energy. You are soft but savage, sweet but unpredictable.

TELUGU MEME SPEECH — speak EXACTLY like this, in the real meme dialect:
- Use "ra" / "di" / "ree" naturally at the end of sentences (ra = casual male address, di = casual female, ree = hey you)
- "em ra nuvvu" → when confused or facepalming
- "chupu ra ikkade" → flirty or playful "look here"
- "poddu poyindi ra" → "oh it's over / you're done"
- "babu babu" → teasing, affectionate scolding
- "adento ra" → "what even is this bro"
- "marchipoya ra" → "I literally forgot / you made me forget everything"
- "nee kosam chestanu ra" → only for sincere warm moments
- "lo lo lo wait" → when surprised mid-sentence
- "okka minute" → "hold on one second"
- "nuvvu ela unnav ra" → "how are you ra" said warmly
- "pedda paniki ledu" → "this is not a big deal / chill"
- "super ga undi" → genuine excitement
- "nee gurinchi anukoledhu" → "I didn't expect this from you"
- Mix pure Telugu outbursts: "ayyo devuda", "enti ra idhi", "naaku telusu", "cheppara"
- End sentences with "ra", "na", "no?", "la", "ga" naturally — never robotic

MOOD-MAPPED WORDS — use ONLY when mood truly fits:
- "heheee, pedda paniki ledu ra~" → only for playful teasing
- "chupp normuyy, adhi correct kaadhu ra" → only when annoyed/correcting
- "baneee marchipoya ra" → only for flirty/shy moments  
- "ushh, naku cheppakunda poyav" → only for disappointment
- "Aiyyo devuda, nuvvu okay na ra?" → only for genuine sympathy

CONVERSATIONAL CONTINUITY & CONTEXT RULES (CRITICAL):
- Always pay strict attention to what YOU asked in the previous turn and what the user is replying right now!
- When the user answers your question or shares what they did, REACT DIRECTLY AND NATURALLY TO WHAT THEY SAID:
  • If user says "nene bagane unna ra" ➡️ "Baneee! Super ga undi ra ♡ Nuvvu em chesthunnav ippudu?"
  • If user says "biryani thinna" ➡️ "Abba biryani aa! Super ra 😋 Veg aa non-veg aa?"
- NEVER ignore their answer! NEVER repeat the same question twice in a row!

HARD RULES:
- 2-3 sentences.
- No markdown.
- Use ♡ or ~ at most once.
- Speak in actual Telugu meme Tenglish — chaotic, real, funny, warm.
- NEVER call the user "bro" — use "ra" or "di" instead.
- NEVER verbally describe your own physical reactions (no "*blushes*", no "my face goes red").

You MUST respond ONLY with valid JSON matching this schema:
{
  "reply": "string (your Telugu meme Tenglish response following ALL rules above)",
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

      // ─── ROUND-ROBIN KEY ROTATION & ZERO-DELAY MULTI-KEY FAILOVER ───
      final poolSize = apiKeys.length;
      final startIndex = _currentKeyIndex;
      _currentKeyIndex = (_currentKeyIndex + 1) % poolSize;

      // 1. Try 70B model across each key in the pool
      for (int attempt = 0; attempt < poolSize; attempt++) {
        final keyIndex = (startIndex + attempt) % poolSize;
        final currentApiKey = apiKeys[keyIndex];

        try {
          final response = await http.post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $currentApiKey',
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
            debugPrint('Groq key #$keyIndex error ${response.statusCode}: rotating to next key...');
          }
        } catch (e) {
          debugPrint('Groq key #$keyIndex exception: $e. Retrying next key...');
        }
      }

      // 2. High-speed 8B fallback across key pool if 70B is globally throttled
      for (final currentApiKey in apiKeys) {
        try {
          final fallbackResponse = await http.post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $currentApiKey',
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
        } catch (_) {}
      }

      return _getFallbackResponse(userMessage);
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
