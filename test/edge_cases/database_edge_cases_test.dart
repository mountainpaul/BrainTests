import 'package:brain_tests/core/services/word_dictionary_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// Comprehensive edge case tests for database operations
///
/// Tests cover:
/// - Empty database scenarios
/// - Duplicate data handling
/// - Invalid data inputs
/// - Boundary conditions
/// - Null/empty string handling
/// - Special characters
/// - Very large datasets
void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();
  });

  tearDown(() async {
    await closeTestDatabase(database);
  });

  group('Database Edge Cases - Empty Database', () {
    test('should handle query on empty word dictionary', () async {
      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.easy,
        5,
      );

      expect(words, isEmpty);
    });

    test('should handle query for non-existent difficulty level', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'TEST',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 4,
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.expert, // Only easy exists
        5,
      );

      expect(words, isEmpty);
    });

    test('should handle query for non-existent language', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'TEST',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 4,
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.spanish, // Only english exists
        ExerciseDifficulty.easy,
        5,
      );

      expect(words, isEmpty);
    });
  });

  group('Database Edge Cases - Boundary Values', () {
    test('should handle requesting 0 words', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'TEST',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 4,
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.easy,
        0,
      );

      expect(words, isEmpty);
    });

    test('should handle requesting more words than available', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'TEST',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 4,
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.easy,
        1000, // Request way more than available
      );

      expect(words.length, 1);
    });

    test('should handle very long words', () async {
      final longWord = 'A' * 50; // 50 character word
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: longWord,
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.expert,
          length: longWord.length,
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.expert,
        1,
      );

      expect(words, isNotEmpty);
      expect(words.first, longWord);
    });

    test('should handle single character words', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'I',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 1,
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.easy,
        1,
      );

      expect(words, ['I']);
    });
  });

  group('Database Edge Cases - Special Characters', () {
    test('should handle words with special characters', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'CAFÉ',
          language: WordLanguage.spanish,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 4,
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.spanish,
        ExerciseDifficulty.easy,
        1,
      );

      expect(words, ['CAFÉ']);
    });

    test('should handle words with hyphens', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'MOTHER-IN-LAW',
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.hard,
          length: 13,
        ),
      );

      final words = await WordDictionaryService.getRandomWordSearchWords(
        database,
        ExerciseDifficulty.hard,
        1,
      );

      expect(words, ['MOTHER-IN-LAW']);
    });

    test('should handle words with apostrophes', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: "CAN'T",
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 5,
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.easy,
        1,
      );

      expect(words, ["CAN'T"]);
    });
  });

  group('Database Edge Cases - Data Consistency', () {
    test('should handle words with incorrect length field', () async {
      // Insert word with length field that doesn't match actual length
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'TESTING', // 7 characters
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.medium,
          length: 5, // Incorrect length
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.medium,
        1,
      );

      expect(words, isNotEmpty);
      expect(words.first.length, 7); // Actual length should be 7
    });

    test('should handle duplicate words', () async {
      // Insert same word twice
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'DUPLICATE',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.medium,
          length: 9,
        ),
      );
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'DUPLICATE',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.medium,
          length: 9,
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.medium,
        5,
      );

      // Should get duplicates if they exist in DB
      expect(words.length, 2);
    });

    test('should handle mixed case words', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'TeSt', // Mixed case
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 4,
        ),
      );

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.easy,
        1,
      );

      expect(words, ['TeSt']);
    });
  });

  group('Database Edge Cases - Large Datasets', () {
    test('should handle requesting 1 word from large dataset', () async {
      // Insert 100 words
      for (int i = 0; i < 100; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'WORD$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.medium,
            length: 5 + i.toString().length,
          ),
        );
      }

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.medium,
        1,
      );

      expect(words.length, 1);
      expect(words.first, startsWith('WORD'));
    });

    test('should handle all words at once', () async {
      // Insert 50 words
      for (int i = 0; i < 50; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'WORD$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.medium,
            length: 5 + i.toString().length,
          ),
        );
      }

      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.medium,
        100, // Request more than available
      );

      expect(words.length, 50); // Should return all 50
    });
  });

  group('Database Edge Cases - Word Types', () {
    test('should not mix anagram and word search words', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'ANAGRAM',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 7,
        ),
      );
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'SEARCH',
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.easy,
          length: 6,
        ),
      );

      final anagramWords = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.easy,
        10,
      );

      expect(anagramWords, ['ANAGRAM']);
      expect(anagramWords, isNot(contains('SEARCH')));
    });

    test('should handle requesting wrong type', () async {
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'ANAGRAM',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 7,
        ),
      );

      // Request word search words when only anagram exists
      final wordSearchWords = await WordDictionaryService.getRandomWordSearchWords(
        database,
        ExerciseDifficulty.easy,
        10,
      );

      expect(wordSearchWords, isEmpty);
    });
  });
}
