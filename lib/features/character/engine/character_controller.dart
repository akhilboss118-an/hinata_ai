import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/js_interop/js_interop.dart';
import '../../../core/services/sound_fx_service.dart';
import 'character_state.dart';
import '../models/affinity_state.dart';
import '../models/character_emotion.dart';
import '../models/character_gesture.dart';
import '../models/spider_suit.dart';
import '../models/stage_environment.dart';

final characterControllerProvider =
    StateNotifierProvider<CharacterController, CharacterState>((ref) {
  return CharacterController();
});

class CharacterController extends StateNotifier<CharacterState> {
  /// Centralized configurable duration before an active emotion decays toward neutral
  static const Duration emotionDecayDuration = Duration(seconds: 8);

  Timer? _idleTimer;
  Timer? _reactionResetTimer;
  Timer? _emotionDecayTimer;
  final Random _random = Random();

  CharacterController() : super(const CharacterState()) {
    _startNaturalIdleLoop();
    _loadPersistedPreferences();
  }

  Future<void> _loadPersistedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final suitId = prefs.getString('spidey_selected_suit');
      final envId = prefs.getString('spidey_selected_env');
      final xp = prefs.getInt('spidey_affinity_xp') ?? 45;
      final streak = prefs.getInt('spidey_interaction_streak') ?? 1;

      final suit = SpiderSuit.fromId(suitId);
      final env = StageEnvironment.fromId(envId);

      state = state.copyWith(
        currentSuit: suit,
        currentEnvironment: env,
        affinity: AffinityState(totalXp: xp, interactionStreak: streak),
      );

      if (kIsWeb) {
        try {
          callJsMethod('applySpiderSuit', [suit.id]);
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Adds Affinity XP, checks for level up and saves to storage
  Future<void> addAffinityXp(int xp) async {
    final oldLevel = state.affinity.currentLevel;
    final newXp = state.affinity.totalXp + xp;
    final newAffinity = state.affinity.copyWith(totalXp: newXp);

    state = state.copyWith(affinity: newAffinity);

    if (newAffinity.currentLevel > oldLevel) {
      SoundFxService().playLevelUp();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('spidey_affinity_xp', newXp);
    } catch (_) {}
  }

  /// Sets the equipped Spider-Man suit and saves to device storage
  Future<void> setSuit(SpiderSuit suit) async {
    state = state.copyWith(currentSuit: suit);
    if (kIsWeb) {
      try {
        callJsMethod('applySpiderSuit', [suit.id]);
      } catch (_) {}
    }
    addAffinityXp(15);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('spidey_selected_suit', suit.id);
    } catch (_) {}
  }

  /// Sets the 3D stage environment / backdrop and saves to device storage
  Future<void> setEnvironment(StageEnvironment environment) async {
    state = state.copyWith(currentEnvironment: environment);
    addAffinityXp(10);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('spidey_selected_env', environment.id);
    } catch (_) {}
  }

  /// Toggles stage settings (Rings, Grid, Particles)
  void toggleStageRings() {
    state = state.copyWith(showStageRings: !state.showStageRings);
  }

  void toggleStageGrid() {
    state = state.copyWith(showStageGrid: !state.showStageGrid);
  }

  void toggleAmbientParticles() {
    state = state.copyWith(showAmbientParticles: !state.showAmbientParticles);
  }

  /// Updates the thinking state when AI is generating responses
  void setThinking(bool thinking) {
    if (thinking) {
      _reactionResetTimer?.cancel();
      state = state.copyWith(
        isThinking: true,
        currentAnimation: 'thinking',
        currentEmotion: CharacterEmotion.thinking,
      );
    } else {
      state = state.copyWith(
        isThinking: false,
        currentAnimation: 'idle',
      );
    }
  }

  /// Sets a specific emotion with memory tracking and decay scheduling
  void setEmotion(CharacterEmotion newEmotion) {
    if (state.currentEmotion == newEmotion) return;

    final prev = state.currentEmotion;
    state = state.copyWith(
      currentEmotion: newEmotion,
      previousEmotion: prev,
      lastEmotionChangedAt: DateTime.now(),
    );

    _scheduleEmotionDecay();
  }

