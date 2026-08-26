import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hinata_ai/core/services/elevenlabs_service.dart';
import '../controllers/auth_controller.dart';
import '../../character/engine/character_controller.dart';
import '../../character/models/character_emotion.dart';
import '../../home/presentation/home_screen.dart';

/// Stitch UI: Hero Identification & Name Setup Screen
class HeroOnboardingScreen extends ConsumerStatefulWidget {
  const HeroOnboardingScreen({super.key});

  @override
  ConsumerState<HeroOnboardingScreen> createState() => _HeroOnboardingScreenState();
}

class _HeroOnboardingScreenState extends ConsumerState<HeroOnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _selectedAgeGroup = '18-24';
  int _selectedAge = 19;
  String _selectedPersona = 'Best Buddy 🤝';
  bool _isLoading = false;

  final List<String> _quickAliasSuggestions = [
    'Alex',
    'Miles',
    'Gwen',
    'Captain',
    'Ace',
    'Nova',
    'Partner',
  ];

  final List<Map<String, dynamic>> _ageOptions = [
    {
      'label': '13 - 17',
      'age': 16,
      'title': 'Teen Web-Head',
      'emoji': '🕸️',
    },
    {
      'label': '18 - 24',
      'age': 20,
      'title': 'College Hero',
      'emoji': '🎓',
    },
    {
      'label': '25+',
      'age': 26,
      'title': 'Avenger Ally',
      'emoji': '⚡',
    },
  ];

  final List<Map<String, String>> _personaOptions = [
    {
      'title': 'Best Buddy 🤝',
      'desc': 'Casual banter, jokes & daily hangouts',
    },
    {
      'title': 'Crime Fighting Partner 🕷️',
      'desc': 'Superhero missions & web tactics',
    },
    {
      'title': 'Study & Tech Ally 🔬',
      'desc': 'Science, homework & tech ideas',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialName();
  }

  Future<void> _loadInitialName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('hero_display_name');
      if (savedName != null && savedName.isNotEmpty) {
        _nameController.text = savedName;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _enterTheGame() async {
    final heroName = _nameController.text.trim().isEmpty ? 'Partner' : _nameController.text.trim();

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.heavyImpact();

    try {
      // 1. Save locally and in state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hero_display_name', heroName);
      await prefs.setInt('hero_age', _selectedAge);
      await prefs.setString('hero_persona', _selectedPersona);
      await prefs.setBool('has_completed_onboarding', true);

      // 2. Update Auth Controller
      await ref.read(authControllerProvider.notifier).updateHeroIdentity(
            name: heroName,
            age: _selectedAge,
            heroPersona: _selectedPersona,
          );

      // 3. Spidey excitement voice greeting
      final greeting = "Hey $heroName! Awesome to have you on the team. Let's swing into action!";
      ref.read(characterControllerProvider.notifier).applyAiReaction(
            emotion: CharacterEmotion.excited,
            animation: 'front_flip',
            speech: greeting,
            intensity: 0.9,
          );

      ElevenLabsService().speakSpiderMan(greeting, emotion: CharacterEmotion.excited);

      if (!mounted) return;

      // 4. Smooth Transition to Home Screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      debugPrint('Error entering game: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: Stack(
        children: [
          // Background ambient cyber glow
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF004B6E).withValues(alpha: 0.25),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF64D5F4).withValues(alpha: 0.15),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101622).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF85BAE3).withValues(alpha: 0.28),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF004B6E).withValues(alpha: 0.4),
                        blurRadius: 32,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Spider-Man Emblem ──
                      Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF004B6E), Color(0xFF0A192F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: const Color(0xFF64D5F4).withValues(alpha: 0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF64D5F4).withValues(alpha: 0.35),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text('🕷️', style: TextStyle(fontSize: 32)),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(0.96, 0.96),
                              end: const Offset(1.04, 1.04),
                              duration: 1200.ms,
                              curve: Curves.easeInOut,
                            ),
                      ),

                      const SizedBox(height: 18),

                      // ── Title & Subtitle ──
                      Text(
                        'WHAT SHOULD SPIDEY CALL YOU?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 6),

                      Text(
                        'Set your hero identity so Peter Parker knows his new partner!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF85BAE3),
                          letterSpacing: 0.3,
                        ),
                      ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                      const SizedBox(height: 24),

                      // ── Step 1: Name Input ──
                      Text(
                        'YOUR HERO NAME / ALIAS',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64D5F4),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF090D14),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF004B6E).withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                        ),
                        child: TextField(
                          controller: _nameController,
                          focusNode: _focusNode,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your name (e.g. Alex, Miles, Gwen)',
                            hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64D5F4), size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Quick Alias Suggestion Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _quickAliasSuggestions.map((alias) {
                          return InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _nameController.text = alias;
                              });
                            },
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF162338),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFF004B6E).withValues(alpha: 0.6),
                                ),
                              ),
                              child: Text(
                                alias,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF85BAE3),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // ── Step 2: Age Selection ──
                      Text(
                        'HERO AGE / EXPERIENCE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64D5F4),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: _ageOptions.map((opt) {
                          final isSelected = _selectedAgeGroup == opt['label'];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _selectedAgeGroup = opt['label'] as String;
                                    _selectedAge = opt['age'] as int;
                                  });
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF004B6E) : const Color(0xFF090D14),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF64D5F4) : const Color(0xFF1E2C3D),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(opt['emoji'] as String, style: const TextStyle(fontSize: 18)),
                                      const SizedBox(height: 4),
                                      Text(
                                        opt['label'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        opt['title'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          color: isSelected ? const Color(0xFF85BAE3) : Colors.white38,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // ── Step 3: Partnership Dynamic ──
                      Text(
                        'PARTNERSHIP DYNAMIC',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64D5F4),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Column(
                        children: _personaOptions.map((persona) {
                          final isSelected = _selectedPersona == persona['title'];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _selectedPersona = persona['title']!;
                                });
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF16273E) : const Color(0xFF090D14),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF64D5F4) : const Color(0xFF1E2C3D),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            persona['title']!,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            persona['desc']!,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: Colors.white60,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      color: isSelected ? const Color(0xFF64D5F4) : Colors.white30,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // ── Primary Action: ENTER THE GAME ──
                      ElevatedButton(
                        onPressed: _isLoading ? null : _enterTheGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004B6E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: const Color(0xFF64D5F4).withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF004B6E).withValues(alpha: 0.6),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🎮', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ENTER THE GAME',
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(delay: 2000.ms, duration: 1500.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
