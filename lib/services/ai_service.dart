import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/task.dart';
import '../models/assumption.dart';
import '../models/risk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY']!;

  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  Future<Goal> generateBreakdown(String goalTitle) async {
    final prompt =
        '''
You are a project planning expert. Break down the following goal into a detailed, hierarchical project plan.

Goal: "$goalTitle"

Provide your response as a valid JSON object with this EXACT structure:
{
  "complexity": <number 1-10>,
  "thought_signature": "<your internal reasoning about this goal>",
  "milestones": [
    {
      "title": "<milestone name>",
      "tasks": [
        {
          "description": "<task description>",
          "estimate_hours": <number or null>,
          "priority": "<high|medium|low>"
        }
      ]
    }
  ],
  "assumptions": [
    "<assumption 1>",
    "<assumption 2>"
  ],
  "risks": [
    {
      "description": "<risk description>",
      "mitigation": "<mitigation strategy>"
    }
  ]
}

Guidelines:
- Create 3-5 milestones representing major phases
- Each milestone should have 2-5 tasks
- Estimate hours realistically (can be null if uncertain)
- Identify 2-4 key assumptions the user should confirm
- Identify 2-3 major risks with concrete mitigation strategies
- thought_signature should capture your reasoning process for future refinement

Return ONLY the JSON, no markdown formatting.
''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);

    if (response.text == null) {
      throw Exception('Failed to generate content');
    }

    try {
      String cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      // Parse milestones and tasks
      List<Milestone> milestones = ((data['milestones'] as List?) ?? []).map((
        m,
      ) {
        List<Task> tasks = ((m['tasks'] as List?) ?? []).map((t) {
          return Task(
            milestoneId: 0, // Will be set when saved to DB
            description: t['description'] ?? '',
            estimateHours: t['estimate_hours'] != null
                ? (t['estimate_hours'] is int
                      ? t['estimate_hours']
                      : (t['estimate_hours'] is String
                            ? int.tryParse(t['estimate_hours'])
                            : (t['estimate_hours'] as num).toInt()))
                : null,
            priority: t['priority'],
          );
        }).toList();

        return Milestone(
          goalId: 0, // Will be set when saved to DB
          title: m['title'] ?? '',
          tasks: tasks,
        );
      }).toList();

      // Parse assumptions
      List<Assumption> assumptions = ((data['assumptions'] as List?) ?? []).map(
        (a) {
          return Assumption(goalId: 0, description: a.toString());
        },
      ).toList();

      // Parse risks
      List<Risk> risks = ((data['risks'] as List?) ?? []).map((r) {
        return Risk(
          goalId: 0,
          description: r['description'] ?? '',
          mitigation: r['mitigation'] ?? '',
        );
      }).toList();

      return Goal(
        title: goalTitle,
        complexity: data['complexity'] is int
            ? data['complexity']
            : (data['complexity'] is String
                  ? int.tryParse(data['complexity']) ?? 5
                  : (data['complexity'] as num).toInt()),
        milestones: milestones,
        assumptions: assumptions,
        risks: risks,
        thoughtSignature: data['thought_signature'],
      );
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }

  Future<Goal> refineGoal(Goal existingGoal, String userFeedback) async {
    final prompt =
        '''
You previously analyzed this goal and created a project plan. Now the user has feedback.

Original Goal: "${existingGoal.title}"
Your Previous Reasoning: "${existingGoal.thoughtSignature}"

User Feedback: "$userFeedback"

Based on this feedback, refine the project plan. Maintain the same JSON structure as before:
{
  "complexity": <number 1-10>,
  "thought_signature": "<updated reasoning incorporating feedback>",
  "milestones": [...],
  "assumptions": [...],
  "risks": [...]
}

Return ONLY the JSON, no markdown formatting.
''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);

    if (response.text == null) {
      throw Exception('Failed to generate content');
    }

    try {
      String cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      // Parse using same logic as generateBreakdown
      List<Milestone> milestones = ((data['milestones'] as List?) ?? []).map((
        m,
      ) {
        List<Task> tasks = ((m['tasks'] as List?) ?? []).map((t) {
          return Task(
            milestoneId: 0,
            description: t['description'] ?? '',
            estimateHours: t['estimate_hours'] != null
                ? (t['estimate_hours'] is int
                      ? t['estimate_hours']
                      : (t['estimate_hours'] is String
                            ? int.tryParse(t['estimate_hours'])
                            : (t['estimate_hours'] as num).toInt()))
                : null,
            priority: t['priority'],
          );
        }).toList();

        return Milestone(
          goalId: existingGoal.id ?? 0,
          title: m['title'] ?? '',
          tasks: tasks,
        );
      }).toList();

      List<Assumption> assumptions = ((data['assumptions'] as List?) ?? []).map(
        (a) {
          return Assumption(
            goalId: existingGoal.id ?? 0,
            description: a.toString(),
          );
        },
      ).toList();

      List<Risk> risks = ((data['risks'] as List?) ?? []).map((r) {
        return Risk(
          goalId: existingGoal.id ?? 0,
          description: r['description'] ?? '',
          mitigation: r['mitigation'] ?? '',
        );
      }).toList();

      return existingGoal.copyWith(
        complexity: data['complexity'] is int
            ? data['complexity']
            : (data['complexity'] is String
                  ? int.tryParse(data['complexity']) ?? existingGoal.complexity
                  : (data['complexity'] as num).toInt()),
        milestones: milestones,
        assumptions: assumptions,
        risks: risks,
        thoughtSignature: data['thought_signature'],
      );
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
