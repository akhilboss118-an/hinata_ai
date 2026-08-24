import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/services/voice_input_service.dart';

/// Floating bottom input composer bar with Stitch design and voice input
class ChatComposer extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onMicTap;
  final bool isEnabled;

  const ChatComposer({
    super.key,
    required this.onSubmitted,
    this.onMicTap,
    this.isEnabled = true,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.isEnabled) {
      widget.onSubmitted(text);
      _controller.clear();
    }
  }

  void _handleVoiceToggle() async {
    if (widget.onMicTap != null) {
      widget.onMicTap!();
      return;
    }

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
          _controller.text = text;
        });
        _handleSend();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.inter(fontSize: 13)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1E2838),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101622).withValues(alpha: 0.92),
        borderRadius: AppRadius.roundedFull,
        border: Border.all(
          color: _isListening
              ? const Color(0xFF64D5F4).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.12),
          width: _isListening ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isListening
                ? const Color(0xFF64D5F4).withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Voice Input Mic Button
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.isEnabled ? _handleVoiceToggle : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening
                      ? const Color(0xFF004B6E)
                      : const Color(0xFF182230),
                  border: Border.all(
                    color: _isListening
                        ? const Color(0xFF64D5F4)
                        : const Color(0xFF2B3A4E),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListening
                        ? const Color(0xFF64D5F4)
                        : const Color(0xFF85BAE3),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Message Input Field
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.isEnabled,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.white,
              ),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _isListening
                    ? 'Listening... Speak now 🎙️'
                    : 'Talk to Spider-Man...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: _isListening
                      ? const Color(0xFF85BAE3)
                      : const Color(0xFF758394),
                  fontStyle: _isListening ? FontStyle.italic : FontStyle.normal,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                isDense: true,
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),

          // Send Action Button
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hasText && widget.isEnabled
                  ? const Color(0xFF004B6E)
                  : const Color(0xFF1E2838),
              border: Border.all(
                color: _hasText && widget.isEnabled
                    ? const Color(0xFF85BAE3).withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_upward_rounded, size: 18),
              color: _hasText && widget.isEnabled ? Colors.white : Colors.white38,
              padding: EdgeInsets.zero,
              onPressed: _hasText && widget.isEnabled ? _handleSend : null,
            ),
          ),
        ],
      ),
    );
  }
}
