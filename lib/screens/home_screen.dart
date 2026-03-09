import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:life_tracker/dialogs/courage_dialog.dart';
import 'package:life_tracker/dialogs/exercise_dialog.dart';
import 'package:life_tracker/dialogs/expense_dialog.dart';
import 'package:life_tracker/dialogs/review_dialog.dart';
import 'package:life_tracker/dialogs/todo_dialog.dart';
import 'package:life_tracker/models/record.dart';
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(DateTime.now()),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const _WorkWeekProgress(),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _QuickActions(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                '时间流',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
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

class _WorkWeekProgress extends StatelessWidget {
  const _WorkWeekProgress();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('做四休三', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('0/4', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final counts = provider.courageCounts;
    final waterCount = provider.todayWaterCount;
    final mindfulnessCount = provider.todayMindfulnessCount;
    final exerciseCount = provider.todayExerciseCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Row 1: 喝水, 正念, 运动
            _buildRow([
              _ActionButton(
                icon: Icons.water_drop,
                label: '喝水',
                sublabel: waterCount > 0 ? '×$waterCount' : null,
                gradientColors: const [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                onTap: () => _addRecord(context, RecordType.water, {}),
              ),
              _ActionButton(
                icon: Icons.self_improvement,
                label: '正念',
                sublabel: mindfulnessCount > 0 ? '×$mindfulnessCount' : null,
                gradientColors: const [Color(0xFF81C784), Color(0xFF388E3C)],
                onTap: () => _addRecord(context, RecordType.mindfulness, {}),
              ),
              _ActionButton(
                icon: Icons.directions_run,
                label: '运动',
                sublabel: exerciseCount > 0 ? '×$exerciseCount' : null,
                gradientColors: const [Color(0xFFFFB74D), Color(0xFFF57C00)],
                onTap: () => ExerciseDialog.show(
                  context,
                  context.read<DataProvider>().addRecord,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            // Row 2: 拒绝, 新事物, 负反馈
            _buildRow([
              _ActionButton(
                icon: Icons.block,
                label: '拒绝',
                sublabel: '${counts[CourageType.rejection] ?? 0}/100',
                gradientColors: const [Color(0xFFEF9A9A), Color(0xFFE53935)],
                onTap: () => CourageDialog.show(
                  context,
                  CourageType.rejection,
                  context.read<DataProvider>().addRecord,
                ),
              ),
              _ActionButton(
                icon: Icons.explore,
                label: '新事物',
                sublabel: '${counts[CourageType.newThing] ?? 0}/100',
                gradientColors: const [Color(0xFFFFF176), Color(0xFFFBC02D)],
                onTap: () => CourageDialog.show(
                  context,
                  CourageType.newThing,
                  context.read<DataProvider>().addRecord,
                ),
              ),
              _ActionButton(
                icon: Icons.feedback_outlined,
                label: '负反馈',
                sublabel: '${counts[CourageType.negativeFeedback] ?? 0}/100',
                gradientColors: const [Color(0xFFF48FB1), Color(0xFFD81B60)],
                onTap: () => CourageDialog.show(
                  context,
                  CourageType.negativeFeedback,
                  context.read<DataProvider>().addRecord,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            // Row 3: 记账, 即时复盘, 添加计划
            _buildRow([
              _ActionButton(
                icon: Icons.account_balance_wallet,
                label: '记账',
                gradientColors: const [Color(0xFFFFD54F), Color(0xFFFFA000)],
                onTap: () => ExpenseDialog.show(
                  context,
                  context.read<DataProvider>().addRecord,
                ),
              ),
              _ActionButton(
                icon: Icons.replay,
                label: '即时复盘',
                gradientColors: const [Color(0xFF7986CB), Color(0xFF3949AB)],
                onTap: () => ReviewDialog.show(
                  context,
                  context.read<DataProvider>().addRecord,
                ),
              ),
              _ActionButton(
                icon: Icons.add_task,
                label: '添加计划',
                gradientColors: const [Color(0xFF80CBC4), Color(0xFF00897B)],
                onTap: () => TodoDialog.show(
                  context,
                  context.read<DataProvider>().addRecord,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> buttons) {
    return Row(
      children: buttons.map((b) => Expanded(child: b)).toList(),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.last.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            if (sublabel != null)
              Text(
                sublabel!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white38,
                    ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

/// 时间流 - 展示今日记录，蓝线=计划内，橙线=即兴
class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    final allRecords = context.watch<DataProvider>().todayRecords;

    // Separate uncompleted todos from other records — they go to the bottom
    final mainRecords = allRecords
        .where((r) => !(r.type == RecordType.todo && r.data['completed'] != true))
        .toList();
    final uncompletedTodos = allRecords
        .where((r) => r.type == RecordType.todo && r.data['completed'] != true)
        .toList();

    if (mainRecords.isEmpty && uncompletedTodos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            '今天还没有记录，开始吧！',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white38),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...mainRecords.map((r) => _buildRow(context, r)),
        if (uncompletedTodos.isNotEmpty) ...[
          if (mainRecords.isNotEmpty) const SizedBox(height: 4),
          ...uncompletedTodos.map((r) => _buildTodoRow(context, r, completed: false)),
        ],
      ],
    );
  }

  Widget _buildRow(BuildContext context, Record r) {
    if (r.type == RecordType.todo) {
      return _buildTodoRow(context, r, completed: true);
    }

    final color = r.origin == RecordOrigin.planned
        ? AppTheme.plannedColor
        : AppTheme.spontaneousColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              _timeLabel(r),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white54),
            ),
          ),
          Container(
            width: 4,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(_recordLabel(r)),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoRow(BuildContext context, Record r, {required bool completed}) {
    final title = r.data['title'] as String? ?? '任务';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              _todoTimeLabel(r),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: completed ? Colors.white54 : Colors.white24,
                  ),
            ),
          ),
          Container(
            width: 4,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: completed
                  ? AppTheme.plannedColor
                  : AppTheme.plannedColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: completed,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: (_) {
                final updated = Record(
                  id: r.id,
                  timestamp: r.timestamp,
                  type: r.type,
                  origin: r.origin,
                  data: {...r.data, 'completed': !completed},
                );
                context.read<DataProvider>().updateRecord(updated);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: completed ? Colors.white70 : Colors.white38,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _todoTimeLabel(Record r) {
    final targetTime = r.data['targetTime'] as DateTime?;
    if (targetTime != null) return _fmt(targetTime);
    return '计划';
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
        return '💧 喝水';
      case RecordType.mindfulness:
        return '🧘 正念';
      case RecordType.exercise:
        final exerciseType = r.data['exerciseType'] as String?;
        final duration = r.data['duration'] as int?;
        if (exerciseType != null && duration != null) {
          return '🏃 $exerciseType (${duration}min)';
        } else if (exerciseType != null) {
          return '🏃 $exerciseType';
        }
        return '🏃 运动';
      case RecordType.courage:
        final ct = r.data['courageType'] as CourageType?;
        final desc = r.data['description'] as String?;
        if (ct != null && desc != null) return '${ct.emoji} $desc';
        if (ct != null) return '${ct.emoji} ${ct.label}';
        return '💪 勇气';
      case RecordType.expense:
        final cat = r.data['expenseCategory'] as ExpenseCategory?;
        final amount = r.data['amount'] as num?;
        return '💸 ${cat?.emoji ?? ''} ${cat?.label ?? '支出'} ¥${amount?.toStringAsFixed(2) ?? ''}'
            .trim();
      case RecordType.income:
        final cat = r.data['incomeCategory'] as IncomeCategory?;
        final amount = r.data['amount'] as num?;
        return '💰 ${cat?.emoji ?? ''} ${cat?.label ?? '收入'} ¥${amount?.toStringAsFixed(2) ?? ''}'
            .trim();
      case RecordType.review:
        final what = r.data['what'] as String? ?? '复盘';
        final cats = (r.data['categories'] as List?)
                ?.whereType<GoalCategory>()
                .map((c) => c.emoji)
                .join(' ') ??
            '';
        return '🔄 $what $cats'.trim();
      case RecordType.todo:
        return '📋 ${r.data['title'] ?? '任务'}';
    }
  }
}
