import 'package:flutter/material.dart';

/// Interactive 3D Stage Environments & Backdrops with dynamic lighting,
/// ambient particle palettes, and atmospheric aura configurations.
enum StageEnvironment {
  cyberLab(
    id: 'cyber_lab',
    name: 'Stark Cyber Lab',
    tagline: 'Holographic telemetry & deep nanotech cyan',
    atmosphereTitle: 'Nanotech Facility',
    atmosphereDesc: 'High-speed data streams, holographic HUDs, and Stark telemetry',
    gradientColors: [
      Color(0xFF003049),
      Color(0xFF0A192F),
      Color(0xFF06090E),
    ],
    ringColor: Color(0xFF64D5F4),
    particleColor: Color(0xFF38BDF8),
    iconEmoji: '🔬',
    ambientIntensity: 0.9,
  ),
  neoTokyoRooftop(
    id: 'neo_tokyo_rooftop',
    name: 'Neo-Tokyo Cyber Skyline',
    tagline: 'Hyper-vibrant magenta neon, rainy reflections & dark alloy',
    atmosphereTitle: 'Cyberpunk Skyline',
    atmosphereDesc: 'Electric magenta towers, glowing bill-boards, and wet neon pavement',
    gradientColors: [
      Color(0xFF831843),
      Color(0xFF2E1065),
      Color(0xFF090314),
    ],
    ringColor: Color(0xFFF43F5E),
    particleColor: Color(0xFFFB7185),
    iconEmoji: '🏮',
    ambientIntensity: 1.0,
  ),
  nySunset(
    id: 'ny_sunset',
    name: 'NYC Rooftop Sunset',
    tagline: 'Warm golden amber, fiery crimson & skyline silhouette',
    atmosphereTitle: 'Manhattan Golden Hour',
    atmosphereDesc: 'Peaceful sunset over the Queensboro Bridge with warm golden rim light',
    gradientColors: [
      Color(0xFF9A3412),
      Color(0xFF581C87),
      Color(0xFF130722),
    ],
    ringColor: Color(0xFFF59E0B),
    particleColor: Color(0xFFFDE047),
    iconEmoji: '🌇',
    ambientIntensity: 0.95,
  ),
  midnightMetropolis(
    id: 'midnight_metropolis',
    name: 'Midnight Metropolis',
    tagline: 'Electric violet neon & dark skyscraper grid',
    atmosphereTitle: 'Electric Nightfall',
    atmosphereDesc: 'Late-night patrol overlooking the sprawling glowing city grid',
    gradientColors: [
      Color(0xFF4C1D95),
      Color(0xFF1E1B4B),
      Color(0xFF060412),
    ],
    ringColor: Color(0xFFA855F7),
    particleColor: Color(0xFFC084FC),
    iconEmoji: '🌃',
    ambientIntensity: 0.85,
  ),
  oscorpObservatory(
    id: 'oscorp_observatory',
    name: 'Oscorp Observatory',
    tagline: 'Emerald particle lasers, quantum physics & obsidian glass',
    atmosphereTitle: 'Quantum Research Dome',
    atmosphereDesc: 'Emerald particle accelerators and dark glass observation decks',
    gradientColors: [
      Color(0xFF064E3B),
      Color(0xFF062822),
      Color(0xFF020E0C),
    ],
    ringColor: Color(0xFF10B981),
    particleColor: Color(0xFF34D399),
    iconEmoji: '🧪',
    ambientIntensity: 0.88,
  ),
  multiverseNexus(
    id: 'multiverse_nexus',
    name: 'Multiverse Nexus',
    tagline: 'Cosmic emerald nebula, dimensional rifts & starfield',
    atmosphereTitle: 'Quantum Web Realm',
    atmosphereDesc: 'Interdimensional cosmic web threads connecting parallel realities',
    gradientColors: [
      Color(0xFF0E7490),
      Color(0xFF0F172A),
      Color(0xFF030712),
    ],
    ringColor: Color(0xFF06B6D4),
    particleColor: Color(0xFF67E8F9),
    iconEmoji: '🌌',
    ambientIntensity: 0.92,
  );

  final String id;
  final String name;
  final String tagline;
  final String atmosphereTitle;
  final String atmosphereDesc;
  final List<Color> gradientColors;
  final Color ringColor;
  final Color particleColor;
  final String iconEmoji;
  final double ambientIntensity;

  const StageEnvironment({
    required this.id,
    required this.name,
    required this.tagline,
    required this.atmosphereTitle,
    required this.atmosphereDesc,
    required this.gradientColors,
    required this.ringColor,
    required this.particleColor,
    required this.iconEmoji,
    required this.ambientIntensity,
  });

  static StageEnvironment fromId(String? id) {
    if (id == null) return StageEnvironment.cyberLab;
    for (final env in StageEnvironment.values) {
      if (env.id == id || env.name.toLowerCase() == id.toLowerCase()) {
        return env;
      }
    }
    return StageEnvironment.cyberLab;
  }
}
