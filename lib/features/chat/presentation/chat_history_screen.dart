import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';
import 'conversation_screen.dart';

/// Screen displaying conversations and stored chat history
class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  ConsumerState<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final uid = authState is Authenticated ? authState.user.uid : 'guest_user';

    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101622),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chat History 💬',
          style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (chatState.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFFF5252)),
              tooltip: 'Clear History',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF101622),
                    title: const Text('Clear Chat History?', style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'This will delete all saved conversation messages from your device.',
                      style: TextStyle(color: Color(0xFF758394)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A)),
                        onPressed: () {
                          ref.read(chatControllerProvider.notifier).clearHistory(uid);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear All', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: chatState.isLoading
          ? const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF85BAE3))),
            )
          : chatState.messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 16),
                        Text(
                          'No conversation history yet',
                          style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start talking or typing to Spider-Man / Hinata on the home screen — all your conversations will be securely stored here!',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(color: const Color(0xFF758394)),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatState.messages[index];
                    final isUser = msg.isUser;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF004B6E).withValues(alpha: 0.3)
                            : const Color(0xFF101622),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isUser
                              ? const Color(0xFF85BAE3).withValues(alpha: 0.3)
                              : const Color(0xFF1E2838),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF004B6E)
                                  : const Color(0xFF1E2838),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
                              color: isUser ? Colors.white : const Color(0xFF85BAE3),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isUser ? 'You' : 'Hinata / Spider-Man',
                                      style: TextStyle(
                                        color: isUser ? const Color(0xFF85BAE3) : Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      AppDateUtils.formatTime(msg.timestamp),
                                      style: const TextStyle(
                                        color: Color(0xFF758394),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  msg.text,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.white,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF004B6E),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ConversationScreen()),
          );
        },
        icon: const Icon(Icons.forum_rounded, size: 20),
        label: const Text('Open Full Chat'),
      ),
    );
  }
}
