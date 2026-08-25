import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../engine/character_controller.dart';
import '../models/spider_suit.dart';
import '../models/stage_environment.dart';

/// Interactive Wardrobe Sheet for switching Spider-Man suits and stage backdrops
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
    _tabController = TabController(length: 2, vsync: this);
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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: const Color(0xFF101622).withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: const Color(0xFF85BAE3).withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Top Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 6),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              // Title and Close Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🥋', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hero Wardrobe & Stage',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Customize Spider-Man suit & stage atmosphere',
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
                    color: const Color(0xFF182230),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2B3A4E)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: const Color(0xFF004B6E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF64D5F4).withValues(alpha: 0.5)),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Spider Suits 🕷️'),
                      Tab(text: 'Stage Backdrops 🌆'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 1. SUITS TAB
                    _buildSuitsList(characterState, characterController),

                    // 2. ENVIRONMENTS TAB
                    _buildEnvironmentsList(characterState, characterController),
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

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isEquipped
                ? const Color(0xFF162338)
                : const Color(0xFF131C28).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEquipped
                  ? suit.glowColor
                  : const Color(0xFF26354A),
              width: isEquipped ? 1.8 : 1,
            ),
            boxShadow: isEquipped
                ? [
                    BoxShadow(
                      color: suit.glowColor.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [suit.primaryColor, suit.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: suit.glowColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: suit.glowColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(suit.iconEmoji, style: const TextStyle(fontSize: 22)),
            ),
            title: Row(
              children: [
                Text(
                  suit.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                if (isEquipped)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: suit.glowColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: suit.glowColor, width: 0.8),
                    ),
                    child: Text(
                      'EQUIPPED',
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
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                suit.tagline,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
            trailing: isEquipped
                ? Icon(Icons.check_circle_rounded, color: suit.glowColor, size: 24)
                : ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      controller.setSuit(suit);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004B6E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Equip'),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEnvironmentsList(dynamic state, CharacterController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: StageEnvironment.values.length,
      itemBuilder: (context, index) {
        final env = StageEnvironment.values[index];
        final isActive = state.currentEnvironment == env;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF162338)
                : const Color(0xFF131C28).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? env.ringColor
                  : const Color(0xFF26354A),
              width: isActive ? 1.8 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: env.ringColor.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: env.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: env.ringColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: env.ringColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(env.iconEmoji, style: const TextStyle(fontSize: 22)),
            ),
            title: Row(
              children: [
                Text(
                  env.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: env.ringColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: env.ringColor, width: 0.8),
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
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                env.tagline,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
            trailing: isActive
                ? Icon(Icons.check_circle_rounded, color: env.ringColor, size: 24)
                : ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      controller.setEnvironment(env);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004B6E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Apply'),
                  ),
          ),
        );
      },
    );
  }
}
