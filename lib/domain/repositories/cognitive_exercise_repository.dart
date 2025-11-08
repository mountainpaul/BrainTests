import '../../data/datasources/database.dart';
import '../entities/cognitive_exercise.dart';

abstract class CognitiveExerciseRepository {
  Future<List<CognitiveExercise>> getAllExercises();
  Future<List<CognitiveExercise>> getExercisesByType(ExerciseType type);
  Future<List<CognitiveExercise>> getExercisesByDifficulty(ExerciseDifficulty difficulty);
  Future<List<CognitiveExercise>> getCompletedExercises();
  Future<CognitiveExercise?> getExerciseById(int id);
  Future<int> insertExercise(CognitiveExercise exercise);
  Future<bool> updateExercise(CognitiveExercise exercise);
  Future<bool> deleteExercise(int id);
  Future<Map<ExerciseType, double>> getAverageScoresByType();
  Future<List<CognitiveExercise>> getRecentExercises({int limit = 10});
}