import 'package:drift/drift.dart';
import '../../data/datasources/database.dart';
import '../../domain/entities/enums.dart';
import '../data/comprehensive_word_lists.dart';
import '../data/validation_word_list.dart';

class WordDictionaryService {
  // Complete English words for anagrams (3000+ words from comprehensive lists)
  static List<Map<String, dynamic>> get englishAnagramWords =>
    ComprehensiveWordLists.englishAnagramWords;

  // Complete Spanish words for anagrams (2000+ words from comprehensive lists)
  static List<Map<String, dynamic>> get spanishAnagramWords =>
    ComprehensiveWordLists.spanishAnagramWords;

  // Complete word search words (5000+ words from comprehensive lists)
  static List<String> get wordSearchWords =>
    ComprehensiveWordLists.wordSearchWords;

  // Validation words (20000+ common English words for answer validation)
  static List<String> get validationWords => ValidationWordList.words;

  // Version of the word dictionary - increment this when word lists are updated
  static const int WORD_DICTIONARY_VERSION = 3; // Updated: added validation-only word list for hybrid approach

  static Future<void> initializeWordDictionaries(AppDatabase database) async {
    // Check if dictionaries already exist with sufficient words
    final existingWords = await database.select(database.wordDictionaryTable).get();

    // Check version - if version mismatch or insufficient words, re-initialize
    final hasCorrectVersion = existingWords.isNotEmpty &&
        existingWords.first.version == WORD_DICTIONARY_VERSION;

    // If we have at least 25000 words with correct version, assume dictionary is populated
    // (includes ~4439 anagram words + ~5000 word search words + ~20000 validation words)
    if (existingWords.length >= 25000 && hasCorrectVersion) {
      print('Word dictionary already initialized with ${existingWords.length} words (v$WORD_DICTIONARY_VERSION).');
      return;
    }

    // Clear existing words if we're re-initializing
    if (existingWords.isNotEmpty) {
      print('Clearing existing ${existingWords.length} words and re-initializing...');
      await database.delete(database.wordDictionaryTable).go();
    }

    print('Initializing word dictionaries with ${englishAnagramWords.length} English words, ${spanishAnagramWords.length} Spanish words, ${wordSearchWords.length} word search words, and ${validationWords.length} validation words...');

    // Use batch insert for much faster performance (10-100x faster than individual inserts)
    await database.batch((batch) {
      // Batch insert English anagram words
      for (final wordData in englishAnagramWords) {
        batch.insert(
          database.wordDictionaryTable,
          WordDictionaryTableCompanion.insert(
            word: wordData['word'] as String,
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: wordData['difficulty'] as ExerciseDifficulty,
            length: (wordData['word'] as String).length,
            version: const Value(WORD_DICTIONARY_VERSION),
          ),
        );
      }

      // Batch insert Spanish anagram words
      for (final wordData in spanishAnagramWords) {
        batch.insert(
          database.wordDictionaryTable,
          WordDictionaryTableCompanion.insert(
            word: wordData['word'] as String,
            language: WordLanguage.spanish,
            type: WordType.anagram,
            difficulty: wordData['difficulty'] as ExerciseDifficulty,
            length: (wordData['word'] as String).length,
            version: const Value(WORD_DICTIONARY_VERSION),
          ),
        );
      }

      // Batch insert word search words (all difficulties)
      for (final word in wordSearchWords) {
        // Assign difficulty based on word length
        ExerciseDifficulty difficulty;
        if (word.length <= 4) {
          difficulty = ExerciseDifficulty.easy;
        } else if (word.length <= 6) {
          difficulty = ExerciseDifficulty.medium;
        } else if (word.length <= 8) {
          difficulty = ExerciseDifficulty.hard;
        } else {
          difficulty = ExerciseDifficulty.expert;
        }

        batch.insert(
          database.wordDictionaryTable,
          WordDictionaryTableCompanion.insert(
            word: word,
            language: WordLanguage.english,
            type: WordType.wordSearch,
            difficulty: difficulty,
            length: word.length,
            version: const Value(WORD_DICTIONARY_VERSION),
          ),
        );
      }

      // Batch insert validation words (for answer validation, not puzzle generation)
      for (final word in validationWords) {
        // Assign difficulty based on word length
        ExerciseDifficulty difficulty;
        if (word.length <= 4) {
          difficulty = ExerciseDifficulty.easy;
        } else if (word.length <= 6) {
          difficulty = ExerciseDifficulty.medium;
        } else if (word.length <= 8) {
          difficulty = ExerciseDifficulty.hard;
        } else {
          difficulty = ExerciseDifficulty.expert;
        }

        batch.insert(
          database.wordDictionaryTable,
          WordDictionaryTableCompanion.insert(
            word: word,
            language: WordLanguage.english,
            type: WordType.validationOnly,
            difficulty: difficulty,
            length: word.length,
            version: const Value(WORD_DICTIONARY_VERSION),
          ),
        );
      }
    });

    print('Word dictionary initialization completed!');
  }

