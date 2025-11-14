import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Spatial Rotation Puzzle Character Verification', () {
    test('L-Block rotations should use correct Unicode characters', () {
      // Generate multiple L-Block puzzles and verify the rotation characters
      for (int i = 0; i < 20; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(difficulty: ExerciseDifficulty.medium);

        if (puzzle.targetShape == 'L') {
          // Check that the correct answer matches expected rotation patterns
          if (puzzle.targetRotation == 0) {
            expect(puzzle.correctAnswer, 'L',
              reason: '0° should be standard L');
          } else if (puzzle.targetRotation == 90) {
            // 90° clockwise: corner at top-left, longest right, shortest down
            // Should look like: ┐ or similar
            expect(puzzle.correctAnswer, '┐',
              reason: '90° should have corner at top-left');
          } else if (puzzle.targetRotation == 180) {
            // 180°: corner at top-right, longest down, shortest left
            // Should look like upside-down backwards L
            expect(puzzle.correctAnswer, '┘',
              reason: '180° should have corner at top-right');
          } else if (puzzle.targetRotation == 270) {
            // 270° clockwise: corner at bottom-right, longest left, shortest up
            // Should look like: └ rotated or ┘ flipped
            expect(puzzle.correctAnswer, '└',
              reason: '270° should have corner at bottom-right');
          }
        }
      }
    });

    test('Right triangle rotations should use correct Unicode characters', () {
      // Generate multiple triangle puzzles and verify the rotation characters
      for (int i = 0; i < 20; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(difficulty: ExerciseDifficulty.medium);

        // Check for wedge/right triangle shape
        if (puzzle.targetShape == '◭' || puzzle.targetShape.contains('triangle')) {
          if (puzzle.targetRotation == 0) {
            // Right angle at bottom-left
            expect(puzzle.correctAnswer, '◤',
              reason: '0° should have right angle at bottom-left');
          } else if (puzzle.targetRotation == 90) {
            // Right angle at top-left
            expect(puzzle.correctAnswer, '◥',
              reason: '90° should have right angle at top-left');
          } else if (puzzle.targetRotation == 180) {
            // Right angle at top-right
            expect(puzzle.correctAnswer, '◢',
              reason: '180° should have right angle at top-right');
          } else if (puzzle.targetRotation == 270) {
            // Right angle at bottom-right
            expect(puzzle.correctAnswer, '◣',
              reason: '270° should have right angle at bottom-right');
          }
        }
      }
    });

    test('Triangle (equilateral) rotations should be correct', () {
      for (int i = 0; i < 20; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(difficulty: ExerciseDifficulty.medium);

        if (puzzle.targetShape == '▲') {
          if (puzzle.targetRotation == 0) {
            expect(puzzle.correctAnswer, '▲', reason: 'Points up');
          } else if (puzzle.targetRotation == 90) {
            expect(puzzle.correctAnswer, '▶', reason: 'Points right');
          } else if (puzzle.targetRotation == 180) {
            expect(puzzle.correctAnswer, '▼', reason: 'Points down');
          } else if (puzzle.targetRotation == 270) {
            expect(puzzle.correctAnswer, '◀', reason: 'Points left');
          }
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
