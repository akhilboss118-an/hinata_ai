import 'package:flutter/material.dart';

/// Interactive 3D Stage Environments & Backdrops
enum StageEnvironment {
  cyberLab(
    id: 'cyber_lab',
    name: 'Stark Cyber Lab',
    tagline: 'Holographic telemetry & deep tech cyan',
    gradientColors: [
      Color(0xFF003049),
      Color(0xFF0A192F),
      Color(0xFF06090E),
    ],
    ringColor: Color(0xFF64D5F4),
    iconEmoji: '🔬',
  ),
  nySunset(
    id: 'ny_sunset',
    name: 'NYC Rooftop Sunset',
    tagline: 'Warm golden amber and crimson skyline',
    gradientColors: [
      Color(0xFF7B2D26),
      Color(0xFF3F1651),
      Color(0xFF0F081D),
    ],
    ringColor: Color(0xFFFF9E00),
    iconEmoji: '🌇',
  ),
  midnightMetropolis(
    id: 'midnight_metropolis',
    name: 'Midnight Metropolis',
    tagline: 'Electric violet neon & dark skyscraper grid',
    gradientColors: [
      Color(0xFF3C096C),
      Color(0xFF10002B),
      Color(0xFF04010A),
    ],
    ringColor: Color(0xFFC77DFF),
    iconEmoji: '🌃',
  ),
  multiverseNexus(
    id: 'multiverse_nexus',
    name: 'Multiverse Nexus',
    tagline: 'Cosmic emerald starfield & quantum energy',
    gradientColors: [
      Color(0xFF005F73),
      Color(0xFF0A2E36),
      Color(0xFF030D10),
    ],
    ringColor: Color(0xFF00F5D4),
    iconEmoji: '🌌',
  );

  final String id;
  final String name;
  final String tagline;
  final List<Color> gradientColors;
  final Color ringColor;
  final String iconEmoji;

  const StageEnvironment({
    required this.id,
    required this.name,
    required this.tagline,
    required this.gradientColors,
    required this.ringColor,
    required this.iconEmoji,
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
