import 'package:drift/drift.dart';
import '../../domain/entities/cognitive_exercise.dart';
import '../../domain/repositories/cognitive_exercise_repository.dart';
import '../datasources/database.dart';

class CognitiveExerciseRepositoryImpl implements CognitiveExerciseRepository {

  CognitiveExerciseRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<CognitiveExercise>> getAllExercises() async {
    final exercises = await _database.select(_database.cognitiveExerciseTable).get();
    return exercises.map(_mapToEntity).toList();
  }

  @override
  Future<List<CognitiveExercise>> getExercisesByType(ExerciseType type) async {
    final exercises = await (_database.select(_database.cognitiveExerciseTable)
          ..where((t) => t.type.equals(type.name)))
        .get();
    return exercises.map(_mapToEntity).toList();
  }

  @override
  Future<List<CognitiveExercise>> getExercisesByDifficulty(ExerciseDifficulty difficulty) async {
    final exercises = await (_database.select(_database.cognitiveExerciseTable)
          ..where((t) => t.difficulty.equals(difficulty.name)))
        .get();
    return exercises.map(_mapToEntity).toList();
  }

  @override
  Future<List<CognitiveExercise>> getCompletedExercises() async {
    final exercises = await (_database.select(_database.cognitiveExerciseTable)
          ..where((t) => t.isCompleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .get();
    return exercises.map(_mapToEntity).toList();
  }

  @override
  Future<CognitiveExercise?> getExerciseById(int id) async {
    final exercise = await (_database.select(_database.cognitiveExerciseTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return exercise != null ? _mapToEntity(exercise) : null;
  }

  @override
  Future<int> insertExercise(CognitiveExercise exercise) async {
    return await _database.into(_database.cognitiveExerciseTable).insert(
      CognitiveExerciseTableCompanion.insert(
        name: exercise.name,
        type: exercise.type,
        difficulty: exercise.difficulty,
        score: Value(exercise.score),
        maxScore: exercise.maxScore,
        timeSpentSeconds: Value(exercise.timeSpentSeconds),
        isCompleted: Value(exercise.isCompleted),
        exerciseData: Value(exercise.exerciseData),
        completedAt: Value(exercise.completedAt),
        createdAt: Value(exercise.createdAt),
      ),
    );
  }

  @override
  Future<bool> updateExercise(CognitiveExercise exercise) async {
    if (exercise.id == null) return false;
    final rowsUpdated = await (_database.update(_database.cognitiveExerciseTable)
          ..where((t) => t.id.equals(exercise.id!)))
        .write(
      CognitiveExerciseTableCompanion(
        name: Value(exercise.name),
        type: Value(exercise.type),
        difficulty: Value(exercise.difficulty),
        score: Value(exercise.score),
        maxScore: Value(exercise.maxScore),
        timeSpentSeconds: Value(exercise.timeSpentSeconds),
        isCompleted: Value(exercise.isCompleted),
        exerciseData: Value(exercise.exerciseData),
        completedAt: Value(exercise.completedAt),
      ),
    );
    return rowsUpdated > 0;
  }

  @override
  Future<bool> deleteExercise(int id) async {
    final rowsDeleted = await (_database.delete(_database.cognitiveExerciseTable)
          ..where((t) => t.id.equals(id)))
        .go();
    return rowsDeleted > 0;
  }

  @override
  Future<Map<ExerciseType, double>> getAverageScoresByType() async {
    final Map<ExerciseType, double> averages = {};
    
    for (final type in ExerciseType.values) {
      final exercises = await getExercisesByType(type);
      final completedExercises = exercises.where((e) => e.isCompleted && e.score != null).toList();
      
      if (completedExercises.isNotEmpty) {
        final totalPercentage = completedExercises
            .map((e) => e.percentage!)
            .reduce((a, b) => a + b);
        averages[type] = totalPercentage / completedExercises.length;
      }
    }
    
    return averages;
  }

  @override
  Future<List<CognitiveExercise>> getRecentExercises({int limit = 10}) async {
    final exercises = await (_database.select(_database.cognitiveExerciseTable)
          ..where((t) => t.isCompleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
          ..limit(limit))
        .get();
    return exercises.map(_mapToEntity).toList();
  }

  CognitiveExercise _mapToEntity(CognitiveExerciseEntry entry) {
    return CognitiveExercise(
      id: entry.id,
      name: entry.name,
      type: entry.type,
      difficulty: entry.difficulty,
      score: entry.score,
      maxScore: entry.maxScore,
      timeSpentSeconds: entry.timeSpentSeconds,
      isCompleted: entry.isCompleted,
      exerciseData: entry.exerciseData,
      completedAt: entry.completedAt,
      createdAt: entry.createdAt,
    );
  }
}