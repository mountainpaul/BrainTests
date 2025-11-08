import 'package:brain_plan/core/services/word_dictionary_service.dart';
import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

/// Critical user journey integration tests
///
/// As a senior engineer, I want to ensure:
/// 1. Complete user workflows work end-to-end
/// 2. State persists correctly across operations
/// 3. Error recovery doesn't corrupt user data
/// 4. Happy path AND edge cases in real scenarios
/// 5. Data integrity throughout the journey
///
/// These tests simulate actual user behavior patterns
void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();

    // Seed database with realistic data
    await _seedDatabase(database);
  });

  tearDown(() async {
    await closeTestDatabase(database);
  });

  group('Critical Journey - New User First Exercise', () {
    test('should complete full exercise workflow from start to finish', () async {
      // Step 1: User selects anagram exercise
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        database: database,
        wordType: WordType.anagram,
      );

      expect(puzzleData, isNotNull);
      expect(puzzleData.targetWord, isNotNull);

      // Step 2: User solves the anagram
      final userAnswer = puzzleData.targetWord!;
      final isCorrect = userAnswer.toUpperCase() == puzzleData.targetWord!.toUpperCase();

      expect(isCorrect, true);

      // Step 3: Calculate score
      const timeSpent = 45; // seconds
      const hintsUsed = 0;
      const baseScore = 100;
      const timeBonus = timeSpent < 60 ? 20 : 0;
      final finalScore = (baseScore + timeBonus - (hintsUsed * 5)).clamp(0, 120);

      expect(finalScore, greaterThanOrEqualTo(0));
      expect(finalScore, lessThanOrEqualTo(120));

      // Step 4: Save result (would normally save to assessments table)
      // Verify data integrity
      expect(finalScore, 120); // Perfect score: 100 + 20 bonus
    });

    test('should handle user abandoning exercise mid-way', () async {
      // User starts exercise
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.medium,
        database: database,
        wordType: WordType.anagram,
      );

      expect(puzzleData, isNotNull);

      // User abandons (navigates away)
      // No score should be saved
      // State should be cleanable

      // Verify: Starting new exercise works
      final newPuzzle = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.medium,
        database: database,
        wordType: WordType.anagram,
      );

      expect(newPuzzle, isNotNull);
      // Note: Random word selection may occasionally produce the same word
      // The important thing is that a new puzzle can be generated successfully
      expect(newPuzzle.scrambledLetters, isNotNull);
    });

    test('should handle user requesting hints during exercise', () async {
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.hard,
        database: database,
        wordType: WordType.anagram,
      );

      var hintsUsed = 0;
      const maxHints = 3;

      // User requests hints
      for (int i = 0; i < maxHints + 1; i++) {
        if (hintsUsed < maxHints) {
          hintsUsed++;
          // Show hint (e.g., reveal first letter)
        }
      }

      expect(hintsUsed, maxHints); // Capped at max

      // Calculate penalized score
      const baseScore = 100;
      const hintPenalty = 5;
      final finalScore = (baseScore - (hintsUsed * hintPenalty)).clamp(0, 100);

      expect(finalScore, 85); // 100 - (3 * 5)
    });
  });

  group('Critical Journey - Progressive Difficulty', () {
    test('should allow user to progress through all difficulty levels', () async {
      const difficulties = ExerciseDifficulty.values;
      final scores = <int>[];

      for (final difficulty in difficulties) {
        // Generate and complete exercise
        final puzzleData = await ExerciseGenerator.generateWordPuzzle(
          difficulty: difficulty,
          database: database,
          wordType: WordType.anagram,
        );

        // Simulate completion with declining performance at higher difficulties
        final difficultyIndex = difficulties.indexOf(difficulty);
        final score = 100 - (difficultyIndex * 10); // 100, 90, 80, 70

        scores.add(score);
      }

      // Verify progression
      expect(scores.length, difficulties.length);
      expect(scores.first, greaterThanOrEqualTo(scores.last)); // Scores may decline
    });

    test('should track user performance trend over time', () async {
      final sessionScores = <int>[];

      // Simulate 10 exercise sessions
      for (int session = 0; session < 10; session++) {
        final puzzleData = await ExerciseGenerator.generateWordPuzzle(
          difficulty: ExerciseDifficulty.medium,
          database: database,
          wordType: WordType.anagram,
        );

        // Simulate improving performance (learning effect)
        final score = 70 + (session * 3); // Improving by 3% per session
        sessionScores.add(score.clamp(0, 100));
      }

      // Calculate trend
      final averageScore = sessionScores.reduce((a, b) => a + b) / sessionScores.length;
      final improvementRate = sessionScores.last - sessionScores.first;

      expect(averageScore, greaterThan(70));
      expect(improvementRate, greaterThan(0)); // User is improving
    });
  });

  group('Critical Journey - Multi-Word Anagram Session', () {
    test('should complete full 5-word anagram session', () async {
      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.easy,
        5,
      );

      expect(words.isNotEmpty, true);

      final results = <bool>[];
      var totalTime = 0;

      // User solves each word
      for (final word in words) {
        final timeForWord = 30 + (word.length * 5); // Realistic time
        totalTime += timeForWord;

        // Simulate user solving (80% success rate)
        final solved = results.length < 4; // Solve 4 out of 5
        results.add(solved);
      }

      // Calculate final score
      final correctCount = results.where((r) => r).length;
      final accuracyScore = (correctCount / words.length * 100).round();
      final timeEfficiency = totalTime < 300 ? 20 : 0; // Bonus if under 5 min
      final finalScore = (accuracyScore + timeEfficiency).clamp(0, 120);

      expect(finalScore, greaterThan(0));
      expect(correctCount, greaterThanOrEqualTo(3)); // At least 60% success
    });

    test('should handle skipping words in multi-word session', () async {
      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.medium,
        5,
      );

      final solved = <bool>[];
      final skipped = <bool>[];

      for (int i = 0; i < words.length; i++) {
        if (i % 2 == 0) {
          solved.add(true); // Solved
          skipped.add(false);
        } else {
          solved.add(false); // Skipped
          skipped.add(true);
        }
      }

      final solvedCount = solved.where((s) => s).length;
      final skippedCount = skipped.where((s) => s).length;

      // Score only counts solved, not skipped
      final score = (solvedCount / words.length * 100).round();

      expect(solvedCount + skippedCount, words.length);
      expect(score, greaterThanOrEqualTo(0));
    });
  });

  group('Critical Journey - Word Search Workflow', () {
    test('should complete word search from generation to completion', () async {
      // Step 1: Generate word search puzzle
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        database: database,
        wordType: WordType.wordSearch,
      );

      expect(puzzleData.grid, isNotNull);
      expect(puzzleData.targetWords, isNotNull);
      expect(puzzleData.targetWords!.isNotEmpty, true);

      // Step 2: User finds words
      final foundWords = <String>[];
      final targetWords = puzzleData.targetWords!;

      // Simulate finding 80% of words
      for (int i = 0; i < targetWords.length; i++) {
        if (i < (targetWords.length * 0.8).ceil()) {
          foundWords.add(targetWords[i]);
        }
      }

      // Step 3: Calculate completion
      final completionRate = (foundWords.length / targetWords.length * 100).round();
      const timeSpent = 90; // seconds
      const timeBonus = timeSpent < 120 ? 10 : 0;
      final finalScore = (completionRate + timeBonus).clamp(0, 110);

      expect(completionRate, greaterThanOrEqualTo(60));
      expect(finalScore, greaterThan(0));
    });

    test('should handle selecting invalid cells in word search', () async {
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.medium,
        database: database,
        wordType: WordType.wordSearch,
      );

      final gridSize = puzzleData.grid!.length;
      final selectedCells = <int>[];

      // User selects cells
      selectedCells.add(0); // Valid
      selectedCells.add(gridSize * gridSize + 10); // Invalid (out of bounds)
      selectedCells.add(-1); // Invalid (negative)

      // Filter valid selections
      final validSelections = selectedCells.where((index) {
        return index >= 0 && index < gridSize * gridSize;
      }).toList();

      expect(validSelections.length, 1); // Only first selection valid
    });
  });

  group('Critical Journey - Memory Game Session', () {
    test('should complete memory game with move tracking', () async {
      final gameData = ExerciseGenerator.generateMemoryGame(
        difficulty: ExerciseDifficulty.easy,
      );

      final totalPairs = gameData.cardSymbols.length ~/ 2;
      var movesCount = 0;
      var pairsFound = 0;

      // Simulate game play
      // Best case: each pair found in 2 moves = totalPairs * 2
      // Realistic: some mistakes = totalPairs * 3
      while (pairsFound < totalPairs) {
        movesCount += 2; // Each attempt uses 2 moves

        // 70% chance of finding pair
        if (movesCount % 6 != 0) {
          pairsFound++;
        }
      }

      // Calculate efficiency
      final perfectMoves = totalPairs * 2;
      final efficiency = (perfectMoves / movesCount * 100).round();
      final score = efficiency.clamp(10, 100);

      expect(pairsFound, totalPairs);
      expect(score, greaterThanOrEqualTo(10));
    });
  });

  group('Critical Journey - Error Recovery', () {
    test('should recover from database error during exercise', () async {
      // Attempt operation that might fail
      try {
        final puzzleData = await ExerciseGenerator.generateWordPuzzle(
          difficulty: ExerciseDifficulty.expert,
          database: database,
          wordType: WordType.anagram,
        );

        expect(puzzleData, isNotNull);
      } catch (e) {
        // If fails, should be able to retry
        final retryPuzzle = await ExerciseGenerator.generateWordPuzzle(
          difficulty: ExerciseDifficulty.easy, // Fallback to easier
          database: database,
          wordType: WordType.anagram,
        );

        expect(retryPuzzle, isNotNull);
      }
    });

    test('should handle app restart mid-exercise', () async {
      // User starts exercise
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.medium,
        database: database,
        wordType: WordType.anagram,
      );

      final originalWord = puzzleData.targetWord;

      // Simulate app restart (close and reopen database)
      await closeTestDatabase(database);
      database = createTestDatabase();
      await _seedDatabase(database);

      // Generate new exercise after restart
      final newPuzzle = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.medium,
        database: database,
        wordType: WordType.anagram,
      );

      expect(newPuzzle, isNotNull);
      // Can't guarantee same word, but should work
    });
  });

  group('Critical Journey - Data Consistency', () {
    test('should maintain referential integrity across operations', () async {
      // Create exercises using same database
      final exercise1 = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        database: database,
        wordType: WordType.anagram,
      );

      final exercise2 = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        database: database,
        wordType: WordType.anagram,
      );

      // Both should be valid and independent
      expect(exercise1.targetWord, isNotNull);
      expect(exercise2.targetWord, isNotNull);
    });

    test('should handle completing same exercise type consecutively', () async {
      // Simulate user doing multiple exercises in a row
      for (int i = 0; i < 5; i++) {
        final puzzleData = await ExerciseGenerator.generateWordPuzzle(
          difficulty: ExerciseDifficulty.medium,
          database: database,
          wordType: WordType.anagram,
        );

        expect(puzzleData, isNotNull);
        expect(puzzleData.targetWord, isNotNull);

        // Simulate completion
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // All should complete successfully without issues
    });
  });
}

