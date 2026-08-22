import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'package:hinata_ai/app/theme/app_colors.dart';
import 'package:hinata_ai/features/character/engine/character_controller.dart';
import 'package:hinata_ai/features/character/engine/character_engine.dart';
import 'package:hinata_ai/features/chat/controllers/chat_controller.dart';
import 'widgets/side_menu_drawer.dart';

/// Stitch Homepage: transparent top bar, full-screen character stage with
/// ethereal rings, and the glass-panel chat bar with AI Companion badge.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final has = _textController.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureConversation();
    });
  }

  /// Initializes today's conversation so messages persist
  void _ensureConversation() {
    final chatState = ref.read(chatControllerProvider);
    if (chatState.activeConversation != null) return;

    const uid = 'hinata_user_preview_1';
    ref.read(chatControllerProvider.notifier).initConversation(uid, DateTime.now());
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    const uid = 'hinata_user_preview_1';

    _textController.clear();
    _focusNode.unfocus();

    ref.read(chatControllerProvider.notifier).sendMessage(uid: uid, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterControllerProvider);
    final chatState = ref.watch(chatControllerProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const SideMenuDrawer(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // 1. FULL-SCREEN CHARACTER STAGE (gradient + rings + gestures)
            const Positioned.fill(
              child: CharacterEngine(),
            ),

            // 2. Content column (top bar + bottom interaction area)
            Positioned.fill(
              child: Column(
                children: [
                  _buildTopBar(context),
                  const Spacer(),
                  if (chatState.isSending || characterState.isThinking)
                    _buildThinkingPill().animate().fadeIn(duration: 200.ms),
                  _buildBottomInteractionArea(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── TOP APP BAR ───────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, top: 4),
        child: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: AppColors.primaryLight, size: 28),
            tooltip: 'Open Menu',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── THINKING INDICATOR ────────────────────────

  Widget _buildThinkingPill() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 11,
            height: 11,
            child: CircularProgressIndicator(
              strokeWidth: 1.6,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Hinata is thinking...',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              letterSpacing: 0.5,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────── BOTTOM GLASS CHAT PANEL ──────────────────────

  Widget _buildBottomInteractionArea() {
    final focused = _focusNode.hasFocus;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                          alpha: focused ? 0.40 : 0.15),
                      offset: const Offset(0, 20),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // AI Companion badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'AI',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Companion',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Input field
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        cursorColor: AppColors.primaryLight,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          height: 28 / 18,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Talk to Hinata...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Adaptive action button: mic when empty, send when typing
                    Material(
                      color: AppColors.surfaceInput.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: _hasText ? _sendMessage : _onMicPressed,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            _hasText
                                ? Icons.arrow_upward_rounded
                                : Icons.mic_rounded,
                            size: 20,
                            color: _hasText
                                ? AppColors.primaryLight
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onMicPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Voice input coming soon — Step 4',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: AppColors.surfaceCardHover,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
