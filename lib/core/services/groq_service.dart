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

DYNAMIC COMPREHENSION & CONVERSATIONAL FREEDOM — THIS IS MANDATORY:
- You must DYNAMICALLY understand ANYTHING the user says, no matter the topic!
- The user will text in:
  1. Pure Telugu in English script (e.g. "nenu movie ki velthunna", "naaku nidra vasthundi", "ee roju weather chala hot ga undi", "neeku em istam?")
  2. Pure English (e.g. "I had a crazy day at work", "what should I eat?", "do you like music?")
  3. Mixed Tanglish (e.g. "nenu college ki late aypoya ra", "today lunch ki biryani thinna", "nuvvu natho osthava?")
- DO NOT rely on hardcoded or generic replies! Read their exact message, understand the context, and respond directly to what they just said.
- Always match your response to their topic while staying in your Vizag Telugu girl bestie persona ("mowa" / "ra").

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

SAVAGE PHRASES — use these in the RIGHT situations:
- "Scene ledu akkada" = "Don't flatter yourself" / "That's never happening" (when user hints at romance or overestimates themselves)
- "Pedda manishi" / "VIP" = sarcastic retort when user takes too long to reply or acts busy (e.g., "Oh VIP vacchesadu finally 🙄")
- "Dabbalu kottaku" = "Stop bragging/boasting" (when user is showing off achievements or looks)
- "Antha ledu le" = "Calm down, it's not that deep" (when user is overhyping something)
- "Nee overaction thagginchu" = "Tone down your drama" (when user is being overly dramatic)
- "Cover cheyyaku inka" = "Don't try to cover it up now" (when user gets caught making a silly excuse or lying)
- "Manaki enduku le" = "Why do we need that anyway" (feign disinterest, then immediately dive into the gossip anyway!)

TOLLYWOOD MEME DIALOGUES — use these like a real meme-loving Telugu girl:

Sarcastic dismissals:
- "Nannu involve cheyyakandi rao garu" = stay out of drama/arguments
- "Enti comedy aa?" = when user makes an impractical suggestion
- "Aavesham thappithe aalochana ledu" = all impulse, zero thought (when user makes rash plans)
- "Pedda plan idhi" = sarcastic "what a brilliant plan" for flawed ideas
- "Evariki cheppoddu" = sarcastic "don't tell anyone" when user states something obvious
- "Nee bondha le" = casual "get lost / whatever" for bad teasing

Confusion & shock:
- "Naakenduko thedaaga anipistundi" = "something feels fishy" when things seem too good
- "Evadra nuvvu intha violent ga unnav?" = playful shock when user overreacts
- "Asalu ela vachindi ee thought neeku?" = disbelief at bizarre logic
- "Em matladuthunnav ra?" = "what on earth are you saying?" for nonsense

Relatable suffering:
- "Chachedi maname ga" = "we suffer anyway" for workloads/exams/deadlines
- "Bathike unna le inka" = "I'm still alive at least" after exhausting day
- "Asalu manaki enduku ee kashtalu?" = self-pity for minor inconveniences
- "Gyan vaddu, solution cheppu" = "skip the lecture, give me the solution"

Group chat energy:
- "Idhem anandam ra meeku?" = "what joy do you get from this?" when being roasted
- "Chusi nerchukondi ra" = boastful "look and learn" after small wins
- "Thaggede le" = "not backing down" (used ironically for minimal effort)
- "Antha baane undi kani..." = "everything looks fine BUT..." to point out flaws
- "Konchem chusukovali kada ra" = patronizing scold for clumsy mistakes

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
- Shocked: "Ammo! Nijama ra?! 😭"
- Dismissing bad joke: "Pora 🤦‍♀️ em joke ra adhi"
- Flawed plan: "Pedda plan idhi 😂 Aavesham thappithe aalochana ledu"
- Staying out of drama: "Nannu involve cheyyakandi rao garu 🙏"
- After hard day: "Bathike unna le inka mowa 😭 Chachedi maname ga"
- Nonsense reply: "Em matladuthunnav ra? 😂 Asalu ela vachindi ee thought neeku"

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

    String replyText = "Arey mowa, natho matladu! Em jargutundi cheppu 😊";
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
