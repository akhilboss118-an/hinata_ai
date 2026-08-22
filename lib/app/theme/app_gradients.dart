import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable glowing gradients
abstract class AppGradients {
  static const LinearGradient primaryButton = LinearGradient(
    colors: [AppColors.primary, Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentHeart = LinearGradient(
    colors: [AppColors.secondary, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlow = LinearGradient(
    colors: [Color(0x338B5CF6), Color(0x11160D2B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkFade = LinearGradient(
    colors: [Colors.transparent, AppColors.background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient avatarBacklight = RadialGradient(
    colors: [Color(0x448B5CF6), Colors.transparent],
    radius: 0.8,
  );
}
