import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:hinata_ai/app/theme/app_colors.dart';
import 'package:hinata_ai/app/theme/app_shadows.dart';
import 'package:hinata_ai/app/theme/app_typography.dart';
import 'package:hinata_ai/app/theme/app_radius.dart';
import '../models/character_emotion.dart';
import '../models/character_gesture.dart';
import 'character_controller.dart';
import 'character_state.dart';

/// Full-Screen Character Viewport & Talking-Tom Touch Gesture Handler
class CharacterEngine extends ConsumerWidget {
  final VoidCallback? onCharacterTap;
  final bool isInteractive;

  const CharacterEngine({
    super.key,
    this.onCharacterTap,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterState = ref.watch(characterControllerProvider);
    final characterController = ref.read(characterControllerProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Subtle Radial Gradient Background (Stitch spec)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.1),
                    radius: 1.1,
                    colors: [
                      AppColors.surfaceCardHover.withValues(alpha: 0.4),
                      AppColors.background.withValues(alpha: 0.9),
                      AppColors.backgroundDeep,
                    ],
                  ),
                ),
              ),
            ),

            // Decorative Ethereal Rings (glass-tube halo, lifted above center)
            _EtherealRing(
              diameter: _clampWidth(constraints.maxWidth, 0.95, 450),
              liftFactor: 0.10,
              borderColor: AppColors.primaryLight.withValues(alpha: 0.10),
            ),
            _EtherealRing(
              diameter: _clampWidth(constraints.maxWidth, 0.85, 400),
              liftFactor: 0.10,
              borderColor: AppColors.primaryLight.withValues(alpha: 0.20),
            ),

            // 3D Character Stage (merged GLB with all animation clips)
            Positioned.fill(
              child: _buildModelStage(characterState),
            ),

            // Transparent full-screen touch layer (Talking-Tom style hitboxes)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  if (!isInteractive) return;
                  final relativeY = details.localPosition.dy / constraints.maxHeight;

                  if (relativeY < 0.4) {
                    // Head Pat
                    characterController.handleGesture(CharacterGesture.headPat);
                  } else if (relativeY < 0.6) {
                    // Cheek / Face Poke
                    characterController.handleGesture(CharacterGesture.cheekPoke);
                  } else {
                    // General tickle / poke
                    characterController.handleGesture(CharacterGesture.tickle);
                  }
                  onCharacterTap?.call();
                },
                onDoubleTap: () {
                  if (isInteractive) {
                    characterController.handleGesture(CharacterGesture.cheekPoke);
                  }
                },
                onLongPress: () {
                  if (isInteractive) {
                    characterController.handleGesture(CharacterGesture.hold);
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (isInteractive) {
                    characterController.handleGesture(CharacterGesture.swipe);
                  }
                },
              ),
            ),

            // Dynamic Reaction / Speech Bubble (Appears directly above character head)
            if (characterState.activeReactionText != null)
              Positioned(
                top: constraints.maxHeight * 0.14,
                left: 28,
                right: 28,
                child: _buildSpeechBubble(
                  characterState.activeReactionText!,
                  characterState.currentEmotion,
                )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: 0.15, end: 0, duration: 250.ms),
              ),
          ],
        );
      },
    );
  }

  double _clampWidth(double maxWidth, double factor, double max) {
    final raw = maxWidth * factor;
    return raw > max ? max : raw;
  }

  /// Maps live character state to the merged GLB animation clip name
  String _clipFor(CharacterState state) {
    final gesture = state.activeGesture;

    // Touch reactions take priority
    if (gesture != null) {
      switch (gesture) {
        case CharacterGesture.headPat:
        case CharacterGesture.cheekPoke:
        case CharacterGesture.noseTap:
        case CharacterGesture.hold:
          return 'Reaction';
        case CharacterGesture.poke:
        case CharacterGesture.swipe:
        case CharacterGesture.tickle:
          return 'Excited';
      }
    }

    // Emotional reactions from chat
    switch (state.currentEmotion) {
      case CharacterEmotion.angry:
      case CharacterEmotion.annoyed:
        return 'Angry';
      case CharacterEmotion.sad:
      case CharacterEmotion.crying:
      case CharacterEmotion.sleepy:
        return 'SadIdle';
      case CharacterEmotion.happy:
      case CharacterEmotion.excited:
      case CharacterEmotion.laughing:
      case CharacterEmotion.playful:
      case CharacterEmotion.affectionate:
      case CharacterEmotion.shy:
      case CharacterEmotion.embarrassed:
      case CharacterEmotion.surprised:
        return 'Excited';
      case CharacterEmotion.neutral:
      case CharacterEmotion.confused:
      case CharacterEmotion.thinking:
        return 'Standing';
    }
  }

  Widget _buildModelStage(CharacterState state) {
    // Flutter web serves bundled assets under /assets/assets/...
    final modelSrc = kIsWeb
        ? 'assets/assets/models/hinata_anim.glb'
        : 'assets/models/hinata_anim.glb';

    return ModelViewer(
      key: const ValueKey('hinata-3d-model'),
      src: modelSrc,
      alt: 'Hinata 3D companion',
      animationName: _clipFor(state),
      autoPlay: true,
      loading: Loading.eager,
      cameraControls: false,
      disableZoom: true,
      interactionPrompt: InteractionPrompt.none,
      cameraOrbit: '0deg 90deg 2.2m',
      minCameraOrbit: '0deg 90deg 2.2m',
      maxCameraOrbit: '0deg 90deg 2.2m',
      fieldOfView: '32deg',
      cameraTarget: 'auto auto auto',
      exposure: 1.0,
      shadowIntensity: 0.5,
    );
  }

  Widget _buildSpeechBubble(String text, CharacterEmotion emotion) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardHover.withValues(alpha: 0.96),
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: emotion.color.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: const [AppShadows.cardSubtle],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emotion.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative blurred halo ring behind the character (Stitch ethereal rings)
class _EtherealRing extends StatelessWidget {
  final double diameter;
  final double liftFactor;
  final Color borderColor;

  const _EtherealRing({
    required this.diameter,
    required this.liftFactor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.translate(
        offset: Offset(0, -diameter * liftFactor),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 0.5),
          ),
        ),
      ),
    );
  }
}
