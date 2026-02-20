import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';
import '../shared/widgets/doodle_icon.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        title: const Text(
          '🏷️ 카테고리 관리',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const DoodleIcon(type: DoodleIconType.arrowBack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          final categories = provider.categories;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == categories.length) {
                return _buildAddCategoryButton(context);
              }
              final category = categories[index];
              return _CategoryItem(category: category);
            },
          );
        },
      ),
    );
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => const _CategoryFormDialog(),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFA8E6CF),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const DoodleIcon(type: DoodleIconType.add, color: Color(0xFF2E7D32), size: 28),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category});

  final TodoCategoryModel category;

  @override
  Widget build(BuildContext context) {
    final canDelete = context.read<CategoryProvider>().canDelete(category.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(
          category.emoji,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        subtitle: category.isDefault
            ? const Text(
                '기본 카테고리',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const DoodleIcon(type: DoodleIconType.edit, color: Color(0xFF2E7D32)),
              onPressed: () => _showEditDialog(context),
            ),
            if (canDelete)
              IconButton(
                icon: const DoodleIcon(type: DoodleIconType.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(context),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(category: category),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('카테고리 삭제'),
        content: Text(
          '"${category.emoji} ${category.name}" 카테고리를 삭제하시겠습니까?\n\n이 카테고리의 할 일도 함께 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TodoProvider>().deleteTodosByCategory(category.id);
              context.read<CategoryProvider>().deleteCategory(category.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.category});

  final TodoCategoryModel? category;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late TextEditingController _nameController;
  String _selectedEmoji = '📌';

  final List<String> _emojis = [
    '📌', '💼', '🏠', '🛒', '💪', '📚', '💰', '✈️', '🍽️', '🎬',
    '👨‍👩‍👧', '👫', '🎨', '🏃', '🤝', '📋', '⏰', '📅', '🔔', '🎯',
    '🎮', '🎵', '📷', '🌱', '🐕', '🚗', '💻', '📱', '🎁', '❤️',
    '⭐', '🔥', '💡', '🎪', '🏆', '🎓', '💊', '🏡', '🌈', '☕',
  ];

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedEmoji = widget.category?.emoji ?? '📌';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEditing ? '✏️ 카테고리 수정' : '🆕 새 카테고리'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '카테고리 이름',
                hintText: '예: 업무, 개인, 쇼핑',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '이모지 선택',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: _emojis.length,
                itemBuilder: (context, index) {
                  final emoji = _emojis[index];
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFA8E6CF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEditing ? '수정' : '추가'),
        ),
      ],
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리 이름을 입력해주세요')),
      );
      return;
    }

    final provider = context.read<CategoryProvider>();

    if (isEditing) {
      provider.updateCategory(
        id: widget.category!.id,
        name: name,
        emoji: _selectedEmoji,
      );
    } else {
      provider.addCategory(
        name: name,
        emoji: _selectedEmoji,
      );
    }

    Navigator.pop(context);
  }
}
