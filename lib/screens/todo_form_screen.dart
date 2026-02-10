import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/doodle_colors.dart';
import '../models/todo.dart';
import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';

class TodoFormScreen extends StatefulWidget {
  const TodoFormScreen({
    super.key,
    this.todo,
    this.isDialog = false,
    this.parentId,
    this.defaultDueDate,
  });

  final Todo? todo;
  final bool isDialog;
  final String? parentId;
  final DateTime? defaultDueDate;

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Priority _priority;
  late List<String> _categoryIds;
  bool _inheritedFromParent = false;
  DateTime? _dueDate;
  DateTime? _startDate;
  bool _showStartDate = false;
  bool _showDueDate = false;
  late Recurrence _recurrence;
  List<int> _recurrenceDays = [];
  late bool _notificationEnabled;
  List<int> _reminderOffsets = [];
  late List<String> _tags;
  final _tagController = TextEditingController();
  int? _estimatedMinutes;

  // 애니메이션 컨트롤러
  late AnimationController _startDateAnimController;
  late AnimationController _dueDateAnimController;
  late Animation<double> _startDateSlideAnim;
  late Animation<double> _dueDateSlideAnim;
  late Animation<double> _startDateFadeAnim;
  late Animation<double> _dueDateFadeAnim;
  late Animation<double> _startDateScaleAnim;
  late Animation<double> _dueDateScaleAnim;

