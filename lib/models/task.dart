import 'dart:convert';

class Task {
  final int? id;
  final int milestoneId;
  final String description;
  final bool isCompleted;
  final int? estimateHours;
  final String? priority; // 'high', 'medium', 'low'

  Task({
    this.id,
    required this.milestoneId,
    required this.description,
    this.isCompleted = false,
    this.estimateHours,
    this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'milestone_id': milestoneId,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'estimate_hours': estimateHours,
      'priority': priority,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toInt(),
      milestoneId: map['milestone_id']?.toInt() ?? 0,
      description: map['description'] ?? '',
      isCompleted: (map['is_completed'] ?? 0) == 1,
      estimateHours: map['estimate_hours'] != null
          ? (map['estimate_hours'] is int
                ? map['estimate_hours']
                : (map['estimate_hours'] as num).toInt())
          : null,
      priority: map['priority'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

  Task copyWith({
    int? id,
    int? milestoneId,
    String? description,
    bool? isCompleted,
    int? estimateHours,
    String? priority,
  }) {
    return Task(
      id: id ?? this.id,
      milestoneId: milestoneId ?? this.milestoneId,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      estimateHours: estimateHours ?? this.estimateHours,
      priority: priority ?? this.priority,
    );
  }
}
