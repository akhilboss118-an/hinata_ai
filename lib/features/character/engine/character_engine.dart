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

            // Video Character Stage (MP4 video loop engine)
            Positioned.fill(
              child: _buildModelStage(characterState),
            ),

            // Transparent full-screen touch layer (Talking-Tom style hitboxes)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
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
          ],
        );
      },
    );
  }

  double _clampWidth(double maxWidth, double factor, double max) {
    final raw = maxWidth * factor;
    return raw > max ? max : raw;
  }

  Widget _buildModelStage(CharacterState state) {
    String modelPath;
    final anim = state.currentAnimation.toLowerCase();

    if (anim == 'wave' || anim == 'waving' || anim == 'hi' || anim == 'hello') {
      modelPath = 'assets/models/waving_gesture.glb';
    } else if (anim == 'clap' || anim == 'clapping' || anim == 'happy' || anim == 'excited') {
      modelPath = 'assets/models/clapping.glb';
    } else if (anim == 'sad' || anim == 'crying' || state.currentEmotion == CharacterEmotion.sad) {
      modelPath = 'assets/models/sad_idle.glb';
    } else {
      modelPath = 'assets/models/standing_idle.glb';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ModelViewer(
          key: ValueKey(modelPath),
          src: modelPath,
          alt: 'Hinata 3D Character',
          ar: false,
          autoRotate: false,
          cameraControls: false,
          disablePan: true,
          disableZoom: true,
          disableTap: true,
          shadowIntensity: 1.0,
          backgroundColor: Colors.transparent,
          autoPlay: true,
          cameraOrbit: '0deg 75deg auto',
          fieldOfView: '30deg',
        ),
      ),
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
