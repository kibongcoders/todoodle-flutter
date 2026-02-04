import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/template.dart';
import '../models/todo.dart';
import '../providers/category_provider.dart';
import '../providers/template_provider.dart';
import '../providers/todo_provider.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        title: const Text(
          '템플릿',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<TemplateProvider>(
        builder: (context, templateProvider, _) {
          final templates = templateProvider.templates;

          if (templates.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _buildTemplateCard(context, template, templateProvider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'template_fab',
        onPressed: () => _showCreateTemplateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            '템플릿이 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '자주 쓰는 할일 세트를 템플릿으로 저장하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCreateTemplateDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('템플릿 만들기'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    TodoTemplate template,
    TemplateProvider templateProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showTemplateDetail(context, template),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(template.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        if (template.description != null)
                          Text(
                            template.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${template.items.length}개',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 할일 목록 미리보기
              ...template.items.take(3).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (template.items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${template.items.length - 3}개 더',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${template.useCount}회 사용',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _applyTemplate(context, template),
                    child: const Text('적용하기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplateDetail(BuildContext context, TodoTemplate template) {
    final templateProvider = context.read<TemplateProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(template.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        if (template.description != null)
                          Text(
                            template.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red[400],
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(context, template, templateProvider);
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: template.items.length,
                itemBuilder: (context, index) {
                  final item = template.items[index];
                  return _buildTemplateItemRow(context, item, index + 1);
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyTemplate(context, template);
                    },
                    child: const Text('이 템플릿으로 할일 생성'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateItemRow(
    BuildContext context,
    TemplateItem item,
    int number,
  ) {
    final categoryProvider = context.read<CategoryProvider>();
    final category = item.categoryIds.isNotEmpty
        ? categoryProvider.getCategoryById(item.categoryIds.first)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFA8E6CF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(category?.emoji ?? '📌', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.estimatedMinutes != null)
                  Text(
                    '예상 ${item.estimatedMinutes}분',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
          _buildPriorityBadge(item.priority),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(Priority priority) {
    final colors = {
      Priority.veryHigh: Colors.red,
      Priority.high: Colors.orange,
      Priority.medium: Colors.blue,
      Priority.low: Colors.green,
      Priority.veryLow: Colors.grey,
    };

    final labels = {
      Priority.veryHigh: '긴급',
      Priority.high: '높음',
      Priority.medium: '보통',
      Priority.low: '낮음',
      Priority.veryLow: '여유',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[priority]!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        labels[priority]!,
        style: TextStyle(
          fontSize: 11,
          color: colors[priority],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _applyTemplate(BuildContext context, TodoTemplate template) async {
    final templateProvider = context.read<TemplateProvider>();
    final todoProvider = context.read<TodoProvider>();

    final todos = templateProvider.getTodosFromTemplate(template.id);

    for (final todoData in todos) {
      todoProvider.addTodo(
        title: todoData['title'],
        description: todoData['description'],
        priority: todoData['priority'],
        categoryIds: todoData['categoryIds'],
        dueDate: todoData['dueDate'],
        tags: todoData['tags'],
      );
    }

    await templateProvider.incrementUseCount(template.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${template.name} 템플릿으로 ${todos.length}개 할일 생성됨'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDelete(
    BuildContext context,
    TodoTemplate template,
    TemplateProvider templateProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('템플릿 삭제'),
        content: Text('"${template.name}" 템플릿을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              templateProvider.deleteTemplate(template.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showCreateTemplateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedEmoji = '📋';
    final items = <TemplateItem>[];

    final emojis = ['📋', '💼', '🏠', '📚', '🏃', '💪', '🛒', '✈️', '🎯', '📅'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Text(
                      '새 템플릿 만들기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이모지 선택
                      const Text(
                        '아이콘',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: emojis.map((emoji) {
                          final isSelected = selectedEmoji == emoji;
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedEmoji = emoji);
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFA8E6CF)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFF2E7D32),
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // 이름 입력
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: '템플릿 이름',
                          hintText: '예: 아침 루틴',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 설명 입력
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: '설명 (선택)',
                          hintText: '예: 매일 아침에 할 일들',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 할일 항목 추가
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '할일 항목',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final item = await _showAddItemDialog(context);
                              if (item != null) {
                                setState(() => items.add(item));
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('추가'),
                          ),
                        ],
                      ),
                      if (items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '항목을 추가해주세요',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        )
                      else
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex--;
                              final item = items.removeAt(oldIndex);
                              items.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              key: ValueKey(index),
                              leading: const Icon(Icons.drag_handle),
                              title: Text(item.title),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() => items.removeAt(index));
                                },
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: items.isEmpty || nameController.text.isEmpty
                          ? null
                          : () {
                              context.read<TemplateProvider>().addTemplate(
                                    name: nameController.text,
                                    description: descController.text.isEmpty
                                        ? null
                                        : descController.text,
                                    emoji: selectedEmoji,
                                    items: items,
                                  );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('템플릿이 생성되었습니다'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      child: const Text('템플릿 저장'),
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

  Future<TemplateItem?> _showAddItemDialog(BuildContext context) async {
    final titleController = TextEditingController();
    Priority selectedPriority = Priority.medium;

    return showDialog<TemplateItem>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('할일 항목 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '할일 제목',
                  hintText: '예: 물 한잔 마시기',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('우선순위: '),
                  const SizedBox(width: 8),
                  DropdownButton<Priority>(
                    value: selectedPriority,
                    items: Priority.values.map((p) {
                      final labels = {
                        Priority.veryHigh: '긴급',
                        Priority.high: '높음',
                        Priority.medium: '보통',
                        Priority.low: '낮음',
                        Priority.veryLow: '여유',
                      };
                      return DropdownMenuItem(
                        value: p,
                        child: Text(labels[p]!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedPriority = value);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: titleController.text.isEmpty
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        TemplateItem(
                          title: titleController.text,
                          priority: selectedPriority,
                        ),
                      );
                    },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}
