import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_tracker/models/record.dart';

/// 核心数据层 - 管理所有记录，持久化到 Hive
class DataProvider extends ChangeNotifier {
  static const _boxName = 'records';

  Box<String>? _box;
  final List<Record> _records = [];

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
    for (final value in _box!.values) {
      try {
        _records.add(Record.fromJson(jsonDecode(value) as Map<String, dynamic>));
      } catch (_) {
        // skip corrupted entries
      }
    }
    notifyListeners();
  }

  List<Record> get records => List.unmodifiable(_records);

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
}
