import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../character/engine/character_controller.dart';
import '../controllers/chat_controller.dart';
import 'widgets/message_bubble.dart';
import '../../home/presentation/widgets/chat_composer.dart';

/// Fullscreen Conversation Screen
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      if (authState is Authenticated) {
        ref.read(chatControllerProvider.notifier).initConversation(
              authState.user.uid,
              DateTime.now(),
            );
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final chatState = ref.watch(chatControllerProvider);
    final characterState = ref.watch(characterControllerProvider);

    final uid = authState is Authenticated ? authState.user.uid : '';

    ref.listen<ChatState>(chatControllerProvider, (previous, next) {
      if (next.messages.length != (previous?.messages.length ?? 0)) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceCard,
                border: Border.all(color: characterState.currentEmotion.color, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(characterState.currentEmotion.emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.defaultCharacterName,
                  style: AppTypography.titleMedium.copyWith(fontSize: 16),
                ),
                Text(
                  characterState.isThinking ? 'Thinking...' : characterState.currentEmotion.label,
                  style: AppTypography.bodySmall.copyWith(
                    color: characterState.currentEmotion.color,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages View
            Expanded(
              child: chatState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : chatState.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('💙', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              Text(
                                'Start a new conversation with Hinata',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: chatState.messages.length,
                          itemBuilder: (context, index) {
                            final msg = chatState.messages[index];
                            return MessageBubble(message: msg);
                          },
                        ),
            ),

            // Thinking Indicator
            if (characterState.isThinking || chatState.isSending)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadius.roundedFull,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hinata is thinking...',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02)),
                  ],
                ),
              ),

            // Bottom Chat Composer
            Padding(
              padding: const EdgeInsets.all(12),
              child: ChatComposer(
                isEnabled: !chatState.isSending && uid.isNotEmpty,
                onSubmitted: (text) {
                  ref.read(chatControllerProvider.notifier).sendMessage(
                        uid: uid,
                        text: text,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
