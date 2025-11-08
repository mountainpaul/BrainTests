import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Math problem bug fix tests
///
/// Tests for issues found in production:
/// 1. Comparison problem asks "which is larger" when both numbers are equal
/// 2. Exercise crashes on third problem (checking for similar issues to anagram)
void main() {
  group('Math Problem - Comparison Bug Fix', () {
    test('should never generate comparison problem with equal numbers', () {
      // Generate 100 comparison problems to check for the bug
      for (int i = 0; i < 100; i++) {
        final problem = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.easy,
        );

        // If it's a comparison problem
        if (problem.question.contains('Which is larger')) {
          // Extract numbers from question "Which is larger: X or Y?"
          final regex = RegExp(r'Which is larger: (\d+) or (\d+)');
          final match = regex.firstMatch(problem.question);

          if (match != null) {
            final num1 = int.parse(match.group(1)!);
            final num2 = int.parse(match.group(2)!);

            // Numbers should NEVER be equal
            expect(num1, isNot(equals(num2)),
                reason: 'Comparison problem has equal numbers: $num1 == $num2');

            // Answer should be the larger number
            expect(problem.answer, greaterThan(0));
            expect([num1, num2].contains(problem.answer), true,
                reason: 'Answer ${problem.answer} should be one of [$num1, $num2]');

            // Answer should be the larger of the two
            final larger = num1 > num2 ? num1 : num2;
            expect(problem.answer, larger,
                reason: 'Answer should be $larger, not ${problem.answer}');
          }
        }
      }
    });

    test('should generate valid comparison problems for all difficulties', () {
      for (final difficulty in ExerciseDifficulty.values) {
        // Generate up to 10 problems, stop after finding 3 comparison problems
        int comparisonCount = 0;
        int attempts = 0;
        const maxAttempts = 30;

        while (comparisonCount < 3 && attempts < maxAttempts) {
          attempts++;
          final problem = ExerciseGenerator.generateMathProblem(
            difficulty: difficulty,
          );

          if (problem.question.contains('Which is larger')) {
            comparisonCount++;
            final regex = RegExp(r'Which is larger: (\d+) or (\d+)');
            final match = regex.firstMatch(problem.question);

            if (match != null) {
              final num1 = int.parse(match.group(1)!);
              final num2 = int.parse(match.group(2)!);

              // Verify numbers are different
              expect(num1, isNot(equals(num2)));

              // Verify answer is correct
              final expectedAnswer = num1 > num2 ? num1 : num2;
              expect(problem.answer, expectedAnswer);
            }
          }
        }

        // Should have found at least one comparison problem in 30 attempts
        expect(comparisonCount, greaterThan(0),
            reason: 'Should generate at least one comparison problem for $difficulty');
      }
    });

    test('should have at least 4 unique options', () {
      for (int i = 0; i < 50; i++) {
        final problem = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.medium,
        );

        expect(problem.options.length, greaterThanOrEqualTo(4));

        // Check for duplicates
        final uniqueOptions = problem.options.toSet();
        expect(uniqueOptions.length, problem.options.length,
            reason: 'Options should be unique, but found duplicates: ${problem.options}');

        // Answer should be in options
        expect(problem.options.contains(problem.answer), true,
            reason: 'Answer ${problem.answer} should be in options ${problem.options}');
      }
    });
  });

  group('Math Problem - Exercise Progression', () {
    test('should generate multiple problems without crashing', () {
      // Simulate generating problems like the exercise screen does
      final problemCounts = {
        ExerciseDifficulty.easy: 5,
        ExerciseDifficulty.medium: 7,
        ExerciseDifficulty.hard: 10,
        ExerciseDifficulty.expert: 12,
      };

      for (final difficulty in ExerciseDifficulty.values) {
        final count = problemCounts[difficulty]!;
        final problems = <MathProblemData>[];

        // Generate expected number of problems
        for (int i = 0; i < count; i++) {
          final problem = ExerciseGenerator.generateMathProblem(
            difficulty: difficulty,
          );
          problems.add(problem);
        }

        expect(problems.length, count);

        // Verify we can access all problems including the third one
        for (int i = 0; i < problems.length; i++) {
          expect(problems[i], isNotNull);
          expect(problems[i].question, isNotEmpty);
          expect(problems[i].options, isNotEmpty);
        }

        // Specifically test accessing third problem (index 2)
        if (problems.length >= 3) {
          expect(problems[2], isNotNull);
          expect(problems[2].question, isNotEmpty);
        }
      }
    });

    test('should handle rapid successive problem generation', () {
      // Generate 50 problems quickly (simulating user going through problems fast)
      for (int i = 0; i < 50; i++) {
        final problem = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.medium,
        );

        expect(problem, isNotNull);
        expect(problem.question, isNotEmpty);
        expect(problem.answer, isNotNull);
        expect(problem.options, isNotEmpty);
      }
    });
  });

  group('Math Problem - Answer Validation', () {
    test('should always have correct answer in options', () {
      for (int i = 0; i < 100; i++) {
        final problem = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.medium,
        );

        expect(problem.options.contains(problem.answer), true,
            reason:
                'Answer ${problem.answer} not found in options ${problem.options} for question: ${problem.question}');
      }
    });

    test('should have reasonable time limits', () {
      for (final difficulty in ExerciseDifficulty.values) {
        final problem = ExerciseGenerator.generateMathProblem(
          difficulty: difficulty,
        );

        expect(problem.timeLimit, greaterThan(0));
        expect(problem.timeLimit, lessThanOrEqualTo(600)); // Max 10 minutes
      }
    });

    test('should generate valid problems for all types', () {
      // Generate many problems to hit different types
      final problemTypes = <MathProblemType>{};

      for (int i = 0; i < 100; i++) {
        final problem = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.medium,
        );

        problemTypes.add(problem.type);

        // Validate problem structure
        expect(problem.question, isNotEmpty);
        expect(problem.answer, isNotNull);
        expect(problem.options.length, greaterThanOrEqualTo(2));
        expect(problem.timeLimit, greaterThan(0));
      }

      // Should generate multiple problem types
      expect(problemTypes.length, greaterThanOrEqualTo(2),
          reason: 'Should generate multiple problem types, but only got: $problemTypes');
    });
  });

  group('Math Problem - Edge Cases', () {
    test('should handle minimum difficulty range', () {
      final problem = ExerciseGenerator.generateMathProblem(
        difficulty: ExerciseDifficulty.easy,
      );

      expect(problem, isNotNull);
      expect(problem.question, isNotEmpty);
      expect(problem.answer, greaterThan(0));
    });

    test('should handle maximum difficulty range', () {
      final problem = ExerciseGenerator.generateMathProblem(
        difficulty: ExerciseDifficulty.expert,
      );

      expect(problem, isNotNull);
      expect(problem.question, isNotEmpty);
      expect(problem.answer, isNotNull);
    });

    test('should never have negative numbers in easy mode', () {
      for (int i = 0; i < 20; i++) {
        final problem = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.easy,
        );

        for (final option in problem.options) {
          expect(option, greaterThanOrEqualTo(0),
              reason: 'Easy mode should not have negative options');
        }

        expect(problem.answer, greaterThanOrEqualTo(0),
            reason: 'Easy mode should not have negative answers');
      }
    });

    test('should generate solvable problems', () {
      for (int i = 0; i < 10; i++) {
        final problem = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.hard,
        );

        // Answer should be a valid integer
        expect(problem.answer, isA<int>());
        expect(problem.answer.isNaN, false);
        expect(problem.answer.isInfinite, false);
      }
    });
  });

  group('Math Problem - Comparison Question Format', () {
    test('comparison questions should always have exactly 2 numbers', () {
      for (int i = 0; i < 10; i++) {
        final problem = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.medium,
        );

        if (problem.question.contains('Which is larger')) {
          final regex = RegExp(r'(\d+)');
          final matches = regex.allMatches(problem.question);

          // Should have exactly 2 numbers in the question
          expect(matches.length, 2,
              reason: 'Comparison question should have 2 numbers: ${problem.question}');
        }
      }
    });

    test('comparison questions should be grammatically correct', () {
      for (int i = 0; i < 50; i++) {
        final problem = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.easy,
        );

        if (problem.question.contains('Which is larger')) {
          // Check format
          expect(problem.question, contains('?'));
          expect(problem.question, contains('or'));
          expect(problem.question.split('or').length, 2,
              reason: 'Should have exactly one "or": ${problem.question}');
        }
      }
    });
  });
}
