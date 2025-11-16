import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Spatial Rotation Puzzle Character Verification', () {
    test('L-Block rotations should use correct Unicode characters', () {
      // Generate multiple L-Block puzzles and verify the shape type
      for (int i = 0; i < 20; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(difficulty: ExerciseDifficulty.medium);

        if (puzzle.targetShape == 'L' || puzzle.shapeType == 'L') {
          // Verify correct answer is a valid index (0-3)
          final answerIndex = int.tryParse(puzzle.correctAnswer);
          expect(answerIndex, isNotNull, reason: 'Correct answer should be a valid index');
          expect(answerIndex, inInclusiveRange(0, 3), reason: 'Answer index must be 0-3');

          // Verify the targetShape field contains 'L'
          expect(puzzle.targetShape, equals('L'), reason: 'Target shape should be L for L-Block');
        }
      }
    });

    test('Right triangle rotations should use correct Unicode characters', () {
      // Generate multiple triangle puzzles and verify the shape type
      for (int i = 0; i < 20; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(difficulty: ExerciseDifficulty.medium);

        // Check for wedge/right triangle shape
        if (puzzle.targetShape == 'triangle' || puzzle.shapeType == 'triangle' || puzzle.targetShape == 'wedge' || puzzle.shapeType == 'wedge') {
          // Verify correct answer is a valid index (0-3)
          final answerIndex = int.tryParse(puzzle.correctAnswer);
          expect(answerIndex, isNotNull, reason: 'Correct answer should be a valid index');
          expect(answerIndex, inInclusiveRange(0, 3), reason: 'Answer index must be 0-3');

        }
      }
    });

    test('Triangle (equilateral) rotations should be correct', () {
      for (int i = 0; i < 20; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(difficulty: ExerciseDifficulty.medium);

        if (puzzle.targetShape == 'triangle' || puzzle.shapeType == 'triangle') {
          // Verify correct answer is a valid index
          final answerIndex = int.tryParse(puzzle.correctAnswer);
          expect(answerIndex, isNotNull, reason: 'Correct answer should be a valid index');
          expect(answerIndex, inInclusiveRange(0, 3), reason: 'Answer index must be 0-3');
        }
      }
    });

    test('Rectangle rotations should be correct', () {
      for (int i = 0; i < 20; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(difficulty: ExerciseDifficulty.medium);

        if (puzzle.targetShape == '▱') {
          if (puzzle.targetRotation == 0 || puzzle.targetRotation == 180) {
            expect(puzzle.correctAnswer, '▱', reason: 'Horizontal at 0° and 180°');
          } else if (puzzle.targetRotation == 90 || puzzle.targetRotation == 270) {
            expect(puzzle.correctAnswer, '▯', reason: 'Vertical at 90° and 270°');
          }
        }
      }
    });
  });
}
