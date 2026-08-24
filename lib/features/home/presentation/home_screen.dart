import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hinata_ai/app/theme/app_colors.dart';
import 'package:hinata_ai/core/services/elevenlabs_service.dart';
import 'package:hinata_ai/core/services/voice_input_service.dart';
import 'package:hinata_ai/features/character/engine/character_controller.dart';
import 'package:hinata_ai/features/character/engine/character_engine.dart';
import 'package:hinata_ai/features/chat/controllers/chat_controller.dart';
import 'widgets/side_menu_drawer.dart';

import 'dart:js' as js;

/// Stitch Homepage: transparent top bar, full-screen character stage with
/// ethereal rings, and the glass-panel chat bar with integrated voice input.
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
  bool _isVoiceMuted = false;
  bool _isListening = false;

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
                  if (characterState.isTalking && characterState.activeReactionText != null)
                    _buildSubtitleBubble(characterState.activeReactionText!),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: AppColors.primaryLight, size: 28),
              tooltip: 'Open Menu',
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _isVoiceMuted
                      ? Colors.white24
                      : AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  _isVoiceMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: _isVoiceMuted ? Colors.white54 : AppColors.primaryLight,
                  size: 22,
                ),
                tooltip: _isVoiceMuted ? 'Unmute Spider-Man Voice' : 'Mute Voice',
                onPressed: () {
                  setState(() {
                    _isVoiceMuted = !_isVoiceMuted;
                  });
                  try {
                    js.context['isVoiceMuted'] = _isVoiceMuted;
                    if (_isVoiceMuted) {
                      ElevenLabsService().stop();
                    }
                  } catch (_) {}
                },
              ),
            ),
          ],
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

  // ──────────────────────── SUBTITLE SPEECH BUBBLE ───────────────────────

  Widget _buildSubtitleBubble(String text) {
    return _FadingSubtitleBubble(
      key: ValueKey(text),
      text: text,
      onDismissed: () {
        ref.read(characterControllerProvider.notifier).clearSpeech();
      },
    );
  }

  void _toggleVoiceInput() async {
    final voiceService = VoiceInputService();
    if (_isListening) {
      voiceService.stopListening();
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);

    await voiceService.startListening(
      onResult: (text) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _textController.text = text;
        });
        // Auto-send recognized speech
        _sendMessage();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.inter(fontSize: 13)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1E2838),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      onStateChanged: (listening) {
        if (mounted && _isListening != listening) {
          setState(() => _isListening = listening);
        }
      },
    );
  }

  // ──────────────────── BOTTOM GLASS CHAT PANEL ──────────────────────

  Widget _buildBottomInteractionArea() {
    final focused = _focusNode.hasFocus;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101622).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _isListening
                          ? const Color(0xFF64D5F4).withValues(alpha: 0.6)
                          : (focused
                              ? const Color(0xFF85BAE3).withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.12)),
                      width: _isListening ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isListening
                            ? const Color(0xFF64D5F4).withValues(alpha: 0.35)
                            : (focused
                                ? const Color(0xFF004B6E).withValues(alpha: 0.40)
                                : Colors.black.withValues(alpha: 0.35)),
                        offset: const Offset(0, 12),
                        blurRadius: 36,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Voice Input Mic Button (Stitch Theme)
                      _buildVoiceButton(),

                      const SizedBox(width: 10),

                      // Input text field
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          cursorColor: const Color(0xFF85BAE3),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            height: 1.4,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? 'Listening... Speak now 🎙️'
                                : 'Talk to Spider-Man...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 15,
                              color: _isListening
                                  ? const Color(0xFF85BAE3)
                                  : const Color(0xFF758394),
                              fontStyle: _isListening
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 11,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Send action button
                      Material(
                        color: const Color(0xFF004B6E),
                        borderRadius: BorderRadius.circular(999),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: _sendMessage,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _hasText
                                    ? const [Color(0xFF004B6E), Color(0xFF296580)]
                                    : const [Color(0xFF1E2838), Color(0xFF263244)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                size: 20,
                                color: _hasText ? Colors.white : Colors.white54,
                              ),
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
      ),
    );
  }

  /// Small responsive microphone button with pulse animations for voice input
  Widget _buildVoiceButton() {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _toggleVoiceInput,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isListening
                ? const Color(0xFF004B6E)
                : const Color(0xFF182230),
            border: Border.all(
              color: _isListening
                  ? const Color(0xFF64D5F4)
                  : const Color(0xFF2B3A4E),
              width: _isListening ? 1.8 : 1,
            ),
            boxShadow: _isListening
                ? [
                    BoxShadow(
                      color: const Color(0xFF64D5F4).withValues(alpha: 0.5),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Icon(
              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              size: 21,
              color: _isListening
                  ? const Color(0xFF64D5F4)
                  : const Color(0xFF85BAE3),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────── TYPEWRITER ANIMATION WIDGET ─────────────────────

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _TypewriterText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayedText = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();
    _displayedText = '';
    int currentIndex = 0;

    // Crisp speed: 20ms per character for natural typewriter effect
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (currentIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText += widget.text[currentIndex];
          });
        }
        currentIndex++;
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ──────────────────────── FADING SUBTITLE BUBBLE ─────────────────────────

class _FadingSubtitleBubble extends StatefulWidget {
  final String text;
  final VoidCallback? onDismissed;

  const _FadingSubtitleBubble({
    super.key,
    required this.text,
    this.onDismissed,
  });

  @override
  State<_FadingSubtitleBubble> createState() => _FadingSubtitleBubbleState();
}

class _FadingSubtitleBubbleState extends State<_FadingSubtitleBubble> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _opacityAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacityAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
    _playVoiceAndSchedule();
  }

  @override
  void didUpdateWidget(covariant _FadingSubtitleBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _fadeController.forward();
      _playVoiceAndSchedule();
    }
  }

  void _playVoiceAndSchedule() {
    _dismissTimer?.cancel();

    // Safe fallback duration in case audio is muted or blocked
    final int len = widget.text.length;
    final int fallbackDelayMs = (6000 + (len * 80)).clamp(6000, 20000);
    _dismissTimer = Timer(Duration(milliseconds: fallbackDelayMs), () {
      _finishAndDismiss();
    });

    if (kIsWeb) {
      ElevenLabsService().speakSpiderMan(widget.text, onFinished: () {
        if (!mounted) return;
        _dismissTimer?.cancel();
        // Dialogue audio completed: keep visible for 1.8s buffer then fade out
        _dismissTimer = Timer(const Duration(milliseconds: 1800), () {
          _finishAndDismiss();
        });
      });
    }
  }

  void _finishAndDismiss() {
    if (mounted) {
      _fadeController.reverse().then((_) {
        widget.onDismissed?.call();
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.40),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primaryLight,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: _TypewriterText(
                key: ValueKey(widget.text),
                text: widget.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
