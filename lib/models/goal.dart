import 'dart:convert';

class GoalStep {
  final String description;
  final bool isCompleted;

  GoalStep({required this.description, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {'description': description, 'isCompleted': isCompleted ? 1 : 0};
  }

  factory GoalStep.fromMap(Map<String, dynamic> map) {
    return GoalStep(
      description: map['description'] ?? '',
      isCompleted: (map['isCompleted'] ?? 0) == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoalStep.fromJson(String source) =>
      GoalStep.fromMap(json.decode(source));
}

class Goal {
  final int? id;
  final String title;
  final int complexity;
  final List<GoalStep> steps;

  Goal({
    this.id,
    required this.title,
    required this.complexity,
    required this.steps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'complexity': complexity,
      'steps': jsonEncode(steps.map((x) => x.toMap()).toList()),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      complexity: map['complexity']?.toInt() ?? 0,
      steps: map['steps'] != null
          ? List<GoalStep>.from(
              jsonDecode(map['steps']).map((x) => GoalStep.fromMap(x)),
            )
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Goal.fromJson(String source) => Goal.fromMap(json.decode(source));
}
