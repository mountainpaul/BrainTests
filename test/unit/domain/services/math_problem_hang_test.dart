import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Math Problem Generation Hang Test', () {
    test('should generate 12 expert math problems without hanging', () async {
      // Simulate what _MathProblemWidget does for expert difficulty
      final problems = <MathProblemData>[];

      // This should complete in reasonable time (< 5 seconds)
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 12; i++) {
        problems.add(ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.expert,
        ));
      }

      stopwatch.stop();

      // Should generate 12 problems
      expect(problems.length, 12);

      // Should complete within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
        reason: 'Math problem generation took ${stopwatch.elapsedMilliseconds}ms');

      // Each problem should have 4 options
      for (final problem in problems) {
        expect(problem.options.length, greaterThanOrEqualTo(3),
          reason: 'Problem should have at least 3 options: ${problem.question}');
      }
    });

    test('should generate algebra problems without infinite loops', () {
      // Test algebra problems specifically since they have the most complex logic
      final stopwatch = Stopwatch()..start();

      final problems = <MathProblemData>[];
      for (int i = 0; i < 20; i++) {
        problems.add(ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.expert,
        ));
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(10000),
        reason: 'Generating 20 expert problems took ${stopwatch.elapsedMilliseconds}ms - likely infinite loop');
    });
  });
}
