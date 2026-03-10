import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/record.dart';
import '../models/todo_item.dart';
import '../providers/data_provider.dart';

// ── Category colors ────────────────────────────────────────────────────────────

const Map<ExpenseCategory, Color> _catColors = {
  ExpenseCategory.food: Color(0xFFFF6B6B),
  ExpenseCategory.transport: Color(0xFF4ECDC4),
  ExpenseCategory.shopping: Color(0xFFFFE66D),
  ExpenseCategory.entertainment: Color(0xFFA78BFA),
  ExpenseCategory.study: Color(0xFF6BCB77),
  ExpenseCategory.sport: Color(0xFF4D96FF),
  ExpenseCategory.social: Color(0xFFFFB347),
  ExpenseCategory.beauty: Color(0xFFFF6EB4),
  ExpenseCategory.medical: Color(0xFF00CED1),
  ExpenseCategory.housing: Color(0xFF9B8EA3),
  ExpenseCategory.other: Color(0xFF808080),
};

// ── Main screen ────────────────────────────────────────────────────────────────

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DataProvider>(
          builder: (context, dp, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle(context, '事项分类'),
              const SizedBox(height: 8),
              _TodoCategoryCard(dp: dp),
              const SizedBox(height: 20),
              _sectionTitle(context, '月度预算'),
              const SizedBox(height: 8),
              _BudgetCard(dp: dp),
              const SizedBox(height: 20),
              _sectionTitle(context, '支出分类'),
              const SizedBox(height: 8),
              _ExpensePieCard(dp: dp),
              const SizedBox(height: 20),
              _sectionTitle(context, '近7日消费趋势'),
              const SizedBox(height: 8),
              _SpendingLineCard(dp: dp),
              const SizedBox(height: 20),
              _sectionTitle(context, '勇气进度'),
              const SizedBox(height: 8),
              _CourageCard(dp: dp),
              const SizedBox(height: 20),
              _sectionTitle(context, '周习惯'),
              const SizedBox(height: 8),
              _WeeklyHabitsCard(dp: dp),
              const SizedBox(height: 20),
              _sectionTitle(context, '执行比率'),
              const SizedBox(height: 8),
              _RatioCards(dp: dp),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
      );
}

