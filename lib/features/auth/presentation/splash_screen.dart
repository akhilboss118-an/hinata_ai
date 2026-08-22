import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import 'login_screen.dart';
import '../../home/presentation/home_screen.dart';

/// Splash screen showing Hinata AI brand with session verification
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
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    try {
      await ref.read(authControllerProvider.notifier).checkAuthState();
    } catch (_) {}

    if (!mounted) return;
    final authState = ref.read(authControllerProvider);
    final targetWidget = authState is Authenticated ? const HomeScreen() : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => targetWidget,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Heart Icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceCard,
                boxShadow: const [AppShadows.neonPink, AppShadows.neonViolet],
              ),
              alignment: Alignment.center,
              child: const Text('💙', style: TextStyle(fontSize: 44)),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.08, 1.08),
                  duration: 1000.ms,
                ),

            const SizedBox(height: 28),

            // App Title
            Text(
              AppConstants.appName.toUpperCase(),
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              AppConstants.appTagline,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryLight,
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms),

            const SizedBox(height: 56),

            // Pulsing Loading Indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms),

            const SizedBox(height: 16),

            Text(
              'Loading...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
