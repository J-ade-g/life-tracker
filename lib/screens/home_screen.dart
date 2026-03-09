import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:life_tracker/dialogs/expense_dialog.dart';
import 'package:life_tracker/dialogs/review_dialog.dart';
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
          // 顶部日期 + 做四休三进度
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
          // 快捷操作卡片
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _QuickActions(),
            ),
          ),
          // 时间流
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 第一行：喝水、正念、运动
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  emoji: '💧',
                  label: waterCount > 0 ? '喝水 ×$waterCount' : '喝水',
                  onTap: () => _addRecord(
                    context,
                    RecordType.water,
                    {},
                  ),
                ),
                _ActionButton(
                  emoji: '🧘',
                  label: mindfulnessCount > 0
                      ? '正念 ×$mindfulnessCount'
                      : '正念',
                  onTap: () => _addRecord(
                    context,
                    RecordType.mindfulness,
                    {},
                  ),
                ),
                _ActionButton(
                  emoji: '🏃',
                  label: '运动',
                  onTap: () => _addRecord(
                    context,
                    RecordType.exercise,
                    {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 第二行：勇气三件套
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  emoji: '🔴',
                  label: '拒绝 ${counts[CourageType.rejection] ?? 0}',
                  onTap: () => _addRecord(
                    context,
                    RecordType.courage,
                    {'courageType': CourageType.rejection},
                  ),
                ),
                _ActionButton(
                  emoji: '🟡',
                  label: '新事物 ${counts[CourageType.newThing] ?? 0}',
                  onTap: () => _addRecord(
                    context,
                    RecordType.courage,
                    {'courageType': CourageType.newThing},
                  ),
                ),
                _ActionButton(
                  emoji: '🟠',
                  label: '负反馈 ${counts[CourageType.negativeFeedback] ?? 0}',
                  onTap: () => _addRecord(
                    context,
                    RecordType.courage,
                    {'courageType': CourageType.negativeFeedback},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 第三行：记账、即时复盘
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  emoji: '💰',
                  label: '记账',
                  onTap: () => ExpenseDialog.show(
                    context,
                    context.read<DataProvider>().addRecord,
                  ),
                ),
                _ActionButton(
                  emoji: '🔄',
                  label: '即时复盘',
                  onTap: () => ReviewDialog.show(
                    context,
                    context.read<DataProvider>().addRecord,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
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
    final records = context.watch<DataProvider>().todayRecords;

    if (records.isEmpty) {
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
      children: records.map((r) => _buildRow(context, r)).toList(),
    );
  }

  Widget _buildRow(BuildContext context, Record r) {
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
        return '🏃 运动';
      case RecordType.courage:
        final ct = r.data['courageType'] as CourageType?;
        return ct != null ? '${ct.emoji} ${ct.label}' : '💪 勇气';
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
