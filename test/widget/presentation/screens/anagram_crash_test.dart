import 'package:brain_tests/core/services/word_dictionary_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/data/repositories/word_repository_impl.dart';import 'package:brain_tests/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import 'package:brain_tests/data/repositories/word_repository_impl.dart';
/// Test to reproduce the crash when there are fewer than 5 anagram words in database
///
/// Issue: When the database has fewer than 5 words for a given difficulty level,
/// the app crashes when trying to access the 3rd word (or any word beyond what's available)
/// because the code assumes 5 words will always be returned.
void main() {
  late AppDatabase database;

  setUp(() async {
    // Create in-memory database for testing
    database = createTestDatabase();
  });

  tearDown(() async {
    await closeTestDatabase(database);
  });

  group('Anagram Exercise Crash Reproduction', () {
    test('should handle when database returns fewer than 5 words', () async {
      // Setup: Insert only 2 words for easy difficulty
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'CAT',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 3,
        ),
      );
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'DOG',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 3,
        ),
      );

      // Act: Request 5 words (but only 2 exist)
      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.easy,
        5,
      );

      // Assert: Should return only 2 words, not crash
      expect(words.length, 2);
      expect(words.length, lessThan(5), reason: 'Should return fewer than requested when insufficient words in database');
    });

    test('should generate puzzle data even with insufficient words', () async {
      // Setup: Insert only 2 words for medium difficulty
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'HOUSE',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.medium,
          length: 5,
        ),
      );
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'MOUSE',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.medium,
          length: 5,
        ),
      );

      // Act: Generate word puzzle (internally requests multiple words)
      final puzzleData = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.medium,
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.anagram,
      );

      // Assert: Should generate valid puzzle data
      expect(puzzleData, isNotNull);
      expect(puzzleData.type, WordPuzzleType.anagram);
      expect(puzzleData.targetWord, isNotNull);
      expect(puzzleData.scrambledLetters, isNotNull);
    });

    test('should simulate the crash scenario - accessing third word when only 2 exist', () async {
      // Setup: Insert only 2 words for easy difficulty
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'CAT',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 3,
        ),
      );
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'DOG',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 3,
        ),
      );

      // Act: Request 5 words
      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        ExerciseDifficulty.easy,
        5,
      );

      // Simulate what happens in exercise_test_screen.dart
      final anagramWords = <String>[];
      final anagramScrambledLetters = <List<String>>[];

      for (final word in words) {
        final scrambledLetters = ExerciseGenerator.ensureScrambled(word.split(''));
        anagramWords.add(word);
        anagramScrambledLetters.add(scrambledLetters);
      }

      // Assert: Lists only have 2 items
      expect(anagramWords.length, 2);
      expect(anagramScrambledLetters.length, 2);

      // This simulates accessing the third word (index 2) which would crash
      expect(
        () => anagramWords[2],
        throwsRangeError,
        reason: 'Accessing index 2 when only 2 items exist should throw RangeError',
      );
      expect(
        () => anagramScrambledLetters[2],
        throwsRangeError,
        reason: 'Accessing index 2 when only 2 items exist should throw RangeError',
      );
    });

    test('should handle word search with insufficient words', () async {
      // Setup: Insert only 1 word for word search
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'CAT',
          language: WordLanguage.english,
          type: WordType.wordSearch,
          difficulty: ExerciseDifficulty.easy,
          length: 3,
        ),
      );

      // Act: Request 3 words for word search (easy difficulty expects 3)
      final words = await WordDictionaryService.getRandomWordSearchWords(
        database,
        ExerciseDifficulty.easy,
        3,
      );

      // Assert: Should return only 1 word
      expect(words.length, 1);
      expect(words.length, lessThan(3));
    });
  });
}
