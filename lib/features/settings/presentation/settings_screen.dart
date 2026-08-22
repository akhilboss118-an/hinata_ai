import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_radius.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../auth/presentation/login_screen.dart';
import '../../memory/presentation/memory_screen.dart';
import '../../chat/presentation/chat_history_screen.dart';
import '../models/user_settings.dart';

final userSettingsProvider = StateProvider<UserSettings>((ref) {
  return const UserSettings();
});

/// Settings Screen for Account, Companion Personality, Voice, and Storage management
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final settings = ref.watch(userSettingsProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final userProfile = authState is Authenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Settings', style: AppTypography.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Account Section
          _sectionHeader('ACCOUNT'),
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: AppRadius.roundedLg,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    userProfile?.displayName.isNotEmpty == true
                        ? userProfile!.displayName[0].toUpperCase()
                        : 'U',
                    style: AppTypography.titleLarge.copyWith(color: AppColors.primaryLight),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile?.displayName ?? 'Guest User',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userProfile?.email ?? 'No email linked',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Companion Personality Section
          _sectionHeader('COMPANION PERSONALITY'),
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: AppRadius.roundedLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sliderTile(
                  label: 'Kindness',
                  value: settings.kindness,
                  onChanged: (v) => ref.read(userSettingsProvider.notifier).state =
                      UserSettings(kindness: v),
                ),
                _sliderTile(
                  label: 'Playfulness',
                  value: settings.playfulness,
                  onChanged: (v) => ref.read(userSettingsProvider.notifier).state =
                      UserSettings(playfulness: v),
                ),
                _sliderTile(
                  label: 'Shyness',
                  value: settings.shyness,
                  onChanged: (v) => ref.read(userSettingsProvider.notifier).state =
                      UserSettings(shyness: v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cloud Memory & Storage
          _sectionHeader('DATA & MEMORIES'),
          GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: AppRadius.roundedLg,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.psychology_rounded, color: AppColors.primaryLight),
                  title: Text('Memory Vault', style: AppTypography.bodyMedium),
                  subtitle: Text('Manage facts Hinata remembered', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MemoryScreen()),
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1),
                ListTile(
                  leading: const Icon(Icons.forum_rounded, color: AppColors.primaryLight),
                  title: Text('Chat History', style: AppTypography.bodyMedium),
                  subtitle: Text('View date-grouped conversations', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sign Out Button
          ElevatedButton.icon(
            onPressed: () async {
              await authController.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.roundedFull,
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primaryLight,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sliderTile({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.bodyMedium),
              Text('${(value * 100).toInt()}%', style: AppTypography.bodySmall.copyWith(color: AppColors.primaryLight)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.borderSubtle,
              thumbColor: AppColors.primaryLight,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
