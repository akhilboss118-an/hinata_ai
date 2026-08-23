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
        reactionText = 'Mm... nijamgaa chala nice ga undi ra ♡';
        animation = 'smile';
        break;
      case CharacterGesture.cheekPoke:
        reactionEmotion = CharacterEmotion.shy;
        reactionText = 'Adento ra!! Marchipoya ra nenu~ face red aipoyindi ♡';
        animation = 'blush';
        break;
      case CharacterGesture.noseTap:
        reactionEmotion = CharacterEmotion.surprised;
        reactionText = 'Aiyyo ra!! Em chesav idhi nee gurinchi?? 😮';
        animation = 'surprised';
        break;
      case CharacterGesture.poke:
        if (state.interactionCount % 4 == 3) {
          reactionEmotion = CharacterEmotion.annoyed;
          reactionText = 'Chupp normuyy, adhi correct kaadhu ra 😤';
          animation = 'pout';
        } else {
          reactionEmotion = CharacterEmotion.playful;
          reactionText = 'Heheee, pedda paniki ledu ra~ 😜';
          animation = 'giggle';
        }
        break;
      case CharacterGesture.hold:
        reactionEmotion = CharacterEmotion.affectionate;
        reactionText = 'Hand pattukunnav... baneee ra ♡';
        animation = 'warmSmile';
        break;
      case CharacterGesture.swipe:
        reactionEmotion = CharacterEmotion.excited;
        reactionText = 'Super ga undi ra! Yooo! ✨';
        animation = 'happyBounce';
        break;
      case CharacterGesture.tickle:
        reactionEmotion = CharacterEmotion.laughing;
        reactionText = 'AYYO DEVUDA stop ra stop!! 🤣';
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

    _reactionResetTimer = Timer(const Duration(milliseconds: 3200), () {
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
