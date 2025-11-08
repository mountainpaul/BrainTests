import 'package:brain_plan/core/services/word_dictionary_service.dart';
import 'package:brain_plan/data/datasources/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WordDictionaryService Tests', () {
    late AppDatabase database;

    setUp(() async {
      // Use in-memory database for testing
      database = AppDatabase.memory();
    });

    tearDown(() async {
      await database.close();
    });

    test('should initialize word dictionaries with validation words', () async {
      // Act
      await WordDictionaryService.initializeWordDictionaries(database);

      // Assert
      final allWords = await database.select(database.wordDictionaryTable).get();
      expect(allWords.isNotEmpty, true);

      // Check that validation words exist
      final validationWords = allWords.where((w) => w.type == WordType.validationOnly).toList();
      expect(validationWords.isNotEmpty, true, reason: 'Should have validation-only words');

      // Validation words should be substantially more than anagram words
      final anagramWords = allWords.where((w) => w.type == WordType.anagram).toList();
      expect(validationWords.length, greaterThan(anagramWords.length * 3),
        reason: 'Validation words (~20K) should be much more than anagram words (~4.4K)');

      print('Total words: ${allWords.length}');
      print('Anagram words: ${anagramWords.length}');
      print('Validation words: ${validationWords.length}');
    });

    test('should contain VIEWER in word dictionary (anagram or validation)', () async {
      // Act
      await WordDictionaryService.initializeWordDictionaries(database);

      // Assert - VIEWER should be in the word dictionary (either as anagram or validation word)
      final viewerResults = await (database.select(database.wordDictionaryTable)
            ..where((tbl) => tbl.word.equals('VIEWER')))
          .get();

      expect(viewerResults.isNotEmpty, true, reason: 'VIEWER should be in word dictionary');
      // VIEWER can be in anagram words or validation words - both are valid for answer checking
    });

    test('should contain common words in validation list', () async {
      // Act
      await WordDictionaryService.initializeWordDictionaries(database);

      // Assert - Check several common words that might be valid anagram answers
      final testWords = ['VIEWER', 'REVIEW', 'ANSWER', 'LISTEN', 'WAITER', 'MASTER'];

      for (final word in testWords) {
        final results = await (database.select(database.wordDictionaryTable)
              ..where((tbl) => tbl.word.equals(word)))
            .get();

        expect(results.isNotEmpty, true, reason: '$word should be in word list');
      }
    });

    test('should not return validation words when querying for anagram words', () async {
      // Act
      await WordDictionaryService.initializeWordDictionaries(database);

      // Assert - Anagram word query should not include validation-only words
      final anagramWords = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.medium,
        10,
      );

      expect(anagramWords.isNotEmpty, true);

      // Verify none of the returned words are validation-only
      for (final word in anagramWords) {
        final wordEntries = await (database.select(database.wordDictionaryTable)
              ..where((tbl) => tbl.word.equals(word))
              ..where((tbl) => tbl.type.equals(WordType.anagram.name)))
            .get();

        expect(wordEntries.isNotEmpty, true, reason: 'Word $word should be marked as anagram type');
      }
    });

    test('should handle validation word lookup correctly', () async {
      // Act
      await WordDictionaryService.initializeWordDictionaries(database);

      // Assert - Should be able to find validation words by query
      final viewerCheck = await (database.select(database.wordDictionaryTable)
            ..where((tbl) => tbl.word.equals('VIEWER'))
            ..where((tbl) => tbl.isActive.equals(true)))
          .get();

      expect(viewerCheck.isNotEmpty, true);
    });

    test('should respect version number for re-initialization', () async {
      // First initialization
      await WordDictionaryService.initializeWordDictionaries(database);
      final firstCount = (await database.select(database.wordDictionaryTable).get()).length;

      // Second initialization (should skip)
      await WordDictionaryService.initializeWordDictionaries(database);
      final secondCount = (await database.select(database.wordDictionaryTable).get()).length;

      // Counts should be equal (no re-initialization)
      expect(firstCount, secondCount);
    });
  });
}