  /// Applies structured AI response reaction (emotion + animation + intensity).
  /// GUARANTEE: The animation plays EXACTLY ONCE for its cycle duration,
  /// then seamlessly returns to 'idle' (standing_idle.glb).
  void applyAiReaction({
    required CharacterEmotion emotion,
    required String animation,
    required double intensity,
    String? speech,
  }) {
    _reactionResetTimer?.cancel();
    _emotionDecayTimer?.cancel();

    final prev = state.currentEmotion;
    final resolvedAnim = _resolveAnimationForEmotion(emotion, requestedAnimation: animation);

    if (emotion == CharacterEmotion.surprised || emotion == CharacterEmotion.confused) {
      SoundFxService().playSpiderSense();
    } else if (emotion == CharacterEmotion.excited) {
      SoundFxService().playTapChime();
    }

    state = state.copyWith(
      currentEmotion: emotion,
      previousEmotion: prev,
      lastEmotionChangedAt: DateTime.now(),
      currentAnimation: resolvedAnim,
      intensity: intensity,
      isThinking: false,
      isTalking: true,
      activeReactionText: speech,
    );

    // Precise Single-Cycle Duration: Animation plays ONCE and returns to idle
    final int singlePlayDurationMs = _getSingleAnimationDurationMs(resolvedAnim);

    _reactionResetTimer = Timer(Duration(milliseconds: singlePlayDurationMs), () {
      if (mounted) {
        state = state.copyWith(
          isTalking: false,
          currentAnimation: 'idle',
        );
      }
    });

    // Schedule gentle emotion decay toward neutral after active reaction ends
    _scheduleEmotionDecay();
  }

  /// Resolves the optimal available .glb animation for a given emotion
  String _resolveAnimationForEmotion(CharacterEmotion emotion, {String? requestedAnimation}) {
    final req = requestedAnimation?.trim().toLowerCase() ?? '';
    if (req.isNotEmpty && req != 'idle' && req != 'standing' && req != 'smile') {
      return req;
    }

    switch (emotion) {
      case CharacterEmotion.excited:
        return 'front_flip';
      case CharacterEmotion.playful:
      case CharacterEmotion.laughing:
        return 'wave_dance';
      case CharacterEmotion.happy:
      case CharacterEmotion.affectionate:
        return 'clap';
      case CharacterEmotion.sad:
      case CharacterEmotion.crying:
      case CharacterEmotion.sleepy:
        return 'sad';
      case CharacterEmotion.angry:
      case CharacterEmotion.annoyed:
        return 'disappointed';
      case CharacterEmotion.surprised:
        return 'swing_landing';
      case CharacterEmotion.confused:
      case CharacterEmotion.thinking:
      case CharacterEmotion.shy:
      case CharacterEmotion.embarrassed:
        return 'thinking';
      case CharacterEmotion.neutral:
        return 'talking';
    }
  }

  /// Schedules gentle emotion decay toward neutral when conversation is idle
  void _scheduleEmotionDecay() {
    _emotionDecayTimer?.cancel();

    if (state.currentEmotion == CharacterEmotion.neutral) return;

    _emotionDecayTimer = Timer(emotionDecayDuration, () {
      if (!mounted) return;
      if (state.isThinking || state.isTalking || state.activeGesture != null) {
        _scheduleEmotionDecay();
        return;
      }

      // Step-down decay: EXCITED -> HAPPY -> NEUTRAL, others -> NEUTRAL
      CharacterEmotion nextEmotion = CharacterEmotion.neutral;
      if (state.currentEmotion == CharacterEmotion.excited) {
        nextEmotion = CharacterEmotion.happy;
      } else if (state.currentEmotion == CharacterEmotion.laughing) {
        nextEmotion = CharacterEmotion.happy;
      } else {
        nextEmotion = CharacterEmotion.neutral;
      }

      final prev = state.currentEmotion;
      state = state.copyWith(
        currentEmotion: nextEmotion,
        previousEmotion: prev,
        lastEmotionChangedAt: DateTime.now(),
      );

      // If still not neutral, schedule next step down
      if (nextEmotion != CharacterEmotion.neutral) {
        _scheduleEmotionDecay();
      }
    });
  }

