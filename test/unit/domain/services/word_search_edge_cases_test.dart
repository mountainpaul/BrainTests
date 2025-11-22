import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/data/repositories/word_repository_impl.dart';import 'package:brain_tests/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import 'package:brain_tests/data/repositories/word_repository_impl.dart';
/// Test to verify word search handles edge cases properly
///
/// Issues to test:
/// 1. Database returns fewer words than requested
/// 2. All returned words are too long for the grid (get filtered out)
/// 3. Mix of valid and too-long words
void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();
  });

  tearDown(() async {
    await closeTestDatabase(database);
  });

  group('Word Search Edge Cases', () {
    test('should handle database with only 1 word for word search', () async {
      // Setup: Insert only 1 word for easy difficulty (expects 3)
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'CAT',
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.easy,
          length: 3,
        ),
      );

      // Act: Generate word search (expects 3 words)
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.wordSearch,
      );

      // Assert: Should generate puzzle with available words
      expect(puzzleData, isNotNull);
      expect(puzzleData.type, WordPuzzleType.wordSearch);
      expect(puzzleData.targetWords, isNotNull);
      expect(puzzleData.targetWords!.length, greaterThan(0),
        reason: 'Should have at least 1 word after fallback');
      expect(puzzleData.grid, isNotNull);
    });

    test('should handle words that are too long for grid', () async {
      // Setup: Insert words that are too long for easy grid (8x8)
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'EXTRAORDINARY', // 13 letters - too long for 8x8 grid
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.easy,
          length: 13,
        ),
      );
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'MAGNIFICENT', // 11 letters - too long for 8x8 grid
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.easy,
          length: 11,
        ),
      );

      // Act: Generate word search
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.wordSearch,
      );

      // Assert: Should fallback to hardcoded words or handle gracefully
      expect(puzzleData, isNotNull);
      expect(puzzleData.targetWords, isNotNull);
      expect(puzzleData.targetWords!.length, greaterThan(0),
        reason: 'Should have words even after filtering out too-long words');

      // Verify all words fit in grid
      final gridSize = puzzleData.grid!.length;
      for (final word in puzzleData.targetWords!) {
        expect(word.length, lessThanOrEqualTo(gridSize),
          reason: 'Word "$word" should fit in ${gridSize}x$gridSize grid');
      }
    });

    test('should handle mix of valid and too-long words', () async {
      // Setup: Mix of valid and invalid words
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'CAT', // 3 letters - fits
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.easy,
          length: 3,
        ),
      );
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'EXTRAORDINARY', // 13 letters - too long
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.easy,
          length: 13,
        ),
      );
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'DOG', // 3 letters - fits
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.easy,
          length: 3,
        ),
      );

      // Act: Generate word search
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.wordSearch,
      );

      // Assert: Should keep valid words and filter out too-long ones
      expect(puzzleData, isNotNull);
      expect(puzzleData.targetWords, isNotNull);
      expect(puzzleData.targetWords!.length, greaterThanOrEqualTo(2),
        reason: 'Should have at least 2 valid words (CAT, DOG)');
      expect(puzzleData.targetWords, isNot(contains('EXTRAORDINARY')),
        reason: 'Should filter out words that are too long');

      // Verify all words fit in grid
      final gridSize = puzzleData.grid!.length;
      for (final word in puzzleData.targetWords!) {
        expect(word.length, lessThanOrEqualTo(gridSize));
      }
    });

    test('should handle empty database with fallback words', () async {
      // Act: Generate word search with empty database
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.easy,
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.wordSearch,
      );

      // Assert: Should use fallback words
      expect(puzzleData, isNotNull);
      expect(puzzleData.targetWords, isNotNull);
      expect(puzzleData.targetWords!.length, greaterThan(0),
        reason: 'Should fallback to hardcoded words when database is empty');
      expect(puzzleData.grid, isNotNull);
    });

    test('should handle different difficulty levels with insufficient words', () async {
      // Setup: Only 2 words for all difficulties
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'TEST',
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.medium,
          length: 4,
        ),
      );
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'CODE',
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.medium,
          length: 4,
        ),
      );

      // Act: Generate word search for medium (expects 4 words)
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.medium,
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.wordSearch,
      );

      // Assert: Should handle gracefully
      expect(puzzleData, isNotNull);
      expect(puzzleData.targetWords, isNotNull);
      expect(puzzleData.targetWords!.length, 2,
        reason: 'Should use available 2 words even though 4 were requested');
    });
  });
}
