import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// 16 Character emotional states influencing facial expression, voice, and animation
enum CharacterEmotion {
  neutral('Neutral', '😌', AppColors.textSecondary),
  happy('Happy', '😊', AppColors.moodHappy),
  excited('Excited', '✨', AppColors.moodExcited),
  laughing('Laughing', '😄', AppColors.moodHappy),
  sad('Sad', '🥺', AppColors.moodSad),
  crying('Crying', '😭', AppColors.moodSad),
  angry('Angry', '😤', AppColors.moodAngry),
  annoyed('Annoyed', '😒', AppColors.moodAngry),
  shy('Shy', '😳', AppColors.moodShy),
  embarrassed('Embarrassed', '🙈', AppColors.moodShy),
  surprised('Surprised', '😲', AppColors.moodSurprised),
  confused('Confused', '🤔', AppColors.moodSurprised),
  thinking('Thinking', '💭', AppColors.statusThinking),
  sleepy('Sleepy', '😴', AppColors.textMuted),
  affectionate('Affectionate', '❤️', AppColors.secondary),
  playful('Playful', '😜', AppColors.primaryLight);

  final String label;
  final String emoji;
  final Color color;

  const CharacterEmotion(this.label, this.emoji, this.color);

  /// Safe parsing with fallback to neutral
  static CharacterEmotion fromString(String? value) {
    if (value == null) return CharacterEmotion.neutral;
    final normalized = value.trim().toLowerCase();
    for (final emotion in CharacterEmotion.values) {
      if (emotion.name.toLowerCase() == normalized) {
        return emotion;
      }
    }
    return CharacterEmotion.neutral;
  }
}
