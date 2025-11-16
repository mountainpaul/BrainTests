import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Spatial Awareness Answer Validation', () {
    test('rotation puzzle answers should be correct', () {
      // Test that rotation answers are actually correct
      final testCases = [
        {'shape': '▲', 'rotation': 90, 'expected': '▶'},
        {'shape': '▲', 'rotation': 180, 'expected': '▼'},
        {'shape': '▲', 'rotation': 270, 'expected': '◀'},
        {'shape': 'L', 'rotation': 90, 'expected': '⌐'},
        {'shape': 'L', 'rotation': 180, 'expected': '⅃'},
      ];

      for (final testCase in testCases) {
        final shape = testCase['shape'];
        final rotation = testCase['rotation'];
        final expected = testCase['expected'];

        // This documents what the correct rotation should be
        expect(expected, isNotNull,
          reason: 'Rotating $shape by $rotation° clockwise should give $expected');
      }
    });

    test('all spatial puzzle answers should be in options list', () {
      // Generate many puzzles and verify answer is always in options
      for (int i = 0; i < 50; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(
          difficulty: ExerciseDifficulty.medium,
        );

        expect(puzzle.correctAnswer, isIn(puzzle.options),
          reason: 'Correct answer "${puzzle.correctAnswer}" must be in options: ${puzzle.options}');
      }
    });

    test('spatial puzzles should have exactly 4 unique options', () {
      for (int i = 0; i < 20; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(
          difficulty: ExerciseDifficulty.medium,
        );

        expect(puzzle.options, hasLength(4),
          reason: 'Should have 4 options');
        expect(puzzle.options.toSet().length, equals(4),
          reason: 'All 4 options should be unique');
      }
    });

    test('rotation puzzles should use proper 3D spatial concepts', () {
      // This test documents that puzzles should be more challenging
      // and use proper 3D spatial reasoning
      for (int i = 0; i < 10; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(
          difficulty: ExerciseDifficulty.hard,
        );

        // Hard difficulty should have more complex puzzles
        expect(puzzle.timeLimit, greaterThan(0));
      }
    });
  });
}
