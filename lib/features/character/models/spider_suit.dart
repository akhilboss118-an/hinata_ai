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
