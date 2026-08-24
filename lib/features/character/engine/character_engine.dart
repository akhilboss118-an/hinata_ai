import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
class CharacterEngine extends ConsumerStatefulWidget {
  final VoidCallback? onCharacterTap;
  final bool isInteractive;

  const CharacterEngine({
    super.key,
    this.onCharacterTap,
    this.isInteractive = true,
  });

  @override
  ConsumerState<CharacterEngine> createState() => _CharacterEngineState();
}

class _CharacterEngineState extends ConsumerState<CharacterEngine> {
  bool isIdle = true;

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterControllerProvider);
    final characterController = ref.read(characterControllerProvider.notifier);

    final anim = characterState.currentAnimation.toLowerCase();
    final bool isAcrobatic = anim.contains('flip') || anim.contains('landing') || anim.contains('swing');
    final bool newIsIdle = (anim == 'idle' || anim.isEmpty) && !characterState.isTalking && !isAcrobatic;

    if (newIsIdle != isIdle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            isIdle = newIsIdle;
          });
        }
      });
    }

    final Alignment stageAlignment;
    if (isAcrobatic) {
      stageAlignment = const Alignment(0.0, 0.10);
    } else if (isIdle) {
      stageAlignment = Alignment.center;
    } else {
      stageAlignment = const Alignment(0.0, -0.25);
    }

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

            // Dynamic 3D Character Stage wrapped in AnimatedAlign based on animation state
            Positioned.fill(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                alignment: stageAlignment,
                child: _buildModelStage(characterState),
              ),
            ),

            // Transparent full-screen touch layer (Talking-Tom style hitboxes)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  if (!widget.isInteractive) return;
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
                  widget.onCharacterTap?.call();
                },
                onDoubleTap: () {
                  if (widget.isInteractive) {
                    characterController.handleGesture(CharacterGesture.cheekPoke);
                  }
                },
                onLongPress: () {
                  if (widget.isInteractive) {
                    characterController.handleGesture(CharacterGesture.hold);
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (widget.isInteractive) {
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

    if (state.isThinking || anim == 'thinking' || anim == 'think' || anim == 'ponder') {
      modelPath = 'assets/models/thinking.glb';
    } else if (anim == 'dance' || anim == 'wave_dance' || anim == 'hiphop' || anim == 'celebrate') {
      modelPath = 'assets/models/wave_dance.glb';
    } else if (anim == 'front_flip' || anim == 'flip' || anim == 'jump' || anim == 'acrobatic' || anim == 'happybounce') {
      modelPath = 'assets/models/front_flip.glb';
    } else if (anim == 'swing_landing' || anim == 'landing' || anim == 'crouch' || anim == 'hero_landing') {
      modelPath = 'assets/models/swing_landing.glb';
    } else if (anim == 'wave' || anim == 'waving' || anim == 'hi' || anim == 'hello') {
      modelPath = 'assets/models/waving_gesture.glb';
    } else if (anim == 'clap' || anim == 'clapping' || anim == 'cheer') {
      modelPath = 'assets/models/clapping.glb';
    } else if (anim == 'disappointed' || anim == 'annoyed' || anim == 'pout' || anim == 'disappoint' || state.currentEmotion == CharacterEmotion.annoyed) {
      modelPath = 'assets/models/disappointed.glb';
    } else if (anim == 'sad' || anim == 'crying' || state.currentEmotion == CharacterEmotion.sad) {
      modelPath = 'assets/models/sad_idle.glb';
    } else if (state.isTalking || anim == 'talk' || anim == 'talking' || anim == 'speech') {
      modelPath = (state.interactionCount % 2 == 0)
          ? 'assets/models/talking.glb'
          : 'assets/models/talking_1.glb';
    } else {
      modelPath = 'assets/models/standing_idle.glb';
    }

    final bool isAcrobatic = anim.contains('flip') || anim.contains('landing') || anim.contains('swing');

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: ModelViewer(
            key: ValueKey(modelPath),
            src: modelPath,
            alt: 'Spider-Man 3D Character',
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
            fieldOfView: isAcrobatic ? '38deg' : '30deg',
          ),
        ),
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