// ── Section 1 – Budget progress ────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final DataProvider dp;
  const _BudgetCard({required this.dp});

  @override
  Widget build(BuildContext context) {
    final spent = dp.monthlySpending;
    final budget = dp.monthlyBudget;
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('已花 ¥${spent.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  '预算 ¥${budget.toStringAsFixed(0)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 12,
                color: isOver ? Colors.redAccent : const Color(0xFF6C63FF),
                backgroundColor: Colors.white12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isOver
                  ? '已超出预算 ¥${(spent - budget).toStringAsFixed(0)}'
                  : '剩余 ¥${(budget - spent).toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                color: isOver ? Colors.redAccent : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section 2 – Expense pie chart ──────────────────────────────────────────────

class _ExpensePieCard extends StatefulWidget {
  final DataProvider dp;
  const _ExpensePieCard({required this.dp});

  @override
  State<_ExpensePieCard> createState() => _ExpensePieCardState();
}

class _ExpensePieCardState extends State<_ExpensePieCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final byCategory = widget.dp.monthlyExpenseByCategory;

    if (byCategory.isEmpty) {
      return Card(
        child: SizedBox(
          height: 160,
          child: Center(
            child: Text(
              '本月暂无支出记录',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white38),
            ),
          ),
        ),
      );
    }

    final entries = byCategory.entries.toList();
    final sections = List.generate(entries.length, (i) {
      final e = entries[i];
      final isTouched = i == _touchedIndex;
      return PieChartSectionData(
        value: e.value,
        color: _catColors[e.key] ?? Colors.grey,
        title: isTouched ? '¥${e.value.toStringAsFixed(0)}' : e.key.emoji,
        radius: isTouched ? 62 : 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 28,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          _touchedIndex =
                              response?.touchedSection?.touchedSectionIndex ??
                              -1;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _catColors[e.key] ?? Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${e.key.label} ¥${e.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section 3 – Daily spending line chart ──────────────────────────────────────

class _SpendingLineCard extends StatelessWidget {
  final DataProvider dp;
  const _SpendingLineCard({required this.dp});

  @override
  Widget build(BuildContext context) {
    final data = dp.last7DaysSpending;
    final maxVal = data.fold(0.0, (a, b) => a > b ? a : b);
    final chartMaxY = maxVal < 10 ? 100.0 : maxVal * 1.25;

    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      const w = ['日', '一', '二', '三', '四', '五', '六'];
      return w[d.weekday % 7];
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: chartMaxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: chartMaxY / 4,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Colors.white10,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= dayLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        dayLabels[idx],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Text(
                        '¥${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white38,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    7,
                    (i) => FlSpot(i.toDouble(), data[i]),
                  ),
                  isCurved: true,
                  color: const Color(0xFF6C63FF),
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section 4 – Courage circular indicators ────────────────────────────────────

class _CourageCard extends StatelessWidget {
  final DataProvider dp;
  const _CourageCard({required this.dp});

  static const _colors = {
    CourageType.rejection: Color(0xFFFF6B6B),
    CourageType.newThing: Color(0xFFFFE66D),
    CourageType.negativeFeedback: Color(0xFFFFB347),
  };

  @override
  Widget build(BuildContext context) {
    final counts = dp.courageCounts;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: CourageType.values.map((ct) {
            final count = counts[ct] ?? 0;
            final color = _colors[ct] ?? Colors.grey;
            return Column(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: (count / 100).clamp(0.0, 1.0),
                        strokeWidth: 7,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.15),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(ct.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Text(
                  ct.label,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Section 5 – Weekly habits bar chart ───────────────────────────────────────

class _WeeklyHabitsCard extends StatelessWidget {
  final DataProvider dp;
  const _WeeklyHabitsCard({required this.dp});

  @override
  Widget build(BuildContext context) {
    final habitCounts = dp.weeklyHabitCounts;
    final waterData = habitCounts[RecordType.water] ?? List.filled(7, 0);
    final exerciseData =
        habitCounts[RecordType.exercise] ?? List.filled(7, 0);
    final mindData =
        habitCounts[RecordType.mindfulness] ?? List.filled(7, 0);

    final allVals = [...waterData, ...exerciseData, ...mindData];
    final maxVal = allVals.fold(0, (a, b) => a > b ? a : b).toDouble();
    final chartMaxY = maxVal < 1 ? 5.0 : maxVal + 1;

    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      const w = ['日', '一', '二', '三', '四', '五', '六'];
      return w[d.weekday % 7];
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          children: [
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: chartMaxY,
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(
                      x: i,
                      barsSpace: 3,
                      barRods: [
                        BarChartRodData(
                          toY: waterData[i].toDouble(),
                          color: const Color(0xFF4D96FF),
                          width: 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                        BarChartRodData(
                          toY: exerciseData[i].toDouble(),
                          color: const Color(0xFFFF9F43),
                          width: 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                        BarChartRodData(
                          toY: mindData[i].toDouble(),
                          color: const Color(0xFF6BCB77),
                          width: 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                      ],
                    );
                  }),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= dayLabels.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            dayLabels[idx],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white38,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value != value.roundToDouble() || value <= 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white38,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(const Color(0xFF4D96FF), '喝水'),
                const SizedBox(width: 20),
                _dot(const Color(0xFFFF9F43), '运动'),
                const SizedBox(width: 20),
                _dot(const Color(0xFF6BCB77), '正念'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color, String label) => Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white54),
          ),
        ],
      );
}

// ── Section 6 – Ratio cards ────────────────────────────────────────────────────

class _RatioCards extends StatelessWidget {
  final DataProvider dp;
  const _RatioCards({required this.dp});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ratioCard(
            context,
            '计划执行率',
            dp.planExecutionRate,
            const Color(0xFF5B9BD5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ratioCard(
            context,
            '即兴产出比',
            dp.spontaneousRatio,
            const Color(0xFFFF9F43),
          ),
        ),
      ],
    );
  }

  Widget _ratioCard(
    BuildContext context,
    String title,
    double ratio,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${(ratio * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section 7 – Todo Category Counts ──────────────────────────────────────────

class _TodoCategoryCard extends StatelessWidget {
  final DataProvider dp;
  const _TodoCategoryCard({required this.dp});

  @override
  Widget build(BuildContext context) {
    // Count todos by category (today + long-term)
    final allTodos = dp.allTodos;
    final now = DateTime.now();
    final todayTodos = allTodos.where((t) =>
        !t.isLongTerm &&
        t.createdAt.year == now.year &&
        t.createdAt.month == now.month &&
        t.createdAt.day == now.day).toList();

    if (todayTodos.isEmpty) {
      return Card(
        child: SizedBox(
          height: 80,
          child: Center(
            child: Text(
              '今日暂无计划事项',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white38),
            ),
          ),
        ),
      );
    }

    // Group by category
    final catCounts = <GoalCategory, int>{};
    final catCompleted = <GoalCategory, int>{};
    for (final todo in todayTodos) {
      catCounts[todo.category] = (catCounts[todo.category] ?? 0) + 1;
      if (todo.isCompleted) {
        catCompleted[todo.category] = (catCompleted[todo.category] ?? 0) + 1;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: catCounts.entries.map((e) {
            final completed = catCompleted[e.key] ?? 0;
            final total = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(e.key.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.key.label,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Text(
                    '$completed/$total',
                    style: TextStyle(
                      color: completed == total ? const Color(0xFF2CD87A) : Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? completed / total : 0,
                        minHeight: 6,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completed == total ? const Color(0xFF2CD87A) : const Color(0xFF5B9BD5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
