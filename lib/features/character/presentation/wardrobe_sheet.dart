import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/sound_fx_service.dart';
import '../engine/character_controller.dart';
import '../models/spider_suit.dart';
import '../models/stage_environment.dart';

/// Ultra-Modern Interactive Wardrobe & Stage Armory for Spider-Man suits and dynamic environments
class WardrobeBottomSheet extends ConsumerStatefulWidget {
  const WardrobeBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const WardrobeBottomSheet(),
    );
  }

  @override
  ConsumerState<WardrobeBottomSheet> createState() => _WardrobeBottomSheetState();
}

class _WardrobeBottomSheetState extends ConsumerState<WardrobeBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterControllerProvider);
    final characterController = ref.read(characterControllerProvider.notifier);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: BoxDecoration(
            color: const Color(0xFF0C101A).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: const Color(0xFF64D5F4).withValues(alpha: 0.30),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64D5F4).withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 48,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              // Title and Close Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E293B),
                            border: Border.all(color: const Color(0xFF64D5F4), width: 1.2),
                          ),
                          child: const Text('🥋', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hero Armory & Stage',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Equip nanotech suits, environments & VFX',
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

              // Navigation Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141C2B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2B3A4E)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: const Color(0xFF004B6E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF64D5F4).withValues(alpha: 0.6)),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Spider Suits 🕷️'),
                      Tab(text: 'Stage Backdrops 🌆'),
                      Tab(text: 'Stage Settings ⚙️'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 1. SUITS TAB
                    _buildSuitsList(characterState, characterController),

                    // 2. ENVIRONMENTS TAB
                    _buildEnvironmentsList(characterState, characterController),

                    // 3. SETTINGS TAB
                    _buildSettingsList(characterState, characterController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuitsList(dynamic state, CharacterController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: SpiderSuit.values.length,
      itemBuilder: (context, index) {
        final suit = SpiderSuit.values[index];
        final isEquipped = state.currentSuit == suit;

        return InkWell(
          onTap: () {
            SoundFxService().playNanotechEquip();
            controller.setSuit(suit);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEquipped
                  ? const Color(0xFF16243C)
                  : const Color(0xFF111824).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isEquipped
                    ? suit.glowColor
                    : const Color(0xFF26354A),
                width: isEquipped ? 2.0 : 1,
              ),
              boxShadow: isEquipped
                  ? [
                      BoxShadow(
                        color: suit.glowColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Suit Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [suit.primaryColor, suit.accentColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: suit.glowColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: suit.glowColor.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(suit.iconEmoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  suit.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isEquipped)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: suit.glowColor.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(99),
                                    border: Border.all(color: suit.glowColor, width: 1),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: suit.glowColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            suit.tagline,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Perk Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: suit.glowColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: suit.glowColor, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${suit.perkName}: ${suit.perkDescription}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Stat Bars Row
                Row(
                  children: [
                    Expanded(child: _buildStatBar('Agility', suit.agility, suit.glowColor)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatBar('Tech', suit.techPower, suit.glowColor)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatBar('Stealth', suit.stealth, suit.glowColor)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatBar('Energy', suit.webEnergy, suit.glowColor)),
                  ],
                ),

                const SizedBox(height: 12),

                // Equip Action Button
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      SoundFxService().playNanotechEquip();
                      controller.setSuit(suit);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEquipped ? suit.glowColor.withValues(alpha: 0.2) : const Color(0xFF004B6E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isEquipped ? suit.glowColor : const Color(0xFF64D5F4).withValues(alpha: 0.5),
                          width: isEquipped ? 1.5 : 1,
                        ),
                      ),
                    ),
                    child: Text(
                      isEquipped ? '✓ Equipped Nanotech' : 'Equip Suit (+15 XP)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isEquipped ? suit.glowColor : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 10.0,
            backgroundColor: const Color(0xFF1E293B),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEnvironmentsList(dynamic state, CharacterController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: StageEnvironment.values.length,
      itemBuilder: (context, index) {
        final env = StageEnvironment.values[index];
        final isActive = state.currentEnvironment == env;

        return InkWell(
          onTap: () {
            SoundFxService().playWhoosh();
            controller.setEnvironment(env);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF16243C)
                  : const Color(0xFF111824).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? env.ringColor : const Color(0xFF26354A),
                width: isActive ? 2.0 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: env.ringColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Environment Color Spectrum Preview
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: env.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: env.ringColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: env.ringColor.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(env.iconEmoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  env.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: env.ringColor.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(99),
                                    border: Border.all(color: env.ringColor, width: 1),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: env.ringColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            env.tagline,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Atmosphere Detail
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: env.ringColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined, color: env.ringColor, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${env.atmosphereTitle}: ${env.atmosphereDesc}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Switch Environment Button
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      SoundFxService().playWhoosh();
                      controller.setEnvironment(env);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? env.ringColor.withValues(alpha: 0.2) : const Color(0xFF004B6E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isActive ? env.ringColor : const Color(0xFF64D5F4).withValues(alpha: 0.5),
                          width: isActive ? 1.5 : 1,
                        ),
                      ),
                    ),
                    child: Text(
                      isActive ? '✓ Active Atmosphere' : 'Set Atmosphere (+10 XP)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? env.ringColor : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsList(dynamic state, CharacterController controller) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        _buildSettingToggle(
          icon: Icons.blur_circular_rounded,
          title: 'Ethereal Dynamic Rings',
          subtitle: 'Floating multi-layer atmospheric energy rings behind character',
          value: state.showStageRings,
          color: const Color(0xFF64D5F4),
          onChanged: (_) => controller.toggleStageRings(),
        ),
        const SizedBox(height: 12),
        _buildSettingToggle(
          icon: Icons.grid_4x4_rounded,
          title: 'Cyber Hologram Floor Grid',
          subtitle: 'Perspective neon floor matrix responding to camera angle',
          value: state.showStageGrid,
          color: const Color(0xFF818CF8),
          onChanged: (_) => controller.toggleStageGrid(),
        ),
        const SizedBox(height: 12),
        _buildSettingToggle(
          icon: Icons.auto_awesome_rounded,
          title: 'Interactive Touch Particles',
          subtitle: 'Heart chime and spark bursts when patting or poking character',
          value: state.showAmbientParticles,
          color: const Color(0xFFF472B6),
          onChanged: (_) => controller.toggleAmbientParticles(),
        ),
      ],
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111824),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26354A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color, width: 1.2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: const Color(0xFF1E293B),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
