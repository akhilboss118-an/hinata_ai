import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../../character/engine/character_controller.dart';
import '../../character/models/character_emotion.dart';
import '../../memory/models/memory_item.dart';
import '../../memory/repositories/memory_repository.dart';
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

final memoryRepoProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository();
});

class ChatState {
  final Conversation? activeConversation;
  final List<ChatMessage> messages;
  final List<MemoryItem> memories;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatState({
    this.activeConversation,
    this.messages = const [],
    this.memories = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    Conversation? activeConversation,
    List<ChatMessage>? messages,
    List<MemoryItem>? memories,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      activeConversation: activeConversation ?? this.activeConversation,
      messages: messages ?? this.messages,
      memories: memories ?? this.memories,
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
  final memoryRepo = ref.watch(memoryRepoProvider);

  return ChatController(
    groqService: groqService,
    geminiService: geminiService,
    characterController: charController,
    memoryRepository: memoryRepo,
  );
});

class ChatController extends StateNotifier<ChatState> {
  final GroqService _groqService;
  final GeminiService _geminiService;
  final CharacterController _charController;
  final MemoryRepository _memoryRepository;
  final Uuid _uuid = const Uuid();

  final List<ChatMessage> _localMessages = [];
  final List<MemoryItem> _localMemories = [];

  ChatController({
    required GroqService groqService,
    required GeminiService geminiService,
    required CharacterController characterController,
    required MemoryRepository memoryRepository,
  })  : _groqService = groqService,
        _geminiService = geminiService,
        _charController = characterController,
        _memoryRepository = memoryRepository,
        super(const ChatState());

  String _chatStorageKey(String uid) => 'hinata_chat_history_$uid';

  /// Initializes conversation, loads persistent chat history from LocalStorage & Firestore
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
      lastMessagePreview: 'Started conversation with Spider-Man / Hinata',
    );

