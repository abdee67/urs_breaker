import 'dart:convert';

class Risk {
  final int? id;
  final int goalId;
  final String description;
  final String mitigation;

  Risk({
    this.id,
    required this.goalId,
    required this.description,
    required this.mitigation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'description': description,
      'mitigation': mitigation,
    };
  }

  factory Risk.fromMap(Map<String, dynamic> map) {
    return Risk(
      id: map['id']?.toInt(),
      goalId: map['goal_id']?.toInt() ?? 0,
      description: map['description'] ?? '',
      mitigation: map['mitigation'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Risk.fromJson(String source) => Risk.fromMap(json.decode(source));

  Risk copyWith({
    int? id,
    int? goalId,
    String? description,
    String? mitigation,
  }) {
    return Risk(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      description: description ?? this.description,
      mitigation: mitigation ?? this.mitigation,
    );
  }
}
