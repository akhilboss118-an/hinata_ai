import 'package:flutter/material.dart';
import '../models/character_emotion.dart';
import '../models/character_gesture.dart';
import '../models/spider_suit.dart';
import '../models/stage_environment.dart';

/// Reactive character runtime state with emotion memory, suit, environment & lighting
class CharacterState {
  final CharacterEmotion currentEmotion;
  final CharacterEmotion previousEmotion;
  final DateTime? lastEmotionChangedAt;
  final SpiderSuit currentSuit;
  final StageEnvironment currentEnvironment;
  final String currentAnimation;
  final double intensity;
  final bool isTalking;
  final bool isThinking;
  final CharacterGesture? activeGesture;
  final String? activeReactionText;
  final int affectionLevel;
  final int interactionCount;

  const CharacterState({
    this.currentEmotion = CharacterEmotion.neutral,
    this.previousEmotion = CharacterEmotion.neutral,
    this.lastEmotionChangedAt,
    this.currentSuit = SpiderSuit.starkEnhanced,
    this.currentEnvironment = StageEnvironment.cyberLab,
    this.currentAnimation = 'idle',
    this.intensity = 0.5,
    this.isTalking = false,
    this.isThinking = false,
    this.activeGesture,
    this.activeReactionText,
    this.affectionLevel = 1,
    this.interactionCount = 0,
  });

  Color get currentAuraColor => currentEmotion.auraColor;

  CharacterState copyWith({
    CharacterEmotion? currentEmotion,
    CharacterEmotion? previousEmotion,
    DateTime? lastEmotionChangedAt,
    SpiderSuit? currentSuit,
    StageEnvironment? currentEnvironment,
    String? currentAnimation,
    double? intensity,
    bool? isTalking,
    bool? isThinking,
    CharacterGesture? activeGesture,
    String? activeReactionText,
    int? affectionLevel,
    int? interactionCount,
  }) {
    return CharacterState(
      currentEmotion: currentEmotion ?? this.currentEmotion,
      previousEmotion: previousEmotion ?? this.previousEmotion,
      lastEmotionChangedAt: lastEmotionChangedAt ?? this.lastEmotionChangedAt,
      currentSuit: currentSuit ?? this.currentSuit,
      currentEnvironment: currentEnvironment ?? this.currentEnvironment,
      currentAnimation: currentAnimation ?? this.currentAnimation,
      intensity: intensity ?? this.intensity,
      isTalking: isTalking ?? this.isTalking,
      isThinking: isThinking ?? this.isThinking,
      activeGesture: activeGesture,
      activeReactionText: activeReactionText,
      affectionLevel: affectionLevel ?? this.affectionLevel,
      interactionCount: interactionCount ?? this.interactionCount,
    );
  }
}
