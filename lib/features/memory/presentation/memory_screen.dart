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
import '../repositories/memory_repository.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository();
});

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

  String _getUid() {
    final authState = ref.read(authControllerProvider);
    if (authState is Authenticated) {
      return authState.user.uid;
    }
    return 'guest_user';
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    final uid = _getUid();
    final repo = ref.read(memoryRepositoryProvider);
    final items = await repo.getMemories(uid);

    if (mounted) {
      setState(() {
        _memories = items;
        _isLoading = false;
      });
    }
  }

  void _showAddMemoryDialog() {
    final controller = TextEditingController();
    String category = 'personal';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF101622),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF1E2838), width: 1.2),
          ),
          title: Text(
            'Add to Memory Vault 🧠',
            style: AppTypography.titleLarge.copyWith(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. User loves Marvel movies and building Flutter apps',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: const Color(0xFF758394)),
                  filled: true,
                  fillColor: const Color(0xFF090D14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF263244)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryChip('personal', 'Personal', category, (cat) => setModalState(() => category = cat)),
                  _buildCategoryChip('preference', 'Like/Fav', category, (cat) => setModalState(() => category = cat)),
                  _buildCategoryChip('work', 'Work/Study', category, (cat) => setModalState(() => category = cat)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: const Color(0xFF8895A5))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004B6E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final uid = _getUid();
                  final repo = ref.read(memoryRepositoryProvider);
                  final newItem = await repo.addMemory(
                    uid: uid,
                    content: text,
                    category: category,
                  );

                  if (mounted) {
                    setState(() {
                      _memories.insert(0, newItem);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved to Memory Vault! ✨'),
                        backgroundColor: Color(0xFF004B6E),
                      ),
                    );
                  }
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Save Memory'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String catKey, String label, String selectedCat, Function(String) onSelect) {
    final isSelected = selectedCat == catKey;
    return GestureDetector(
      onTap: () => onSelect(catKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004B6E) : const Color(0xFF1E2838),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF85BAE3) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF8895A5),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'identity':
        return Icons.badge_rounded;
      case 'preference':
        return Icons.favorite_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'study':
        return Icons.school_rounded;
      case 'location':
        return Icons.location_on_rounded;
      case 'important':
        return Icons.star_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101622),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Memory Vault 🧠',
          style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF85BAE3)),
            onPressed: _showAddMemoryDialog,
            tooltip: 'Add Memory',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF85BAE3))),
            )
          : _memories.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🧠', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 16),
                        Text(
                          'No memories stored yet',
                          style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'As you chat, Spider-Man / Hinata will automatically remember your name, likes, habits, and details here!',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(color: const Color(0xFF758394)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _showAddMemoryDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004B6E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add First Memory'),
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
                          color: const Color(0xFFBA1A1A).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5252)),
                      ),
                      onDismissed: (_) async {
                        final uid = _getUid();
                        final repo = ref.read(memoryRepositoryProvider);
                        await repo.deleteMemory(uid, item.memoryId);
                        setState(() {
                          _memories.removeAt(index);
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Memory removed.')),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101622),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E2838), width: 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF004B6E).withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(item.category),
                                color: const Color(0xFF85BAE3),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.content,
                                    style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E2838),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.category.toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF85BAE3),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppDateUtils.formatDisplay(item.createdAt),
                                        style: const TextStyle(
                                          color: Color(0xFF758394),
                                          fontSize: 10,
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
                    );
                  },
                ),
    );
  }
}
