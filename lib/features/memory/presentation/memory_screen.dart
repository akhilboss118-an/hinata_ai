import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../models/memory_item.dart';

/// Memory Vault screen allowing users to view, manage, and delete long-term companion memories
class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  List<MemoryItem> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    // Memory loading will use Firestore once Firebase is configured.
    // For now, showing empty list.
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddMemoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text('Add Memory', style: AppTypography.titleLarge),
        content: TextField(
          controller: controller,
          style: AppTypography.bodyMedium,
          decoration: const InputDecoration(
            hintText: 'e.g. User loves building mobile apps with Flutter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                // Will save to Firestore once Firebase is configured
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memory will be saved once Firebase is connected')),
                );
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save Memory'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Memory Vault', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLight),
            onPressed: _showAddMemoryDialog,
            tooltip: 'Add Memory',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)),
            )
          : _memories.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🧠', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No memories stored yet',
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'As you chat with Hinata, important facts and preferences will automatically be remembered here!',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _memories.length,
                  itemBuilder: (context, index) {
                    final item = _memories[index];
                    return Dismissible(
                      key: Key(item.memoryId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.2),
                          borderRadius: AppRadius.roundedMd,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      ),
                      onDismissed: (_) async {
                        setState(() {
                          _memories.removeAt(index);
                        });
                      },
                      child: GlassCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        borderRadius: AppRadius.roundedMd,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.primaryLight,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.content,
                                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Saved on ${AppDateUtils.formatDisplay(item.createdAt)}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textDisabled,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