  /// Returns the exact, calibrated single-play duration in milliseconds for each 3D GLB model animation.
  /// Every triggered animation finishes its single cycle and immediately transitions back to idle.
  int _getSingleAnimationDurationMs(String animation) {
    final anim = animation.toLowerCase();
    if (anim.contains('dance')) {
      return 3600; // 1 full wave dance rhythm
    } else if (anim.contains('flip') || anim.contains('acrobatic') || anim.contains('jump')) {
      return 2400; // 1 acrobatic front flip
    } else if (anim.contains('landing') || anim.contains('swing') || anim.contains('crouch')) {
      return 2500; // 1 superhero landing pose & recover
    } else if (anim.contains('wave') || anim == 'hi' || anim == 'hello') {
      return 2600; // 1 friendly hand wave
    } else if (anim.contains('clap') || anim.contains('cheer')) {
      return 2500; // 1 clapping sequence
    } else if (anim.contains('disappoint') || anim.contains('annoy')) {
      return 2800; // 1 disappointed head shake
    } else if (anim == 'sad' || anim == 'crying') {
      return 3000; // 1 sad posture cycle
    } else if (anim.contains('think') || anim == 'ponder') {
      return 3200; // 1 chin-tap thinking pose
    } else if (anim.contains('talk') || anim == 'speech') {
      return 2800; // 1 conversational sentence gesture
    }

    return 2600;
  }

  /// Handles Talking-Tom style interactive gesture triggers.
  /// Plays the gesture animation EXACTLY ONCE, adds Affinity XP, and returns to standing idle.
  void handleGesture(CharacterGesture gesture) {
    _reactionResetTimer?.cancel();
    _emotionDecayTimer?.cancel();

    final newCount = state.interactionCount + 1;
    addAffinityXp(8); // Award +8 XP on interactive physical contact

    CharacterEmotion reactionEmotion;
    String reactionText;
    String animation;

    switch (gesture) {
      case CharacterGesture.headPat:
        SoundFxService().playTapChime();
        reactionEmotion = CharacterEmotion.happy;
        reactionText = 'Hey, thank you! Always great hanging out with you.';
        animation = 'wave';
        break;
      case CharacterGesture.cheekPoke:
        SoundFxService().playTapChime();
        reactionEmotion = CharacterEmotion.excited;
        reactionText = 'Superhero landing! Spider-Man at your service.';
        animation = 'swing_landing';
        break;
      case CharacterGesture.noseTap:
        SoundFxService().playSpiderSense();
        reactionEmotion = CharacterEmotion.thinking;
        reactionText = 'Whoa! Spider-sense is tingling. What is on your mind?';
        animation = 'thinking';
        break;
      case CharacterGesture.poke:
        SoundFxService().playTapChime();
        reactionEmotion = CharacterEmotion.playful;
        reactionText = 'Hey there! What are you working on today?';
        animation = 'talking';
        break;
      case CharacterGesture.hold:
        SoundFxService().playTapChime();
        reactionEmotion = CharacterEmotion.affectionate;
        reactionText = 'I have got your back! Let us get things done.';
        animation = 'clap';
        break;
      case CharacterGesture.swipe:
        SoundFxService().playWhoosh();
        reactionEmotion = CharacterEmotion.excited;
        reactionText = 'Acrobatic flip! Ready for action, what is next?';
        animation = 'front_flip';
        break;
      case CharacterGesture.tickle:
        SoundFxService().playTapChime();
        reactionEmotion = CharacterEmotion.playful;
        reactionText = 'Check out these moves! Let us make things happen.';
        animation = 'wave_dance';
        break;
    }

    final prev = state.currentEmotion;
    state = state.copyWith(
      currentEmotion: reactionEmotion,
      previousEmotion: prev,
      lastEmotionChangedAt: DateTime.now(),
      currentAnimation: animation,
      activeGesture: gesture,
      activeReactionText: reactionText,
      interactionCount: newCount,
    );

    // Reset animation after EXACTLY ONE play cycle (guaranteed single execution)
    final int singlePlayDurationMs = _getSingleAnimationDurationMs(animation);
    _reactionResetTimer = Timer(Duration(milliseconds: singlePlayDurationMs), () {
      if (mounted) {
        state = state.copyWith(
          activeGesture: null,
          activeReactionText: null,
          currentAnimation: 'idle',
        );
      }
    });

    _scheduleEmotionDecay();
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
    _emotionDecayTimer?.cancel();
    super.dispose();
  }
}