  bool get isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.todo?.description ?? '');
    _priority = widget.todo?.priority ?? Priority.medium;

    // 부모가 있으면 부모의 값을 기본값으로 상속
    if (widget.parentId != null && widget.todo == null) {
      // 새로 만드는 하위 할 일인 경우
      final todoProvider = context.read<TodoProvider>();
      final parent = todoProvider.getTodo(widget.parentId!);
      if (parent != null) {
        _categoryIds = List.from(parent.categoryIds);
        _inheritedFromParent = true;
        // 시작일/마감일도 부모에서 기본값 상속 (수정 가능)
        _startDate = parent.startDate;
        _dueDate = parent.dueDate;
      } else {
        _categoryIds = ['personal'];
        _startDate = null;
        _dueDate = null;
      }
    } else {
      // 기존 할 일 수정이거나 최상위 할 일 생성
      _categoryIds = widget.todo?.categoryIds ?? ['personal'];
      _startDate = widget.todo?.startDate;
      _dueDate = widget.todo?.dueDate ?? widget.defaultDueDate;
    }
    // 기존 데이터가 있으면 섹션 펼치기
    _showStartDate = _startDate != null;
    _showDueDate = _dueDate != null;

    // 반복 주기 초기화
    _recurrence = widget.todo?.recurrence ?? Recurrence.none;
    _recurrenceDays = widget.todo?.recurrenceDays ?? [];

    // 알림 설정 초기화
    _notificationEnabled = widget.todo?.notificationEnabled ?? true;
    _reminderOffsets = widget.todo?.reminderOffsets ?? [];

    // 태그 초기화
    _tags = widget.todo?.tags ?? [];

    // 예상 시간 초기화
    _estimatedMinutes = widget.todo?.estimatedMinutes;

    // 애니메이션 초기화
    _startDateAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _dueDateAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 슬라이드 애니메이션 (아래에서 위로)
    _startDateSlideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _startDateAnimController, curve: Curves.easeOutCubic),
    );
    _dueDateSlideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _dueDateAnimController, curve: Curves.easeOutCubic),
    );

    // 페이드 애니메이션
    _startDateFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _startDateAnimController, curve: Curves.easeOut),
    );
    _dueDateFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _dueDateAnimController, curve: Curves.easeOut),
    );

    // 스케일 애니메이션 (살짝 커지면서)
    _startDateScaleAnim = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _startDateAnimController, curve: Curves.easeOutBack),
    );
    _dueDateScaleAnim = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _dueDateAnimController, curve: Curves.easeOutBack),
    );

    // 기존 데이터가 있으면 애니메이션 완료 상태로
    if (_showStartDate) _startDateAnimController.value = 1;
    if (_showDueDate) _dueDateAnimController.value = 1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _startDateAnimController.dispose();
    _dueDateAnimController.dispose();
    super.dispose();
  }

  String _priorityLabel(Priority priority) {
    switch (priority) {
      case Priority.veryHigh:
        return '🚨 비상';
      case Priority.high:
        return '🔥 높음';
      case Priority.medium:
        return '✨ 보통';
      case Priority.low:
        return '🌿 낮음';
      case Priority.veryLow:
        return '😴 매우 낮음';
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DoodleColors.primaryLight,
              onPrimary: DoodleColors.primary,
              surface: DoodleColors.paperWhite,
              onSurface: DoodleColors.pencilDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        if (_dueDate != null) {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _dueDate!.hour,
            _dueDate!.minute,
          );
        } else {
          _dueDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueDate != null
          ? TimeOfDay(hour: _dueDate!.hour, minute: _dueDate!.minute)
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DoodleColors.primaryLight,
              onPrimary: DoodleColors.primary,
              surface: DoodleColors.paperWhite,
              onSurface: DoodleColors.pencilDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        final date = _dueDate ?? DateTime.now();
        _dueDate = DateTime(
          date.year,
          date.month,
          date.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DoodleColors.primaryLight,
              onPrimary: DoodleColors.primary,
              surface: DoodleColors.paperWhite,
              onSurface: DoodleColors.pencilDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        if (_startDate != null) {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _startDate!.hour,
            _startDate!.minute,
          );
        } else {
          _startDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _startDate != null
          ? TimeOfDay(hour: _startDate!.hour, minute: _startDate!.minute)
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DoodleColors.primaryLight,
              onPrimary: DoodleColors.primary,
              surface: DoodleColors.paperWhite,
              onSurface: DoodleColors.pencilDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        final date = _startDate ?? DateTime.now();
        _startDate = DateTime(
          date.year,
          date.month,
          date.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _showAddCategoryDialog(CategoryProvider categoryProvider) {
    final nameController = TextEditingController();
    String selectedEmoji = '📌';
    final emojis = ['📌', '💼', '🏠', '🎯', '📚', '💪', '🎨', '🎮', '🛒', '✈️', '💰', '❤️'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('새 카테고리'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 이모지 선택
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: emojis.map((emoji) {
                  final isSelected = selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedEmoji = emoji),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFA8E6CF) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: const Color(0xFF2E7D32), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 20)),
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
                  labelText: '카테고리 이름',
                  hintText: '예: 운동, 독서',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  categoryProvider.addCategory(name: name, emoji: selectedEmoji);
                  Navigator.pop(context);
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // 카테고리가 하나도 선택되지 않았으면 기본값
    if (_categoryIds.isEmpty) {
      _categoryIds = ['personal'];
    }

    final provider = context.read<TodoProvider>();

    if (isEditing) {
      provider.updateTodo(
        id: widget.todo!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        categoryIds: _categoryIds,
        dueDate: _dueDate,
        startDate: _startDate,
        recurrence: _recurrence,
        recurrenceDays: _recurrence == Recurrence.custom ? _recurrenceDays : null,
        notificationEnabled: _notificationEnabled,
        reminderOffsets: _reminderOffsets.isNotEmpty ? _reminderOffsets : null,
        tags: _tags,
        estimatedMinutes: _estimatedMinutes,
      );
    } else {
      provider.addTodo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        categoryIds: _categoryIds,
        dueDate: _dueDate,
        startDate: _startDate,
        parentId: widget.parentId,
        recurrence: _recurrence,
        recurrenceDays: _recurrence == Recurrence.custom ? _recurrenceDays : null,
        notificationEnabled: _notificationEnabled,
        reminderOffsets: _reminderOffsets.isNotEmpty ? _reminderOffsets : null,
        tags: _tags,
        estimatedMinutes: _estimatedMinutes,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDialog) {
      return Material(
        color: const Color(0xFFF0FFF4),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? '✏️ 할 일 수정' : '🌟 새 할 일',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._buildFormFields(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        title: Text(
          isEditing ? '✏️ 할 일 수정' : '🌟 새 할 일',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: _buildFormFields(),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      // 1. 제목 카드
      _buildSectionCard(
        emoji: '📝',
        title: '무엇을 해야 하나요?',
        child: TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '할 일을 입력해주세요',
            border: InputBorder.none,
            filled: false,
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '제목을 입력해주세요';
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 16),

      // 2. 시작일 토글 버튼 또는 카드
      _buildAnimatedDateSection(
        isExpanded: _showStartDate,
        animController: _startDateAnimController,
        slideAnim: _startDateSlideAnim,
        fadeAnim: _startDateFadeAnim,
        scaleAnim: _startDateScaleAnim,
        buttonEmoji: '🚀',
        buttonLabel: '시작일 추가',
        onExpand: () {
          setState(() => _showStartDate = true);
          _startDateAnimController.forward();
        },
        onCollapse: () {
          _startDateAnimController.reverse().then((_) {
            setState(() {
              _showStartDate = false;
              _startDate = null;
            });
          });
        },
        cardEmoji: '🚀',
        cardTitle: '시작일',
        cardChild: Column(
          children: [
            // 날짜 선택
            _buildDateTimeRow(
              emoji: _startDate != null ? '🗓️' : '📆',
              text: _startDate != null
                  ? '${_startDate!.year}년 ${_startDate!.month}월 ${_startDate!.day}일'
                  : '날짜를 선택해주세요',
              isSelected: _startDate != null,
              onTap: _selectStartDate,
            ),
            const SizedBox(height: 8),
            // 시간 선택
            _buildDateTimeRow(
              emoji: _startDate != null && (_startDate!.hour != 0 || _startDate!.minute != 0) ? '⏰' : '🕐',
              text: _startDate != null && (_startDate!.hour != 0 || _startDate!.minute != 0)
                  ? '${_startDate!.hour.toString().padLeft(2, '0')}:${_startDate!.minute.toString().padLeft(2, '0')}'
                  : '시간을 선택해주세요',
              isSelected: _startDate != null && (_startDate!.hour != 0 || _startDate!.minute != 0),
              onTap: _selectStartTime,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 3. 마감일 토글 버튼 또는 카드
      _buildAnimatedDateSection(
        isExpanded: _showDueDate,
        animController: _dueDateAnimController,
        slideAnim: _dueDateSlideAnim,
        fadeAnim: _dueDateFadeAnim,
        scaleAnim: _dueDateScaleAnim,
        buttonEmoji: '📅',
        buttonLabel: '마감일 추가',
        onExpand: () {
          setState(() => _showDueDate = true);
          _dueDateAnimController.forward();
        },
        onCollapse: () {
          _dueDateAnimController.reverse().then((_) {
            setState(() {
              _showDueDate = false;
              _dueDate = null;
            });
          });
        },
        cardEmoji: '📅',
        cardTitle: '마감일',
        cardChild: Column(
          children: [
            // 날짜 선택
            _buildDateTimeRow(
              emoji: _dueDate != null ? '🗓️' : '📆',
              text: _dueDate != null
                  ? '${_dueDate!.year}년 ${_dueDate!.month}월 ${_dueDate!.day}일'
                  : '날짜를 선택해주세요',
              isSelected: _dueDate != null,
              onTap: _selectDate,
            ),
            const SizedBox(height: 8),
            // 시간 선택
            _buildDateTimeRow(
              emoji: _dueDate != null && (_dueDate!.hour != 0 || _dueDate!.minute != 0) ? '⏰' : '🕐',
              text: _dueDate != null && (_dueDate!.hour != 0 || _dueDate!.minute != 0)
                  ? '${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}'
                  : '시간을 선택해주세요',
              isSelected: _dueDate != null && (_dueDate!.hour != 0 || _dueDate!.minute != 0),
              onTap: _selectTime,
            ),
            const SizedBox(height: 12),
            // 알림 설정
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _notificationEnabled
                    ? const Color(0xFFA8E6CF).withValues(alpha: 0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    _notificationEnabled ? '🔔' : '🔕',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '마감 시간에 알림',
                      style: TextStyle(
                        fontSize: 15,
                        color: _notificationEnabled ? const Color(0xFF2E7D32) : Colors.grey[500],
                        fontWeight: _notificationEnabled ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  Switch(
                    value: _notificationEnabled,
                    onChanged: (value) => setState(() => _notificationEnabled = value),
                    activeThumbColor: const Color(0xFF2E7D32),
                    activeTrackColor: const Color(0xFFA8E6CF),
                  ),
                ],
              ),
            ),
            // 사전 알림 설정
            if (_notificationEnabled) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('⏰', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          '사전 알림',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildReminderChip(10, '10분 전'),
                        _buildReminderChip(30, '30분 전'),
                        _buildReminderChip(60, '1시간 전'),
                        _buildReminderChip(1440, '1일 전'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 4. 반복 주기 카드
      _buildSectionCard(
        emoji: '🔄',
        title: '반복 설정',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildRecurrenceChip(Recurrence.none, '없음'),
                _buildRecurrenceChip(Recurrence.daily, '매일'),
                _buildRecurrenceChip(Recurrence.weekly, '매주'),
                _buildRecurrenceChip(Recurrence.monthly, '매월'),
                _buildRecurrenceChip(Recurrence.custom, '요일 선택'),
              ],
            ),
            // 요일 선택 (custom인 경우만 표시)
            if (_recurrence == Recurrence.custom) ...[
              const SizedBox(height: 16),
              const Text(
                '반복할 요일을 선택하세요',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDayChip(0, '월'),
                  _buildDayChip(1, '화'),
                  _buildDayChip(2, '수'),
                  _buildDayChip(3, '목'),
                  _buildDayChip(4, '금'),
                  _buildDayChip(5, '토'),
                  _buildDayChip(6, '일'),
                ],
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 5. 우선순위 카드
      _buildSectionCard(
        emoji: '⚡',
        title: '얼마나 급한가요?',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Priority.values.map((priority) {
            final isSelected = _priority == priority;
            return ChoiceChip(
              label: Text(_priorityLabel(priority)),
              selected: isSelected,
              onSelected: (_) => setState(() => _priority = priority),
              showCheckmark: false,
              selectedColor: const Color(0xFFA8E6CF),
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 16),

      // 5. 카테고리 카드
      Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          final categories = categoryProvider.categories;
          return _buildSectionCard(
            emoji: '📂',
            title: _inheritedFromParent ? '카테고리 (부모에서 상속)' : '어떤 종류인가요?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_inheritedFromParent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text('🔗', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '하위 할 일은 부모의 카테고리를 따릅니다',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // 카테고리 칩들
                    ...categories.map((category) {
                      final isSelected = _categoryIds.contains(category.id);
                      return FilterChip(
                        label: Text('${category.emoji} ${category.name}'),
                        selected: isSelected,
                        onSelected: _inheritedFromParent
                            ? null // 부모 상속 시 선택 불가
                            : (selected) {
                                setState(() {
                                  if (selected) {
                                    _categoryIds.add(category.id);
                                  } else {
                                    _categoryIds.remove(category.id);
                                  }
                                });
                              },
                        showCheckmark: true,
                        checkmarkColor: const Color(0xFF2E7D32),
                        selectedColor: const Color(0xFFA8E6CF),
                        backgroundColor: _inheritedFromParent
                            ? Colors.grey[200]
                            : Colors.grey[100],
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : (_inheritedFromParent ? Colors.grey[500] : Colors.grey[700]),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }),
                    // 카테고리 추가 버튼
                    if (!_inheritedFromParent)
                      ActionChip(
                        label: const Text('+ 추가'),
                        onPressed: () => _showAddCategoryDialog(categoryProvider),
                        backgroundColor: Colors.grey[100],
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 16),

      // 6. 메모 카드
      _buildSectionCard(
        emoji: '💭',
        title: '메모',
        child: TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: '추가 메모를 남겨보세요',
            border: InputBorder.none,
            filled: false,
          ),
          style: const TextStyle(fontSize: 15),
          maxLines: 3,
        ),
      ),
      const SizedBox(height: 24),

      // 예상 시간 섹션
      _buildEstimatedTimeSection(),

      const SizedBox(height: 24),

      // 태그 섹션
      _buildTagsSection(),

      const SizedBox(height: 32),

      // 저장 버튼
      FilledButton(
        onPressed: _save,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          isEditing ? '✨ 수정 완료' : '🎉 추가하기',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 32),
    ];
  }

  Widget _buildRecurrenceChip(Recurrence recurrence, String label) {
    final isSelected = _recurrence == recurrence;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _recurrence = recurrence;
          if (recurrence != Recurrence.custom) {
            _recurrenceDays = [];
          }
        });
      },
      showCheckmark: false,
      selectedColor: const Color(0xFFA8E6CF),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildDayChip(int day, String label) {
    final isSelected = _recurrenceDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _recurrenceDays.add(day);
            _recurrenceDays.sort();
          } else {
            _recurrenceDays.remove(day);
          }
        });
      },
      showCheckmark: true,
      checkmarkColor: const Color(0xFF2E7D32),
      selectedColor: const Color(0xFFA8E6CF),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildReminderChip(int minutes, String label) {
    final isSelected = _reminderOffsets.contains(minutes);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _reminderOffsets.add(minutes);
            _reminderOffsets.sort();
          } else {
            _reminderOffsets.remove(minutes);
          }
        });
      },
      showCheckmark: true,
      checkmarkColor: const Color(0xFF2E7D32),
      selectedColor: const Color(0xFFA8E6CF),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 13,
        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // 세련된 애니메이션이 적용된 날짜 섹션
  Widget _buildAnimatedDateSection({
    required bool isExpanded,
    required AnimationController animController,
    required Animation<double> slideAnim,
    required Animation<double> fadeAnim,
    required Animation<double> scaleAnim,
    required String buttonEmoji,
    required String buttonLabel,
    required VoidCallback onExpand,
    required VoidCallback onCollapse,
    required String cardEmoji,
    required String cardTitle,
    required Widget cardChild,
  }) {
    return AnimatedBuilder(
      animation: animController,
      builder: (context, _) {
        if (!isExpanded && animController.value == 0) {
          // 버튼 표시 (펼쳐지지 않은 상태)
          return _buildAddDateButton(
            emoji: buttonEmoji,
            label: buttonLabel,
            onTap: onExpand,
          );
        }

        // 카드 표시 (애니메이션 중이거나 펼쳐진 상태)
        return Transform.translate(
          offset: Offset(0, slideAnim.value),
          child: Transform.scale(
            scale: scaleAnim.value,
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: fadeAnim.value.clamp(0.0, 1.0),
              child: _buildSectionCard(
                emoji: cardEmoji,
                title: cardTitle,
                onClose: onCollapse,
                child: cardChild,
              ),
            ),
          ),
        );
      },
    );
  }

  // 날짜/시간 선택 행
  Widget _buildDateTimeRow({
    required String emoji,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA8E6CF).withValues(alpha: 0.2)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDateButton({
    required String emoji,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFA8E6CF),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA8E6CF).withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String emoji,
    required String title,
    required Widget child,
    VoidCallback? onClose,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8E6CF).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.grey[500],
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildEstimatedTimeSection() {
    return _buildSectionCard(
      emoji: '⏱️',
      title: '예상 시간',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 빠른 선택 버튼
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTimeChip(15, '15분'),
              _buildTimeChip(30, '30분'),
              _buildTimeChip(60, '1시간'),
              _buildTimeChip(120, '2시간'),
              // 직접 입력 버튼
              ActionChip(
                avatar: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: _estimatedMinutes != null &&
                          ![15, 30, 60, 120].contains(_estimatedMinutes)
                      ? Colors.white
                      : const Color(0xFF2E7D32),
                ),
                label: Text(
                  _estimatedMinutes != null &&
                          ![15, 30, 60, 120].contains(_estimatedMinutes)
                      ? _formatMinutes(_estimatedMinutes!)
                      : '직접 입력',
                  style: TextStyle(
                    fontSize: 13,
                    color: _estimatedMinutes != null &&
                            ![15, 30, 60, 120].contains(_estimatedMinutes)
                        ? Colors.white
                        : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: _estimatedMinutes != null &&
                        ![15, 30, 60, 120].contains(_estimatedMinutes)
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFA8E6CF).withValues(alpha: 0.3),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () => _showTimeInputDialog(),
              ),
            ],
          ),
          // 선택 해제 버튼
          if (_estimatedMinutes != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _estimatedMinutes = null;
                });
              },
              child: Text(
                '시간 설정 해제',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeChip(int minutes, String label) {
    final isSelected = _estimatedMinutes == minutes;
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: isSelected ? Colors.white : const Color(0xFF2E7D32),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isSelected
          ? const Color(0xFF2E7D32)
          : const Color(0xFFA8E6CF).withValues(alpha: 0.3),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () {
        setState(() {
          _estimatedMinutes = isSelected ? null : minutes;
        });
      },
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes분';
    } else if (minutes % 60 == 0) {
      return '${minutes ~/ 60}시간';
    } else {
      return '${minutes ~/ 60}시간 ${minutes % 60}분';
    }
  }

  void _showTimeInputDialog() {
    int hours = (_estimatedMinutes ?? 0) ~/ 60;
    int mins = (_estimatedMinutes ?? 0) % 60;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Text('⏱️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('예상 시간 입력'),
            ],
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 시간 선택
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      if (hours < 12) {
                        setDialogState(() => hours++);
                      }
                    },
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  Text(
                    '$hours',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const Text('시간', style: TextStyle(fontSize: 12)),
                  IconButton(
                    onPressed: () {
                      if (hours > 0) {
                        setDialogState(() => hours--);
                      }
                    },
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // 분 선택
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      if (mins < 55) {
                        setDialogState(() => mins += 5);
                      }
                    },
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  Text(
                    mins.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const Text('분', style: TextStyle(fontSize: 12)),
                  IconButton(
                    onPressed: () {
                      if (mins >= 5) {
                        setDialogState(() => mins -= 5);
                      }
                    },
                    icon: const Icon(Icons.keyboard_arrow_down),
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
              onPressed: () {
                final totalMinutes = hours * 60 + mins;
                setState(() {
                  _estimatedMinutes = totalMinutes > 0 ? totalMinutes : null;
                });
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    final todoProvider = context.read<TodoProvider>();
    final allTags = todoProvider.getAllTags();
    // 현재 입력 중인 텍스트에서 추천할 태그 필터링
    final inputText = _tagController.text.trim().toLowerCase();
    final suggestedTags = inputText.isEmpty
        ? allTags.where((tag) => !_tags.contains(tag)).take(5).toList()
        : allTags
            .where((tag) =>
                tag.toLowerCase().contains(inputText) && !_tags.contains(tag))
            .take(5)
            .toList();

    return _buildSectionCard(
      emoji: '#',
      title: '태그',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 태그 목록
          if (_tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
                  deleteIcon: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Color(0xFF2E7D32),
                  ),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          // 태그 입력 필드
          TextField(
            controller: _tagController,
            decoration: InputDecoration(
              hintText: '태그 입력 (엔터로 추가)',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.tag_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              setState(() {}); // 추천 태그 업데이트
            },
            onSubmitted: (value) {
              _addTag(value);
            },
          ),
          // 추천 태그
          if (suggestedTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              inputText.isEmpty ? '자주 쓰는 태그' : '추천 태그',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedTags.map((tag) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!_tags.contains(tag)) {
                        _tags.add(tag);
                      }
                      _tagController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _addTag(String value) {
    // # 기호 제거하고 공백 제거
    String tag = value.trim();
    if (tag.startsWith('#')) {
      tag = tag.substring(1);
    }
    tag = tag.trim();

    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    } else {
      _tagController.clear();
    }
  }
}
