/// 记录来源：计划内 vs 即兴
enum RecordOrigin {
  /// 提前规划的任务，完成后打卡
  planned,
  /// 没有提前规划，通过即时复盘录入
  spontaneous,
}

/// 目标分类
enum GoalCategory {
  thesis('毕业论文', '📚'),
  aiPortfolio('AI作品集', '🤖'),
  productKnowledge('产品知识', '💡'),
  exercise('运动/NEAT', '🏃'),
  english('英语', '🇬🇧'),
  earning('赚钱', '💰'),
  other('其他', '📌');

  final String label;
  final String emoji;
  const GoalCategory(this.label, this.emoji);
}

/// 原则
enum Principle {
  patience('耐心'),
  fastOverPerfect('Fast>Perfect'),
  courage('勇敢'),
  grounded('落地'),
  antiOverthink('反内耗'),
  learning('学习'),
  reviewPrinciple('复盘');

  final String label;
  const Principle(this.label);
}

/// 勇气类型
enum CourageType {
  rejection('拒绝', '🔴'),
  newThing('新事物', '🟡'),
  negativeFeedback('负反馈', '🟠');

  final String label;
  final String emoji;
  const CourageType(this.label, this.emoji);
}

/// 支出分类
enum ExpenseCategory {
  food('餐饮', '🍜'),
  transport('交通', '🚌'),
  shopping('购物', '🛍️'),
  entertainment('娱乐', '🎮'),
  study('学习', '📖'),
  sport('运动', '⚽'),
  social('社交', '👥'),
  beauty('美妆', '💄'),
  medical('医疗', '🏥'),
  housing('住房', '🏠'),
  other('其他', '📦');

  final String label;
  final String emoji;
  const ExpenseCategory(this.label, this.emoji);
}

/// 收入分类
enum IncomeCategory {
  salary('工资', '💵'),
  partTime('兼职', '🔧'),
  redPacket('红包', '🧧'),
  investment('理财', '📈'),
  other('其他', '📦');

  final String label;
  final String emoji;
  const IncomeCategory(this.label, this.emoji);
}

enum RecordType {
  water,
  mindfulness,
  exercise,
  courage,
  expense,
  income,
  review, // 即时复盘
  todo,   // 计划任务
}

/// 基础记录
class Record {
  final String id;
  final DateTime timestamp;
  final RecordType type;
  final RecordOrigin origin;
  final Map<String, dynamic> data;

  Record({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.origin,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'origin': origin.name,
      'data': _serializeData(),
    };
  }

  Map<String, dynamic> _serializeData() {
    final result = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is Enum) {
        result[key] = value.name;
      } else if (value is List) {
        result[key] = value.map((e) => e is Enum ? e.name : e).toList();
      } else if (value is DateTime) {
        result[key] = value.toIso8601String();
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    final type = RecordType.values.byName(json['type'] as String);
    return Record(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: type,
      origin: RecordOrigin.values.byName(json['origin'] as String),
      data: _deserializeData(json['data'] as Map<String, dynamic>, type),
    );
  }

  static Map<String, dynamic> _deserializeData(
    Map<String, dynamic> raw,
    RecordType type,
  ) {
    switch (type) {
      case RecordType.courage:
        return {
          ...raw,
          if (raw['courageType'] != null)
            'courageType': CourageType.values.byName(raw['courageType'] as String),
        };
      case RecordType.expense:
        return {
          ...raw,
          if (raw['expenseCategory'] != null)
            'expenseCategory': ExpenseCategory.values.byName(raw['expenseCategory'] as String),
        };
      case RecordType.income:
        return {
          ...raw,
          if (raw['incomeCategory'] != null)
            'incomeCategory': IncomeCategory.values.byName(raw['incomeCategory'] as String),
        };
      case RecordType.review:
        return {
          ...raw,
          if (raw['categories'] != null)
            'categories': (raw['categories'] as List)
                .map((e) => GoalCategory.values.byName(e as String))
                .toList(),
          if (raw['principles'] != null)
            'principles': (raw['principles'] as List)
                .map((e) => Principle.values.byName(e as String))
                .toList(),
          if (raw['startTime'] != null)
            'startTime': DateTime.parse(raw['startTime'] as String),
          if (raw['endTime'] != null)
            'endTime': DateTime.parse(raw['endTime'] as String),
        };
      case RecordType.todo:
        return {
          ...raw,
          if (raw['targetTime'] != null)
            'targetTime': DateTime.parse(raw['targetTime'] as String),
          if (raw['category'] != null)
            'category': GoalCategory.values.byName(raw['category'] as String),
        };
      default:
        return raw;
    }
  }
}
