import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/data/repositories/cognitive_exercise_repository_impl.dart';
import 'package:brain_plan/domain/entities/cognitive_exercise.dart';
import 'package:flutter_test/flutter_test.dart';

/// Direct test of repository to verify exercises are saved
void main() {
  late AppDatabase database;
  late CognitiveExerciseRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.memory();
    repository = CognitiveExerciseRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('repository should save exercise to database', () async {
    // Arrange
    final exercise = CognitiveExercise(
      name: 'Memory Game',
      type: ExerciseType.memoryGame,
      difficulty: ExerciseDifficulty.medium,
      score: 85,
      maxScore: 100,
      timeSpentSeconds: 120,
      isCompleted: true,
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    // Act
    final id = await repository.insertExercise(exercise);

    // Assert
    expect(id, greaterThan(0));

    // Verify it's in the database
    final saved = await database.select(database.cognitiveExerciseTable).get();
    expect(saved.length, equals(1));
    expect(saved.first.name, equals('Memory Game'));
    expect(saved.first.score, equals(85));
  });

  test('repository should return completed exercises', () async {
    // Arrange
    final exercise = CognitiveExercise(
      name: 'Memory Game',
      type: ExerciseType.memoryGame,
      difficulty: ExerciseDifficulty.medium,
      score: 85,
      maxScore: 100,
      timeSpentSeconds: 120,
      isCompleted: true,
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await repository.insertExercise(exercise);

    // Act
    final completed = await repository.getCompletedExercises();

    // Assert
    expect(completed.length, equals(1));
    expect(completed.first.name, equals('Memory Game'));
  });
}
