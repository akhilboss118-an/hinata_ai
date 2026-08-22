import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../auth/controllers/auth_state.dart';
import '../../../character/engine/character_controller.dart';
import '../../../auth/presentation/login_screen.dart';

/// Top bar displaying Companion status, Affection level, and User Profile
class CompanionHeader extends ConsumerWidget {
  const CompanionHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final characterState = ref.watch(characterControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final userProfile = authState is Authenticated ? authState.user : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          // Hinata Avatar & Online Status
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceCard,
              border: Border.all(color: AppColors.primaryLight, width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Text('💙', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),

          // Name and Status Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      AppConstants.defaultCharacterName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.statusOnline,
                      ),
                    ),
                  ],
                ),
                Text(
                  userProfile != null ? 'Companion to ${userProfile.displayName}' : 'AI Companion',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Affection Heart Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: AppRadius.roundedFull,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('❤️', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  'Lv.${characterState.affectionLevel}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Profile / Logout Popup Menu
          PopupMenuButton<String>(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceCard,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            color: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.roundedMd,
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context, authController);
              }
            },
            itemBuilder: (context) => [
              if (userProfile != null)
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile.displayName,
                        style: AppTypography.titleMedium.copyWith(fontSize: 14),
                      ),
                      Text(
                        userProfile.email,
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                      const Divider(color: AppColors.divider),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Sign Out',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text('Sign Out', style: AppTypography.headline),
        content: Text(
          'Are you sure you want to sign out? Your chats and memories will remain safely synced in the cloud.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await controller.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
