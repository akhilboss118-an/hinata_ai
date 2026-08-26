import 'package:flutter/material.dart';

/// Level data descriptor for Bond / Affinity progression
class BondTier {
  final int level;
  final String title;
  final String badgeEmoji;
  final int xpRequired;
  final String perkUnlocked;
  final Color themeColor;

  const BondTier({
    required this.level,
    required this.title,
    required this.badgeEmoji,
    required this.xpRequired,
    required this.perkUnlocked,
    required this.themeColor,
  });
}

/// Affinity & Bond Progression State tracking XP, Bond Level, and Perks
class AffinityState {
  final int totalXp;
  final int interactionStreak;
  final DateTime? lastInteractionDate;

  const AffinityState({
    this.totalXp = 45,
    this.interactionStreak = 1,
    this.lastInteractionDate,
  });

  static const List<BondTier> tiers = [
    BondTier(
      level: 1,
      title: 'Rookie Duo',
      badgeEmoji: '🤝',
      xpRequired: 0,
      perkUnlocked: 'Basic Gestures & AI Chat',
      themeColor: Color(0xFF64D5F4),
    ),
    BondTier(
      level: 2,
      title: 'Trusted Ally',
      badgeEmoji: '⚡',
      xpRequired: 100,
      perkUnlocked: 'Unlocked Heart Reaction & Web Sound FX',
      themeColor: Color(0xFF38BDF8),
    ),
    BondTier(
      level: 3,
      title: 'Web Buddy',
      badgeEmoji: '🕷️',
      xpRequired: 250,
      perkUnlocked: 'Unlocked Spider-Sense & Rapid Thought Processing',
      themeColor: Color(0xFF818CF8),
    ),
    BondTier(
      level: 4,
      title: 'Crimefighting Partner',
      badgeEmoji: '🛡️',
      xpRequired: 500,
      perkUnlocked: 'Unlocked Symbiote & Cyber 2099 Wardrobe Resonance',
      themeColor: Color(0xFFA78BFA),
    ),
    BondTier(
      level: 5,
      title: 'Heroic Bond',
      badgeEmoji: '🌟',
      xpRequired: 850,
      perkUnlocked: 'Multimodal Vision Synergy & Deep Memory Extraction',
      themeColor: Color(0xFFF472B6),
    ),
    BondTier(
      level: 6,
      title: 'Legendary Pair',
      badgeEmoji: '🔥',
      xpRequired: 1300,
      perkUnlocked: 'Quantum Flip Overdrive & High-Speed Audio Streams',
      themeColor: Color(0xFFFB923C),
    ),
    BondTier(
      level: 7,
      title: 'Dimensional Guardians',
      badgeEmoji: '🌌',
      xpRequired: 1900,
      perkUnlocked: 'Multiverse Nexus Backdrops & Custom Voice Pitching',
      themeColor: Color(0xFF34D399),
    ),
    BondTier(
      level: 8,
      title: 'Ultimate Duo',
      badgeEmoji: '👑',
      xpRequired: 2700,
      perkUnlocked: 'Master Hero Synergy & Infinite Telemetry Synchronization',
      themeColor: Color(0xFFFBBF24),
    ),
  ];

  BondTier get currentTier {
    for (int i = tiers.length - 1; i >= 0; i--) {
      if (totalXp >= tiers[i].xpRequired) {
        return tiers[i];
      }
    }
    return tiers.first;
  }

  BondTier? get nextTier {
    final currentIdx = tiers.indexOf(currentTier);
    if (currentIdx < tiers.length - 1) {
      return tiers[currentIdx + 1];
    }
    return null;
  }

  int get currentLevel => currentTier.level;
  String get title => currentTier.title;
  String get badgeEmoji => currentTier.badgeEmoji;
  Color get themeColor => currentTier.themeColor;

  /// Returns progress value from 0.0 to 1.0 towards next tier
  double get progressToNextLevel {
    final next = nextTier;
    if (next == null) return 1.0;
    final currentMin = currentTier.xpRequired;
    final nextTarget = next.xpRequired;
    final diff = nextTarget - currentMin;
    if (diff <= 0) return 1.0;
    final progress = (totalXp - currentMin) / diff;
    return progress.clamp(0.0, 1.0);
  }

  int get xpToNextLevel {
    final next = nextTier;
    if (next == null) return 0;
    return (next.xpRequired - totalXp).clamp(0, 99999);
  }

  AffinityState copyWith({
    int? totalXp,
    int? interactionStreak,
    DateTime? lastInteractionDate,
  }) {
    return AffinityState(
      totalXp: totalXp ?? this.totalXp,
      interactionStreak: interactionStreak ?? this.interactionStreak,
      lastInteractionDate: lastInteractionDate ?? this.lastInteractionDate,
    );
  }
}
