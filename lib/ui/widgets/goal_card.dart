import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:ur_breaker/models/assumption.dart';
import 'package:ur_breaker/models/milestone.dart';
import 'package:ur_breaker/models/risk.dart';
import 'package:ur_breaker/models/task.dart';
import '../../models/goal.dart';

class GoalCard extends StatefulWidget {
  final Goal goal;
  final Function(int taskId, bool completed)? onTaskToggle;
  final VoidCallback? onRefine;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTaskToggle,
    this.onRefine,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  final Set<int> _expandedMilestones = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and complexity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.goal.title,
                style: ShadTheme.of(context).textTheme.h3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getComplexityColor(widget.goal.complexity),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Toughness: ${widget.goal.complexity}/10',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Assumptions Section
        if (widget.goal.assumptions.isNotEmpty) ...[
          _buildSectionHeader('Assumptions', Icons.lightbulb_outline),
          const SizedBox(height: 8),
          ...widget.goal.assumptions.map(
            (assumption) => _buildAssumptionItem(assumption),
          ),
          const SizedBox(height: 24),
        ],
        // Milestones Section
        _buildSectionHeader('Project Breakdown', Icons.account_tree),
        const SizedBox(height: 12),
        ...widget.goal.milestones.asMap().entries.map((entry) {
          int index = entry.key;
          return _buildMilestoneCard(entry.value, index);
        }),

        // Risks Section
        if (widget.goal.risks.isNotEmpty) ...[
          _buildSectionHeader('Risks & Mitigations', Icons.warning_amber),
          const SizedBox(height: 8),
          ...widget.goal.risks.map((risk) => _buildRiskItem(risk)),
          const SizedBox(height: 24),
        ],

        const SizedBox(height: 24),

        // Refine Button
        if (widget.onRefine != null)
          ShadButton(
            onPressed: widget.onRefine,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_fix_high, size: 16),
                SizedBox(width: 8),
                Text('Refine with AI'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(title, style: ShadTheme.of(context).textTheme.h4),
      ],
    );
  }

  Widget _buildAssumptionItem(Assumption assumption) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            assumption.isConfirmed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 20,
            color: assumption.isConfirmed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              assumption.description,
              style: TextStyle(
                decoration: assumption.isConfirmed
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskItem(Risk risk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ShadTheme.of(context).colorScheme.muted.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    risk.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(risk.mitigation)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneCard(Milestone milestone, int milestoneIndex) {
    final isExpanded = _expandedMilestones.contains(milestoneIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ShadCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedMilestones.remove(milestoneIndex);
                  } else {
                    _expandedMilestones.add(milestoneIndex);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        milestone.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${milestone.tasks.length} tasks',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: milestone.tasks
                      .map((task) => _buildTaskItem(task))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              if (widget.onTaskToggle != null && task.id != null) {
                widget.onTaskToggle!(task.id!, value ?? false);
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.description,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (task.estimateHours != null) ...[
                      Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${task.estimateHours}h',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (task.priority != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task.priority!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.priority!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getComplexityColor(int score) {
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
