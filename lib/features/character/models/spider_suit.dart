import 'package:flutter/material.dart';

/// Available Spider-Man suits in the wardrobe
enum SpiderSuit {
  starkEnhanced(
    id: 'stark_enhanced',
    name: 'Stark Enhanced',
    tagline: 'High-Tech Nanotech & Web Shooters',
    primaryColor: Color(0xFFE53E3E),
    accentColor: Color(0xFF3182CE),
    glowColor: Color(0xFF64D5F4),
    iconEmoji: '🕷️',
  ),
  classicSpidey(
    id: 'classic_spidey',
    name: 'Classic Vintage',
    tagline: 'Iconic Comic Red & Blue Web-Slinger',
    primaryColor: Color(0xFFC53030),
    accentColor: Color(0xFF2B6CB0),
    glowColor: Color(0xFFFF4D4D),
    iconEmoji: '🕸️',
  ),
  symbioteBlack(
    id: 'symbiote_black',
    name: 'Symbiote Stealth',
    tagline: 'Midnight Black Alien Suit with White Emblem',
    primaryColor: Color(0xFF1A202C),
    accentColor: Color(0xFFE2E8F0),
    glowColor: Color(0xFFA0AEC0),
    iconEmoji: '🖤',
  ),
  ironSpider(
    id: 'iron_spider',
    name: 'Iron Spider',
    tagline: 'Armored Nanotech with Golden Accents',
    primaryColor: Color(0xFF9B2C2C),
    accentColor: Color(0xFFD69E2E),
    glowColor: Color(0xFFF6E05E),
    iconEmoji: '✨',
  ),
  cyber2099(
    id: 'cyber_2099',
    name: 'Cyber 2099',
    tagline: 'Futuristic Neon Cyan & Dark Titanium',
    primaryColor: Color(0xFF00B4D8),
    accentColor: Color(0xFFF72585),
    glowColor: Color(0xFF00F5D4),
    iconEmoji: '⚡',
  );

  final String id;
  final String name;
  final String tagline;
  final Color primaryColor;
  final Color accentColor;
  final Color glowColor;
  final String iconEmoji;

  const SpiderSuit({
    required this.id,
    required this.name,
    required this.tagline,
    required this.primaryColor,
    required this.accentColor,
    required this.glowColor,
    required this.iconEmoji,
  });

  List<double> get colorMatrix {
    switch (this) {
      case SpiderSuit.symbioteBlack:
        // Grayscale + High Contrast + Deep Shadow (Pure Symbiote Black & White look)
        return const [
          0.33 * 1.4, 0.33 * 1.4, 0.33 * 1.4, 0, -45,
          0.33 * 1.4, 0.33 * 1.4, 0.33 * 1.4, 0, -45,
          0.33 * 1.4, 0.33 * 1.4, 0.33 * 1.4, 0, -45,
          0,          0,          0,          1, 0,
        ];
      case SpiderSuit.ironSpider:
        // Warm Gold & Armor Crimson tint (Iron Spider nanotech look)
        return const [
          1.25, 0.20, 0.00, 0, 20,
          0.20, 1.15, 0.00, 0, 15,
          0.00, 0.10, 0.45, 0, -25,
          0,    0,    0,    1, 0,
        ];
      case SpiderSuit.cyber2099:
        // Cyan / Neon Teal and Magenta shift (Cyber 2099 futuristic look)
        return const [
          0.10, 0.85, 0.50, 0, 5,
          0.20, 0.65, 0.95, 0, 15,
          0.80, 0.20, 1.35, 0, 25,
          0,    0,    0,    1, 0,
        ];
      case SpiderSuit.classicSpidey:
        // High saturation and contrast (Comic Book vintage)
        return const [
          1.35, -0.10, -0.10, 0, 8,
          -0.10, 1.25, -0.10, 0, 8,
          -0.10, -0.10, 1.45, 0, 8,
          0,     0,     0,    1, 0,
        ];
      case SpiderSuit.starkEnhanced:
        // Identity matrix
        return const [
          1, 0, 0, 0, 0,
          0, 1, 0, 0, 0,
          0, 0, 1, 0, 0,
          0, 0, 0, 1, 0,
        ];
    }
  }

  String get cssFilter {
    switch (this) {
      case SpiderSuit.symbioteBlack:
        return 'grayscale(100%) contrast(160%) brightness(70%) drop-shadow(0 0 18px rgba(255,255,255,0.45))';
      case SpiderSuit.ironSpider:
        return 'sepia(55%) saturate(190%) contrast(120%) drop-shadow(0 0 18px rgba(255,215,0,0.55))';
      case SpiderSuit.cyber2099:
        return 'hue-rotate(160deg) saturate(200%) contrast(130%) drop-shadow(0 0 20px rgba(0,245,212,0.6))';
      case SpiderSuit.classicSpidey:
        return 'saturate(160%) contrast(115%) brightness(105%) drop-shadow(0 0 14px rgba(255,77,77,0.4))';
      case SpiderSuit.starkEnhanced:
        return 'none';
    }
  }

  static SpiderSuit fromId(String? id) {
    if (id == null) return SpiderSuit.starkEnhanced;
    for (final suit in SpiderSuit.values) {
      if (suit.id == id || suit.name.toLowerCase() == id.toLowerCase()) {
        return suit;
      }
    }
    return SpiderSuit.starkEnhanced;
  }
}
