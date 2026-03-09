import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:life_tracker/dialogs/courage_dialog.dart';
import 'package:life_tracker/dialogs/exercise_dialog.dart';
import 'package:life_tracker/dialogs/expense_dialog.dart';
import 'package:life_tracker/dialogs/review_dialog.dart';
import 'package:life_tracker/models/record.dart';
import 'package:life_tracker/models/todo_item.dart';
import 'package:life_tracker/providers/data_provider.dart';
import 'package:life_tracker/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(DateTime.now()),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const _WorkWeekProgress(),
                ],
              ),
            ),
          ),
          // Habit cards section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _SectionHeader(title: '今日习惯'),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _HabitCards(),
            ),
          ),
          // Today's todos section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _TodoSection(),
            ),
          ),
          // Long-term goals section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _LongTermSection(),
            ),
          ),
          // Timeline section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: _SectionHeader(title: '时间流'),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _Timeline(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${dt.month}月${dt.day}日 ${weekdays[dt.weekday - 1]}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
    );
  }
}

class _WorkWeekProgress extends StatelessWidget {
  const _WorkWeekProgress();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('做四休三', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38)),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0,
              minHeight: 4,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emeraldGreen),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('0/4', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38)),
      ],
    );
  }
}

// ─── Momo-style Habit Cards ───────────────────────────────────────────────────

class _HabitCards extends StatelessWidget {
  const _HabitCards();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final counts = provider.courageCounts;
    final waterCount = provider.todayWaterCount;
    final mindfulnessCount = provider.todayMindfulnessCount;
    final exerciseCount = provider.todayExerciseCount;

    return Column(
      children: [
        _HabitCard(
          icon: Icons.water_drop,
          iconBgColor: const Color(0xFF1976D2),
          label: '喝水',
          countLabel: '×$waterCount',
          onTap: () => _addRecord(context, RecordType.water, {}),
        ),
        _HabitCard(
          icon: Icons.self_improvement,
          iconBgColor: const Color(0xFF00796B),
          label: '正念',
          countLabel: '×$mindfulnessCount',
          onTap: () => _addRecord(context, RecordType.mindfulness, {}),
        ),
        _HabitCard(
          icon: Icons.directions_run,
          iconBgColor: const Color(0xFFE65100),
          label: '运动',
          countLabel: '×$exerciseCount',
          onTap: () => ExerciseDialog.show(
            context,
            context.read<DataProvider>().addRecord,
          ),
        ),
        _HabitCard(
          icon: Icons.block,
          iconBgColor: const Color(0xFFC62828),
          label: '拒绝挑战',
          countLabel: '${counts[CourageType.rejection] ?? 0}/100',
          onTap: () => CourageDialog.show(
            context,
            CourageType.rejection,
            context.read<DataProvider>().addRecord,
          ),
        ),
        _HabitCard(
          icon: Icons.explore,
          iconBgColor: const Color(0xFFF9A825),
          label: '新事物',
          countLabel: '${counts[CourageType.newThing] ?? 0}/100',
          onTap: () => CourageDialog.show(
            context,
            CourageType.newThing,
            context.read<DataProvider>().addRecord,
          ),
        ),
        _HabitCard(
          icon: Icons.feedback_outlined,
          iconBgColor: const Color(0xFFBF360C),
          label: '负反馈',
          countLabel: '${counts[CourageType.negativeFeedback] ?? 0}/100',
          onTap: () => CourageDialog.show(
            context,
            CourageType.negativeFeedback,
            context.read<DataProvider>().addRecord,
          ),
        ),
        _HabitCard(
          icon: Icons.account_balance_wallet,
          iconBgColor: const Color(0xFFF57F17),
          label: '记账',
          onTap: () => ExpenseDialog.show(
            context,
            context.read<DataProvider>().addRecord,
          ),
        ),
        _HabitCard(
          icon: Icons.replay,
          iconBgColor: const Color(0xFF4527A0),
          label: '即时复盘',
          onTap: () => ReviewDialog.show(
            context,
            context.read<DataProvider>().addRecord,
          ),
        ),
      ],
    );
  }

  void _addRecord(
    BuildContext context,
    RecordType type,
    Map<String, dynamic> data,
  ) {
    context.read<DataProvider>().addRecord(Record(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          type: type,
          origin: RecordOrigin.spontaneous,
          data: data,
        ));
  }
}