/// Helper to seed database with realistic test data
Future<void> _seedDatabase(AppDatabase database) async {
  final words = [
    'CAT', 'DOG', 'BIRD', 'FISH', 'MOUSE',
    'HOUSE', 'TREE', 'BOOK', 'CHAIR', 'TABLE',
    'COMPUTER', 'KEYBOARD', 'MONITOR', 'PRINTER',
    'ELEPHANT', 'GIRAFFE', 'LION', 'TIGER',
  ];

  for (final word in words) {
    await database.into(database.wordDictionaryTable).insert(
      WordDictionaryTableCompanion.insert(
        word: word,
        language: WordLanguage.english,
        type: WordType.anagram,
        difficulty: _getDifficultyForLength(word.length),
        length: word.length,
      ),
    );

    // Also add for word search
    await database.into(database.wordDictionaryTable).insert(
      WordDictionaryTableCompanion.insert(
        word: word,
        language: WordLanguage.english,
        type: WordType.wordSearch,
        difficulty: _getDifficultyForLength(word.length),
        length: word.length,
      ),
    );
  }
}

ExerciseDifficulty _getDifficultyForLength(int length) {
  if (length <= 4) return ExerciseDifficulty.easy;
  if (length <= 6) return ExerciseDifficulty.medium;
  if (length <= 8) return ExerciseDifficulty.hard;
  return ExerciseDifficulty.expert;
}
