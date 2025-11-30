import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/goal.dart';
import '../../providers/goal_provider.dart';
import 'goal_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GoalCardWrapper extends ConsumerStatefulWidget {
  final Goal goal;

  const GoalCardWrapper({super.key, required this.goal});

  @override
  ConsumerState<GoalCardWrapper> createState() => _GoalCardWrapperState();
}

class _GoalCardWrapperState extends ConsumerState<GoalCardWrapper> {
  bool _isRefining = false;

  Future<void> _showRefineDialog() async {
    final TextEditingController feedbackController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Refine Goal with AI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Provide feedback to refine this goal breakdown:'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                hintText: 'e.g., "Add more detail to milestone 2"',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, feedbackController.text),
            child: const Text('Refine'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _isRefining = true);
      try {
        await ref
            .read(goalsProvider.notifier)
            .refineGoal(widget.goal.id!, result);

        if (mounted) {
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Success'),
              description: Text('Goal refined successfully!'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Error'),
              description: Text(e.toString()),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isRefining = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isRefining) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitDancingSquare(color: Colors.white, size: 80),
            SizedBox(height: 20),
            Text('Refining...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    return GoalCard(goal: widget.goal, onRefine: _showRefineDialog);
  }
}
