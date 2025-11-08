import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseGenerator - Spatial Awareness', () {
    group('Rotation Puzzle', () {
      test('should generate rotation puzzle with visual shape symbols only, no text', () {
        // Generate multiple rotation puzzles to test various scenarios
        for (int i = 0; i < 10; i++) {
          final puzzle = ExerciseGenerator.generateSpatialAwareness(
            difficulty: ExerciseDifficulty.medium,
          );

          // Skip if not a rotation puzzle
          if (puzzle.type != SpatialType.rotation) continue;

          // Test 1: targetShape should be a shape symbol WITHOUT description text
          expect(puzzle.targetShape, isNotNull);
          // Should NOT contain parentheses or description text
          expect(puzzle.targetShape.contains('('), isFalse,
            reason: 'targetShape should be symbol only, not "▲ (Triangle)"');
          expect(puzzle.targetShape.contains(')'), isFalse,
            reason: 'targetShape should be symbol only, not "▲ (Triangle)"');

          // Should not contain underscore (no "L_90" format)
          expect(puzzle.targetShape.contains('_'), isFalse,
            reason: 'targetShape should not contain underscore like "L_90"');

          // Should be a short symbol (1-5 characters)
          expect(puzzle.targetShape.length, lessThanOrEqualTo(5),
            reason: 'targetShape should be a visual symbol, not text: ${puzzle.targetShape}');

          // Test 2: Options should not contain text codes like "T_90", "L_90", "Z_180"
          for (final option in puzzle.options) {
            expect(option.contains('_'), isFalse,
              reason: 'Options should not contain text codes like "$option"');

            // Options should be visual symbols or simple rotation indicators
            expect(option.length, lessThanOrEqualTo(10),
              reason: 'Option should be a symbol or simple indicator, not "$option"');
          }

          // Test 3: correctAnswer should not be in the format "SHAPE_DEGREES"
          expect(puzzle.correctAnswer.contains('_'), isFalse,
            reason: 'correctAnswer should not be in format like "Z_180"');

          // Test 4: targetRotation should be a valid rotation angle
          if (puzzle.targetRotation != null) {
            expect([0, 90, 180, 270], contains(puzzle.targetRotation),
              reason: 'targetRotation should be 0, 90, 180, or 270 degrees');
          }
        }
      });

      test('should generate rotation puzzle with consistent shape representations', () {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(
          difficulty: ExerciseDifficulty.medium,
        );

        if (puzzle.type != SpatialType.rotation) {
          return; // Skip if not rotation puzzle
        }

        // The puzzle should use visual symbols like arrows or shapes
        // Common rotation symbols: ↑, →, ↓, ←, ↗, ↘, ↙, ↖
        // Or shape symbols: L, T, Z rotated visually
        expect(puzzle.targetShape, isNotEmpty);
        expect(puzzle.options, hasLength(4));
        expect(puzzle.correctAnswer, isIn(puzzle.options));
      });

      test('should generate all difficulties correctly', () {
        for (final difficulty in ExerciseDifficulty.values) {
          final puzzle = ExerciseGenerator.generateSpatialAwareness(
            difficulty: difficulty,
          );

          // Skip if not rotation puzzle
          if (puzzle.type != SpatialType.rotation) continue;

          expect(puzzle.targetShape, isNotEmpty);
          expect(puzzle.options, hasLength(4));
          expect(puzzle.options.toSet().length, equals(4),
            reason: 'All options should be unique');
        }
      });
    });

    group('Folding Puzzle', () {
      test('should use shape symbols only, not text labels or codes', () {
        for (int i = 0; i < 10; i++) {
          final puzzle = ExerciseGenerator.generateSpatialAwareness(
            difficulty: ExerciseDifficulty.medium,
          );

          // Skip if not a folding puzzle
          if (puzzle.type != SpatialType.folding) continue;

          // Should not contain "fold_" prefix
          expect(puzzle.targetShape.contains('fold_'), isFalse,
            reason: 'targetShape should be a symbol, not "fold_1", "fold_2", etc.');

          for (final option in puzzle.options) {
            expect(option.contains('fold_'), isFalse,
              reason: 'Options should be symbols, not text codes');

            // Should not contain text labels like "Tetrahedron", "Cube", etc.
            expect(option.contains('Tetrahedron'), isFalse,
              reason: 'Option should be symbol only: $option');
            expect(option.contains('Octahedron'), isFalse,
              reason: 'Option should be symbol only: $option');
            expect(option.contains('Cube'), isFalse,
              reason: 'Option should be symbol only: $option');
            expect(option.contains('Pyramid'), isFalse,
              reason: 'Option should be symbol only: $option');

            // Should be short (1-5 characters for symbols)
            expect(option.length, lessThanOrEqualTo(5),
              reason: 'Option should be a visual symbol: $option');
          }
        }
      });
    });
  });
}
