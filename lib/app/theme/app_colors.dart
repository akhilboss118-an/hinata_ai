import 'package:flutter/material.dart';

/// Centralized color palette for Hinata AI
/// Stitch design tokens: dark charcoal surfaces with cyan luminescence.
abstract class AppColors {
  // Backgrounds & Surface
  static const Color background = Color(0xFF111317);
  static const Color backgroundDeep = Color(0xFF0C0E12);
  static const Color surfaceCard = Color(0xFF1E2024);
  static const Color surfaceCardHover = Color(0xFF282A2E);
  static const Color surfaceGlass = Color(0x0DFFFFFF); // white @ 5%
  static const Color surfaceInput = Color(0xFF333539);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF3D494C);
  static const Color borderGlow = Color(0xFF64D5F4);
  static const Color divider = Color(0xFF333539);

  // Brand Primary & Accents
  static const Color primary = Color(0xFF64D5F4); // Cyan surface-tint
  static const Color primaryLight = Color(0xFFD2F3FF); // Primary
  static const Color primaryDark = Color(0xFF004E5E);
  static const Color secondary = Color(0xFFD3BBFF); // Soft lavender
  static const Color secondaryLight = Color(0xFFEBDDFF);
  static const Color accentCyan = Color(0xFF70E0FF);
  static const Color accentBlue = Color(0xFFB0ECFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFE2E2E8);
  static const Color textSecondary = Color(0xFFBDC8CD);
  static const Color textMuted = Color(0xFF879397);
  static const Color textDisabled = Color(0xFF3D494C);

  // Status & Feedback
  static const Color statusOnline = Color(0xFF10B981);
  static const Color statusThinking = Color(0xFFFFCA5A);
  static const Color statusSpeaking = Color(0xFF64D5F4);
  static const Color error = Color(0xFFFFB4AB);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFFCA5A);

  // Mood/Emotion Colors
  static const Color moodHappy = Color(0xFFFFCA5A);
  static const Color moodExcited = Color(0xFF70E0FF);
  static const Color moodSad = Color(0xFF60A5FA);
  static const Color moodShy = Color(0xFFF43F5E);
  static const Color moodAngry = Color(0xFFEF4444);
  static const Color moodSurprised = Color(0xFFD3BBFF);
}