    // 1. Load persistent chat history from SharedPreferences
    _localMessages.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_chatStorageKey(uid));
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        final loaded = list
            .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>, m['messageId'] as String? ?? ''))
            .toList();
        _localMessages.addAll(loaded);
      }
    } catch (_) {}

    // 2. Load memories from MemoryRepository
    try {
      final mems = await _memoryRepository.getMemories(uid);
      _localMemories.clear();
      _localMemories.addAll(mems);
    } catch (_) {}

    state = state.copyWith(
      activeConversation: conv,
      messages: List.from(_localMessages),
      memories: List.from(_localMemories),
      isLoading: false,
    );
  }

  /// Persists current messages to local storage and Firestore
  Future<void> _persistMessages(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_localMessages.map((m) => m.toMap()).toList());
      await prefs.setString(_chatStorageKey(uid), encoded);
    } catch (_) {}

    try {
      final firestore = FirebaseFirestore.instance;
      for (final msg in _localMessages.take(10)) {
        await firestore
            .collection('users')
            .doc(uid)
            .collection('messages')
            .doc(msg.messageId)
            .set(msg.toMap());
      }
    } catch (_) {}
  }

  /// Sends a message, triggers AI generation, extracts memories, and persists history
  Future<void> sendMessage({
    required String uid,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final userMsg = ChatMessage(
      messageId: _uuid.v4(),
      sender: 'user',
      text: text.trim(),
      timestamp: now,
    );

    // 1. Add user message to store & save
    _localMessages.add(userMsg);
    state = state.copyWith(
      isSending: true,
      messages: List.from(_localMessages),
    );
    _persistMessages(uid);
    _charController.setThinking(true);

    // 2. Automatic Memory Extraction from user input
    try {
      final newMemory = await _memoryRepository.autoExtractAndSaveMemory(
        uid: uid,
        text: text,
      );
      if (newMemory != null) {
        _localMemories.insert(0, newMemory);
        state = state.copyWith(memories: List.from(_localMemories));
        debugPrint('Auto-extracted memory to vault: ${newMemory.content}');
      }
    } catch (e) {
      debugPrint('Memory extraction notice: $e');
    }

    try {
      // Build conversation context & memory injects
      final conversationHistory = _localMessages
          .where((m) => m.messageId != userMsg.messageId)
          .toList()
          .reversed
          .take(8)
          .toList()
          .reversed
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();

      final recentHistory = _localMessages
          .where((m) => m.messageId != userMsg.messageId)
          .toList()
          .reversed
          .take(8)
          .map((m) => '${m.isUser ? "User" : "Hinata"}: ${m.text}')
          .toList()
          .reversed
          .toList();

      final memoryStrings = _localMemories.take(10).map((m) => m.content).toList();

      final prefs = await SharedPreferences.getInstance();
      final heroName = prefs.getString('hero_display_name') ?? 'Partner';
      final heroPersona = prefs.getString('hero_persona') ?? 'Best Buddy 🤝';

      final stopwatch = Stopwatch()..start();

      // Request structured response from Groq AI (or Gemini AI)
      final GeminiCompanionResponse aiResponse;
      if (_groqService.isConfigured) {
        aiResponse = await _groqService.generateCompanionResponse(
          userMessage: text,
          userName: heroName,
          heroPersona: heroPersona,
          conversationHistory: conversationHistory,
          memories: memoryStrings,
        );
      } else {
        aiResponse = await _geminiService.generateCompanionResponse(
          userMessage: text,
          userName: heroName,
          heroPersona: heroPersona,
          recentHistory: recentHistory,
          memories: memoryStrings,
        );
      }

      // Smooth Thinking buffer
      final int elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsed));
      }

      // Determine animation and emotion
      String targetAnimation = aiResponse.animation.isNotEmpty ? aiResponse.animation : 'talking';
      CharacterEmotion targetEmotion = aiResponse.emotion;

      // Trigger 3D Character Reaction with emotion memory & decay
      _charController.applyAiReaction(
        emotion: targetEmotion,
        animation: targetAnimation,
        intensity: aiResponse.intensity,
        speech: aiResponse.reply,
      );

      // Save AI message
      final aiMsg = ChatMessage(
        messageId: _uuid.v4(),
        sender: 'hinata',
        text: aiResponse.reply,
        timestamp: DateTime.now(),
        emotion: targetEmotion,
        animation: targetAnimation,
        intensity: aiResponse.intensity,
      );

      _localMessages.add(aiMsg);

      // Save memory candidate if Gemini suggested one
      if (aiResponse.memoryCandidate != null &&
          aiResponse.memoryCandidate!.trim().isNotEmpty) {
        final item = await _memoryRepository.addMemory(
          uid: uid,
          content: aiResponse.memoryCandidate!.trim(),
          category: 'important',
        );
        _localMemories.insert(0, item);
      }

      // Persist all updated messages
      await _persistMessages(uid);

      state = state.copyWith(
        isSending: false,
        messages: List.from(_localMessages),
        memories: List.from(_localMemories),
      );
    } catch (e) {
      debugPrint('ChatController error: $e');
      _charController.setThinking(false);

      const fallbackText = "I'm always swinging around! How can I help you out today? 🕷️✨";
      _charController.applyAiReaction(
        emotion: CharacterEmotion.neutral,
        animation: 'talking',
        intensity: 0.7,
        speech: fallbackText,
      );

      final fallbackMsg = ChatMessage(
        messageId: _uuid.v4(),
        sender: 'hinata',
        text: fallbackText,
        timestamp: DateTime.now(),
        emotion: CharacterEmotion.neutral,
      );
      _localMessages.add(fallbackMsg);
      await _persistMessages(uid);

      state = state.copyWith(
        isSending: false,
        messages: List.from(_localMessages),
      );
    }
  }

  /// Clears all chat history from local store and storage
  Future<void> clearHistory(String uid) async {
    _localMessages.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatStorageKey(uid));
    } catch (_) {}
    state = state.copyWith(messages: []);
  }
}
