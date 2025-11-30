import 'dart:convert';
import 'milestone.dart';
import 'assumption.dart';
import 'risk.dart';

class Goal {
  final int? id;
  final String title;
  final int complexity;
  final List<Milestone> milestones;
  final List<Assumption> assumptions;
  final List<Risk> risks;
  final String? thoughtSignature;

  Goal({
    this.id,
    required this.title,
    required this.complexity,
    required this.milestones,
    this.assumptions = const [],
    this.risks = const [],
    this.thoughtSignature,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'complexity': complexity,
      'milestones': jsonEncode(milestones.map((x) => x.toMap()).toList()),
      'assumptions': jsonEncode(assumptions.map((x) => x.toMap()).toList()),
      'risks': jsonEncode(risks.map((x) => x.toMap()).toList()),
      'thought_signature': thoughtSignature,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      complexity: map['complexity']?.toInt() ?? 0,
      milestones: map['milestones'] != null
          ? (jsonDecode(map['milestones']) as List<dynamic>?)
                    ?.map((x) => Milestone.fromMap(x))
                    .toList() ??
                []
          : [],
      assumptions: map['assumptions'] != null
          ? (jsonDecode(map['assumptions']) as List<dynamic>?)
                    ?.map((x) => Assumption.fromMap(x))
                    .toList() ??
                []
          : [],
      risks: map['risks'] != null
          ? (jsonDecode(map['risks']) as List<dynamic>?)
                    ?.map((x) => Risk.fromMap(x))
                    .toList() ??
                []
          : [],
      thoughtSignature: map['thought_signature'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Goal.fromJson(String source) => Goal.fromMap(json.decode(source));

  Goal copyWith({
    int? id,
    String? title,
    int? complexity,
    List<Milestone>? milestones,
    List<Assumption>? assumptions,
    List<Risk>? risks,
    String? thoughtSignature,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      complexity: complexity ?? this.complexity,
      milestones: milestones ?? this.milestones,
      assumptions: assumptions ?? this.assumptions,
      risks: risks ?? this.risks,
      thoughtSignature: thoughtSignature ?? this.thoughtSignature,
    );
  }
}
