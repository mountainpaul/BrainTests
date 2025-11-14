import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/daily_goals_repository_impl.dart';
import '../../domain/entities/daily_goal.dart';
import 'database_provider.dart';

final dailyGoalsRepositoryProvider = Provider<DailyGoalsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DailyGoalsRepository(database);
});

final todayGoalProvider = FutureProvider<DailyGoal>((ref) async {
  final repository = ref.watch(dailyGoalsRepositoryProvider);
  return await repository.getOrCreateTodayGoal();
});

final currentStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(dailyGoalsRepositoryProvider);
  return await repository.getCurrentStreak(DateTime.now());
});

final longestStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(dailyGoalsRepositoryProvider);
  return await repository.getLongestStreak();
});

final completionStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(dailyGoalsRepositoryProvider);
  return await repository.getCompletionStatistics();
});
