import 'word_list_generator.dart';
import 'word_list_persistence.dart';

/// High-level manager for word lists that coordinates generation and persistence
///
/// Provides:
/// - Automatic list generation and regeneration
/// - Persistence of usage state across sessions
/// - Progress tracking (used/remaining lists)
/// - Generation number tracking
class WordListManager {
  final WordListGenerator _generator;
  final WordListPersistence _persistence;

  bool _initialized = false;

  WordListManager({
    WordListGenerator? generator,
    WordListPersistence? persistence,
  })  : _generator = generator ?? WordListGenerator(),
        _persistence = persistence ?? WordListPersistence();

  /// Initialize the manager by loading previous state
  ///
  /// Loads:
  /// - Previously used list indices
  /// - Current generation number
  /// - Generates initial lists if needed
  Future<void> initialize() async {
    if (_initialized) return;

    // Load persisted state
    final usedIndices = await _persistence.loadUsedIndices();
    final generationNumber = await _persistence.loadGenerationNumber();

    // Generate initial lists
    _generator.generateInitialLists();

    // Restore used indices from persistence
    for (final index in usedIndices) {
      _generator.markListAsUsed(index);
    }

    // Restore generation number
    _generator.setGenerationNumber(generationNumber);

    _initialized = true;
  }

  /// Get the next unused word list
  ///
  /// Returns a list of 5 words. If all lists have been used,
  /// automatically regenerates a new set of 200 lists.
  ///
  /// Persists state after each call.
  Future<List<String>> getNextWordList() async {
    // Auto-initialize if not done
    if (!_initialized) {
      await initialize();
    }

    // Check if regeneration is needed
    if (!_generator.hasUnusedLists()) {
      await _regenerate();
    }

    // Get next unused list
    final index = _generator.getUnusedListIndex();
    final wordList = _generator.getList(index);

    // Mark as used
    _generator.markListAsUsed(index);

    // Persist state
    await _saveState();

    return wordList;
  }

  /// Get current generation number (0 = initial, 1+ = regenerated)
  int getCurrentGeneration() {
    return _generator.generationNumber;
  }

  /// Get count of used lists in current generation
  int getUsedListCount() {
    return _generator.usedListIndices.length;
  }

  /// Get count of remaining unused lists
  int getRemainingListCount() {
    return getTotalLists() - getUsedListCount();
  }

  /// Get total number of lists (always 200)
  int getTotalLists() {
    return _generator.getCurrentLists().length;
  }

  /// Regenerate lists with new shuffle
  Future<void> _regenerate() async {
    _generator.regenerateLists();
    await _saveState();
  }

  /// Save current state to persistence
  Future<void> _saveState() async {
    await _persistence.saveUsedIndices(_generator.usedListIndices);
    await _persistence.saveGenerationNumber(_generator.generationNumber);
  }

  /// Clear all persisted data (for testing or reset)
  Future<void> clearAll() async {
    await _persistence.clearAll();
    _generator.generateInitialLists();
    _initialized = false;
  }
}
