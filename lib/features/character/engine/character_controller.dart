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

  /// Sets character into Thinking state when AI is generating a reply
  void setThinking(bool isThinking) {
    if (isThinking) {
      state = state.copyWith(
        isThinking: true,
        currentEmotion: CharacterEmotion.thinking,
        currentAnimation: 'thinking',
      );
    } else {
      state = state.copyWith(isThinking: false);
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
        reactionText = 'Hello andi! Thank you, it is a pleasure interacting with you.';
        animation = 'smile';
        break;
      case CharacterGesture.cheekPoke:
        reactionEmotion = CharacterEmotion.happy;
        reactionText = 'Spider-Man at your service andi! How may I assist you?';
        animation = 'smile';
        break;
      case CharacterGesture.noseTap:
        reactionEmotion = CharacterEmotion.surprised;
        reactionText = 'Greetings andi! I am alert and ready for your commands.';
        animation = 'surprised';
        break;
      case CharacterGesture.poke:
        reactionEmotion = CharacterEmotion.happy;
        reactionText = 'Hello andi! Please let me know what you would like to discuss.';
        animation = 'talking';
        break;
      case CharacterGesture.hold:
        reactionEmotion = CharacterEmotion.happy;
        reactionText = 'Thank you andi. I appreciate our collaboration today.';
        animation = 'warmSmile';
        break;
      case CharacterGesture.swipe:
        reactionEmotion = CharacterEmotion.excited;
        reactionText = 'Ready for action andi! Please feel free to ask anything.';
        animation = 'happyBounce';
        break;
      case CharacterGesture.tickle:
        reactionEmotion = CharacterEmotion.laughing;
        reactionText = 'Haha, very lively andi! Let us see what we can accomplish today.';
        animation = 'laugh';
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
