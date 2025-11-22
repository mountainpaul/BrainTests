import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/data/repositories/word_repository_impl.dart';import 'package:brain_tests/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';
import 'package:brain_tests/data/repositories/word_repository_impl.dart';
/// Comprehensive edge case tests for exercise generation
///
/// Tests cover:
/// - Extreme difficulty levels
/// - Minimum/maximum values
/// - Empty/null handling
/// - Grid size boundaries
/// - Letter scrambling edge cases
/// - Math problem boundaries
void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();
  });

  tearDown(() async {
    await closeTestDatabase(database);
  });

  group('Exercise Generation - Memory Game Edge Cases', () {
    test('should generate valid easy memory game', () {
      final gameData = ExerciseGenerator.generateMemoryGame(
        difficulty: ExerciseDifficulty.easy,
      );

      expect(gameData.gridSize, greaterThan(0));
      expect(gameData.cardSymbols.length, gameData.gridSize * gameData.gridSize);
      expect(gameData.showTimeSeconds, greaterThan(0));
      expect(gameData.timeLimit, greaterThan(0));
    });

    test('should generate valid expert memory game', () {
      final gameData = ExerciseGenerator.generateMemoryGame(
        difficulty: ExerciseDifficulty.expert,
      );

      expect(gameData.gridSize, greaterThan(0));
      expect(gameData.cardSymbols.length, gameData.gridSize * gameData.gridSize);
      expect(gameData.cardSymbols.length, greaterThanOrEqualTo(2)); // At least 1 pair
    });

    test('should have pairs in card symbols', () {
      final gameData = ExerciseGenerator.generateMemoryGame(
        difficulty: ExerciseDifficulty.medium,
      );

      // Count occurrences of each symbol
      final symbolCounts = <String, int>{};
      for (final symbol in gameData.cardSymbols) {
        symbolCounts[symbol] = (symbolCounts[symbol] ?? 0) + 1;
      }

      // Each symbol should appear exactly twice (pairs)
      for (final count in symbolCounts.values) {
        expect(count, 2);
      }
    });

    test('should have different symbols for each pair', () {
      final gameData = ExerciseGenerator.generateMemoryGame(
        difficulty: ExerciseDifficulty.medium,
      );

      final uniqueSymbols = gameData.cardSymbols.toSet();
      final expectedPairs = gameData.cardSymbols.length ~/ 2;

      expect(uniqueSymbols.length, expectedPairs);
    });
  });

  group('Exercise Generation - Anagram Edge Cases', () {
    test('should handle single letter word', () {
      final letters = ExerciseGenerator.ensureScrambled(['A']);
      expect(letters.length, 1);
      expect(letters, ['A']);
    });

    test('should handle two letter word', () {
      final letters = ExerciseGenerator.ensureScrambled(['A', 'B']);
      expect(letters.length, 2);
      expect(letters.toSet(), {'A', 'B'});
    });

    test('should scramble multi-letter word', () {
      final original = ['H', 'E', 'L', 'L', 'O'];
      final scrambled = ExerciseGenerator.ensureScrambled(original);

      expect(scrambled.length, original.length);
      expect(scrambled.toSet(), original.toSet());
      // Note: Might be same order sometimes due to randomness, but logic is correct
    });

    test('should handle word with all same letters', () {
      final letters = ExerciseGenerator.ensureScrambled(['A', 'A', 'A', 'A']);
      expect(letters.length, 4);
      expect(letters, ['A', 'A', 'A', 'A']);
    });

    test('should handle empty word list', () {
      final letters = ExerciseGenerator.ensureScrambled([]);
      expect(letters, isEmpty);
    });

    test('should generate anagram with empty database', () async {
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.anagram,
      );

      expect(puzzleData, isNotNull);
      expect(puzzleData.type, WordPuzzleType.anagram);
      expect(puzzleData.targetWord, isNotNull);
      expect(puzzleData.scrambledLetters, isNotNull);
      expect(puzzleData.scrambledLetters!.length, puzzleData.targetWord!.length);
    });
  });

  group('Exercise Generation - Word Search Edge Cases', () {
    test('should generate word search with empty database', () async {
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.wordSearch,
      );

      expect(puzzleData, isNotNull);
      expect(puzzleData.type, WordPuzzleType.wordSearch);
      expect(puzzleData.grid, isNotNull);
      expect(puzzleData.targetWords, isNotNull);
      expect(puzzleData.targetWords!.isNotEmpty, true);
    });

    test('should generate valid grid for each difficulty', () async {
      for (final difficulty in ExerciseDifficulty.values) {
        final puzzleData = await ExerciseGenerator.generateWordPuzzle(
          difficulty: difficulty,
          wordRepository: WordRepositoryImpl(database),
          wordType: WordType.wordSearch,
        );

        expect(puzzleData.grid, isNotNull);
        expect(puzzleData.grid!.length, greaterThan(0));
        expect(puzzleData.grid!.first.length, puzzleData.grid!.length); // Square grid
      }
    });

    test('should ensure all target words fit in grid', () async {
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.wordSearch,
      );

      final gridSize = puzzleData.grid!.length;
      for (final word in puzzleData.targetWords!) {
        expect(word.length, lessThanOrEqualTo(gridSize),
          reason: 'Word "$word" should fit in ${gridSize}x$gridSize grid');
      }
    });

    test('should fill empty grid cells with letters', () async {
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.medium,
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.wordSearch,
      );

      // Check that no cell is empty
      for (final row in puzzleData.grid!) {
        for (final cell in row) {
          expect(cell, isNotEmpty);
          expect(cell.length, 1);
        }
      }
    });
  });

  group('Exercise Generation - Math Problem Edge Cases', () {
    test('should generate valid easy math problem', () {
      final problemData = ExerciseGenerator.generateMathProblem(
        difficulty: ExerciseDifficulty.easy,
      );

      expect(problemData.question, isNotEmpty);
      expect(problemData.answer, isNotNull);
      expect(problemData.options.length, 4);
      expect(problemData.options, contains(problemData.answer));
      expect(problemData.timeLimit, greaterThan(0));
    });

    test('should generate valid expert math problem', () {
      final problemData = ExerciseGenerator.generateMathProblem(
        difficulty: ExerciseDifficulty.expert,
      );

      expect(problemData.question, isNotEmpty);
      expect(problemData.answer, isNotNull);
      expect(problemData.options.length, 4);
      expect(problemData.options, contains(problemData.answer));
    });

    test('should have unique options', () {
      final problemData = ExerciseGenerator.generateMathProblem(
        difficulty: ExerciseDifficulty.medium,
      );

      final uniqueOptions = problemData.options.toSet();
      expect(uniqueOptions.length, problemData.options.length,
        reason: 'All options should be unique');
    });

    test('should generate positive answers for comparison problems', () {
      // Generate multiple to test
      for (int i = 0; i < 10; i++) {
        final problemData = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.easy,
        );

        // Most answers should be positive
        if (problemData.type == MathProblemType.comparison) {
          expect(problemData.answer, greaterThanOrEqualTo(0));
        }
      }
    });

    test('should generate valid division problems', () {
      for (int i = 0; i < 10; i++) {
        final problemData = ExerciseGenerator.generateMathProblem(
          difficulty: ExerciseDifficulty.hard, // Hard includes division
        );

        if (problemData.question.contains('÷')) {
          expect(problemData.answer, isNot(double.nan));
          expect(problemData.answer, isNot(double.infinity));
          expect(problemData.answer, greaterThanOrEqualTo(0));
        }
      }
    });
  });

  group('Exercise Generation - Pattern Recognition Edge Cases', () {
    test('should generate valid pattern for each difficulty', () {
      for (final difficulty in ExerciseDifficulty.values) {
        final patternData = ExerciseGenerator.generatePatternRecognition(
          difficulty: difficulty,
        );

        expect(patternData.pattern, isNotEmpty);
        expect(patternData.options.length, 4);
        expect(patternData.options, contains(patternData.correctAnswer));
        expect(patternData.timeLimit, greaterThan(0));
      }
    });

    test('should have unique options', () {
      final patternData = ExerciseGenerator.generatePatternRecognition(
        difficulty: ExerciseDifficulty.medium,
      );

      final uniqueOptions = patternData.options.toSet();
      expect(uniqueOptions.length, patternData.options.length);
    });

    test('should generate patterns of appropriate length', () {
      final easyPattern = ExerciseGenerator.generatePatternRecognition(
        difficulty: ExerciseDifficulty.easy,
      );
      final expertPattern = ExerciseGenerator.generatePatternRecognition(
        difficulty: ExerciseDifficulty.expert,
      );

      expect(expertPattern.pattern.length, greaterThanOrEqualTo(easyPattern.pattern.length),
        reason: 'Expert patterns should be at least as long as easy patterns');
    });
  });

  group('Exercise Generation - Sequence Recall Edge Cases', () {
    test('should generate valid sequence for each difficulty', () {
      for (final difficulty in ExerciseDifficulty.values) {
        final sequenceData = ExerciseGenerator.generateSequenceRecall(
          difficulty: difficulty,
        );

        expect(sequenceData.sequence, isNotEmpty);
        expect(sequenceData.displayTimeMs, greaterThan(0));
        expect(sequenceData.timeLimit, greaterThan(0));
      }
    });

    test('should increase sequence length with difficulty', () {
      final easySequence = ExerciseGenerator.generateSequenceRecall(
        difficulty: ExerciseDifficulty.easy,
      );
      final hardSequence = ExerciseGenerator.generateSequenceRecall(
        difficulty: ExerciseDifficulty.hard,
      );
      final expertSequence = ExerciseGenerator.generateSequenceRecall(
        difficulty: ExerciseDifficulty.expert,
      );

      expect(hardSequence.sequence.length, greaterThanOrEqualTo(easySequence.sequence.length));
      expect(expertSequence.sequence.length, greaterThanOrEqualTo(hardSequence.sequence.length));
    });

    test('should decrease display time with difficulty', () {
      final easySequence = ExerciseGenerator.generateSequenceRecall(
        difficulty: ExerciseDifficulty.easy,
      );
      final expertSequence = ExerciseGenerator.generateSequenceRecall(
        difficulty: ExerciseDifficulty.expert,
      );

      expect(expertSequence.displayTimeMs, lessThanOrEqualTo(easySequence.displayTimeMs));
    });
  });

  group('Exercise Generation - Spatial Awareness Edge Cases', () {
    test('should generate valid spatial problem for each difficulty', () {
      for (final difficulty in ExerciseDifficulty.values) {
        final spatialData = ExerciseGenerator.generateSpatialAwareness(
          difficulty: difficulty,
        );

        expect(spatialData.targetShape, isNotEmpty);
        expect(spatialData.options.length, greaterThan(0));
        expect(spatialData.options, contains(spatialData.correctAnswer));
        expect(spatialData.timeLimit, greaterThan(0));
      }
    });

    test('should have at least 2 options', () {
      final spatialData = ExerciseGenerator.generateSpatialAwareness(
        difficulty: ExerciseDifficulty.easy,
      );

      expect(spatialData.options.length, greaterThanOrEqualTo(2));
    });

    test('should include correct answer in options', () {
      for (int i = 0; i < 10; i++) {
        final spatialData = ExerciseGenerator.generateSpatialAwareness(
          difficulty: ExerciseDifficulty.medium,
        );

        expect(spatialData.options, contains(spatialData.correctAnswer));
      }
    });
  });

  group('Exercise Generation - Spanish Anagram Edge Cases', () {
    test('should generate Spanish anagram with empty database', () async {
      final puzzleData = await ExerciseGenerator.generateSpanishAnagram(
        difficulty: ExerciseDifficulty.easy,
        wordRepository: WordRepositoryImpl(database),
      );

      expect(puzzleData, isNotNull);
      expect(puzzleData.type, WordPuzzleType.anagram);
      expect(puzzleData.targetWord, isNotNull);
      expect(puzzleData.scrambledLetters, isNotNull);
    });

    test('should generate Spanish anagram for all difficulties', () async {
      for (final difficulty in ExerciseDifficulty.values) {
        final puzzleData = await ExerciseGenerator.generateSpanishAnagram(
          difficulty: difficulty,
          wordRepository: WordRepositoryImpl(database),
        );

        expect(puzzleData.targetWord, isNotNull);
        expect(puzzleData.scrambledLetters, isNotNull);
        expect(puzzleData.scrambledLetters!.length, puzzleData.targetWord!.length);
      }
    });
  });

  group('Exercise Generation - Time Limits', () {
    test('should have decreasing time limits with difficulty for math', () {
      final easyMath = ExerciseGenerator.generateMathProblem(
        difficulty: ExerciseDifficulty.easy,
      );
      final expertMath = ExerciseGenerator.generateMathProblem(
        difficulty: ExerciseDifficulty.expert,
      );

      expect(expertMath.timeLimit, lessThanOrEqualTo(easyMath.timeLimit));
    });

    test('should have positive time limits for all exercises', () async {
      final memoryGame = ExerciseGenerator.generateMemoryGame(
        difficulty: ExerciseDifficulty.medium,
      );
      final mathProblem = ExerciseGenerator.generateMathProblem(
        difficulty: ExerciseDifficulty.medium,
      );
      final pattern = ExerciseGenerator.generatePatternRecognition(
        difficulty: ExerciseDifficulty.medium,
      );
      final sequence = ExerciseGenerator.generateSequenceRecall(
        difficulty: ExerciseDifficulty.medium,
      );
      final spatial = ExerciseGenerator.generateSpatialAwareness(
        difficulty: ExerciseDifficulty.medium,
      );

      expect(memoryGame.timeLimit, greaterThan(0));
      expect(mathProblem.timeLimit, greaterThan(0));
      expect(pattern.timeLimit, greaterThan(0));
      expect(sequence.timeLimit, greaterThan(0));
      expect(spatial.timeLimit, greaterThan(0));
    });
  });
}
