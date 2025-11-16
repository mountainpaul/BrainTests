import 'package:brain_tests/core/services/word_dictionary_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Anagram Validation Integration Tests', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.memory();
      await WordDictionaryService.initializeWordDictionaries(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('VIEWER should be found as a valid word for anagram validation', () async {
      // This tests the actual use case: checking if VIEWER is a valid answer
      final results = await (database.select(database.wordDictionaryTable)
            ..where((tbl) => tbl.word.equals('VIEWER'))
            ..where((tbl) => tbl.isActive.equals(true)))
          .get();

      expect(results.isNotEmpty, true, reason: 'VIEWER should be found in the word dictionary');
      print('VIEWER found with types: ${results.map((r) => r.type).toList()}');
    });

    test('Common anagram answer words should all be valid', () async {
      // Test words that might be valid anagram answers
      // These are common English words that should be accepted as valid answers
      final testWords = [
        'VIEWER',  // Was missing in original 4.4K list, causing the reported issue
        'REVIEW',
        'WAITER',
        'LISTEN',
        'MASTER',
        'ANSWER',
        'SILENT',
        'STREAM',
      ];

      for (final word in testWords) {
        final results = await (database.select(database.wordDictionaryTable)
              ..where((tbl) => tbl.word.equals(word.toUpperCase()))
              ..where((tbl) => tbl.isActive.equals(true)))
            .get();

        expect(results.isNotEmpty, true,
          reason: '$word should be a valid word for anagram validation');
      }

      print('All ${testWords.length} common anagram words validated successfully!');
    });

    test('Anagram generation should not use validation-only words', () async {
      // Get anagram words for puzzle generation
      final anagramWords = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.medium,
        100,
      );

      // Verify each word is marked as anagram type (not validation-only)
      for (final word in anagramWords) {
        final wordEntries = await (database.select(database.wordDictionaryTable)
              ..where((tbl) => tbl.word.equals(word))
              ..where((tbl) => tbl.type.equals(WordType.anagram.name)))
            .get();

        expect(wordEntries.isNotEmpty, true,
          reason: 'Puzzle word $word should be marked as anagram type');
      }

      print('Verified ${anagramWords.length} puzzle words are properly typed');
    });

    test('Validation word list should have significantly more words than anagram list', () async {
      final allWords = await database.select(database.wordDictionaryTable).get();
      final anagramWords = allWords.where((w) => w.type == WordType.anagram).toList();
      final validationWords = allWords.where((w) => w.type == WordType.validationOnly).toList();

      expect(validationWords.length, greaterThan(anagramWords.length * 3),
        reason: 'Validation list should have at least 3x more words than anagram list');

      print('Anagram words: ${anagramWords.length}');
      print('Validation words: ${validationWords.length}');
      print('Ratio: ${(validationWords.length / anagramWords.length).toStringAsFixed(1)}x');
    });
  });
}
