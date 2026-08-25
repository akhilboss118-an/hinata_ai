import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// 16 Character emotional states influencing facial expression, voice, lighting aura, and animation
enum CharacterEmotion {
  neutral('Neutral', '😌', AppColors.textSecondary, voicePitch: 1.20, voiceRate: 1.10, auraColor: Color(0xFF64D5F4)),
  happy('Happy', '😊', AppColors.moodHappy, voicePitch: 1.25, voiceRate: 1.15, auraColor: Color(0xFFFFCA5A)),
  excited('Excited', '✨', AppColors.moodExcited, voicePitch: 1.30, voiceRate: 1.25, auraColor: Color(0xFF70E0FF)),
  laughing('Laughing', '😄', AppColors.moodHappy, voicePitch: 1.28, voiceRate: 1.20, auraColor: Color(0xFFFFD56B)),
  sad('Sad', '🥺', AppColors.moodSad, voicePitch: 1.05, voiceRate: 0.92, auraColor: Color(0xFF60A5FA)),
  crying('Crying', '😭', AppColors.moodSad, voicePitch: 1.02, voiceRate: 0.88, auraColor: Color(0xFF3B82F6)),
  angry('Angry', '😤', AppColors.moodAngry, voicePitch: 1.12, voiceRate: 1.12, auraColor: Color(0xFFEF4444)),
  annoyed('Annoyed', '😒', AppColors.moodAngry, voicePitch: 1.08, voiceRate: 1.05, auraColor: Color(0xFFF97316)),
  shy('Shy', '😳', AppColors.moodShy, voicePitch: 1.22, voiceRate: 0.95, auraColor: Color(0xFFF43F5E)),
  embarrassed('Embarrassed', '🙈', AppColors.moodShy, voicePitch: 1.20, voiceRate: 0.98, auraColor: Color(0xFFFB7185)),
  surprised('Surprised', '😲', AppColors.moodSurprised, voicePitch: 1.35, voiceRate: 1.20, auraColor: Color(0xFFD3BBFF)),
  confused('Confused', '🤔', AppColors.moodSurprised, voicePitch: 1.18, voiceRate: 0.95, auraColor: Color(0xFFA78BFA)),
  thinking('Thinking', '💭', AppColors.statusThinking, voicePitch: 1.15, voiceRate: 1.00, auraColor: Color(0xFFFBBF24)),
  sleepy('Tired', '😴', AppColors.textMuted, voicePitch: 1.00, voiceRate: 0.85, auraColor: Color(0xFF64748B)),
  affectionate('Love', '❤️', AppColors.secondary, voicePitch: 1.22, voiceRate: 1.02, auraColor: Color(0xFFEC4899)),
  playful('Playful', '😜', AppColors.primaryLight, voicePitch: 1.28, voiceRate: 1.18, auraColor: Color(0xFF38BDF8));

  final String label;
  final String emoji;
  final Color color;
  final double voicePitch;
  final double voiceRate;
  final Color auraColor;

  const CharacterEmotion(
    this.label,
    this.emoji,
    this.color, {
    this.voicePitch = 1.20,
    this.voiceRate = 1.10,
    this.auraColor = const Color(0xFF64D5F4),
  });

  /// Safe parsing with comprehensive alias matching and strict fallback to neutral
  static CharacterEmotion fromString(String? value) {
    if (value == null || value.trim().isEmpty) return CharacterEmotion.neutral;
    final normalized = value.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '').replaceAll('-', '');

    // Direct match
    for (final emotion in CharacterEmotion.values) {
      if (emotion.name.toLowerCase() == normalized ||
          emotion.label.toLowerCase().replaceAll(' ', '') == normalized) {
        return emotion;
      }
    }

    // Semantic aliases
    if (normalized.contains('love') ||
        normalized.contains('ador') ||
        normalized.contains('affection') ||
        normalized.contains('heart') ||
        normalized.contains('caring') ||
        normalized.contains('sweet')) {
      return CharacterEmotion.affectionate;
    }
    if (normalized.contains('tired') ||
        normalized.contains('sleep') ||
        normalized.contains('exhaust') ||
        normalized.contains('drowsy') ||
        normalized.contains('rest')) {
      return CharacterEmotion.sleepy;
    }
    if (normalized.contains('excite') ||
        normalized.contains('hype') ||
        normalized.contains('pump') ||
        normalized.contains('thrill') ||
        normalized.contains('energetic') ||
        normalized.contains('hero')) {
      return CharacterEmotion.excited;
    }
    if (normalized.contains('laugh') ||
        normalized.contains('lol') ||
        normalized.contains('giggle') ||
        normalized.contains('funny') ||
        normalized.contains('joke')) {
      return CharacterEmotion.laughing;
    }
    if (normalized.contains('happy') ||
        normalized.contains('joy') ||
        normalized.contains('glad') ||
        normalized.contains('cheer') ||
        normalized.contains('great') ||
        normalized.contains('awesome') ||
        normalized.contains('smile')) {
      return CharacterEmotion.happy;
    }
    if (normalized.contains('cry') || normalized.contains('tear') || normalized.contains('sobbing')) {
      return CharacterEmotion.crying;
    }
    if (normalized.contains('sad') ||
        normalized.contains('down') ||
        normalized.contains('depress') ||
        normalized.contains('sorrow') ||
        normalized.contains('grief') ||
        normalized.contains('upset')) {
      return CharacterEmotion.sad;
    }
    if (normalized.contains('angry') ||
        normalized.contains('mad') ||
        normalized.contains('furious') ||
        normalized.contains('rage')) {
      return CharacterEmotion.angry;
    }
    if (normalized.contains('annoy') ||
        normalized.contains('irritat') ||
        normalized.contains('frustrat') ||
        normalized.contains('disappoint') ||
        normalized.contains('pout')) {
      return CharacterEmotion.annoyed;
    }
    if (normalized.contains('surpris') ||
        normalized.contains('shock') ||
        normalized.contains('amaz') ||
        normalized.contains('astonish') ||
        normalized.contains('whoa') ||
        normalized.contains('wow')) {
      return CharacterEmotion.surprised;
    }
    if (normalized.contains('confus') ||
        normalized.contains('puzzl') ||
        normalized.contains('curious') ||
        normalized.contains('doubt') ||
        normalized.contains('wonder') ||
        normalized.contains('unsure')) {
      return CharacterEmotion.confused;
    }
    if (normalized.contains('think') ||
        normalized.contains('ponder') ||
        normalized.contains('analys') ||
        normalized.contains('brain') ||
        normalized.contains('reflect')) {
      return CharacterEmotion.thinking;
    }
    if (normalized.contains('playful') ||
        normalized.contains('teas') ||
        normalized.contains('silly') ||
        normalized.contains('prank') ||
        normalized.contains('game')) {
      return CharacterEmotion.playful;
    }
    if (normalized.contains('shy') ||
        normalized.contains('blush') ||
        normalized.contains('timid')) {
      return CharacterEmotion.shy;
    }
    if (normalized.contains('embarrass')) {
      return CharacterEmotion.embarrassed;
    }
    if (normalized.contains('neutral') ||
        normalized.contains('calm') ||
        normalized.contains('idle') ||
        normalized.contains('normal') ||
        normalized.contains('chill')) {
      return CharacterEmotion.neutral;
    }

    return CharacterEmotion.neutral;
  }
}