class _HabitCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String label;
  final String? countLabel;
  final VoidCallback onTap;

  const _HabitCard({
    required this.icon,
    required this.iconBgColor,
    required this.label,
    required this.onTap,
    this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Left: colored circle with icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                // Center: label
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Right: count label
                if (countLabel != null)
                  Text(
                    countLabel!,
                    style: const TextStyle(
                      color: AppTheme.emeraldGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Today's Todos ────────────────────────────────────────────────────────────

class _TodoSection extends StatelessWidget {
  const _TodoSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final todos = provider.todayTodos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '今日计划',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showAddTodoDialog(context, isLongTerm: false),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppTheme.emeraldGreen, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (todos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '还没有今日计划，点 + 添加',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white24),
            ),
          )
        else
          ...todos.map((todo) => _TodoCard(todo: todo)),
      ],
    );
  }

  void _showAddTodoDialog(BuildContext context, {required bool isLongTerm}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddTodoSheet(
        isLongTerm: isLongTerm,
        onSubmit: (todo) => context.read<DataProvider>().addTodo(todo),
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  final TodoItem todo;

  const _TodoCard({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.read<DataProvider>().toggleTodo(todo.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Left: checkbox circle
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: todo.isCompleted
                        ? AppTheme.emeraldGreen
                        : Colors.transparent,
                    border: todo.isCompleted
                        ? null
                        : Border.all(color: Colors.white38, width: 1.5),
                  ),
                  child: todo.isCompleted
                      ? const Icon(Icons.check, color: Colors.black, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                // Center: title + time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          color: todo.isCompleted ? Colors.white38 : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: Colors.white38,
                        ),
                      ),
                      if (todo.targetTime != null)
                        Text(
                          _fmt(todo.targetTime!),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Right: category emoji
                Text(
                  todo.category.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

// ─── Long-term Goals ──────────────────────────────────────────────────────────

class _LongTermSection extends StatefulWidget {
  const _LongTermSection();

  @override
  State<_LongTermSection> createState() => _LongTermSectionState();
}

class _LongTermSectionState extends State<_LongTermSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final goals = provider.getLongTermTodos();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '长期目标',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showAddGoalDialog(context),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.plannedColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: AppTheme.plannedColor, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white38,
              ),
            ),
          ],
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '还没有长期目标，点 + 添加',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white24),
              ),
            )
          else
            ...goals.map((goal) => _LongTermGoalCard(goal: goal)),
        ],
      ],
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddTodoSheet(
        isLongTerm: true,
        onSubmit: (todo) => context.read<DataProvider>().addTodo(todo),
      ),
    );
  }
}

class _LongTermGoalCard extends StatelessWidget {
  final TodoItem goal;

