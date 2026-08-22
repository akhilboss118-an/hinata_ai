import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';

/// Floating bottom input composer bar for messaging Hinata
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.95),
        borderRadius: AppRadius.roundedFull,
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Voice Input Mic Button
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: AppColors.primaryLight),
            onPressed: widget.isEnabled ? widget.onMicTap : null,
            splashRadius: 20,
            tooltip: 'Voice Input',
          ),

          // Message Input Field
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.isEnabled,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Message Hinata...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                isDense: true,
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),

          // Send Action Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hasText && widget.isEnabled
                  ? AppColors.primary
                  : AppColors.borderSubtle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_upward_rounded, size: 20),
              color: _hasText && widget.isEnabled ? Colors.white : AppColors.textDisabled,
              padding: EdgeInsets.zero,
              onPressed: _hasText && widget.isEnabled ? _handleSend : null,
            ),
          ),
        ],
      ),
    );
  }
}
