import '../../core/services/word_dictionary_service.dart';
import '../../data/datasources/database.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/word_repository.dart';

class WordRepositoryImpl implements WordRepository {
  final AppDatabase _database;

  WordRepositoryImpl(this._database);

  @override
  Future<List<String>> getAnagramWords(
    WordLanguage language,
    ExerciseDifficulty difficulty,
    int count,
  ) {
    return WordDictionaryService.getRandomAnagramWords(
      _database,
      language,
      difficulty,
      count,
    );
  }

  @override
  Future<List<String>> getWordSearchWords(
    ExerciseDifficulty difficulty,
    int count,
  ) {
    return WordDictionaryService.getRandomWordSearchWords(
      _database,
      difficulty,
      count,
    );
  }

  @override
  Future<bool> isValidWord(String word, WordLanguage language) {
    return WordDictionaryService.isValidWord(
      _database,
      word,
      language,
    );
  }
}
