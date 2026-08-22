import 'package:flutter/material.dart';

/// Neon and soft elevation box shadows
abstract class AppShadows {
  static const BoxShadow neonViolet = BoxShadow(
    color: Color(0x668B5CF6),
    blurRadius: 20,
    spreadRadius: -2,
    offset: Offset(0, 4),
  );

  static const BoxShadow neonPink = BoxShadow(
    color: Color(0x66EC4899),
    blurRadius: 18,
    spreadRadius: -2,
    offset: Offset(0, 4),
  );

  static const BoxShadow cardSubtle = BoxShadow(
    color: Color(0x40000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const BoxShadow ambientGlow = BoxShadow(
    color: Color(0x338B5CF6),
    blurRadius: 30,
    spreadRadius: 4,
  );
}