  const _LongTermGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.read<DataProvider>().toggleTodo(goal.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goal.isCompleted
                        ? AppTheme.emeraldGreen
                        : Colors.transparent,
                    border: goal.isCompleted
                        ? null
                        : Border.all(color: AppTheme.plannedColor, width: 1.5),
                  ),
                  child: goal.isCompleted
                      ? const Icon(Icons.check, color: Colors.black, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: TextStyle(
                          color: goal.isCompleted ? Colors.white38 : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.white38,
                        ),
                      ),
                      if (goal.streak > 0)
                        Text(
                          '连续 ${goal.streak} 天',
                          style: const TextStyle(
                            color: AppTheme.emeraldGreen,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  goal.category.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Add Todo Bottom Sheet ────────────────────────────────────────────────────

class _AddTodoSheet extends StatefulWidget {
  final bool isLongTerm;
  final void Function(TodoItem) onSubmit;

  const _AddTodoSheet({required this.isLongTerm, required this.onSubmit});

  @override
  State<_AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<_AddTodoSheet> {
  final _titleController = TextEditingController();
  GoalCategory _selectedCategory = GoalCategory.other;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isLongTerm ? '添加长期目标' : '添加今日计划',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 20),
            // Title input
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.isLongTerm ? '目标名称' : '任务名称',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF162030),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            // Time picker (only for today's tasks)
            if (!widget.isLongTerm) ...[
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedTime = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162030),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : '目标时间（可选）',
                        style: TextStyle(
                          color: _selectedTime != null ? Colors.white : Colors.white38,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Category picker
            Text('分类', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GoalCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.emeraldGreen.withValues(alpha: 0.2)
                          : const Color(0xFF162030),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.emeraldGreen : Colors.white12,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      '${cat.emoji} ${cat.label}',
                      style: TextStyle(
                        color: isSelected ? AppTheme.emeraldGreen : Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写任务名称')),
      );
      return;
    }

    DateTime? targetTime;
    if (_selectedTime != null) {
      final now = DateTime.now();
      targetTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    widget.onSubmit(TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      targetTime: targetTime,
      category: _selectedCategory,
      createdAt: DateTime.now(),
      isLongTerm: widget.isLongTerm,
    ));

    Navigator.of(context).pop();
  }
}

// ─── Timeline ─────────────────────────────────────────────────────────────────

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    final allRecords = context.watch<DataProvider>().todayRecords;

    if (allRecords.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            '今天还没有记录，开始吧！',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white24),
          ),
        ),
      );
    }

    return Column(
      children: allRecords
          .where((r) => r.type != RecordType.todo)
          .map((r) => _buildTimelineCard(context, r))
          .toList(),
    );
  }

  Widget _buildTimelineCard(BuildContext context, Record r) {
    final isPlanned = r.origin == RecordOrigin.planned;
    final barColor = isPlanned ? AppTheme.plannedColor : AppTheme.spontaneousColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Left: colored bar
              Container(
                width: 3,
                height: 36,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Time
              SizedBox(
                width: 80,
                child: Text(
                  _timeLabel(r),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Text(
                  _recordLabel(r),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeLabel(Record r) {
    if (r.type == RecordType.review) {
      final start = r.data['startTime'] as DateTime?;
      final end = r.data['endTime'] as DateTime?;
      if (start != null && end != null) {
        return '${_fmt(start)}~${_fmt(end)}';
      }
    }
    return _fmt(r.timestamp);
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _recordLabel(Record r) {
    switch (r.type) {
      case RecordType.water:
        return '喝水';
      case RecordType.mindfulness:
        return '正念';
      case RecordType.exercise:
        final exerciseType = r.data['exerciseType'] as String?;
        final duration = r.data['duration'] as int?;
        if (exerciseType != null && duration != null) {
          return '$exerciseType (${duration}min)';
        } else if (exerciseType != null) {
          return exerciseType;
        }
        return '运动';
      case RecordType.courage:
        final ct = r.data['courageType'] as CourageType?;
        final desc = r.data['description'] as String?;
        if (ct != null && desc != null) return '${ct.label}: $desc';
        if (ct != null) return ct.label;
        return '勇气';
      case RecordType.expense:
        final cat = r.data['expenseCategory'] as ExpenseCategory?;
        final amount = r.data['amount'] as num?;
        return '${cat?.label ?? '支出'} ¥${amount?.toStringAsFixed(2) ?? ''}';
      case RecordType.income:
        final cat = r.data['incomeCategory'] as IncomeCategory?;
        final amount = r.data['amount'] as num?;
        return '${cat?.label ?? '收入'} ¥${amount?.toStringAsFixed(2) ?? ''}';
      case RecordType.review:
        final what = r.data['what'] as String? ?? '复盘';
        return what;
      case RecordType.todo:
        return r.data['title'] as String? ?? '任务';
    }
  }
}
