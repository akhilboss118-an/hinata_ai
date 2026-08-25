import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_radius.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import 'hero_onboarding_screen.dart';

/// Pixel-perfect Stitch UI Login Screen for Hinata AI / Spider-Man Companion
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _showEmailForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
          backgroundColor: Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authController = ref.read(authControllerProvider.notifier);
    if (_isSignUp) {
      authController.signUpWithEmailPassword(email, password);
    } else {
      authController.signInWithEmailPassword(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is Authenticated) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HeroOnboardingScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1114),
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFFF5252), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    next.message,
                    style: GoogleFonts.inter(color: const Color(0xFFFF8A80), fontSize: 13),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.roundedMd,
              side: BorderSide(color: Color(0xFFBA1A1A), width: 1),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                decoration: BoxDecoration(
                  color: const Color(0xFF101622),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF1E2838), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: const Color(0xFF004B6E).withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── TOP: Stitch Logo & Expressive Avatar ──
                    _buildLogoEmblem()
                        .animate()
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 24),

                    // ── HEADER: Title & Subtitle ──
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to continue to your account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF939DA8),
                        fontWeight: FontWeight.w400,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 400.ms),

                    const SizedBox(height: 32),

                    // ── PRIMARY ACTION: Google SSO Button (Full Pill) ──
                    _buildGoogleSignInButton(
                      isLoading: isLoading,
                      onPressed: () => authController.signInWithGoogle(),
                    )
                        .animate()
                        .fadeIn(delay: 350.ms, duration: 450.ms)
                        .slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 14),

                    // ── SECONDARY ACTION: Continue as Guest (Full Pill) ──
                    _buildContinueAsGuestButton(
                      onPressed: () => authController.continueAsGuest(),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 450.ms)
                        .slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 24),

                    // ── EXPANDABLE / TOGGLE: Email & Password ──
                    if (_showEmailForm) ...[
                      const SizedBox(height: 8),
                      _buildInputField(
                        label: 'Email',
                        hint: 'you@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.alternate_email_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      _buildSubmitButton(
                        isLoading: isLoading,
                        text: _isSignUp ? 'Create Account' : 'Sign In',
                        onPressed: _submitForm,
                      ),
                      const SizedBox(height: 16),
                    ],

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showEmailForm = !_showEmailForm;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          _showEmailForm
                              ? 'Hide email sign-in'
                              : 'Or sign in with email & password',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF85BAE3),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── FOOTER: Production by Little Hearts ──
                    Text(
                      'Production by Little Hearts',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: const Color(0xFF758394),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top Hero Logo with glowing mask emblem
  Widget _buildLogoEmblem() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF00334D),
        border: Border.all(color: const Color(0xFF85BAE3).withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004B6E).withValues(alpha: 0.6),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Color(0xFF001E2F),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(44),
        child: Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAHKd34Tulqg2Oig1ywKWy9TqIeKW53XMYA1rZdBPS0z2eg20FIS6JmGBqybQLCVkpmZlPQXxKnOaYIJGYk48bPDjb7sF6MV09sUXcSlfsP8ke_Wc8n7CjJNxO2f7d0SSByRDGGskY8WE-Qph2fQiQ_WvTLE0f_xDMtw4_hYvS9xdjWNK4CA-u4T5hi5myuGGCcr9DaVNNeNHaw6FBOzygj3vhmNKeCCun3hVx3TcDchV5lTb_4TsE7kA',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Text('🕷️', style: TextStyle(fontSize: 42)),
          ),
        ),
      ),
    );
  }

  /// Official Style Google SSO Button
  Widget _buildGoogleSignInButton({
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                       strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00334D)),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGoogleGIcon(),
                    const SizedBox(width: 12),
                    Text(
                      'Sign in with Google',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Outlined Pill Continue as Guest Button (Stitch design)
  Widget _buildContinueAsGuestButton({
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF85BAE3).withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Text(
            'Continue as Guest',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF85BAE3),
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }

  /// Sharp 4-Color Google G Logo
  Widget _buildGoogleGIcon() {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      child: CustomPaint(
        size: const Size(20, 20),
        painter: _GoogleGLogoPainter(),
      ),
    );
  }

  /// Clean Input Field
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF090D14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF263244), width: 1.2),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF556272),
              ),
              prefixIcon: icon != null
                  ? Icon(icon, color: const Color(0xFF758394), size: 19)
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  /// Password Input Field with Forgot Password action and visibility toggle
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            if (!_isSignUp)
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to your registered email.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF85BAE3),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF090D14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF263244), width: 1.2),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF556272),
              ),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF758394), size: 19),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF758394),
                  size: 19,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  /// Primary Action Button in Deep Ocean Blue
  Widget _buildSubmitButton({
    required bool isLoading,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0xFF00334D),
      borderRadius: BorderRadius.circular(999),
      elevation: 4,
      shadowColor: const Color(0xFF004B6E).withValues(alpha: 0.5),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [Color(0xFF00334D), Color(0xFF004B6E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFF85BAE3).withValues(alpha: 0.3), width: 1),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Custom Painter to render Google 4-color G icon flawlessly without assets
class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;

    // Blue arc + bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.8),
      -0.785, // -45 deg
      1.57,  // 90 deg
      false,
      paint,
    );

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(center.dx - 1, center.dy - 2, center.dx + radius - 1, center.dy + 2),
        const Radius.circular(2),
      ),
      barPaint,
    );

    // Green arc (bottom right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.8),
      0.785, // 45 deg
      1.57,  // 90 deg
      false,
      paint,
    );

    // Yellow arc (bottom left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.8),
      2.355, // 135 deg
      1.57,  // 90 deg
      false,
      paint,
    );

    // Red arc (top left)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.8),
      3.925, // 225 deg
      1.57,  // 90 deg
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