  // Get random words for anagram puzzles
  static Future<List<String>> getRandomAnagramWords(
    AppDatabase database,
    WordLanguage language,
    ExerciseDifficulty difficulty,
    int count,
  ) async {
    final words = await (database.select(database.wordDictionaryTable)
          ..where((tbl) => tbl.language.equals(language.name))
          ..where((tbl) => tbl.type.equals(WordType.anagram.name))
          ..where((tbl) => tbl.difficulty.equals(difficulty.name))
          ..where((tbl) => tbl.isActive.equals(true)))
        .get();
    
    if (words.isEmpty) return [];
    
    words.shuffle();
    return words.take(count).map((w) => w.word).toList();
  }

  // Get random words for word search puzzles
  static Future<List<String>> getRandomWordSearchWords(
    AppDatabase database,
    ExerciseDifficulty difficulty,
    int count,
  ) async {
    final words = await (database.select(database.wordDictionaryTable)
          ..where((tbl) => tbl.language.equals(WordLanguage.english.name))
          ..where((tbl) => tbl.type.equals(WordType.wordSearch.name))
          ..where((tbl) => tbl.difficulty.equals(difficulty.name))
          ..where((tbl) => tbl.isActive.equals(true)))
        .get();
    
    if (words.isEmpty) return [];
    
    words.shuffle();
    return words.take(count).map((w) => w.word).toList();
  }

  // Check if a word is valid (exists in dictionary)
  static Future<bool> isValidWord(
    AppDatabase database,
    String word,
    WordLanguage language,
  ) async {
    final results = await (database.select(database.wordDictionaryTable)
          ..where((tbl) => tbl.word.equals(word.toUpperCase()))
          // Ideally check language too, but original code didn't. 
          // Adding language check is safer.
          // ..where((tbl) => tbl.language.equals(language.name)) 
          // Wait, validation words are marked as WordType.validationOnly or others?
          // If I check language, I must ensure validation words have correct language set.
          // They do (lines 115, 128).
          // But the widget logic didn't pass language.
          // I'll stick to simple check for now or try to match widget behavior?
          // Widget behavior: `_isValidWordInDatabase` checks ONLY word and isActive.
          // But I added `WordLanguage` to `WordRepository.isValidWord`.
          // So I SHOULD check language if provided.
          // I'll check language if it matches logic.
          // If I don't check language, "HOLA" (Spanish) might validate in English game if DB has it?
          // Yes. Ideally validation should be language specific.
          // I will add language check.
          ..where((tbl) => tbl.isActive.equals(true)))
        .get();
    
    // Filter by language in memory or add where clause?
    // Drift enums are stored as Strings (name).
    // ..where((tbl) => tbl.language.equals(language.name))
    
    return results.any((w) => w.language == language); 
  }
}