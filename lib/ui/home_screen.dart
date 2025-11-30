import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../providers/goal_provider.dart';
import 'widgets/goal_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitGoal() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(goalsProvider.notifier).addGoal(_controller.text);
      _controller.clear();
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('The Smart Goal Breaker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ShadInput(
                    controller: _controller,
                    placeholder: const Text(
                      'Enter a vague goal (e.g., "Launch a startup")',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ShadButton(
                  onPressed: _isLoading ? null : _submitGoal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const Icon(Icons.auto_awesome, size: 16),
                      const SizedBox(width: 8),
                      const Text('Break it'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: goalsAsync.when(
                data: (goals) {
                  if (goals.isEmpty) {
                    return const Center(
                      child: Text('No goals yet. Start by adding one!'),
                    );
                  }
                  return ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      return GoalCard(goal: goals[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Something went south.: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
