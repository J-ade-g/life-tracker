import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_tracker/models/record.dart';

/// 核心数据层 - 管理所有记录，持久化到 Hive
class DataProvider extends ChangeNotifier {
  static const _boxName = 'records';
  static const _budgetKey = '__budget__';

  Box<String>? _box;
  final List<Record> _records = [];
  double _monthlyBudget = 3000;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
    // Load budget setting
    final budgetStr = _box?.get(_budgetKey);
    if (budgetStr != null) {
      _monthlyBudget = double.tryParse(budgetStr) ?? 3000;
    }
    // Load all records
    for (final entry in _box!.toMap().entries) {
      if (entry.key == _budgetKey) continue;
      try {
        _records.add(
          Record.fromJson(jsonDecode(entry.value) as Map<String, dynamic>),
        );
      } catch (_) {
        // skip corrupted entries
      }
    }
    notifyListeners();
  }

  List<Record> get records => List.unmodifiable(_records);

  // ── Budget ─────────────────────────────────────────────────────────────

  double get monthlyBudget => _monthlyBudget;

  Future<void> setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    await _box?.put(_budgetKey, budget.toString());
    notifyListeners();
  }

  // ── Today ──────────────────────────────────────────────────────────────

  /// 今日记录（按时间升序）
  List<Record> get todayRecords {
    final now = DateTime.now();
    return _records
        .where((r) =>
            r.timestamp.year == now.year &&
            r.timestamp.month == now.month &&
            r.timestamp.day == now.day)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// 今日喝水次数
  int get todayWaterCount =>
      todayRecords.where((r) => r.type == RecordType.water).length;

  /// 今日正念次数
  int get todayMindfulnessCount =>
      todayRecords.where((r) => r.type == RecordType.mindfulness).length;

  // ── Courage ────────────────────────────────────────────────────────────

  /// 勇气计数（总计）
  Map<CourageType, int> get courageCounts {
    final map = <CourageType, int>{};
    for (final ct in CourageType.values) {
      map[ct] = _records
          .where((r) =>
              r.type == RecordType.courage && r.data['courageType'] == ct)
          .length;
    }
    return map;
  }

  // ── Expense stats ──────────────────────────────────────────────────────

  /// 本月总支出
  double get monthlySpending {
    final now = DateTime.now();
    return _records
        .where((r) =>
            r.type == RecordType.expense &&
            r.timestamp.year == now.year &&
            r.timestamp.month == now.month)
        .fold(
          0.0,
          (sum, r) => sum + ((r.data['amount'] as num?)?.toDouble() ?? 0),
        );
  }

  /// 本月各分类支出
  Map<ExpenseCategory, double> get monthlyExpenseByCategory {
    final now = DateTime.now();
    final result = <ExpenseCategory, double>{};
    for (final r in _records) {
      if (r.type == RecordType.expense &&
          r.timestamp.year == now.year &&
          r.timestamp.month == now.month) {
        final cat = r.data['expenseCategory'] as ExpenseCategory?;
        if (cat != null) {
          result[cat] =
              (result[cat] ?? 0) +
              ((r.data['amount'] as num?)?.toDouble() ?? 0);
        }
      }
    }
    return result;
  }

  /// 近7日每日支出（index 0 = 6天前，index 6 = 今天）
  List<double> get last7DaysSpending {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _records
          .where((r) =>
              r.type == RecordType.expense &&
              r.timestamp.year == day.year &&
              r.timestamp.month == day.month &&
              r.timestamp.day == day.day)
          .fold(
            0.0,
            (sum, r) => sum + ((r.data['amount'] as num?)?.toDouble() ?? 0),
          );
    });
  }

  // ── Weekly habits ──────────────────────────────────────────────────────

  /// 近7日习惯次数 (water/exercise/mindfulness)
  Map<RecordType, List<int>> get weeklyHabitCounts {
    final now = DateTime.now();
    final types = [
      RecordType.water,
      RecordType.exercise,
      RecordType.mindfulness,
    ];
    final result = <RecordType, List<int>>{};
    for (final type in types) {
      result[type] = List.generate(7, (i) {
        final day = now.subtract(Duration(days: 6 - i));
        return _records
            .where((r) =>
                r.type == type &&
                r.timestamp.year == day.year &&
                r.timestamp.month == day.month &&
                r.timestamp.day == day.day)
            .length;
      });
    }
    return result;
  }

  // ── Plan / Spontaneous ratios ──────────────────────────────────────────

  /// 计划执行率
  double get planExecutionRate {
    final planned = _records.where((r) => r.origin == RecordOrigin.planned);
    if (planned.isEmpty) return 0;
    final completed = planned.where((r) => r.data['completed'] == true);
    return completed.length / planned.length;
  }

  /// 即兴产出比
  double get spontaneousRatio {
    final today = todayRecords;
    if (today.isEmpty) return 0;
    final spontaneous =
        today.where((r) => r.origin == RecordOrigin.spontaneous);
    return spontaneous.length / today.length;
  }

  // ── Goal records ───────────────────────────────────────────────────────

  /// 按目标分类筛选复盘记录（按时间降序）
  List<Record> recordsByGoalCategory(GoalCategory category) {
    return _records
        .where((r) =>
            r.type == RecordType.review &&
            (r.data['categories'] as List?)
                    ?.any((c) => c == category) ==
                true)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// 某目标分类的总投入时间（小时）
  double totalHoursForGoal(GoalCategory category) {
    double total = 0;
    for (final r in recordsByGoalCategory(category)) {
      final start = r.data['startTime'] as DateTime?;
      final end = r.data['endTime'] as DateTime?;
      if (start != null && end != null) {
        total += end.difference(start).inMinutes / 60.0;
      }
    }
    return total;
  }

  // ── Persistence actions ────────────────────────────────────────────────

  void addRecord(Record record) {
    _records.add(record);
    _box?.put(record.id, jsonEncode(record.toJson()));
    notifyListeners();
  }

  /// 切换记录的来源类型（计划内 ↔ 即兴）
  void toggleOrigin(String recordId) {
    final idx = _records.indexWhere((r) => r.id == recordId);
    if (idx == -1) return;
    final old = _records[idx];
    final updated = Record(
      id: old.id,
      timestamp: old.timestamp,
      type: old.type,
      origin: old.origin == RecordOrigin.planned
          ? RecordOrigin.spontaneous
          : RecordOrigin.planned,
      data: old.data,
    );
    _records[idx] = updated;
    _box?.put(updated.id, jsonEncode(updated.toJson()));
    notifyListeners();
  }

  /// 导出所有数据为 JSON 字符串
  String exportDataAsJson() {
    return jsonEncode(_records.map((r) => r.toJson()).toList());
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    _records.clear();
    await _box?.clear();
    // Restore budget after clearing
    await _box?.put(_budgetKey, _monthlyBudget.toString());
    notifyListeners();
  }
}
