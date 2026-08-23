import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../../character/engine/character_controller.dart';
import '../../character/models/character_emotion.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/groq_service.dart';
import '../../../core/utils/date_utils.dart';

final groqServiceProvider = Provider<GroqService>((ref) {
  return GroqService();
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(
    apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
  );
});

class ChatState {
  final Conversation? activeConversation;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatState({
    this.activeConversation,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    Conversation? activeConversation,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      activeConversation: activeConversation ?? this.activeConversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final groqService = ref.watch(groqServiceProvider);
  final geminiService = ref.watch(geminiServiceProvider);
  final charController = ref.watch(characterControllerProvider.notifier);

  return ChatController(
    groqService: groqService,
    geminiService: geminiService,
    characterController: charController,
  );
});

class ChatController extends StateNotifier<ChatState> {
  final GroqService _groqService;
  final GeminiService _geminiService;
  final CharacterController _charController;
  final Uuid _uuid = const Uuid();

  // In-memory storage for messages (replaces Firestore while Firebase is unavailable)
  final List<ChatMessage> _localMessages = [];
  // In-memory memory store
  final List<String> _localMemories = [];

  ChatController({
    required GroqService groqService,
    required GeminiService geminiService,
    required CharacterController characterController,
  })  : _groqService = groqService,
        _geminiService = geminiService,
        _charController = characterController,
        super(const ChatState());

  /// Initializes conversation for a given user UID and date (in-memory)
  Future<void> initConversation(String uid, DateTime date) async {
    state = state.copyWith(isLoading: true);
    final dateKey = AppDateUtils.toDateKey(date);
    final conversationId = _uuid.v4();
    final now = DateTime.now();
    final conv = Conversation(
      conversationId: conversationId,
      title: 'Chat on ${AppDateUtils.formatDisplay(date)}',
      dateKey: dateKey,
      createdAt: now,
      updatedAt: now,
      lastMessagePreview: 'Started conversation with Hinata',
    );
    state = state.copyWith(
      activeConversation: conv,
      messages: List.from(_localMessages),
      isLoading: false,
    );
  }

  /// Sends a message and triggers Gemini AI companion structured generation
  Future<void> sendMessage({
    required String uid,
    required String text,
  }) async {
    if (state.activeConversation == null || text.trim().isEmpty) return;

    final now = DateTime.now();
    final userMsg = ChatMessage(
      messageId: _uuid.v4(),
      sender: 'user',
      text: text.trim(),
      timestamp: now,
    );

    // Add user message to local store
    _localMessages.add(userMsg);
    state = state.copyWith(
      isSending: true,
      messages: List.from(_localMessages),
    );
    _charController.setThinking(true);

    try {
      // Fetch recent context & long-term memories
      final recentHistory = _localMessages
          .reversed
          .take(6)
          .map((m) => '${m.isUser ? "User" : "Hinata"}: ${m.text}')
          .toList()
          .reversed
          .toList();

      final memories = _localMemories.take(5).toList();

      // Request structured response from Groq AI (or Gemini AI)
      final GeminiCompanionResponse aiResponse;
      if (_groqService.isConfigured) {
        aiResponse = await _groqService.generateCompanionResponse(
          userMessage: text,
          recentHistory: recentHistory,
          memories: memories,
        );
      } else {
        aiResponse = await _geminiService.generateCompanionResponse(
          userMessage: text,
          recentHistory: recentHistory,
          memories: memories,
        );
      }

      // Trust AI-chosen animation & emotion first — only override if AI returned empty/idle
      String targetAnimation = aiResponse.animation.isNotEmpty ? aiResponse.animation : 'talking';
      CharacterEmotion targetEmotion = aiResponse.emotion;

      // Only apply keyword-based override if AI returned 'idle' or empty (fallback safety net)
      if (targetAnimation == 'idle' || targetAnimation.isEmpty) {
        final lower = text.trim().toLowerCase();
        // English + Telugu keyword matching
        if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey') || lower.contains('wave') || lower.contains('namaste')) {
          targetAnimation = 'wave';
          targetEmotion = CharacterEmotion.happy;
        } else if (lower.contains('happy') || lower.contains('clap') || lower.contains('excited') || lower.contains('yay') || lower.contains('great') || lower.contains('baaga') || lower.contains('super') || lower.contains('bagundi')) {
          targetAnimation = 'clap';
          targetEmotion = CharacterEmotion.excited;
        } else if (lower.contains('disappointed') || lower.contains('bad') || lower.contains('hate') || lower.contains('bore') || lower.contains('boring') || lower.contains('istam ledu')) {
          targetAnimation = 'disappointed';
          targetEmotion = CharacterEmotion.annoyed;
        } else if (lower.contains('sad') || lower.contains('cry') || lower.contains('depressed') || lower.contains('badhaga') || lower.contains('edusthunna')) {
          targetAnimation = 'sad';
          targetEmotion = CharacterEmotion.sad;
        } else {
          targetAnimation = 'talking';
        }
      }

      // Trigger 3D Character Reaction (with speech bubble showing the reply)
      _charController.applyAiReaction(
        emotion: targetEmotion,
        animation: targetAnimation,
        intensity: aiResponse.intensity,
        speech: aiResponse.reply,
      );

      // Save Hinata AI response in local store
      final hinataMsg = ChatMessage(
        messageId: _uuid.v4(),
        sender: 'hinata',
        text: aiResponse.reply,
        timestamp: DateTime.now(),
        emotion: aiResponse.emotion,
        animation: aiResponse.animation,
        intensity: aiResponse.intensity,
      );

      _localMessages.add(hinataMsg);

      // Automatically extract and save memory candidate if found
      if (aiResponse.memoryCandidate != null &&
          aiResponse.memoryCandidate!.trim().isNotEmpty) {
        _localMemories.add(aiResponse.memoryCandidate!.trim());
        debugPrint('Memory saved: ${aiResponse.memoryCandidate}');
      }

      state = state.copyWith(
        isSending: false,
        messages: List.from(_localMessages),
      );
    } catch (e) {
      debugPrint('ChatController error: $e');
      _charController.setThinking(false);

      final String fallbackText;
      final String errStr = e.toString().toLowerCase();

      if (errStr.contains('socketexception') ||
          errStr.contains('network') ||
          errStr.contains('offline') ||
          errStr.contains('failed to host') ||
          errStr.contains('clientexception')) {
        fallbackText = "Arey mowa, check your internet connection ra! 🌐 status offline";
      } else {
        fallbackText = "I think I missed something, can you repeat again? 😊";
      }

      _charController.applyAiReaction(
        emotion: CharacterEmotion.surprised,
        animation: 'talking',
        intensity: 0.7,
        speech: fallbackText,
      );

      final fallbackMsg = ChatMessage(
        messageId: _uuid.v4(),
        sender: 'hinata',
        text: fallbackText,
        timestamp: DateTime.now(),
      );
      _localMessages.add(fallbackMsg);

      state = state.copyWith(
        isSending: false,
        messages: List.from(_localMessages),
        error: e.toString(),
      );
    }
  }
}
