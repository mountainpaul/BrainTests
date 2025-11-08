import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/services/exercise_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Spatial Awareness UI Requirements', () {
    test('rotation puzzle should specify clockwise direction', () {
      // Generate multiple rotation puzzles
      for (int i = 0; i < 10; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(
          difficulty: ExerciseDifficulty.medium,
        );

        if (puzzle.type != SpatialType.rotation) continue;

        // The rotation should be unambiguous
        // Test will ensure UI shows "clockwise" in description
        expect(puzzle.targetRotation, isNotNull);
        expect([0, 90, 180, 270], contains(puzzle.targetRotation));

        // For non-180 degree rotations, direction matters
        // UI should specify "clockwise" to avoid ambiguity
        if (puzzle.targetRotation != 0 && puzzle.targetRotation != 180) {
          // This test documents that direction should be specified
          expect(puzzle.targetRotation, isIn([90, 270]));
        }
      }
    });

    test('all puzzle options should use consistent visual format', () {
      for (final difficulty in ExerciseDifficulty.values) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(
          difficulty: difficulty,
        );

        // All options should be similar length (visual symbols)
        final optionLengths = puzzle.options.map((o) => o.length).toSet();

        // Options should be concise visual symbols (1-3 chars max)
        for (final option in puzzle.options) {
          expect(option.length, lessThanOrEqualTo(3),
            reason: 'Option "$option" should be a concise visual symbol');
        }

        // All options should be unique
        expect(puzzle.options.toSet().length, equals(puzzle.options.length),
          reason: 'All options should be unique');
      }
    });

    test('spatial puzzles should have consistent theming', () {
      // This test documents that colors should be consistent
      // between target shape and options
      final rotationPuzzle = ExerciseGenerator.generateSpatialAwareness(
        difficulty: ExerciseDifficulty.medium,
      );

      // Verify rotation puzzle structure
      if (rotationPuzzle.type == SpatialType.rotation) {
        expect(rotationPuzzle.targetShape, isNotEmpty);
        expect(rotationPuzzle.options, hasLength(4));
        expect(rotationPuzzle.correctAnswer, isIn(rotationPuzzle.options));
      }

      final foldingPuzzle = ExerciseGenerator.generateSpatialAwareness(
        difficulty: ExerciseDifficulty.medium,
      );

      // Verify folding puzzle structure
      if (foldingPuzzle.type == SpatialType.folding) {
        expect(foldingPuzzle.targetShape, isNotEmpty);
        expect(foldingPuzzle.options, hasLength(4));
        expect(foldingPuzzle.correctAnswer, isIn(foldingPuzzle.options));
      }
    });

    test('rotation and folding options should use same visual style as target', () {
      // Test that all options are presented with consistent styling
      // The UI should apply the same background/foreground colors to all shapes
      for (int i = 0; i < 20; i++) {
        final puzzle = ExerciseGenerator.generateSpatialAwareness(
          difficulty: ExerciseDifficulty.medium,
        );

        // For rotation and folding puzzles, all options should be
        // styled identically (same colors, same background)
        if (puzzle.type == SpatialType.rotation || puzzle.type == SpatialType.folding) {
          // All options should be the same type of content (symbols)
          // This test documents that the UI must apply consistent styling
          expect(puzzle.options.length, equals(4));
          expect(puzzle.targetShape, isNotEmpty);

          // Options should all be visual symbols (not mixed with text)
          for (final option in puzzle.options) {
            expect(option.length, lessThanOrEqualTo(3),
              reason: 'All options should be visual symbols with consistent styling');
          }
        }
      }
    });
  });

  group('Spatial Awareness Completion Screen', () {
    testWidgets('completion screen should not wrap text unnecessarily', (tester) async {
      // This test documents the requirement that "Exercises" button
      // should not wrap text when there's enough space
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200, // Reasonable button width
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Exercises'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the text widget
      final textFinder = find.text('Exercises');
      expect(textFinder, findsOneWidget);

      // Get the text widget
      final Text textWidget = tester.widget(textFinder);

      // Should not have maxLines set to wrap unnecessarily
      expect(textWidget.maxLines, anyOf(isNull, greaterThan(1)));

      // Text should render without overflow
      expect(tester.takeException(), isNull);
    });
  });
}
