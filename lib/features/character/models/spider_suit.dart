import 'package:flutter/material.dart';

/// Available Spider-Man suits in the wardrobe with custom color matrices,
/// dynamic lighting filters, tech perks, and stats.
enum SpiderSuit {
  starkEnhanced(
    id: 'stark_enhanced',
    name: 'Stark Enhanced',
    tagline: 'High-Tech Nanotech & Web Shooters',
    perkName: 'AI Web Assist',
    perkDescription: 'Enhanced reaction speed & real-time telemetry HUD',
    primaryColor: Color(0xFFE53E3E),
    accentColor: Color(0xFF3182CE),
    glowColor: Color(0xFF64D5F4),
    iconEmoji: '🕷️',
    agility: 9,
    techPower: 10,
    stealth: 7,
    webEnergy: 9,
  ),
  milesMorales(
    id: 'miles_morales',
    name: 'Shadow Strike Miles',
    tagline: 'Matte Midnight Black with Bio-Electric Venom Lines',
    perkName: 'Venom Blast Charge',
    perkDescription: 'Bio-electric stun aura and camouflage stealth active',
    primaryColor: Color(0xFF18181B),
    accentColor: Color(0xFFEF4444),
    glowColor: Color(0xFFFF2A55),
    iconEmoji: '⚡',
    agility: 10,
    techPower: 8,
    stealth: 10,
    webEnergy: 9,
  ),
  spiderPunk(
    id: 'spider_punk',
    name: 'Spider-Punk Riot',
    tagline: 'Electric Neon Magenta, Denim Hue & Punk Rock Aura',
    perkName: 'Sonic Guitar Shockwave',
    perkDescription: 'Punk rock amplifier frequency disrupts interference',
    primaryColor: Color(0xFFEC4899),
    accentColor: Color(0xFF3B82F6),
    glowColor: Color(0xFFF43F5E),
    iconEmoji: '🎸',
    agility: 9,
    techPower: 7,
    stealth: 6,
    webEnergy: 10,
  ),
  futureFoundation(
    id: 'future_foundation',
    name: 'Future Foundation',
    tagline: 'Monochrome Lunar White with Quantum Nanofibers',
    perkName: 'Quantum Particle Shift',
    perkDescription: 'Self-repairing smart fabric never gets stained or torn',
    primaryColor: Color(0xFFF8FAFC),
    accentColor: Color(0xFF0F172A),
    glowColor: Color(0xFF38BDF8),
    iconEmoji: '⚪',
    agility: 9,
    techPower: 10,
    stealth: 9,
    webEnergy: 8,
  ),
  symbioteBlack(
    id: 'symbiote_black',
    name: 'Symbiote Stealth',
    tagline: 'Midnight Black Alien Organic Suit with White Emblem',
    perkName: 'Organic Web Surge',
    perkDescription: 'Unlimited organic tendrils and heightened physical power',
    primaryColor: Color(0xFF0F172A),
    accentColor: Color(0xFF94A3B8),
    glowColor: Color(0xFFCBD5E1),
    iconEmoji: '🖤',
    agility: 10,
    techPower: 6,
    stealth: 10,
    webEnergy: 10,
  ),
  ironSpider(
    id: 'iron_spider',
    name: 'Iron Spider Armor',
    tagline: 'Armored Nanotech with 24K Golden Trims & Waldoes',
    perkName: 'Nanotech Waldoes',
    perkDescription: 'Four robotic mechanical spider-arms deploy for combat',
    primaryColor: Color(0xFF991B1B),
    accentColor: Color(0xFFD97706),
    glowColor: Color(0xFFFCD34D),
    iconEmoji: '✨',
    agility: 8,
    techPower: 10,
    stealth: 6,
    webEnergy: 10,
  ),
  cyber2099(
    id: 'cyber_2099',
    name: 'Cyber 2099 Neo',
    tagline: 'Futuristic Neon Teal & Electric Violet Hologram Visor',
    perkName: 'Holo-Decoy Matrix',
    perkDescription: 'Generates hard-light clones to confuse opponents',
    primaryColor: Color(0xFF06B6D4),
    accentColor: Color(0xFF8B5CF6),
    glowColor: Color(0xFF22D3EE),
    iconEmoji: '💠',
    agility: 9,
    techPower: 10,
    stealth: 8,
    webEnergy: 9,
  ),
  velocitySuit(
    id: 'velocity_suit',
    name: 'Velocity Overdrive',
    tagline: 'Kinetic Energy Amplifier with Amber Speed Glow',
    perkName: 'Super-Sonic Web Dash',
    perkDescription: 'Kinetic absorption converts momentum into raw burst speed',
    primaryColor: Color(0xFFF59E0B),
    accentColor: Color(0xFFEF4444),
    glowColor: Color(0xFFFBBF24),
    iconEmoji: '🔥',
    agility: 10,
    techPower: 9,
    stealth: 7,
    webEnergy: 10,
  ),
  classicSpidey(
    id: 'classic_spidey',
    name: 'Classic Vintage',
    tagline: 'Iconic Comic Red & Blue Web-Slinger since 1962',
    perkName: 'Heart of a Hero',
    perkDescription: 'Inspires maximum optimism and unwavering determination',
    primaryColor: Color(0xFFDC2626),
    accentColor: Color(0xFF2563EB),
    glowColor: Color(0xFFFF6B6B),
    iconEmoji: '🕸️',
    agility: 9,
    techPower: 8,
    stealth: 7,
    webEnergy: 9,
  );

