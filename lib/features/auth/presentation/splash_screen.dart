import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import 'login_screen.dart';
import 'hero_onboarding_screen.dart';
import '../../home/presentation/home_screen.dart';

/// App Startup Loading & Session Verification Screen with Stitch Aesthetics
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    // Ultra-fast responsive startup duration (250ms)
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    try {
      await ref
          .read(authControllerProvider.notifier)
          .checkAuthState()
          .timeout(const Duration(milliseconds: 400));
    } catch (_) {}

    if (!mounted) return;
    final authState = ref.read(authControllerProvider);
    Widget targetWidget = const LoginScreen();

    if (authState is Authenticated) {
      final prefs = await SharedPreferences.getInstance();
      final hasCompleted = prefs.getBool('has_completed_onboarding') ?? false;
      targetWidget = hasCompleted ? const HomeScreen() : const HeroOnboardingScreen();
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => targetWidget,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── GLOWING EMBLEM ──
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00334D),
                border: Border.all(color: const Color(0xFF85BAE3).withValues(alpha: 0.5), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF004B6E).withValues(alpha: 0.8),
                    blurRadius: 36,
                    spreadRadius: 6,
                  ),
                  BoxShadow(
                    color: const Color(0xFF85BAE3).withValues(alpha: 0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(52),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAHKd34Tulqg2Oig1ywKWy9TqIeKW53XMYA1rZdBPS0z2eg20FIS6JmGBqybQLCVkpmZlPQXxKnOaYIJGYk48bPDjb7sF6MV09sUXcSlfsP8ke_Wc8n7CjJNxO2f7d0SSByRDGGskY8WE-Qph2fQiQ_WvTLE0f_xDMtw4_hYvS9xdjWNK4CA-u4T5hi5myuGGCcr9DaVNNeNHaw6FBOzygj3vhmNKeCCun3hVx3TcDchV5lTb_4TsE7kA',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('🕷️', style: TextStyle(fontSize: 48)),
                  ),
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.96, 0.96),
                  end: const Offset(1.05, 1.05),
                  duration: 1100.ms,
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 32),

            // ── APP TITLE ──
            Text(
              'READY TO STEP ON SPIDEY',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms),

            const SizedBox(height: 8),

            // ── SUBTITLE ──
            Text(
              'Digital Stillness • Companion Engine',
              style: GoogleFonts.inter(
                color: const Color(0xFF85BAE3),
                fontSize: 13,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w500,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms),

            const SizedBox(height: 52),

            // ── LOADING INDICATOR ──
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF85BAE3)),
              ),
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 500.ms),

            const SizedBox(height: 16),

            Text(
              'Connecting...',
              style: GoogleFonts.inter(
                color: const Color(0xFF556272),
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
