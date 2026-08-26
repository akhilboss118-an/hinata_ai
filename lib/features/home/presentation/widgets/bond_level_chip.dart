import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../character/models/affinity_state.dart';

/// Top Bar HUD Chip displaying current Bond Level, XP progress bar,
/// and interactive modal with unlocked perks and streaks
class BondLevelChip extends StatelessWidget {
  final AffinityState affinity;

  const BondLevelChip({super.key, required this.affinity});

  void _showBondDetailsModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BondDetailsSheet(affinity: affinity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = affinity.currentTier;
    final progress = affinity.progressToNextLevel;

    return InkWell(
      onTap: () => _showBondDetailsModal(context),
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF101622).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: tier.themeColor.withValues(alpha: 0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: tier.themeColor.withValues(alpha: 0.20),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tier.badgeEmoji,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 5),
            Text(
              'LVL ${affinity.currentLevel}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: tier.themeColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 24,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation(tier.themeColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BondDetailsSheet extends StatelessWidget {
  final AffinityState affinity;

  const _BondDetailsSheet({required this.affinity});

  @override
  Widget build(BuildContext context) {
    final tier = affinity.currentTier;
    final next = affinity.nextTier;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1320).withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: tier.themeColor.withValues(alpha: 0.35)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Level Header
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tier.themeColor.withValues(alpha: 0.15),
                        border: Border.all(color: tier.themeColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: tier.themeColor.withValues(alpha: 0.4),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(tier.badgeEmoji, style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Level ${affinity.currentLevel}: ',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                tier.title,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: tier.themeColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Streak: ${affinity.interactionStreak} Days Active 🔥',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF85BAE3)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // XP Progress Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141C2B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF26354A)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Affinity XP Progress',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            next != null
                                ? '${affinity.totalXp} / ${next.xpRequired} XP'
                                : '${affinity.totalXp} XP (MAX TIER)',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tier.themeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: affinity.progressToNextLevel,
                          backgroundColor: const Color(0xFF1E293B),
                          valueColor: AlwaysStoppedAnimation(tier.themeColor),
                          minHeight: 8,
                        ),
                      ),
                      if (next != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${affinity.xpToNextLevel} XP needed for Level ${next.level} (${next.title})',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Unlocked Perk
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141C2B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tier.themeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: tier.themeColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unlocked Bond Perk',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tier.perkUnlocked,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // How to Earn XP
                Text(
                  '💡 How to level up faster:',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '• Chat with Spider-Man (+15 XP)\n• Share photos & camera shots (+20 XP)\n• Pat & interact with 3D character (+8 XP)\n• Equip new suits & environments (+15 XP)',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    height: 1.5,
                    color: const Color(0xFF94A3B8),
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
