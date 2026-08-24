import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../features/auth/presentation/splash_screen.dart';

/// Main Hinata AI application root widget
class HinataApp extends StatelessWidget {
  const HinataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hinata AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
