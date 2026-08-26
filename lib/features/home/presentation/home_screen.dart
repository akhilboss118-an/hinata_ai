import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hinata_ai/app/theme/app_colors.dart';
import 'package:hinata_ai/core/services/elevenlabs_service.dart';
import 'package:hinata_ai/core/services/voice_input_service.dart';
import 'package:hinata_ai/core/services/sound_fx_service.dart';
import 'package:hinata_ai/features/character/models/character_emotion.dart';
import 'package:hinata_ai/features/character/engine/character_controller.dart';
import 'package:hinata_ai/features/character/engine/character_engine.dart';
import 'package:hinata_ai/features/chat/controllers/chat_controller.dart';
import 'package:hinata_ai/features/auth/controllers/auth_controller.dart';
import 'package:hinata_ai/features/auth/controllers/auth_state.dart';
import 'widgets/side_menu_drawer.dart';
import 'widgets/bond_level_chip.dart';

/// Full-Screen AI Companion Home Screen with Single-Cycle Animations,
/// Multimodal Camera & Vision Input, Bond Progression HUD, and Glass Chat Interface
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
  bool _isListening = false;

  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final has = _textController.text.trim().isNotEmpty || _selectedImageBytes != null;
      if (has != _hasText) setState(() => _hasText = has);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureConversation();
    });
  }

  String _getUid() {
    final authState = ref.read(authControllerProvider);
    if (authState is Authenticated) {
      return authState.user.uid;
    }
    return 'guest_user';
  }

  /// Initializes conversation so messages and memories persist
  void _ensureConversation() {
    final uid = _getUid();
    ref.read(chatControllerProvider.notifier).initConversation(uid, DateTime.now());
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _hasText = true;
        });
        SoundFxService().playTapChime();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourcePicker() {
    SoundFxService().playTapChime();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: const Color(0xFF64D5F4).withValues(alpha: 0.35)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Multimodal Vision & Camera 👁️',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Let Spider-Man inspect your photo with Gemini AI vision',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF85BAE3),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildVisionSourceTile(
                        icon: Icons.camera_alt_rounded,
                        title: 'Snap Photo',
                        subtitle: 'Use Camera',
                        color: const Color(0xFF64D5F4),
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                      _buildVisionSourceTile(
                        icon: Icons.photo_library_rounded,
                        title: 'Photo Library',
                        subtitle: 'Upload Gallery',
                        color: const Color(0xFF818CF8),
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisionSourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF162338),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImageBytes == null) return;

    SoundFxService().playThwip();

    final uid = _getUid();
    final imgBytes = _selectedImageBytes;

    _textController.clear();
    setState(() {
      _selectedImageBytes = null;
      _hasText = false;
    });
    _focusNode.unfocus();

    ref.read(chatControllerProvider.notifier).sendMessage(
      uid: uid,
      text: text,
      imageBytes: imgBytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterControllerProvider);

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

                  // Attached Image Preview Thumbnail Chip
                  if (_selectedImageBytes != null) _buildImagePreviewChip(),

                  // 3D Speech Reaction Subtitle Pill (auto-fading)
                  if (characterState.activeReactionText != null &&
                      characterState.activeReactionText!.isNotEmpty)
                    _buildSubtitleBubble(
                      characterState.activeReactionText!,
                      emotion: characterState.currentEmotion,
                    ),

                  // Thinking pill
                  if (characterState.isThinking) _buildThinkingPill(),

                  // Glass Chat Input Bar
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
    final characterState = ref.watch(characterControllerProvider);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: Color(0xFF85BAE3), size: 28),
              tooltip: 'Open Menu',
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── BOND LEVEL HUD CHIP ───
                BondLevelChip(affinity: characterState.affinity),

                const SizedBox(width: 8),

                // ─── POLISHED ANIMATED EMOTION / MOOD INDICATOR ───
                AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101622).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: characterState.currentEmotion.color.withValues(alpha: 0.45),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: characterState.currentEmotion.color.withValues(alpha: 0.20),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Row(
                      key: ValueKey(characterState.currentEmotion),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          characterState.currentEmotion.emoji,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          characterState.currentEmotion.label.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: characterState.currentEmotion.color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  // ──────────────────────── IMAGE PREVIEW CHIP ─────────────────────────

  Widget _buildImagePreviewChip() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF101622).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF64D5F4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64D5F4).withValues(alpha: 0.25),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              _selectedImageBytes!,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Photo Attached 📸',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Gemini Vision Active',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF64D5F4),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.cancel_rounded, size: 18, color: Colors.white70),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _selectedImageBytes = null;
                _hasText = _textController.text.trim().isNotEmpty;
              });
            },
          ),
        ],
      ),
    );
  }

  // ──────────────────────── SUBTITLE SPEECH BUBBLE ───────────────────────

  Widget _buildSubtitleBubble(String text, {CharacterEmotion emotion = CharacterEmotion.neutral}) {
    return _FadingSubtitleBubble(
      key: ValueKey(text),
      text: text,
      emotion: emotion,
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
                      // Voice Input Mic Button
                      _buildVoiceButton(),

                      const SizedBox(width: 8),

                      // Camera / Vision Button
                      _buildCameraButton(),

                      const SizedBox(width: 8),

                      // Input text field
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          cursorColor: const Color(0xFF85BAE3),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? 'Listening... Speak now 🎙️'
                                : (_selectedImageBytes != null
                                    ? 'Ask about this photo... 👁️'
                                    : 'Talk to Spider-Man...'),
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14,
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

  /// Responsive microphone button with pulse animations for voice input
  Widget _buildVoiceButton() {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _toggleVoiceInput,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 40,
          height: 40,
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
              color: _isListening ? const Color(0xFF64D5F4) : const Color(0xFF85BAE3),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// Camera / Multimodal vision attachment trigger button
  Widget _buildCameraButton() {
    final bool hasImage = _selectedImageBytes != null;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _showImageSourcePicker,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasImage ? const Color(0xFF004B6E) : const Color(0xFF182230),
            border: Border.all(
              color: hasImage ? const Color(0xFF64D5F4) : const Color(0xFF2B3A4E),
              width: hasImage ? 1.8 : 1,
            ),
            boxShadow: hasImage
                ? [
                    BoxShadow(
                      color: const Color(0xFF64D5F4).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Icon(
              Icons.camera_alt_rounded,
              color: hasImage ? const Color(0xFF64D5F4) : const Color(0xFF85BAE3),
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────── TYPEWRITER SUBTITLE EFFECT ────────────────────────

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
  final CharacterEmotion emotion;
  final VoidCallback? onDismissed;

  const _FadingSubtitleBubble({
    super.key,
    required this.text,
    this.emotion = CharacterEmotion.neutral,
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

    final int len = widget.text.length;
    final int fallbackDelayMs = (4000 + (len * 60)).clamp(4000, 15000);
    _dismissTimer = Timer(Duration(milliseconds: fallbackDelayMs), () {
      _finishAndDismiss();
    });

    ElevenLabsService().speakSpiderMan(
      widget.text,
      emotion: widget.emotion,
      onFinished: () {
        if (!mounted) return;
        _dismissTimer?.cancel();
        _dismissTimer = Timer(const Duration(milliseconds: 1400), () {
          _finishAndDismiss();
        });
      },
    );
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
