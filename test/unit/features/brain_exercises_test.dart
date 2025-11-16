import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:brain_tests/domain/repositories/cognitive_exercise_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([CognitiveExerciseRepository])
import 'brain_exercises_test.mocks.dart';

void main() {
  group('Brain Exercises Tests', () {
    late MockCognitiveExerciseRepository mockRepository;

    setUp(() {
      mockRepository = MockCognitiveExerciseRepository();
    });

    group('CognitiveExercise Entity Tests', () {
      test('should calculate percentage correctly when score is available', () {
        final exercise = CognitiveExercise(
          name: 'Memory Game',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          score: 8,
          maxScore: 10,
          isCompleted: true,
          createdAt: DateTime.now(),
        );

        expect(exercise.percentage, equals(80.0));
      });

      test('should return null percentage when score is not available', () {
        final exercise = CognitiveExercise(
          name: 'Memory Game',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          maxScore: 10,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        expect(exercise.percentage, isNull);
      });

      test('should format time correctly', () {
        final exercise1 = CognitiveExercise(
          name: 'Memory Game',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          maxScore: 10,
          timeSpentSeconds: 125, // 2 minutes 5 seconds
          isCompleted: true,
          createdAt: DateTime.now(),
        );

        final exercise2 = CognitiveExercise(
          name: 'Math Problem',
          type: ExerciseType.mathProblem,
          difficulty: ExerciseDifficulty.easy,
          maxScore: 5,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        expect(exercise1.formattedTime, equals('2m 5s'));
        expect(exercise2.formattedTime, equals('--'));
      });

      test('should create proper copy with changes', () {
        final original = CognitiveExercise(
          id: 1,
          name: 'Word Puzzle',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.medium,
          score: 7,
          maxScore: 10,
          timeSpentSeconds: 300,
          isCompleted: false,
          exerciseData: 'original data',
          createdAt: DateTime(2024, 1, 1),
        );

        final copy = original.copyWith(
          score: 9,
          isCompleted: true,
          completedAt: DateTime.now(),
        );

        expect(copy.id, equals(1));
        expect(copy.name, equals('Word Puzzle'));
        expect(copy.score, equals(9));
        expect(copy.isCompleted, isTrue);
        expect(copy.completedAt, isNotNull);
      });
    });

    group('Exercise Types Coverage', () {
      test('should support all exercise types', () {
        final types = [
          ExerciseType.memoryGame,
          ExerciseType.wordPuzzle,
          ExerciseType.spanishAnagram,
          ExerciseType.mathProblem,
          ExerciseType.patternRecognition,
          ExerciseType.sequenceRecall,
          ExerciseType.spatialAwareness,
        ];

        for (final type in types) {
          final exercise = CognitiveExercise(
            name: 'Test Exercise',
            type: type,
            difficulty: ExerciseDifficulty.medium,
            score: 5,
            maxScore: 10,
            isCompleted: true,
            createdAt: DateTime.now(),
          );

          expect(exercise.type, equals(type));
          expect(exercise.percentage, equals(50.0));
        }
      });
    });

    group('Exercise Difficulty Levels', () {
      test('should support all difficulty levels', () {
        final difficulties = [
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
          ExerciseDifficulty.expert,
        ];

        for (final difficulty in difficulties) {
          final exercise = CognitiveExercise(
            name: 'Test Exercise',
            type: ExerciseType.memoryGame,
            difficulty: difficulty,
            maxScore: 10,
            isCompleted: false,
            createdAt: DateTime.now(),
          );

          expect(exercise.difficulty, equals(difficulty));
        }
      });
    });

    group('Exercise Repository Integration', () {
      test('should save exercise successfully', () async {
        final exercise = CognitiveExercise(
          name: 'Memory Game',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          maxScore: 10,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final savedExercise = exercise.copyWith(id: 1);
        when(mockRepository.insertExercise(exercise))
            .thenAnswer((_) async => 1);

        final result = await mockRepository.insertExercise(exercise);

        expect(result, equals(1));
        verify(mockRepository.insertExercise(exercise)).called(1);
      });

      test('should retrieve exercises by type', () async {
        final exercises = [
          CognitiveExercise(
            id: 1,
            name: 'Memory Game 1',
            type: ExerciseType.memoryGame,
            difficulty: ExerciseDifficulty.easy,
            score: 8,
            maxScore: 10,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
          CognitiveExercise(
            id: 2,
            name: 'Memory Game 2',
            type: ExerciseType.memoryGame,
            difficulty: ExerciseDifficulty.medium,
            score: 6,
            maxScore: 10,
            isCompleted: true,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        when(mockRepository.getExercisesByType(ExerciseType.memoryGame))
            .thenAnswer((_) async => exercises);

        final result = await mockRepository.getExercisesByType(ExerciseType.memoryGame);

        expect(result.length, equals(2));
        expect(result.every((e) => e.type == ExerciseType.memoryGame), isTrue);
        verify(mockRepository.getExercisesByType(ExerciseType.memoryGame)).called(1);
      });

      test('should update exercise completion', () async {
        final exercise = CognitiveExercise(
          id: 1,
          name: 'Word Puzzle',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.medium,
          maxScore: 10,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final completedExercise = exercise.copyWith(
          score: 9,
          timeSpentSeconds: 180,
          isCompleted: true,
          completedAt: DateTime.now(),
        );

        when(mockRepository.updateExercise(completedExercise))
            .thenAnswer((_) async => true);

        final result = await mockRepository.updateExercise(completedExercise);

        expect(result, isTrue);
        expect(completedExercise.isCompleted, isTrue);
        expect(completedExercise.score, equals(9));
        expect(completedExercise.timeSpentSeconds, equals(180));
        expect(completedExercise.completedAt, isNotNull);
        verify(mockRepository.updateExercise(completedExercise)).called(1);
      });
    });

    group('Exercise Progress Tracking', () {
      test('should track performance improvement by type', () async {
        final exercises = [
          CognitiveExercise(
            id: 1,
            name: 'Math Problem Easy',
            type: ExerciseType.mathProblem,
            difficulty: ExerciseDifficulty.easy,
            score: 8,
            maxScore: 10,
            timeSpentSeconds: 120,
            isCompleted: true,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          CognitiveExercise(
            id: 2,
            name: 'Math Problem Easy',
            type: ExerciseType.mathProblem,
            difficulty: ExerciseDifficulty.easy,
            score: 9,
            maxScore: 10,
            timeSpentSeconds: 90,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ];

        when(mockRepository.getExercisesByType(ExerciseType.mathProblem))
            .thenAnswer((_) async => exercises);

        final result = await mockRepository.getExercisesByType(ExerciseType.mathProblem);

        final sortedByDate = result
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        expect(sortedByDate.first.percentage, equals(80.0));
        expect(sortedByDate.last.percentage, equals(90.0));

        final timeImprovement = sortedByDate.first.timeSpentSeconds! - sortedByDate.last.timeSpentSeconds!;
        expect(timeImprovement, equals(30)); // 30 seconds faster
      });

      test('should calculate average performance by type', () async {
        final exercises = [
          CognitiveExercise(
            id: 1,
            name: 'Pattern Recognition 1',
            type: ExerciseType.patternRecognition,
            difficulty: ExerciseDifficulty.medium,
            score: 7,
            maxScore: 10,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
          CognitiveExercise(
            id: 2,
            name: 'Pattern Recognition 2',
            type: ExerciseType.patternRecognition,
            difficulty: ExerciseDifficulty.medium,
            score: 9,
            maxScore: 10,
            isCompleted: true,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];

        when(mockRepository.getExercisesByType(ExerciseType.patternRecognition))
            .thenAnswer((_) async => exercises);

        final result = await mockRepository.getExercisesByType(ExerciseType.patternRecognition);
        final completedExercises = result.where((e) => e.isCompleted && e.score != null);
        final averagePercentage = completedExercises
            .map((e) => e.percentage!)
            .reduce((a, b) => a + b) / completedExercises.length;

        expect(averagePercentage, equals(80.0));
      });
    });

    group('Exercise Data Handling', () {
      test('should handle exercise data storage', () {
        const exerciseData = '{"sequence": [1, 2, 3], "userResponse": [1, 2, 4]}';
        final exercise = CognitiveExercise(
          name: 'Sequence Recall',
          type: ExerciseType.sequenceRecall,
          difficulty: ExerciseDifficulty.medium,
          maxScore: 10,
          exerciseData: exerciseData,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        expect(exercise.exerciseData, contains('sequence'));
        expect(exercise.exerciseData, contains('userResponse'));
      });

      test('should handle Spanish anagram exercises', () {
        final exercise = CognitiveExercise(
          name: 'Anagrama en Español',
          type: ExerciseType.spanishAnagram,
          difficulty: ExerciseDifficulty.hard,
          score: 5,
          maxScore: 8,
          timeSpentSeconds: 240,
          isCompleted: true,
          exerciseData: '{"word": "CASA", "anagram": "SACA", "solved": true}',
          createdAt: DateTime.now(),
        );

        expect(exercise.type, equals(ExerciseType.spanishAnagram));
        expect(exercise.percentage, equals(62.5));
        expect(exercise.exerciseData, contains('CASA'));
      });
    });

    group('Exercise Edge Cases', () {
      test('should handle perfect scores', () {
        final exercise = CognitiveExercise(
          name: 'Perfect Game',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.expert,
          score: 20,
          maxScore: 20,
          isCompleted: true,
          createdAt: DateTime.now(),
        );

        expect(exercise.percentage, equals(100.0));
      });

      test('should handle zero scores', () {
        final exercise = CognitiveExercise(
          name: 'Challenging Exercise',
          type: ExerciseType.spatialAwareness,
          difficulty: ExerciseDifficulty.expert,
          score: 0,
          maxScore: 15,
          isCompleted: true,
          createdAt: DateTime.now(),
        );

        expect(exercise.percentage, equals(0.0));
      });

      test('should handle incomplete exercises', () {
        final exercise = CognitiveExercise(
          name: 'In Progress',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.medium,
          maxScore: 10,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        expect(exercise.isCompleted, isFalse);
        expect(exercise.score, isNull);
        expect(exercise.percentage, isNull);
        expect(exercise.completedAt, isNull);
      });

      test('should handle long exercise times', () {
        final exercise = CognitiveExercise(
          name: 'Long Exercise',
          type: ExerciseType.sequenceRecall,
          difficulty: ExerciseDifficulty.expert,
          maxScore: 10,
          timeSpentSeconds: 3661, // 1 hour, 1 minute, 1 second
          isCompleted: true,
          createdAt: DateTime.now(),
        );

        expect(exercise.formattedTime, equals('61m 1s'));
      });
    });
  });
}