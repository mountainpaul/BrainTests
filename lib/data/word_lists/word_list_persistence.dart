import 'package:shared_preferences/shared_preferences.dart';

/// Handles persistence of word list usage tracking
///
/// Saves/loads:
/// - Which list indices have been used
/// - Current generation number
/// - Ensures data persists across app restarts
class WordListPersistence {
  static const String _keyUsedIndices = 'word_list_used_indices';
  static const String _keyGeneration = 'word_list_generation';

  /// Save used list indices to persistent storage
  Future<void> saveUsedIndices(Set<int> usedIndices) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> indicesList = usedIndices.map((i) => i.toString()).toList();
    await prefs.setStringList(_keyUsedIndices, indicesList);
  }

  /// Load used list indices from persistent storage
  Future<Set<int>> loadUsedIndices() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? indicesList = prefs.getStringList(_keyUsedIndices);

    if (indicesList == null || indicesList.isEmpty) {
      return {};
    }

    return indicesList.map((s) => int.parse(s)).toSet();
  }

  /// Save current generation number
  Future<void> saveGenerationNumber(int generation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGeneration, generation);
  }

  /// Load current generation number (defaults to 0)
  Future<int> loadGenerationNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyGeneration) ?? 0;
  }

  /// Clear used indices (called on regeneration)
  Future<void> clearUsedIndices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsedIndices);
  }

  /// Clear all word list data (for testing or reset)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsedIndices);
    await prefs.remove(_keyGeneration);
  }
}
