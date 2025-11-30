import 'dart:convert';
import 'task.dart';

class Milestone {
  final int? id;
  final int goalId;
  final String title;
  final List<Task> tasks;

  Milestone({
    this.id,
    required this.goalId,
    required this.title,
    required this.tasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'tasks': jsonEncode(tasks.map((x) => x.toMap()).toList()),
    };
  }

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map['id']?.toInt(),
      goalId: map['goal_id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      tasks: map['tasks'] != null
          ? List<Task>.from(
              jsonDecode(map['tasks']).map((x) => Task.fromMap(x)),
            )
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Milestone.fromJson(String source) =>
      Milestone.fromMap(json.decode(source));

  Milestone copyWith({int? id, int? goalId, String? title, List<Task>? tasks}) {
    return Milestone(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
    );
  }
}
