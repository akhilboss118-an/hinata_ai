import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hinata_ai/core/services/elevenlabs_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../../character/engine/character_controller.dart';
import '../../character/models/character_emotion.dart';

/// Interactive Sheet for Editing User/Hero Profile, Name, and Settings
class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const EditProfileSheet(),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  String _selectedPersona = 'Best Buddy 🤝';
  String _selectedAvatarEmoji = '👤';
  bool _isSaving = false;

  final List<String> _avatarEmojis = [
    '👤',
    '🕷️',
    '🕸️',
    '🦸‍♂️',
    '🦸‍♀️',
    '⚡',
    '🔥',
    '🚀',
    '🕶️',
  ];

  final List<String> _personaList = [
    'Best Buddy 🤝',
    'Crime Fighting Partner 🕷️',
    'Study & Tech Ally 🔬',
    'Web-Slinger Apprentice 🕸️',
  ];

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authControllerProvider);
    final user = authState is Authenticated ? authState.user : null;

    _nameController = TextEditingController(text: user?.displayName ?? 'Alex');
    _ageController = TextEditingController(text: (user?.age ?? 19).toString());
    _selectedPersona = user?.heroPersona ?? 'Best Buddy 🤝';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim().isEmpty ? 'Partner' : _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 19;

    setState(() {
      _isSaving = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hero_display_name', name);
      await prefs.setInt('hero_age', age);
      await prefs.setString('hero_persona', _selectedPersona);

      await ref.read(authControllerProvider.notifier).updateHeroIdentity(
            name: name,
            age: age,
            heroPersona: _selectedPersona,
          );

      // Spidey acknowledgement reaction
      final responseText = "Got it, $name! I've updated your credentials. Looking good, partner!";
      ref.read(characterControllerProvider.notifier).applyAiReaction(
            emotion: CharacterEmotion.happy,
            animation: 'clap',
            speech: responseText,
            intensity: 0.8,
          );

      ElevenLabsService().speakSpiderMan(responseText, emotion: CharacterEmotion.happy);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF101622),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF64D5F4), size: 20),
                const SizedBox(width: 10),
                Text(
                  'Hero profile updated for $name! 🕷️',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF004B6E)),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF101622).withValues(alpha: 0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: const Color(0xFF85BAE3).withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 6),
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🦸‍♂️', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Hero Profile',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Update how Spidey calls and interacts with you',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF85BAE3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Color(0xFF26354A), height: 1),

                // Form List
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shrinkWrap: true,
                    children: [
                      // Avatar Emoji Picker
                      Text(
                        'HERO AVATAR ICON',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64D5F4),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _avatarEmojis.length,
                          itemBuilder: (context, index) {
                            final emoji = _avatarEmojis[index];
                            final isSelected = _selectedAvatarEmoji == emoji;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _selectedAvatarEmoji = emoji;
                                });
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF004B6E) : const Color(0xFF162338),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF64D5F4) : const Color(0xFF26354A),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(emoji, style: const TextStyle(fontSize: 22)),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Name Field
                      Text(
                        'WHAT SHOULD SPIDEY CALL YOU?',
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
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF004B6E)),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Enter your name or hero alias',
                            hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                            prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF64D5F4), size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Age Field
                      Text(
                        'HERO AGE',
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
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF004B6E)),
                        ),
                        child: TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Enter age (e.g. 19)',
                            hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                            prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF64D5F4), size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Dynamic Style Selection
                      Text(
                        'PARTNERSHIP STYLE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64D5F4),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _personaList.map((p) {
                          final isSelected = _selectedPersona == p;
                          return InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedPersona = p;
                              });
                            },
                            borderRadius: BorderRadius.circular(99),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF004B6E) : const Color(0xFF162338),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF64D5F4) : const Color(0xFF26354A),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                p,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004B6E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: const Color(0xFF64D5F4).withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SAVE CHANGES',
                                    style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
