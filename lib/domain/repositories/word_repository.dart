import '../entities/enums.dart';

abstract class WordRepository {
  Future<List<String>> getAnagramWords(
    WordLanguage language,
    ExerciseDifficulty difficulty,
    int count,
  );

  Future<List<String>> getWordSearchWords(
    ExerciseDifficulty difficulty,
    int count,
  );

  Future<bool> isValidWord(String word, WordLanguage language);
}