  final String id;
  final String name;
  final String tagline;
  final String perkName;
  final String perkDescription;
  final Color primaryColor;
  final Color accentColor;
  final Color glowColor;
  final String iconEmoji;
  final int agility;
  final int techPower;
  final int stealth;
  final int webEnergy;

  const SpiderSuit({
    required this.id,
    required this.name,
    required this.tagline,
    required this.perkName,
    required this.perkDescription,
    required this.primaryColor,
    required this.accentColor,
    required this.glowColor,
    required this.iconEmoji,
    required this.agility,
    required this.techPower,
    required this.stealth,
    required this.webEnergy,
  });

  List<double> get colorMatrix {
    switch (this) {
      case SpiderSuit.milesMorales:
        // Darkened stealth contrast + punchy red glow
        return const [
          0.45 * 1.5, 0.15, 0.15, 0, -35,
          0.10, 0.40 * 1.5, 0.10, 0, -35,
          0.10, 0.10, 0.40 * 1.5, 0, -35,
          0,    0,    0,          1, 0,
        ];
      case SpiderSuit.spiderPunk:
        // High saturation neon pink & cyan punk split
        return const [
          1.45, 0.10, 0.20, 0, 15,
          0.00, 0.70, 0.90, 0, -10,
          0.40, 0.20, 1.50, 0, 20,
          0,    0,    0,    1, 0,
        ];
      case SpiderSuit.futureFoundation:
        // Inverted lunar bright silver-white with obsidian darks
        return const [
          1.60, 1.40, 1.40, 0, 45,
          1.40, 1.60, 1.40, 0, 45,
          1.40, 1.40, 1.60, 0, 45,
          0,    0,    0,    1, 0,
        ];
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
          1.30, 0.25, 0.00, 0, 25,
          0.25, 1.20, 0.00, 0, 18,
          0.00, 0.10, 0.40, 0, -30,
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
      case SpiderSuit.velocitySuit:
        // Kinetic Amber & Warm Crimson overdrive
        return const [
          1.50, 0.30, 0.00, 0, 25,
          0.50, 1.10, 0.00, 0, 15,
          0.00, 0.10, 0.50, 0, -20,
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
      case SpiderSuit.milesMorales:
        return 'contrast(160%) brightness(65%) drop-shadow(0 0 20px rgba(255,42,85,0.6))';
      case SpiderSuit.spiderPunk:
        return 'hue-rotate(290deg) saturate(220%) contrast(140%) drop-shadow(0 0 22px rgba(244,63,94,0.65))';
      case SpiderSuit.futureFoundation:
        return 'brightness(140%) contrast(150%) drop-shadow(0 0 22px rgba(56,189,248,0.7))';
      case SpiderSuit.symbioteBlack:
        return 'grayscale(100%) contrast(160%) brightness(70%) drop-shadow(0 0 18px rgba(255,255,255,0.45))';
      case SpiderSuit.ironSpider:
        return 'sepia(55%) saturate(190%) contrast(120%) drop-shadow(0 0 18px rgba(255,215,0,0.55))';
      case SpiderSuit.cyber2099:
        return 'hue-rotate(160deg) saturate(200%) contrast(130%) drop-shadow(0 0 20px rgba(0,245,212,0.6))';
      case SpiderSuit.velocitySuit:
        return 'hue-rotate(40deg) saturate(200%) contrast(125%) drop-shadow(0 0 22px rgba(251,191,36,0.6))';
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
