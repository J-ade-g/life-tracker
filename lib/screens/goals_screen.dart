import 'package:flutter/material.dart';
import 'package:life_tracker/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../models/record.dart';
import '../providers/data_provider.dart';

// ── Main screen ────────────────────────────────────────────────────────────────

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DataProvider>(
          builder: (context, dp, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: GoalCategory.values.map((cat) {
              final count = dp.recordsByGoalCategory(cat).length;
              final hours = dp.totalHoursForGoal(cat);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GoalCard(
                  category: cat,
                  recordCount: count,
                  totalHours: hours,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => _GoalDetailScreen(
                        category: cat,
                        dp: dp,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Goal category card ─────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final GoalCategory category;
  final int recordCount;
  final double totalHours;
  final VoidCallback onTap;

  const _GoalCard({
    required this.category,
    required this.recordCount,
    required this.totalHours,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$recordCount 条记录  ·  ${totalHours.toStringAsFixed(1)} 小时',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Goal detail screen ─────────────────────────────────────────────────────────

class _GoalDetailScreen extends StatelessWidget {
  final GoalCategory category;
  final DataProvider dp;

  const _GoalDetailScreen({required this.category, required this.dp});

  @override
  Widget build(BuildContext context) {
    final records = dp.recordsByGoalCategory(category);
    final totalHours = dp.totalHoursForGoal(category);

    return Scaffold(
      appBar: AppBar(
        title: Text('${category.emoji} ${category.label}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _chip(
                  context,
                  '共 ${records.length} 条',
                  Icons.list_alt_outlined,
                ),
                const SizedBox(width: 12),
                _chip(
                  context,
                  '${totalHours.toStringAsFixed(1)} 小时',
                  Icons.timer_outlined,
                ),
              ],
            ),
          ),
          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Text(
                      '暂无记录',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _RecordItem(record: records[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String text, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF9B8AFF)),
            const SizedBox(width: 6),
            Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// ── Record list item ───────────────────────────────────────────────────────────

class _RecordItem extends StatefulWidget {
  final Record record;
  const _RecordItem({required this.record});

  @override
  State<_RecordItem> createState() => _RecordItemState();
}

class _RecordItemState extends State<_RecordItem> {
  bool _expanded = false;

  Record get record => widget.record;

  @override
  Widget build(BuildContext context) {
    final what = record.data['what'] as String? ?? '（无描述）';
    final start = record.data['startTime'] as DateTime?;
    final end = record.data['endTime'] as DateTime?;
    final optimization = record.data['optimization'] as String?;

    String durationStr = '';
    if (start != null && end != null) {
      final mins = end.difference(start).inMinutes;
      durationStr = mins >= 60
          ? '${(mins / 60).toStringAsFixed(1)}h'
          : '${mins}min';
    }

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _expanded ? AppTheme.emeraldGreen.withValues(alpha: 0.5) : AppTheme.cardBorder, width: 1.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _fmtDate(record.timestamp),
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                if (durationStr.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      durationStr,
                      style: const TextStyle(fontSize: 11, color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18, color: AppTheme.textSecondary),
              ],
            ),
            const SizedBox(height: 6),
            Text(what, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            if (optimization != null && optimization.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('💡 $optimization', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
            if (_expanded) ...[
              const Divider(height: 16),
              if (record.data['principles'] != null && (record.data['principles'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('原则：${(record.data['principles'] as List).map((p) => p is Principle ? p.label : p.toString()).join('、')}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ),
              if (record.data['categories'] != null)
                Text('分类：${(record.data['categories'] as List).map((c) => c is GoalCategory ? '${c.emoji} ${c.label}' : c.toString()).join('、')}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$m/$d $hh:$mm';
  }
}
