import 'package:brain_tests/core/services/word_dictionary_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/data/repositories/word_repository_impl.dart';
import 'package:brain_tests/domain/entities/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';

void main() {
  group('WordRepositoryImpl Integration Tests', () {
    late AppDatabase database;
    late WordRepositoryImpl repository;

    setUp(() async {
      // Use in-memory database for speed and isolation
      database = AppDatabase.memory();
      repository = WordRepositoryImpl(database);
      
      // Initialize dictionary with some test data
      // We need to manually insert since WordDictionaryService.initialize uses hardcoded lists
      // and we want a controlled test environment.
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'TEST',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 4,
          version: const drift.Value(1),
        ),
      );
      
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'HOLA',
          language: WordLanguage.spanish,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 4,
          version: const drift.Value(1),
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('getAnagramWords should return words for specific language', () async {
      final englishWords = await repository.getAnagramWords(
        WordLanguage.english,
        ExerciseDifficulty.easy,
        5,
      );
      
      expect(englishWords, contains('TEST'));
      expect(englishWords, isNot(contains('HOLA')));
    });

    test('isValidWord should validate word existence and language', () async {
      // Valid English word
      expect(await repository.isValidWord('TEST', WordLanguage.english), isTrue);
      
      // Valid Spanish word
      expect(await repository.isValidWord('HOLA', WordLanguage.spanish), isTrue);
      
      // Word exists but wrong language (assuming strict check, though currently implementation finds ANY match)
      // Wait, my implementation of isValidWord checks: return results.any((w) => w.language == language);
      // So checking 'TEST' (English) with Spanish should return FALSE.
      expect(await repository.isValidWord('TEST', WordLanguage.spanish), isFalse);
      
      // Non-existent word
      expect(await repository.isValidWord('INVALID', WordLanguage.english), isFalse);
    });
    
    test('isValidWord should be case insensitive', () async {
      expect(await repository.isValidWord('test', WordLanguage.english), isTrue);
    });
  });
}
