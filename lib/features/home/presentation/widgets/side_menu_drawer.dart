import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hinata_ai/app/theme/app_colors.dart';
import 'package:hinata_ai/app/theme/app_typography.dart';
import 'package:hinata_ai/app/theme/app_radius.dart';
import 'package:hinata_ai/app/theme/app_shadows.dart';
import 'package:hinata_ai/features/auth/controllers/auth_controller.dart';
import 'package:hinata_ai/features/auth/controllers/auth_state.dart';
import 'package:hinata_ai/features/auth/presentation/login_screen.dart';
import 'package:hinata_ai/features/chat/presentation/chat_history_screen.dart';
import 'package:hinata_ai/features/memory/presentation/memory_screen.dart';
import 'package:hinata_ai/features/diary/presentation/diary_screen.dart';
import 'package:hinata_ai/features/settings/presentation/settings_screen.dart';
import 'package:hinata_ai/features/character/presentation/wardrobe_sheet.dart';

/// Clean glassmorphic side menu drawer ("Three lines" system)
class SideMenuDrawer extends ConsumerWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState is Authenticated ? authState.user : null;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.82,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundDeep.withValues(alpha: 0.95),
          border: const Border(right: BorderSide(color: AppColors.borderSubtle, width: 1)),
          boxShadow: const [AppShadows.ambientGlow],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceCard,
                        border: Border.all(color: AppColors.primary, width: 2),
                        boxShadow: const [AppShadows.neonViolet],
                        image: user?.photoUrl != null
                            ? DecorationImage(image: NetworkImage(user!.photoUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: user?.photoUrl == null
                          ? const Text('👤', style: TextStyle(fontSize: 26))
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Alex',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cloud Synced',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primaryLight,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.borderSubtle, height: 1),

              const SizedBox(height: 12),

              // Menu Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _drawerTile(
                      icon: Icons.checkroom_rounded,
                      title: 'Hero Wardrobe & Stage',
                      subtitle: 'Suits, nanotech & stage backdrops',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).pop();
                        WardrobeBottomSheet.show(context);
                      },
                    ),
                    _drawerTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Chat History',
                      subtitle: 'Daily conversation archives',
                      color: AppColors.primaryLight,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
                        );
                      },
                    ),
                    _drawerTile(
                      icon: Icons.psychology_outlined,
                      title: 'Memory Vault',
                      subtitle: 'Things Hinata remembers about you',
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MemoryScreen()),
                        );
                      },
                    ),
                    _drawerTile(
                      icon: Icons.book_outlined,
                      title: 'Companion Diary',
                      subtitle: 'Daily moods & recorded logs',
                      color: AppColors.secondaryLight,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DiaryScreen()),
                        );
                      },
                    ),
                    _drawerTile(
                      icon: Icons.tune_rounded,
                      title: 'Settings & Personality',
                      subtitle: 'Voice, Gemini API key, behavior',
                      color: AppColors.textSecondary,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Sign Out
              Padding(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  borderRadius: AppRadius.roundedFull,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: AppRadius.roundedFull,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard.withValues(alpha: 0.6),
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
