import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());
final aiServiceProvider = Provider((ref) => AIService());

final goalsProvider = AsyncNotifierProvider<GoalNotifier, List<Goal>>(
  GoalNotifier.new,
);

class GoalNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    final dbService = ref.watch(databaseServiceProvider);
    return dbService.getGoals();
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
}
