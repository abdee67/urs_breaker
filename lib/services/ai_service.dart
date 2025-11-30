import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/goal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static final String _apiKey = 'AIzaSyBRNG8o3cusnDgBiY8sIB0lm3jAuDUrG68';

  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  Future<Goal> generateBreakdown(String goalTitle) async {
    final prompt =
        '''
      Break down the following goal into 5 actionable steps. 
      Also provide a complexity score from 1 to 10.
      Return the result as a valid JSON object with the following structure:
      {
        "complexity": 5,
        "steps": [
          {"description": "Step 1 description"},
          {"description": "Step 2 description"},
          ...
        ]
      }
      Goal: "$goalTitle"
      Do not include any markdown formatting (like ```json). Just the raw JSON string.
    ''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);

    if (response.text == null) {
      throw Exception('Failed to generate content');
    }

    try {
      // Clean up potential markdown code blocks if the model ignores instructions
      String cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      List<GoalStep> steps = (data['steps'] as List)
          .map((e) => GoalStep(description: e['description']))
          .toList();

      return Goal(
        title: goalTitle,
        complexity: data['complexity'],
        steps: steps,
      );
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
