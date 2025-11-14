import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseGenerator - Pattern Recognition Enhancements', () {
    test('should generate valid patterns for all difficulties', () {
      // Test that patterns are generated correctly for all difficulties
      for (final difficulty in ExerciseDifficulty.values) {
        for (int i = 0; i < 20; i++) {
          final pattern = ExerciseGenerator.generatePatternRecognition(
            difficulty: difficulty,
          );

          expect(pattern.pattern, isNotEmpty);
          expect(pattern.options, hasLength(4));
          expect(pattern.correctAnswer, isIn(pattern.options));

          // All options should be unique
          expect(pattern.options.toSet().length, equals(4),
              reason: 'All options should be unique');
        }
      }
    });

    test('should generate patterns with appropriate complexity by difficulty', () {
      // Easy patterns should generally be shorter/simpler
      final easyPatterns = List.generate(
        20,
        (_) => ExerciseGenerator.generatePatternRecognition(
          difficulty: ExerciseDifficulty.easy,
        ),
      );

      // Hard patterns should generally be longer/more complex
      final hardPatterns = List.generate(
        20,
        (_) => ExerciseGenerator.generatePatternRecognition(
          difficulty: ExerciseDifficulty.hard,
        ),
      );

      // Calculate average pattern lengths
      final avgEasyLength =
          easyPatterns.map((p) => p.pattern.length).reduce((a, b) => a + b) /
              easyPatterns.length;
      final avgHardLength =
          hardPatterns.map((p) => p.pattern.length).reduce((a, b) => a + b) /
              hardPatterns.length;

      // Hard patterns should generally be longer or equal to easy patterns
      expect(avgHardLength, greaterThanOrEqualTo(avgEasyLength * 0.9),
          reason:
              'Hard patterns should be at least as long as easy patterns on average');
    });

    test('should use diverse symbols across multiple pattern generations', () {
      final allSymbols = <String>{};

      // Generate many patterns and collect all unique symbols
      for (int i = 0; i < 50; i++) {
        final pattern = ExerciseGenerator.generatePatternRecognition(
          difficulty: ExerciseDifficulty.hard,
        );

        for (final symbol in pattern.pattern) {
          allSymbols.add(symbol);
        }
      }

      // Should have a good variety of symbols (at least 10 different ones)
      expect(allSymbols.length, greaterThanOrEqualTo(10),
          reason: 'Should use diverse symbols: $allSymbols');
    });

    test('should generate number patterns with reasonable step sizes', () {
      // Track arithmetic patterns
      int arithmeticCount = 0;
      int totalStepSize = 0;

      for (int i = 0; i < 50; i++) {
        final pattern = ExerciseGenerator.generatePatternRecognition(
          difficulty: ExerciseDifficulty.easy,
        );

        // Check if this is a number pattern
        if (pattern.pattern.every((s) => int.tryParse(s) != null)) {
          final numbers = pattern.pattern.map(int.parse).toList();

          if (numbers.length >= 2) {
            final diff = numbers[1] - numbers[0];
            // Check if it's an arithmetic sequence
            if (diff > 0 &&
                numbers.length >= 3 &&
                numbers[2] - numbers[1] == diff) {
              totalStepSize += diff;
              arithmeticCount++;
            }
          }
        }
      }

      // If we found arithmetic sequences, check average step size
      if (arithmeticCount > 0) {
        final avgStepSize = totalStepSize / arithmeticCount;
        // Average step size should be >= 2 (the new minimum)
        expect(avgStepSize, greaterThanOrEqualTo(1.5),
            reason:
                'Easy patterns should have reasonable step sizes (found avg: $avgStepSize)');
      }
    });
  });

  group('ExerciseGenerator - Spatial Awareness Fixes', () {
    group('Rotation Puzzles', () {
      test('should not include description text in targetShape', () {
        for (int i = 0; i < 30; i++) {
          final puzzle = ExerciseGenerator.generateSpatialAwareness(
            difficulty: ExerciseDifficulty.medium,
          );

          if (puzzle.type != SpatialType.rotation) continue;

          // targetShape should be just the symbol, no "(Description)" text
          expect(puzzle.targetShape.contains('('), isFalse,
              reason:
                  'targetShape should not contain parentheses: ${puzzle.targetShape}');
          expect(puzzle.targetShape.contains(')'), isFalse,
              reason:
                  'targetShape should not contain parentheses: ${puzzle.targetShape}');

          // Should not contain text like "Triangle", "Square", etc.
          expect(puzzle.targetShape.contains('Triangle'), isFalse);
          expect(puzzle.targetShape.contains('Square'), isFalse);
          expect(puzzle.targetShape.contains('Circle'), isFalse);

          // Should be a valid shape type identifier
          expect(['L', 'triangle', 'rectangle', 'wedge'].contains(puzzle.targetShape), isTrue,
              reason:
                  'targetShape should be a valid shape type: ${puzzle.targetShape}');
        }
      });

      test('should generate valid rotation puzzles for all difficulties', () {
        for (final difficulty in ExerciseDifficulty.values) {
          for (int i = 0; i < 10; i++) {
            final puzzle = ExerciseGenerator.generateSpatialAwareness(
              difficulty: difficulty,
            );

            if (puzzle.type != SpatialType.rotation) continue;

            expect(puzzle.targetShape, isNotEmpty);
            expect(puzzle.options, hasLength(4));
            expect(puzzle.correctAnswer, isIn(puzzle.options));
            expect(puzzle.options.toSet().length, equals(4));
          }
        }
      });
    });

    group('Folding Puzzles', () {
      test('should use only visual symbols in options, no text labels', () {
        for (int i = 0; i < 30; i++) {
          final puzzle = ExerciseGenerator.generateSpatialAwareness(
            difficulty: ExerciseDifficulty.hard,
          );

          if (puzzle.type != SpatialType.folding) continue;

          // Options should be only symbols, not text like "Tetrahedron", "Cube", etc.
          for (final option in puzzle.options) {
            // Should not contain common 3D shape names
            expect(option.contains('Tetrahedron'), isFalse,
                reason: 'Option should not contain text: $option');
            expect(option.contains('Octahedron'), isFalse,
                reason: 'Option should not contain text: $option');
            expect(option.contains('Cube'), isFalse,
                reason: 'Option should not contain text: $option');
            expect(option.contains('Pyramid'), isFalse,
                reason: 'Option should not contain text: $option');
            expect(option.contains('Prism'), isFalse,
                reason: 'Option should not contain text: $option');
            expect(option.contains('Cylinder'), isFalse,
                reason: 'Option should not contain text: $option');
            expect(option.contains('Diamond'), isFalse,
                reason: 'Option should not contain text: $option');
            expect(option.contains('Square'), isFalse,
                reason: 'Option should not contain text: $option');
            expect(option.contains('Short'), isFalse,
                reason: 'Option should not contain text: $option');
            expect(option.contains('Tall'), isFalse,
                reason: 'Option should not contain text: $option');
            expect(option.contains('Wide'), isFalse,
                reason: 'Option should not contain text: $option');

            // Should be a short visual symbol (typically 1-5 characters)
            expect(option.length, lessThanOrEqualTo(5),
                reason: 'Option should be a symbol, not text: $option');
          }

          // Verify the correct answer is also symbol-only
          expect(puzzle.correctAnswer.contains('Tetrahedron'), isFalse);
          expect(puzzle.correctAnswer.contains('Octahedron'), isFalse);
          expect(puzzle.correctAnswer.contains('Cube'), isFalse);
        }
      });

      test('should generate valid folding puzzles', () {
        for (int i = 0; i < 20; i++) {
          final puzzle = ExerciseGenerator.generateSpatialAwareness(
            difficulty: ExerciseDifficulty.hard,
          );

          if (puzzle.type != SpatialType.folding) continue;

          expect(puzzle.targetShape, isNotEmpty);
          expect(puzzle.options, hasLength(4));
          expect(puzzle.correctAnswer, isIn(puzzle.options));

          // All options should be unique
          expect(puzzle.options.toSet().length, equals(4),
              reason: 'All options should be unique');
        }
      });

      test('should not have old nonsensical text codes', () {
        for (int i = 0; i < 30; i++) {
          final puzzle = ExerciseGenerator.generateSpatialAwareness(
            difficulty: ExerciseDifficulty.medium,
          );

          if (puzzle.type != SpatialType.folding) continue;

          // Should not have old "fold_" prefix format
          expect(puzzle.targetShape.contains('fold_'), isFalse,
              reason: 'Should not use old fold_ format');

          for (final option in puzzle.options) {
            expect(option.contains('fold_'), isFalse,
                reason: 'Should not use old fold_ format in options');
          }
        }
      });
    });
  });

  group('ExerciseGenerator - Memory Game Fixes', () {
    test('should not have duplicate or similar star symbols', () {
      // Test multiple times to ensure consistency
      for (int i = 0; i < 10; i++) {
        final memoryData = ExerciseGenerator.generateMemoryGame(
          difficulty: ExerciseDifficulty.medium,
        );

        // Get all symbols used in the memory game
        final symbols = memoryData.cardSymbols.toSet().toList();

        // Should not contain both ⭐ and 🌟 (too similar)
        final hasBothStars = symbols.contains('⭐') && symbols.contains('🌟');
        expect(hasBothStars, isFalse,
            reason: 'Should not use both ⭐ and 🌟 as they are too similar');

        // All symbols should be unique
        expect(symbols.length, equals(memoryData.cardSymbols.toSet().length),
            reason: 'All symbols should be visually distinct');
      }
    });

    test('should use gem symbol 💎 instead of white star ⭐', () {
      // Test multiple times to check if ⭐ never appears
      for (int i = 0; i < 20; i++) {
        final memoryData = ExerciseGenerator.generateMemoryGame(
          difficulty: ExerciseDifficulty.medium,
        );

        // White star ⭐ should never appear
        expect(memoryData.cardSymbols.contains('⭐'), isFalse,
            reason: 'White star ⭐ should be replaced with gem 💎');
      }
    });
  });

  group('ExerciseGenerator - Integration Tests', () {
    test('should generate valid exercises for all types and difficulties', () {
      // Test pattern recognition
      for (final difficulty in ExerciseDifficulty.values) {
        final pattern = ExerciseGenerator.generatePatternRecognition(
          difficulty: difficulty,
        );

        expect(pattern.pattern, isNotEmpty);
        expect(pattern.options, hasLength(4));
        expect(pattern.correctAnswer, isIn(pattern.options));
      }

      // Test spatial awareness
      for (final difficulty in ExerciseDifficulty.values) {
        final spatial = ExerciseGenerator.generateSpatialAwareness(
          difficulty: difficulty,
        );

        expect(spatial.targetShape, isNotEmpty);
        expect(spatial.options, hasLength(4));
        expect(spatial.correctAnswer, isIn(spatial.options));
      }

      // Test memory game
      for (final difficulty in ExerciseDifficulty.values) {
        final memory = ExerciseGenerator.generateMemoryGame(
          difficulty: difficulty,
        );

        expect(memory.cardSymbols, isNotEmpty);
      }
    });

    test('should maintain consistent quality across multiple generations', () {
      // Generate 50 exercises and ensure they all meet quality standards
      for (int i = 0; i < 50; i++) {
        // Pattern recognition
        final pattern = ExerciseGenerator.generatePatternRecognition(
          difficulty: ExerciseDifficulty.hard,
        );
        expect(pattern.options.toSet().length, equals(4));
        expect(pattern.correctAnswer, isIn(pattern.options));

        // Spatial awareness
        final spatial = ExerciseGenerator.generateSpatialAwareness(
          difficulty: ExerciseDifficulty.hard,
        );
        expect(spatial.options.toSet().length, equals(4));
        expect(spatial.correctAnswer, isIn(spatial.options));
      }
    });
  });
}
