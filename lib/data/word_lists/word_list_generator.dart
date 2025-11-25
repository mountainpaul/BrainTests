import 'dart:math';
import 'grouped_word_lists.dart';

/// Manages pre-grouped word lists with semantic categories for cognitive testing.
///
/// Each list contains exactly one word from each semantic category:
/// - Food
/// - Profession
/// - Abstract concept
/// - Object
/// - Animal
///
/// Key features:
/// - 200 pre-grouped lists ensuring semantic diversity
/// - Tracks which lists have been used
/// - Can shuffle list order when all lists are exhausted
/// - Reproducible with seeds for testing
class WordListGenerator {
  final int seed;
  final Random _random;

  List<List<String>> _currentLists = [];
  final Set<int> _usedListIndices = {};
  int _generationNumber = 0;

  /// Create a new word list generator with optional seed for reproducibility
  WordListGenerator({int? seed})
      : seed = seed ?? DateTime.now().millisecondsSinceEpoch,
        _random = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

  /// Get the set of used list indices
  Set<int> get usedListIndices => Set.unmodifiable(_usedListIndices);

  /// Get current generation number (0 = initial, 1+ = regenerated)
  int get generationNumber => _generationNumber;

  /// Generate the initial 200 word lists
  ///
  /// Uses pre-grouped lists where each list contains one word from each
  /// semantic category (Food, Profession, Abstract, Object, Animal).
  /// Words within each list are shuffled to prevent positional learning.
  /// This ensures:
  /// - Semantic diversity within each list
  /// - No clustering of similar words
  /// - Balanced cognitive load
  /// - No predictable word positions
  List<List<String>> generateInitialLists() {
    // Copy the pre-grouped lists and shuffle words within each list
    _currentLists = GroupedWordLists.lists.map((list) {
      final shuffledList = List<String>.from(list);
      shuffledList.shuffle(_random);
      return shuffledList;
    }).toList();

    _usedListIndices.clear();
    _generationNumber = 0;

    return _currentLists;
  }

  /// Mark a list index as used
  void markListAsUsed(int index) {
    if (index < 0 || index >= _currentLists.length) {
      throw ArgumentError('Invalid list index: $index');
    }
    _usedListIndices.add(index);
  }

  /// Check if there are any unused lists remaining
  bool hasUnusedLists() {
    return _usedListIndices.length < _currentLists.length;
  }

  /// Get a random unused list index
  ///
  /// Returns -1 if all lists have been used
  int getUnusedListIndex() {
    if (!hasUnusedLists()) {
      return -1;
    }

    // Find all unused indices
    final unusedIndices = <int>[];
    for (int i = 0; i < _currentLists.length; i++) {
      if (!_usedListIndices.contains(i)) {
        unusedIndices.add(i);
      }
    }

    // Return a random unused index
    return unusedIndices[_random.nextInt(unusedIndices.length)];
  }

  /// Regenerate lists by shuffling their order when all have been used
  ///
  /// Shuffles the order in which the pre-grouped lists appear, AND
  /// shuffles the words within each list to prevent positional learning.
  /// The semantic grouping (one word per category) is preserved.
  List<List<String>> regenerateLists() {
    _generationNumber++;

    // Copy and shuffle words within each list, then shuffle list order
    _currentLists = GroupedWordLists.lists.map((list) {
      final shuffledList = List<String>.from(list);
      shuffledList.shuffle(_random);
      return shuffledList;
    }).toList();
    _currentLists.shuffle(_random);

    // Reset usage tracking
    _usedListIndices.clear();

    return _currentLists;
  }

  /// Get the current lists
  List<List<String>> getCurrentLists() => _currentLists;

  /// Get a specific list by index
  List<String> getList(int index) {
    if (index < 0 || index >= _currentLists.length) {
      throw ArgumentError('Invalid list index: $index');
    }
    return _currentLists[index];
  }

  /// Set the generation number (used when restoring from persistence)
  void setGenerationNumber(int generation) {
    _generationNumber = generation;
  }
}
