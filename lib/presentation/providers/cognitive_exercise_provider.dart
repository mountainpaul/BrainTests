import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/database.dart';
import '../../domain/entities/cognitive_exercise.dart';
import 'cognitive_activity_provider.dart';
import 'daily_goals_provider.dart';
import 'repository_providers.dart';

part 'cognitive_exercise_provider.g.dart';

final cognitiveExercisesProvider = FutureProvider<List<CognitiveExercise>>((ref) async {
  final repository = ref.read(cognitiveExerciseRepositoryProvider);
  return await repository.getAllExercises();
});

final completedExercisesProvider = FutureProvider<List<CognitiveExercise>>((ref) async {
  final repository = ref.read(cognitiveExerciseRepositoryProvider);
  return await repository.getCompletedExercises();
});

final recentExercisesProvider = FutureProvider<List<CognitiveExercise>>((ref) async {
  final repository = ref.read(cognitiveExerciseRepositoryProvider);
  return await repository.getRecentExercises(limit: 5);
});

final exercisesByTypeProvider = FutureProvider.family<List<CognitiveExercise>, ExerciseType>((ref, type) async {
  final repository = ref.read(cognitiveExerciseRepositoryProvider);
  return await repository.getExercisesByType(type);
});

final exercisesByDifficultyProvider = FutureProvider.family<List<CognitiveExercise>, ExerciseDifficulty>((ref, difficulty) async {
  final repository = ref.read(cognitiveExerciseRepositoryProvider);
  return await repository.getExercisesByDifficulty(difficulty);
});

final averageExerciseScoresByTypeProvider = FutureProvider<Map<ExerciseType, double>>((ref) async {
  final repository = ref.read(cognitiveExerciseRepositoryProvider);
  return await repository.getAverageScoresByType();
});

@riverpod
class CognitiveExerciseNotifier extends _$CognitiveExerciseNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> addExercise(CognitiveExercise exercise) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cognitiveExerciseRepositoryProvider);
      await repository.insertExercise(exercise);

      // Check if still mounted after async operation
      if (!ref.mounted) return;

      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateExercise(CognitiveExercise exercise) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cognitiveExerciseRepositoryProvider);
      await repository.updateExercise(exercise);

      if (!ref.mounted) return;

      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteExercise(int id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cognitiveExerciseRepositoryProvider);
      await repository.deleteExercise(id);

      if (!ref.mounted) return;

      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> completeExercise(int exerciseId, int score, int timeSpentSeconds) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cognitiveExerciseRepositoryProvider);
      final exercise = await repository.getExerciseById(exerciseId);
      if (exercise != null) {
        final completedExercise = exercise.copyWith(
          score: score,
          timeSpentSeconds: timeSpentSeconds,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        await repository.updateExercise(completedExercise);

        // Increment daily goals counter
        final dailyGoalsRepo = ref.read(dailyGoalsRepositoryProvider);
        await dailyGoalsRepo.incrementCompletedGames();
      }
      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _invalidateProviders() {
    ref.invalidate(cognitiveExercisesProvider);
    ref.invalidate(completedExercisesProvider);
    ref.invalidate(todayGoalProvider);
    ref.invalidate(currentStreakProvider);
    ref.invalidate(recentExercisesProvider);
    ref.invalidate(averageExerciseScoresByTypeProvider);
    ref.invalidate(recentCognitiveActivityProvider);
  }
}