import 'package:life_tracker/models/record.dart';

/// A todo item - either today's task or a long-term goal
class TodoItem {
  final String id;
  final String title;
  final DateTime? targetTime;
  final GoalCategory category;
  final bool isCompleted;
  final DateTime createdAt;
  final bool isLongTerm;
  final int streak;

  const TodoItem({
    required this.id,
    required this.title,
    this.targetTime,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.isLongTerm = false,
    this.streak = 0,
  });

  TodoItem copyWith({
    String? id,
    String? title,
    DateTime? targetTime,
    GoalCategory? category,
    bool? isCompleted,
    DateTime? createdAt,
    bool? isLongTerm,
    int? streak,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      targetTime: targetTime ?? this.targetTime,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      isLongTerm: isLongTerm ?? this.isLongTerm,
      streak: streak ?? this.streak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetTime': targetTime?.toIso8601String(),
      'category': category.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'isLongTerm': isLongTerm,
      'streak': streak,
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      targetTime: json['targetTime'] != null
          ? DateTime.parse(json['targetTime'] as String)
          : null,
      category: GoalCategory.values.byName(json['category'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isLongTerm: json['isLongTerm'] as bool? ?? false,
      streak: json['streak'] as int? ?? 0,
    );
  }
}
