import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ShadCard(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                goal.title,
                style: ShadTheme.of(context).textTheme.h4,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getComplexityColor(goal.complexity),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Complexity: ${goal.complexity}/10',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        description:
            const SizedBox.shrink(), // Description moved to title row for better layout
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ...goal.steps.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              GoalStep step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$idx.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(step.description)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getComplexityColor(int score) {
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }
}
