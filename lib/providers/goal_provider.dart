import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../models/goal.dart';

final aiServiceProvider = Provider<AIService>((ref) => AIService());
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);

final goalsProvider = AsyncNotifierProvider<GoalNotifier, List<Goal>>(
  GoalNotifier.new,
);

class GoalNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    final dbService = ref.read(databaseServiceProvider);
    return await dbService.getGoals();
  }

  Future<void> addGoal(String goalTitle) async {
    state = const AsyncValue.loading();
    try {
      final aiService = ref.read(aiServiceProvider);
      final dbService = ref.read(databaseServiceProvider);

      final goal = await aiService.generateBreakdown(goalTitle);
      await dbService.insertGoal(goal);

      // Reload goals
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refineGoal(int goalId, String feedback) async {
    state = const AsyncValue.loading();
    try {
      final aiService = ref.read(aiServiceProvider);
      final dbService = ref.read(databaseServiceProvider);

      // Get existing goal
      final existingGoal = await dbService.getGoalById(goalId);
      if (existingGoal == null) {
        throw Exception('Goal not found');
      }

      // Refine with AI
      final refinedGoal = await aiService.refineGoal(existingGoal, feedback);

      // Update in database
      await dbService.updateGoal(refinedGoal.copyWith(id: goalId));

      // Reload goals
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.updateGoal(goal);

      // Reload goals
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteGoal(int goalId) async {
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.deleteGoal(goalId);

      // Reload goals
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleTaskCompletion(
    Goal goal,
    int milestoneIndex,
    int taskIndex,
  ) async {
    try {
      final milestone = goal.milestones[milestoneIndex];
      final task = milestone.tasks[taskIndex];

      // Toggle completion
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

      // Update tasks list
      final updatedTasks = List.of(milestone.tasks);
      updatedTasks[taskIndex] = updatedTask;

      // Update milestone
      final updatedMilestone = milestone.copyWith(tasks: updatedTasks);

      // Update milestones list
      final updatedMilestones = List.of(goal.milestones);
      updatedMilestones[milestoneIndex] = updatedMilestone;

      // Update goal
      final updatedGoal = goal.copyWith(milestones: updatedMilestones);

      await updateGoal(updatedGoal);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleAssumptionConfirmation(
    Goal goal,
    int assumptionIndex,
  ) async {
    try {
      final assumption = goal.assumptions[assumptionIndex];

      // Toggle confirmation
      final updatedAssumption = assumption.copyWith(
        isConfirmed: !assumption.isConfirmed,
      );

      // Update assumptions list
      final updatedAssumptions = List.of(goal.assumptions);
      updatedAssumptions[assumptionIndex] = updatedAssumption;

      // Update goal
      final updatedGoal = goal.copyWith(assumptions: updatedAssumptions);

      await updateGoal(updatedGoal);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
