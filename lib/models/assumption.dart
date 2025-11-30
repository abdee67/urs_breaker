import 'dart:convert';

class Assumption {
  final int? id;
  final int goalId;
  final String description;
  final bool isConfirmed;

  Assumption({
    this.id,
    required this.goalId,
    required this.description,
    this.isConfirmed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'description': description,
      'is_confirmed': isConfirmed ? 1 : 0,
    };
  }

  factory Assumption.fromMap(Map<String, dynamic> map) {
    return Assumption(
      id: map['id']?.toInt(),
      goalId: map['goal_id']?.toInt() ?? 0,
      description: map['description'] ?? '',
      isConfirmed: (map['is_confirmed'] ?? 0) == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Assumption.fromJson(String source) =>
      Assumption.fromMap(json.decode(source));

  Assumption copyWith({
    int? id,
    int? goalId,
    String? description,
    bool? isConfirmed,
  }) {
    return Assumption(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      description: description ?? this.description,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}
