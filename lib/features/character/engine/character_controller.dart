import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'character_state.dart';
import '../models/character_emotion.dart';
import '../models/character_gesture.dart';

final characterControllerProvider =
    StateNotifierProvider<CharacterController, CharacterState>((ref) {
  return CharacterController();
});

class CharacterController extends StateNotifier<CharacterState> {
  Timer? _idleTimer;
  Timer? _reactionResetTimer;
  final Random _random = Random();

  CharacterController() : super(const CharacterState()) {
    _startNaturalIdleLoop();
  }

  ///  /// Updates the thinking state when AI is generating responses
  void setThinking(bool thinking) {
    if (thinking) {
      _reactionResetTimer?.cancel();
      state = state.copyWith(
        isThinking: true,
        currentAnimation: 'thinking',
      );
    } else {
      state = state.copyWith(
        isThinking: false,
        currentAnimation: 'idle',
      );
    }
  }

  /// Applies structured AI response reaction (emotion + animation + intensity)
  void applyAiReaction({
    required CharacterEmotion emotion,
    required String animation,
    required double intensity,
    String? speech,
  }) {
    _reactionResetTimer?.cancel();
    state = state.copyWith(
      currentEmotion: emotion,
      currentAnimation: animation,
      intensity: intensity,
      isThinking: false,
      isTalking: true,
      activeReactionText: speech,
    );

    // Natural timing for gesture reactions before returning to idle
    final anim = animation.toLowerCase();
    int durationMs = 3200;
    if (anim == 'sad' || anim == 'crying') {
      durationMs = 4500;
    } else if (anim == 'front_flip' || anim == 'flip') {
      durationMs = 2800;
    } else if (anim == 'wave_dance' || anim == 'dance') {
      durationMs = 5000;
    }

    _reactionResetTimer = Timer(Duration(milliseconds: durationMs), () {
      if (mounted) {
        state = state.copyWith(
          isTalking: false,
          currentAnimation: 'idle',
        );
      }
    });
  }

  /// Handles Talking-Tom style interactive gesture triggers
  void handleGesture(CharacterGesture gesture) {
    _reactionResetTimer?.cancel();
    final newCount = state.interactionCount + 1;
    final newAffection = min(100, state.affectionLevel + 1);

    CharacterEmotion reactionEmotion;
    String reactionText;
    String animation;

    switch (gesture) {
      case CharacterGesture.headPat:
        reactionEmotion = CharacterEmotion.happy;
        reactionText = 'Hey, thank you! Always great hanging out with you.';
        animation = 'wave';
        break;
      case CharacterGesture.cheekPoke:
        reactionEmotion = CharacterEmotion.excited;
        reactionText = 'Superhero landing! Spider-Man at your service.';
        animation = 'swing_landing';
        break;
      case CharacterGesture.noseTap:
        reactionEmotion = CharacterEmotion.thinking;
        reactionText = 'Whoa! Spider-sense is tingling. What is on your mind?';
        animation = 'thinking';
        break;
      case CharacterGesture.poke:
        reactionEmotion = CharacterEmotion.happy;
        reactionText = 'Hey there! What are you working on today?';
        animation = 'talking';
        break;
      case CharacterGesture.hold:
        reactionEmotion = CharacterEmotion.excited;
        reactionText = 'I have got your back! Let us get things done.';
        animation = 'clap';
        break;
      case CharacterGesture.swipe:
        reactionEmotion = CharacterEmotion.excited;
        reactionText = 'Acrobatic flip! Ready for action, what is next?';
        animation = 'front_flip';
        break;
      case CharacterGesture.tickle:
        reactionEmotion = CharacterEmotion.happy;
        reactionText = 'Check out these moves! Let us make things happen.';
        animation = 'wave_dance';
        break;
    }

    state = state.copyWith(
      currentEmotion: reactionEmotion,
      currentAnimation: animation,
      activeGesture: gesture,
      activeReactionText: reactionText,
      interactionCount: newCount,
      affectionLevel: newAffection,
    );

    final int len = reactionText.length;
    final int gestureDisplayMs = len <= 35 ? 4000 : (4000 + (len - 35) * 45).clamp(4000, 7000);
    _reactionResetTimer = Timer(Duration(milliseconds: gestureDisplayMs), () {
      if (mounted) {
        state = state.copyWith(
          activeGesture: null,
          activeReactionText: null,
          currentAnimation: 'idle',
        );
      }
    });
  }

  /// Probabilistic natural idle micro-motion generator
  void _startNaturalIdleLoop() {
    _idleTimer?.cancel();
    _idleTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) return;
      if (state.isThinking || state.isTalking || state.activeGesture != null) {
        return;
      }

      final roll = _random.nextDouble();
      if (roll < 0.3) {
        state = state.copyWith(currentAnimation: 'lookAround');
      } else if (roll < 0.6) {
        state = state.copyWith(currentAnimation: 'headTilt');
      } else if (roll < 0.8) {
        state = state.copyWith(currentAnimation: 'breathing');
      } else {
        state = state.copyWith(currentAnimation: 'blink');
      }
    });
  }

  /// Clears the speech bubble text
  void clearSpeech() {
    if (mounted) {
      state = state.copyWith(activeReactionText: null);
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _reactionResetTimer?.cancel();
    super.dispose();
  }
}
