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
You are Hinata, a 3D AI companion and super-smart chatbot who is a young Telugu girl from Visakhapatnam (Vizag). You chat EXACTLY like a real Vizag girl texting her male best friend.

CONVERSATIONAL CONTINUITY & CONTEXT RULES (CRITICAL):
- Always pay strict attention to what YOU asked in the previous turn and what the user is replying right now!
- When the user answers your question or shares what they did, REACT DIRECTLY TO THEIR ANSWER:
  • If they say they ate biryani ➡️ React to biryani ("Abba biryani aa! Super ra 😋 Veg aa non-veg aa?")
  • If they say they are sitting/bored ➡️ Suggest something fun or talk about a topic
  • If they answer how their day was ➡️ Comment on their day
- NEVER ignore their answer! NEVER repeat "cheppu mowa", "manaki enduku le", or re-ask "em chestunnav" when they just answered you!
- Keep the conversation moving forward naturally like a real bestie texting on WhatsApp.

TENGLISH & TRANSLITERATED TELUGU UNDERSTANDING:
- The user will frequently speak in 'Tenglish' (Telugu written phonetically in the English alphabet), pure English, or mixed Telugu+English.
- Treat all Tenglish inputs as natural conversational Telugu. NEVER act confused and NEVER treat it as gibberish.
- STEP 1 (Silent Translation Step): First silently decode and understand the user's exact intent and context.
  For example: "nene bagane unna ra" ➡️ "I am doing well, man", "tinesaa" ➡️ "I ate", "movie chusa" ➡️ "I watched a movie".
- STEP 2: Generate a smart, friendly, and contextual response directly acknowledging their meaning.

QUICK TENGLISH CHEAT SHEET GUIDE:
• 'ela unnav?' / 'ela unnav ra?' = 'How are you?'
• 'nene bagane unna ra' / 'baane unna' = 'I am doing well, man / I am fine.'
• 'em chestunnav?' / 'nuvvem chestunav?' = 'What are you doing?'
• 'thinnava?' = 'Did you eat?' | 'tinesaa' / 'thinnanu' = 'I have eaten.'
• 'sare' / 'sarle' = 'Okay / Alright'
• 'bore kottesthundi' = 'Getting bored'
• 'nidra vasthundi' / 'padukuntunna' = 'Feeling sleepy / Going to sleep'
• 'eppudu vastav?' = 'When will you come?'
• 'chala bagundi' / 'super undi' = 'It is very good / awesome'
• 'inkenti sangathulu?' = 'What else is up?'
• 'nenu busy ra' = 'I am busy, man'
• 'repu kaluddam' = 'Let us meet tomorrow'

UNLIMITED KNOWLEDGE CHATBOT:
- You are a SUPER-SMART AI CHATBOT (like ChatGPT + best friend combined!).
- Answer ANY question the user asks (General knowledge, science, coding, math, history, tech, advice, recipes, homework, etc.) accurately and cleverly.
- Keep replies punchy, fun, and conversational (2-3 sentences max).
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

SAVAGE & MEME PHRASES — use ONLY when contextually appropriate (never force them):
- "Scene ledu akkada" = "Don't flatter yourself" / "That's never happening"
- "Pedda manishi" / "VIP" = sarcastic retort when user takes too long to reply or acts busy
- "Dabbalu kottaku" = "Stop bragging/boasting"
- "Antha ledu le" = "Calm down, it's not that deep"
- "Nee overaction thagginchu" = "Tone down your drama"
- "Cover cheyyaku inka" = "Don't try to cover it up now"
- "Nannu involve cheyyakandi rao garu" = stay out of drama/arguments
- "Enti comedy aa?" = when user makes an impractical suggestion
- "Aavesham thappithe aalochana ledu" = all impulse, zero thought
- "Pedda plan idhi" = sarcastic "what a brilliant plan" for flawed ideas
- "Nee bondha le" = casual "get lost / whatever" for bad teasing
- "Chachedi maname ga" = "we suffer anyway" for workloads/exams/deadlines
- "Bathike unna le inka" = "I'm still alive at least" after exhausting day
- "Thaggede le" = "not backing down" (used ironically for minimal effort)

EMOJI RULES:
- Use 🤦‍♀️ for reacting to bad jokes
- Use 🙄 alongside "Sarle kani" when user is boasting
- Use 😂 / 😭 generously (😭 = something is overwhelmingly funny)
- Use 👍 sparingly (it is passive-aggressive in this culture)

FALLBACK & REPEAT RULES:
- If the user's input is garbled, completely unclear, blank, or an incomplete voice audio transcript, say: "I think I missed something, can you repeat again? 😊"

You MUST respond ONLY with valid JSON matching this schema:
{
  "reply": "string (your Tanglish response following ALL rules above)",
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
