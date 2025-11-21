import 'package:flutter_test/flutter_test.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/domain/entities/cognitive_activity.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';

void main() {
  group('CognitiveActivity', () {
    late Assessment testAssessment;
    late CognitiveExercise testExercise;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);

      testAssessment = Assessment(
        id: 1,
        type: AssessmentType.processingSpeed,
        score: 85,
        maxScore: 100,
        notes: 'Trail Making Test A',
        completedAt: testDate,
        createdAt: testDate,
      );

      testExercise = CognitiveExercise(
        id: 1,
        name: 'Memory Match',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 90,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: true,
        completedAt: testDate.add(const Duration(hours: 1)),
        createdAt: testDate,
      );
    });

    group('fromAssessment', () {
      test('creates CognitiveActivity from Assessment', () {
        final activity = CognitiveActivity.fromAssessment(testAssessment);

        expect(activity.assessment, equals(testAssessment));
        expect(activity.exercise, isNull);
        expect(activity.isAssessment, isTrue);
        expect(activity.isExercise, isFalse);
      });

      test('returns correct name for assessment', () {
        final activity = CognitiveActivity.fromAssessment(testAssessment);

        expect(activity.name, equals('Processing Speed'));
      });

      test('returns correct score for assessment', () {
        final activity = CognitiveActivity.fromAssessment(testAssessment);

        expect(activity.score, equals(85.0));
      });

      test('returns correct completedAt for assessment', () {
        final activity = CognitiveActivity.fromAssessment(testAssessment);

        expect(activity.completedAt, equals(testDate));
      });

      test('returns correct icon type for assessment', () {
        final activity = CognitiveActivity.fromAssessment(testAssessment);

        expect(activity.iconType, equals('assessment'));
      });
    });

    group('fromExercise', () {
      test('creates CognitiveActivity from Exercise', () {
        final activity = CognitiveActivity.fromExercise(testExercise);

        expect(activity.exercise, equals(testExercise));
        expect(activity.assessment, isNull);
        expect(activity.isExercise, isTrue);
        expect(activity.isAssessment, isFalse);
      });

      test('returns correct name for exercise', () {
        final activity = CognitiveActivity.fromExercise(testExercise);

        expect(activity.name, equals('Memory Match'));
      });

      test('returns correct score for exercise', () {
        final activity = CognitiveActivity.fromExercise(testExercise);

        expect(activity.score, equals(90.0));
      });

      test('returns correct completedAt for exercise', () {
        final activity = CognitiveActivity.fromExercise(testExercise);

        expect(activity.completedAt, equals(testDate.add(const Duration(hours: 1))));
      });

      test('returns correct icon type for exercise', () {
        final activity = CognitiveActivity.fromExercise(testExercise);

        expect(activity.iconType, equals('exercise'));
      });

      test('handles exercise with null score', () {
        final incompleteExercise = testExercise.copyWith(
          score: null,
          isCompleted: false,
        );
        final activity = CognitiveActivity.fromExercise(incompleteExercise);

        expect(activity.score, equals(0.0));
      });
    });

    group('compareTo', () {
      test('sorts by completedAt descending (most recent first)', () {
        final olderAssessment = testAssessment.copyWith(
          completedAt: DateTime(2024, 1, 14),
        );
        final newerExercise = testExercise.copyWith(
          completedAt: DateTime(2024, 1, 16),
        );

        final activity1 = CognitiveActivity.fromAssessment(olderAssessment);
        final activity2 = CognitiveActivity.fromExercise(newerExercise);

        expect(activity2.compareTo(activity1), lessThan(0));
        expect(activity1.compareTo(activity2), greaterThan(0));
      });

      test('sorts same date as equal', () {
        final activity1 = CognitiveActivity.fromAssessment(testAssessment);
        final activity2 = CognitiveActivity.fromAssessment(
          testAssessment.copyWith(score: 70),
        );

        expect(activity1.compareTo(activity2), equals(0));
      });
    });

    group('equality', () {
      test('two activities from same assessment are equal', () {
        final activity1 = CognitiveActivity.fromAssessment(testAssessment);
        final activity2 = CognitiveActivity.fromAssessment(testAssessment);

        expect(activity1, equals(activity2));
        expect(activity1.hashCode, equals(activity2.hashCode));
      });

      test('two activities from same exercise are equal', () {
        final activity1 = CognitiveActivity.fromExercise(testExercise);
        final activity2 = CognitiveActivity.fromExercise(testExercise);

        expect(activity1, equals(activity2));
        expect(activity1.hashCode, equals(activity2.hashCode));
      });

      test('activities from different sources are not equal', () {
        final activity1 = CognitiveActivity.fromAssessment(testAssessment);
        final activity2 = CognitiveActivity.fromExercise(testExercise);

        expect(activity1, isNot(equals(activity2)));
      });
    });
  });
}
