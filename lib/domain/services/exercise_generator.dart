import 'dart:math';

import '../../core/services/word_dictionary_service.dart';
import '../../data/datasources/database.dart';

/// Service that generates real cognitive exercises
class ExerciseGenerator {
  static final Random _random = Random();

  /// Ensures letters are scrambled and different from original order
  static List<String> ensureScrambled(List<String> originalLetters) {
    final letters = List<String>.from(originalLetters);
    final originalString = letters.join('');

    // Try up to 10 times to get a different arrangement
    for (int attempts = 0; attempts < 10; attempts++) {
      letters.shuffle(_random);
      if (letters.join('') != originalString) {
        return letters;
      }
    }

    // If shuffle didn't work (rare case with very short words), manually rearrange
    if (letters.length >= 2) {
      // Swap first two letters if they're different
      if (letters[0] != letters[1]) {
        final temp = letters[0];
        letters[0] = letters[1];
        letters[1] = temp;
      } else if (letters.length >= 3) {
        // Swap first and last letters
        final temp = letters[0];
        letters[0] = letters[letters.length - 1];
        letters[letters.length - 1] = temp;
      }
    }

    return letters;
  }

  /// Generate Memory Game Exercise - Card Matching
  static MemoryGameData generateMemoryGame({
    ExerciseDifficulty difficulty = ExerciseDifficulty.medium,
    int? userAge,
  }) {
    final gridSize = _getMemoryGameGridSize(difficulty);
    final totalCards = gridSize * gridSize;
    final pairs = totalCards ~/ 2;

    // Generate card symbols (using emojis for visual appeal)
    final symbols = [
      '🐱', '🐶', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯',
      '🦁', '🐸', '🐷', '🐮', '🐵', '🐔', '🐧', '🦉',
      '🦋', '🐝', '🐞', '🦄', '🌟', '💎', '🌙', '☀️',
      '🍎', '🍌', '🍇', '🍊', '🍓', '🍒', '🥝', '🍑'
    ];

    // Select random symbols for pairs
    final shuffledSymbols = List<String>.from(symbols)..shuffle(_random);
    final selectedSymbols = shuffledSymbols.take(pairs).toList();
    final cardSymbols = <String>[];

    // Add each symbol twice (for pairs)
    for (final String symbol in selectedSymbols) {
      cardSymbols.add(symbol);
      cardSymbols.add(symbol);
    }

    // Shuffle the cards
    cardSymbols.shuffle(_random);

    return MemoryGameData(
      gridSize: gridSize,
      cardSymbols: cardSymbols,
      showTimeSeconds: _getMemoryShowTime(difficulty, userAge),
      timeLimit: _getMemoryTimeLimit(difficulty),
    );
  }

  /// Generate Word Puzzle Exercise - Anagram or Word Search
  static Future<WordPuzzleData> generateWordPuzzle({
    ExerciseDifficulty difficulty = ExerciseDifficulty.medium,
    required AppDatabase database,
    WordType wordType = WordType.anagram,
  }) async {
    if (wordType == WordType.anagram) {
      return await _generateAnagramPuzzle(difficulty, database);
    } else {
      return await _generateWordSearchPuzzle(difficulty, database);
    }
  }

  /// Generate Spanish Anagram Exercise
  static Future<WordPuzzleData> generateSpanishAnagram({
    ExerciseDifficulty difficulty = ExerciseDifficulty.medium,
    required AppDatabase database,
  }) async {
    return await _generateSpanishAnagramPuzzle(difficulty, database);
  }

  /// Generate Math Problem Exercise - Arithmetic Challenges
  static MathProblemData generateMathProblem({ExerciseDifficulty difficulty = ExerciseDifficulty.medium}) {
    // Filter problem types based on difficulty
    // Easy mode: no algebra (which introduces negative numbers)
    final availableTypes = difficulty == ExerciseDifficulty.easy
        ? [MathProblemType.arithmetic, MathProblemType.sequence, MathProblemType.comparison]
        : MathProblemType.values;

    final problemType = availableTypes[_random.nextInt(availableTypes.length)];

    switch (problemType) {
      case MathProblemType.arithmetic:
        return _generateArithmeticProblem(difficulty);
      case MathProblemType.sequence:
        return _generateNumberSequence(difficulty);
      case MathProblemType.comparison:
        return _generateComparisonProblem(difficulty);
      case MathProblemType.algebra:
        return _generateAlgebraProblem(difficulty);
    }
  }

  /// Generate Pattern Recognition Exercise - Visual/Logic Patterns
  static PatternRecognitionData generatePatternRecognition({ExerciseDifficulty difficulty = ExerciseDifficulty.medium}) {
    final patternType = PatternType.values[_random.nextInt(PatternType.values.length)];
    
    switch (patternType) {
      case PatternType.shape:
        return _generateShapePattern(difficulty);
      case PatternType.color:
        return _generateColorPattern(difficulty);
      case PatternType.number:
        return _generateNumberPattern(difficulty);
    }
  }

  /// Generate Sequence Recall Exercise - Memory Sequences
  static SequenceRecallData generateSequenceRecall({ExerciseDifficulty difficulty = ExerciseDifficulty.medium}) {
    final sequenceLength = _getSequenceLength(difficulty);
    final sequenceType = SequenceType.values[_random.nextInt(SequenceType.values.length)];
    
    switch (sequenceType) {
      case SequenceType.visual:
        return _generateVisualSequence(difficulty, sequenceLength);
      case SequenceType.audio:
        return _generateAudioSequence(difficulty, sequenceLength);
      case SequenceType.spatial:
        return _generateSpatialSequence(difficulty, sequenceLength);
    }
  }

  /// Generate Spatial Awareness Exercise - 3D Visualization
  static SpatialAwarenessData generateSpatialAwareness({ExerciseDifficulty difficulty = ExerciseDifficulty.medium}) {
    final spatialType = SpatialType.values[_random.nextInt(SpatialType.values.length)];
    
    switch (spatialType) {
      case SpatialType.rotation:
        return _generateRotationPuzzle(difficulty);
      case SpatialType.folding:
        return _generateFoldingPuzzle(difficulty);
      case SpatialType.navigation:
        return _generateNavigationPuzzle(difficulty);
    }
  }

  // Helper methods for Memory Game
  static int _getMemoryGameGridSize(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 2; // 2x2 = 4 cards (2 pairs)
      case ExerciseDifficulty.medium:
        return 4; // 4x4 = 16 cards (8 pairs)
      case ExerciseDifficulty.hard:
        return 6; // 6x6 = 36 cards (18 pairs)
      case ExerciseDifficulty.expert:
        return 8; // 8x8 = 64 cards (32 pairs)
    }
  }

  static int _getMemoryShowTime(ExerciseDifficulty difficulty, int? userAge) {
    int baseTime;
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        baseTime = 5;
        break;
      case ExerciseDifficulty.medium:
        baseTime = 4;
        break;
      case ExerciseDifficulty.hard:
        baseTime = 3;
        break;
      case ExerciseDifficulty.expert:
        baseTime = 2;
        break;
    }

    // Apply age adjustment if available
    if (userAge != null) {
      // Import is needed but we can't import services here, so we'll calculate inline
      double multiplier = 1.0;
      if (userAge >= 80) {
        multiplier = 1.8; // +80%
      } else if (userAge >= 70) {
        multiplier = 1.6; // +60%
      } else if (userAge >= 60) {
        multiplier = 1.4; // +40%
      } else if (userAge >= 50) {
        multiplier = 1.2; // +20%
      }

      return (baseTime * multiplier).round();
    }

    return baseTime;
  }

  static int _getMemoryTimeLimit(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 180; // 3 minutes
      case ExerciseDifficulty.medium:
        return 120; // 2 minutes
      case ExerciseDifficulty.hard:
        return 90;  // 1.5 minutes
      case ExerciseDifficulty.expert:
        return 60;  // 1 minute
    }
  }

  // Helper methods for Word Puzzles
  static Future<WordPuzzleData> _generateAnagramPuzzle(ExerciseDifficulty difficulty, AppDatabase database) async {
    final words = await WordDictionaryService.getRandomAnagramWords(
      database,
      WordLanguage.english,
      difficulty,
      1, // Get one word
    );

    if (words.isEmpty) {
      // Fallback to hardcoded word if database is empty
      final fallbackWord = difficulty == ExerciseDifficulty.easy ? 'CAT' : 'HOUSE';
      final scrambledLetters = ensureScrambled(fallbackWord.split(''));
      return WordPuzzleData(
        type: WordPuzzleType.anagram,
        targetWord: fallbackWord,
        scrambledLetters: scrambledLetters,
        timeLimit: _getWordPuzzleTimeLimit(difficulty),
      );
    }

    final targetWord = words.first;
    final scrambledLetters = ensureScrambled(targetWord.split(''));

    return WordPuzzleData(
      type: WordPuzzleType.anagram,
      targetWord: targetWord,
      scrambledLetters: scrambledLetters,
      timeLimit: _getWordPuzzleTimeLimit(difficulty),
    );
  }

  static Future<WordPuzzleData> _generateSpanishAnagramPuzzle(ExerciseDifficulty difficulty, AppDatabase database) async {
    final words = await WordDictionaryService.getRandomAnagramWords(
      database,
      WordLanguage.spanish,
      difficulty,
      1, // Get one word
    );

    if (words.isEmpty) {
      // Fallback to hardcoded Spanish word if database is empty
      final fallbackWord = difficulty == ExerciseDifficulty.easy ? 'CASA' : 'FAMILIA';
      final scrambledLetters = ensureScrambled(fallbackWord.split(''));
      return WordPuzzleData(
        type: WordPuzzleType.anagram,
        targetWord: fallbackWord,
        scrambledLetters: scrambledLetters,
        timeLimit: _getWordPuzzleTimeLimit(difficulty),
      );
    }

    final targetWord = words.first;
    final scrambledLetters = ensureScrambled(targetWord.split(''));

    return WordPuzzleData(
      type: WordPuzzleType.anagram,
      targetWord: targetWord,
      scrambledLetters: scrambledLetters,
      timeLimit: _getWordPuzzleTimeLimit(difficulty),
    );
  }

  static Future<WordPuzzleData> _generateWordSearchPuzzle(ExerciseDifficulty difficulty, AppDatabase database) async {
    final wordCount = _getWordSearchCount(difficulty);
    final gridSize = _getWordSearchGridSize(difficulty);

    final words = await WordDictionaryService.getRandomWordSearchWords(
      database,
      difficulty,
      wordCount,
    );

    List<String> targetWords;
    if (words.isEmpty) {
      // Fallback to hardcoded words if database is empty
      final fallbackWords = ['CAT', 'DOG', 'SUN', 'CAR', 'BOOK', 'TREE', 'FISH', 'BIRD'];
      final shuffledWords = List<String>.from(fallbackWords)..shuffle(_random);
      targetWords = shuffledWords.take(wordCount).toList();
    } else {
      targetWords = words;
    }

    // Filter words that can fit in the grid
    targetWords = targetWords.where((word) => word.length <= gridSize).toList();

    // If no words fit after filtering, use fallback words appropriate for grid size
    if (targetWords.isEmpty) {
      final fallbackWords = ['CAT', 'DOG', 'SUN', 'CAR', 'BOOK', 'TREE', 'FISH', 'BIRD'];
      final validFallbacks = fallbackWords.where((word) => word.length <= gridSize).toList();
      final shuffledWords = List<String>.from(validFallbacks)..shuffle(_random);
      targetWords = shuffledWords.take(wordCount.clamp(1, validFallbacks.length)).toList();
    }

    // Generate grid with words placed
    final grid = _generateWordSearchGrid(targetWords, gridSize);

    return WordPuzzleData(
      type: WordPuzzleType.wordSearch,
      grid: grid,
      targetWords: targetWords,
      timeLimit: _getWordPuzzleTimeLimit(difficulty),
    );
  }

  static int _getWordPuzzleTimeLimit(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 120;
      case ExerciseDifficulty.medium:
        return 90;
      case ExerciseDifficulty.hard:
        return 60;
      case ExerciseDifficulty.expert:
        return 45;
    }
  }

  static int _getWordSearchCount(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 3;
      case ExerciseDifficulty.medium:
        return 4;
      case ExerciseDifficulty.hard:
        return 5;
      case ExerciseDifficulty.expert:
        return 6;
    }
  }

  static int _getWordSearchGridSize(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 8;
      case ExerciseDifficulty.medium:
        return 10;
      case ExerciseDifficulty.hard:
        return 12;
      case ExerciseDifficulty.expert:
        return 15;
    }
  }

  static List<List<String>> _generateWordSearchGrid(List<String> targetWords, int gridSize) {
    // Initialize grid with empty spaces
    final grid = List.generate(gridSize, 
      (i) => List.generate(gridSize, (j) => '')
    );
    
    // Placement directions: horizontal, vertical, diagonal
    final directions = [
      [0, 1],   // horizontal
      [1, 0],   // vertical
      [1, 1],   // diagonal down-right
      [-1, 1],  // diagonal up-right
    ];
    
    // Place each word in the grid
    for (final word in targetWords) {
      bool placed = false;
      int attempts = 0;
      
      while (!placed && attempts < 100) {
        final direction = directions[_random.nextInt(directions.length)];
        final startRow = _random.nextInt(gridSize);
        final startCol = _random.nextInt(gridSize);
        
        if (_canPlaceWord(grid, word, startRow, startCol, direction, gridSize)) {
          _placeWord(grid, word, startRow, startCol, direction);
          placed = true;
        }
        attempts++;
      }
    }
    
    // Fill empty spaces with random letters
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].isEmpty) {
          grid[i][j] = String.fromCharCode(65 + _random.nextInt(26));
        }
      }
    }
    
    return grid;
  }
  
  static bool _canPlaceWord(List<List<String>> grid, String word, int row, int col, List<int> direction, int gridSize) {
    for (int i = 0; i < word.length; i++) {
      final newRow = row + (i * direction[0]);
      final newCol = col + (i * direction[1]);
      
      // Check bounds
      if (newRow < 0 || newRow >= gridSize || newCol < 0 || newCol >= gridSize) {
        return false;
      }
      
      // Check if position is empty or contains the same letter
      if (grid[newRow][newCol].isNotEmpty && grid[newRow][newCol] != word[i]) {
        return false;
      }
    }
    return true;
  }
  
  static void _placeWord(List<List<String>> grid, String word, int row, int col, List<int> direction) {
    for (int i = 0; i < word.length; i++) {
      final newRow = row + (i * direction[0]);
      final newCol = col + (i * direction[1]);
      grid[newRow][newCol] = word[i];
    }
  }

  // Helper methods for Math Problems
  static MathProblemData _generateArithmeticProblem(ExerciseDifficulty difficulty) {
    final range = _getMathRange(difficulty);
    final operations = _getMathOperations(difficulty);
    final operation = operations[_random.nextInt(operations.length)];
    
    int a, b, answer;
    String question;
    
    switch (operation) {
      case '+':
        a = _random.nextInt(range) + 1;
        b = _random.nextInt(range) + 1;
        answer = a + b;
        question = '$a + $b = ?';
        break;
      case '-':
        a = _random.nextInt(range) + range ~/ 2;
        b = _random.nextInt(range ~/ 2) + 1;
        answer = a - b;
        question = '$a - $b = ?';
        break;
      case '×':
        a = _random.nextInt(range ~/ 5) + 1;
        b = _random.nextInt(range ~/ 5) + 1;
        answer = a * b;
        question = '$a × $b = ?';
        break;
      case '÷':
        b = _random.nextInt(range ~/ 10) + 2;
        answer = _random.nextInt(range ~/ 5) + 1;
        a = b * answer;
        question = '$a ÷ $b = ?';
        break;
      default:
        a = _random.nextInt(range) + 1;
        b = _random.nextInt(range) + 1;
        answer = a + b;
        question = '$a + $b = ?';
    }

    // Generate multiple choice options
    final options = <int>[answer];
    int attempts = 0;
    while (options.length < 4 && attempts < 100) {
      attempts++;
      final wrongAnswer = answer + _random.nextInt(20) - 10;
      if (wrongAnswer != answer && wrongAnswer > 0 && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    options.shuffle(_random);

    return MathProblemData(
      type: MathProblemType.arithmetic,
      question: question,
      answer: answer,
      options: options,
      timeLimit: _getMathTimeLimit(difficulty),
    );
  }

  static MathProblemData _generateNumberSequence(ExerciseDifficulty difficulty) {
    final sequenceLength = _getMathSequenceLength(difficulty);
    final step = _random.nextInt(5) + 2;
    final start = _random.nextInt(20) + 1;
    
    final sequence = <int>[];
    for (int i = 0; i < sequenceLength - 1; i++) {
      sequence.add(start + (i * step));
    }
    
    final answer = start + ((sequenceLength - 1) * step);
    final question = 'What comes next? ${sequence.join(', ')}, ?';
    
    final options = <int>[answer];
    int attempts = 0;
    while (options.length < 4 && attempts < 100) {
      attempts++;
      final wrongAnswer = answer + _random.nextInt(20) - 10;
      if (wrongAnswer != answer && wrongAnswer > 0 && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    options.shuffle(_random);

    return MathProblemData(
      type: MathProblemType.sequence,
      question: question,
      answer: answer,
      options: options,
      timeLimit: _getMathTimeLimit(difficulty),
    );
  }

  static MathProblemData _generateComparisonProblem(ExerciseDifficulty difficulty) {
    final range = _getMathRange(difficulty);
    final int a = _random.nextInt(range) + 1;
    int b = _random.nextInt(range) + 1;

    // Ensure a and b are different
    while (a == b) {
      b = _random.nextInt(range) + 1;
    }

    String question;
    int answer;
    List<int> options;

    if (a > b) {
      question = 'Which is larger: $a or $b?';
      answer = a;
      options = [a, b];
    } else {
      question = 'Which is larger: $a or $b?';
      answer = b;
      options = [a, b];
    }
    
    // Add additional options
    int attempts = 0;
    while (options.length < 4 && attempts < 100) {
      attempts++;
      final extra = _random.nextInt(range) + 1;
      if (!options.contains(extra)) {
        options.add(extra);
      }
    }
    options.shuffle(_random);

    return MathProblemData(
      type: MathProblemType.comparison,
      question: question,
      answer: answer,
      options: options,
      timeLimit: _getMathTimeLimit(difficulty),
    );
  }

  static MathProblemData _generateAlgebraProblem(ExerciseDifficulty difficulty) {
    final algebraTypes = _getAlgebraTypes(difficulty);
    final algebraType = algebraTypes[_random.nextInt(algebraTypes.length)];
    
    switch (algebraType) {
      case 'linear':
        return _generateLinearEquation(difficulty);
      case 'quadratic':
        return _generateQuadraticEquation(difficulty);
      case 'system':
        return _generateSystemOfEquations(difficulty);
      case 'polynomial':
        return _generatePolynomialProblem(difficulty);
      case 'factoring':
        return _generateFactoringProblem(difficulty);
      default:
        return _generateLinearEquation(difficulty);
    }
  }

  static MathProblemData _generateLinearEquation(ExerciseDifficulty difficulty) {
    final range = _getAlgebraRange(difficulty);
    
    // Generate equation ax + b = c, solve for x
    int a, b, c, x;
    String question;
    
    // Choose random coefficients
    a = _random.nextInt(range) + 1; // 1 to range
    x = _random.nextInt(range * 2) - range; // -range to range
    b = _random.nextInt(range * 2) - range; // -range to range
    c = a * x + b;
    
    // Format the equation nicely
    final String bString = b >= 0 ? '+ $b' : '- ${-b}';
    question = '${a}x $bString = $c. Solve for x:';
    
    final options = <int>[x];
    int attempts = 0;
    while (options.length < 4 && attempts < 100) {
      attempts++;
      final wrongAnswer = x + _random.nextInt(10) - 5;
      if (wrongAnswer != x && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    options.shuffle(_random);

    return MathProblemData(
      type: MathProblemType.algebra,
      question: question,
      answer: x,
      options: options,
      timeLimit: _getAlgebraTimeLimit(difficulty),
    );
  }

  static MathProblemData _generateQuadraticEquation(ExerciseDifficulty difficulty) {
    // Generate simple quadratic: x² + bx + c = 0 with integer solutions
    int p, q; // roots
    p = _random.nextInt(10) - 5; // -5 to 4
    q = _random.nextInt(10) - 5; // -5 to 4
    
    // Expand (x - p)(x - q) = x² - (p+q)x + pq
    final int b = -(p + q);
    final int c = p * q;
    
    final String bString = b >= 0 ? '+ ${b}x' : '- ${-b}x';
    final String cString = c >= 0 ? '+ $c' : '- ${-c}';
    final String question = 'x² $bString $cString = 0. Find one solution:';
    
    // Pick one of the roots randomly
    final answer = _random.nextBool() ? p : q;
    
    final options = <int>[answer];
    int attempts = 0;
    while (options.length < 4 && attempts < 100) {
      attempts++;
      final wrongAnswer = answer + _random.nextInt(10) - 5;
      if (wrongAnswer != answer && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    options.shuffle(_random);

    return MathProblemData(
      type: MathProblemType.algebra,
      question: question,
      answer: answer,
      options: options,
      timeLimit: _getAlgebraTimeLimit(difficulty),
    );
  }

  static MathProblemData _generateSystemOfEquations(ExerciseDifficulty difficulty) {
    // Generate 2x2 system with integer solutions
    int x, y; // solutions
    x = _random.nextInt(10) - 5; // -5 to 4
    y = _random.nextInt(10) - 5; // -5 to 4
    
    // Generate coefficients
    int a1, b1, c1, a2, b2, c2;
    a1 = _random.nextInt(5) + 1; // 1 to 5
    b1 = _random.nextInt(5) + 1; // 1 to 5
    c1 = a1 * x + b1 * y;
    
    a2 = _random.nextInt(5) + 1; // 1 to 5
    b2 = _random.nextInt(5) + 1; // 1 to 5
    c2 = a2 * x + b2 * y;
    
    final String question = '${a1}x + ${b1}y = $c1\n${a2}x + ${b2}y = $c2\nFind x:';
    
    final options = <int>[x];
    int attempts = 0;
    while (options.length < 4 && attempts < 100) {
      attempts++;
      final wrongAnswer = x + _random.nextInt(10) - 5;
      if (wrongAnswer != x && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    options.shuffle(_random);

    return MathProblemData(
      type: MathProblemType.algebra,
      question: question,
      answer: x,
      options: options,
      timeLimit: _getAlgebraTimeLimit(difficulty),
    );
  }

  static MathProblemData _generatePolynomialProblem(ExerciseDifficulty difficulty) {
    // Expand (x + a)(x + b) = x² + (a+b)x + ab
    int a, b;
    a = _random.nextInt(8) - 4; // -4 to 3
    b = _random.nextInt(8) - 4; // -4 to 3
    
    final int middle = a + b;
    final int constant = a * b;
    
    // Format terms properly with + or - signs
    String aString = a == 0 ? '' : a > 0 ? ' + $a' : ' - ${-a}';
    String bString = b == 0 ? '' : b > 0 ? ' + $b' : ' - ${-b}';
    
    // Handle special cases for cleaner display
    if (a == 0 && b == 0) {
      aString = '';
      bString = '';
    }
    
    final String question = 'Expand (x$aString)(x$bString):';
    
    final options = <int>[middle];
    int attempts = 0;
    while (options.length < 4 && attempts < 100) {
      attempts++;
      final wrongAnswer = middle + _random.nextInt(10) - 5;
      if (wrongAnswer != middle && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    options.shuffle(_random);

    return MathProblemData(
      type: MathProblemType.algebra,
      question: '$question\nWhat is the coefficient of x?',
      answer: middle,
      options: options,
      timeLimit: _getAlgebraTimeLimit(difficulty),
    );
  }

  static MathProblemData _generateFactoringProblem(ExerciseDifficulty difficulty) {
    // Factor x² + bx + c = (x + p)(x + q) where p*q = c, p+q = b
    int p, q;
    p = _random.nextInt(6) + 1; // 1 to 6
    q = _random.nextInt(6) + 1; // 1 to 6
    
    final int b = p + q;
    final int c = p * q;
    
    final String question = 'Factor x² + ${b}x + $c = (x + a)(x + b).\nWhat is the value of a?';
    
    // Answer is one of the factors
    final answer = _random.nextBool() ? p : q;
    
    final options = <int>[answer];
    int attempts = 0;
    while (options.length < 4 && attempts < 100) {
      attempts++;
      final wrongAnswer = answer + _random.nextInt(6) - 3;
      if (wrongAnswer != answer && wrongAnswer > 0 && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    options.shuffle(_random);

    return MathProblemData(
      type: MathProblemType.algebra,
      question: question,
      answer: answer,
      options: options,
      timeLimit: _getAlgebraTimeLimit(difficulty),
    );
  }

  static int _getMathRange(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 20;
      case ExerciseDifficulty.medium:
        return 50;
      case ExerciseDifficulty.hard:
        return 100;
      case ExerciseDifficulty.expert:
        return 200;
    }
  }

  static List<String> _getMathOperations(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return ['+', '-'];
      case ExerciseDifficulty.medium:
        return ['+', '-', '×'];
      case ExerciseDifficulty.hard:
        return ['+', '-', '×', '÷'];
      case ExerciseDifficulty.expert:
        return ['+', '-', '×', '÷'];
    }
  }

  static int _getMathTimeLimit(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 60;
      case ExerciseDifficulty.medium:
        return 45;
      case ExerciseDifficulty.hard:
        return 30;
      case ExerciseDifficulty.expert:
        return 20;
    }
  }

  static int _getMathSequenceLength(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 4;
      case ExerciseDifficulty.medium:
        return 5;
      case ExerciseDifficulty.hard:
        return 6;
      case ExerciseDifficulty.expert:
        return 7;
    }
  }

  // Helper methods for Algebra Problems
  static List<String> _getAlgebraTypes(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return ['linear'];
      case ExerciseDifficulty.medium:
        return ['linear', 'polynomial'];
      case ExerciseDifficulty.hard:
        return ['linear', 'polynomial', 'factoring', 'quadratic'];
      case ExerciseDifficulty.expert:
        return ['linear', 'polynomial', 'factoring', 'quadratic', 'system'];
    }
  }

  static int _getAlgebraRange(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 5;
      case ExerciseDifficulty.medium:
        return 10;
      case ExerciseDifficulty.hard:
        return 15;
      case ExerciseDifficulty.expert:
        return 20;
    }
  }

  static int _getAlgebraTimeLimit(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 90;  // 1.5 minutes
      case ExerciseDifficulty.medium:
        return 120; // 2 minutes
      case ExerciseDifficulty.hard:
        return 150; // 2.5 minutes
      case ExerciseDifficulty.expert:
        return 180; // 3 minutes
    }
  }

  // Helper methods for Pattern Recognition
  static PatternRecognitionData _generateShapePattern(ExerciseDifficulty difficulty) {
    final shapes = ['●', '■', '▲', '◆', '★', '♦', '♠', '♣', '♥', '▼', '◀', '▶'];
    final patternLength = _getPatternLength(difficulty);
    final pattern = <String>[];
    String nextItem;

    // Choose pattern complexity based on difficulty
    final patternComplexity = difficulty == ExerciseDifficulty.easy
        ? 'simple'
        : (difficulty == ExerciseDifficulty.medium
            ? (_random.nextBool() ? 'simple' : 'alternating')
            : ['alternating', 'growing', 'nested'][_random.nextInt(3)]);

    switch (patternComplexity) {
      case 'simple':
        // Simple repeating pattern: ●■●■●■
        final basePattern = shapes.take(_random.nextInt(3) + 2).toList();
        for (int i = 0; i < patternLength; i++) {
          pattern.add(basePattern[i % basePattern.length]);
        }
        nextItem = basePattern[patternLength % basePattern.length];
        break;

      case 'alternating':
        // Alternating pattern: ●■▲●■▲ or ●■■▲●■■▲
        final shapeA = shapes[_random.nextInt(shapes.length)];
        final shapeB = shapes[_random.nextInt(shapes.length)];
        final shapeC = shapes[_random.nextInt(shapes.length)];

        final groupSize = _random.nextInt(2) + 1; // 1 or 2
        final useThreeShapes = difficulty != ExerciseDifficulty.medium && _random.nextBool();

        for (int i = 0; i < patternLength; i++) {
          final groupIndex = (i ~/ groupSize) % (useThreeShapes ? 3 : 2);
          pattern.add(groupIndex == 0 ? shapeA : (groupIndex == 1 ? shapeB : shapeC));
        }

        final nextGroupIndex = (patternLength ~/ groupSize) % (useThreeShapes ? 3 : 2);
        nextItem = nextGroupIndex == 0 ? shapeA : (nextGroupIndex == 1 ? shapeB : shapeC);
        break;

      case 'growing':
        // Growing pattern: ●●■●●●■■●●●●■■■
        final shapeA = shapes[_random.nextInt(shapes.length)];
        final shapeB = shapes[_random.nextInt(shapes.length)];

        int currentGroup = 1;
        int inGroupCount = 0;
        bool isAGroup = true;

        for (int i = 0; i < patternLength; i++) {
          pattern.add(isAGroup ? shapeA : shapeB);
          inGroupCount++;

          if (inGroupCount >= currentGroup) {
            isAGroup = !isAGroup;
            inGroupCount = 0;
            if (!isAGroup) currentGroup++;
          }
        }

        nextItem = isAGroup ? shapeA : shapeB;
        break;

      case 'nested':
        // Nested/Complex pattern: ●■▲■●■▲■●■▲■
        final shapeA = shapes[_random.nextInt(shapes.length)];
        final shapeB = shapes[_random.nextInt(shapes.length)];
        final shapeC = shapes[_random.nextInt(shapes.length)];

        // Pattern: A, B, C, B, repeat
        final basePattern = [shapeA, shapeB, shapeC, shapeB];
        for (int i = 0; i < patternLength; i++) {
          pattern.add(basePattern[i % basePattern.length]);
        }
        nextItem = basePattern[patternLength % basePattern.length];
        break;

      default:
        // Fallback to simple
        final basePattern = shapes.take(_random.nextInt(3) + 2).toList();
        for (int i = 0; i < patternLength; i++) {
          pattern.add(basePattern[i % basePattern.length]);
        }
        nextItem = basePattern[patternLength % basePattern.length];
    }

    // Generate plausible wrong options
    final options = <String>[nextItem];
    final usedShapes = pattern.toSet();

    // Add shapes that appear in the pattern but aren't correct
    for (final shape in usedShapes) {
      if (shape != nextItem && options.length < 4) {
        options.add(shape);
      }
    }

    // Fill remaining with random shapes
    while (options.length < 4) {
      final shape = shapes[_random.nextInt(shapes.length)];
      if (!options.contains(shape)) {
        options.add(shape);
      }
    }

    options.shuffle(_random);

    return PatternRecognitionData(
      type: PatternType.shape,
      pattern: pattern,
      options: options,
      correctAnswer: nextItem,
      timeLimit: _getPatternTimeLimit(difficulty),
    );
  }

  static PatternRecognitionData _generateColorPattern(ExerciseDifficulty difficulty) {
    final colors = ['🔴', '🟡', '🟢', '🔵', '🟣', '🟠', '🟤', '⚫', '⚪', '🟤'];
    final patternLength = _getPatternLength(difficulty);
    final pattern = <String>[];
    String nextItem;

    // Choose pattern complexity based on difficulty (same as shapes)
    final patternComplexity = difficulty == ExerciseDifficulty.easy
        ? 'simple'
        : (difficulty == ExerciseDifficulty.medium
            ? (_random.nextBool() ? 'simple' : 'alternating')
            : ['alternating', 'growing', 'nested'][_random.nextInt(3)]);

    switch (patternComplexity) {
      case 'simple':
        // Simple repeating pattern: 🔴🟡🔴🟡🔴🟡
        final basePattern = colors.take(_random.nextInt(3) + 2).toList();
        for (int i = 0; i < patternLength; i++) {
          pattern.add(basePattern[i % basePattern.length]);
        }
        nextItem = basePattern[patternLength % basePattern.length];
        break;

      case 'alternating':
        // Alternating pattern: 🔴🟡🟢🔴🟡🟢 or 🔴🔴🟡🔴🔴🟡
        final colorA = colors[_random.nextInt(colors.length)];
        final colorB = colors[_random.nextInt(colors.length)];
        final colorC = colors[_random.nextInt(colors.length)];

        final groupSize = _random.nextInt(2) + 1; // 1 or 2
        final useThreeColors = difficulty != ExerciseDifficulty.medium && _random.nextBool();

        for (int i = 0; i < patternLength; i++) {
          final groupIndex = (i ~/ groupSize) % (useThreeColors ? 3 : 2);
          pattern.add(groupIndex == 0 ? colorA : (groupIndex == 1 ? colorB : colorC));
        }

        final nextGroupIndex = (patternLength ~/ groupSize) % (useThreeColors ? 3 : 2);
        nextItem = nextGroupIndex == 0 ? colorA : (nextGroupIndex == 1 ? colorB : colorC);
        break;

      case 'growing':
        // Growing pattern: 🔴🔴🟡🔴🔴🔴🟡🟡🔴🔴🔴🔴🟡🟡🟡
        final colorA = colors[_random.nextInt(colors.length)];
        final colorB = colors[_random.nextInt(colors.length)];

        int currentGroup = 1;
        int inGroupCount = 0;
        bool isAGroup = true;

        for (int i = 0; i < patternLength; i++) {
          pattern.add(isAGroup ? colorA : colorB);
          inGroupCount++;

          if (inGroupCount >= currentGroup) {
            isAGroup = !isAGroup;
            inGroupCount = 0;
            if (!isAGroup) currentGroup++;
          }
        }

        nextItem = isAGroup ? colorA : colorB;
        break;

      case 'nested':
        // Nested/Complex pattern: 🔴🟡🟢🟡🔴🟡🟢🟡
        final colorA = colors[_random.nextInt(colors.length)];
        final colorB = colors[_random.nextInt(colors.length)];
        final colorC = colors[_random.nextInt(colors.length)];

        // Pattern: A, B, C, B, repeat
        final basePattern = [colorA, colorB, colorC, colorB];
        for (int i = 0; i < patternLength; i++) {
          pattern.add(basePattern[i % basePattern.length]);
        }
        nextItem = basePattern[patternLength % basePattern.length];
        break;

      default:
        // Fallback to simple
        final basePattern = colors.take(_random.nextInt(3) + 2).toList();
        for (int i = 0; i < patternLength; i++) {
          pattern.add(basePattern[i % basePattern.length]);
        }
        nextItem = basePattern[patternLength % basePattern.length];
    }

    // Generate plausible wrong options
    final options = <String>[nextItem];
    final usedColors = pattern.toSet();

    // Add colors that appear in the pattern but aren't correct
    for (final color in usedColors) {
      if (color != nextItem && options.length < 4) {
        options.add(color);
      }
    }

    // Fill remaining with random colors
    while (options.length < 4) {
      final color = colors[_random.nextInt(colors.length)];
      if (!options.contains(color)) {
        options.add(color);
      }
    }

    options.shuffle(_random);

    return PatternRecognitionData(
      type: PatternType.color,
      pattern: pattern,
      options: options,
      correctAnswer: nextItem,
      timeLimit: _getPatternTimeLimit(difficulty),
    );
  }

  static PatternRecognitionData _generateNumberPattern(ExerciseDifficulty difficulty) {
    final patternLength = _getPatternLength(difficulty);
    final pattern = <String>[];
    String nextItem;

    // Choose pattern type based on difficulty
    final patternTypes = [
      'arithmetic',      // +n each time (easy)
      'multiplicative',  // ×n each time (medium)
      'squares',         // n² (medium-hard)
      'fibonacci',       // sum of previous two (hard)
      'alternating',     // two different operations (hard)
    ];

    String patternType;
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        patternType = patternTypes[_random.nextInt(1)]; // Only arithmetic
        break;
      case ExerciseDifficulty.medium:
        patternType = patternTypes[_random.nextInt(3)]; // arithmetic, multiplicative, squares
        break;
      case ExerciseDifficulty.hard:
      case ExerciseDifficulty.expert:
        patternType = patternTypes[_random.nextInt(patternTypes.length)]; // All types
        break;
    }

    switch (patternType) {
      case 'arithmetic':
        // Simple addition pattern: 2, 5, 8, 11...
        final step = _random.nextInt(8) + 2; // 2-9 step size
        final start = _random.nextInt(10) + 1;
        for (int i = 0; i < patternLength; i++) {
          pattern.add((start + (i * step)).toString());
        }
        nextItem = (start + (patternLength * step)).toString();
        break;

      case 'multiplicative':
        // Multiplication pattern: 2, 4, 8, 16... or 3, 9, 27...
        final multiplier = _random.nextInt(2) + 2; // 2 or 3
        final start = _random.nextInt(3) + 1;
        int current = start;
        for (int i = 0; i < patternLength; i++) {
          pattern.add(current.toString());
          current *= multiplier;
        }
        nextItem = current.toString();
        break;

      case 'squares':
        // Perfect squares: 1, 4, 9, 16, 25...
        final start = _random.nextInt(3) + 1;
        for (int i = 0; i < patternLength; i++) {
          final num = start + i;
          pattern.add((num * num).toString());
        }
        final nextNum = start + patternLength;
        nextItem = (nextNum * nextNum).toString();
        break;

      case 'fibonacci':
        // Fibonacci-like: 1, 1, 2, 3, 5, 8, 13...
        final first = _random.nextInt(3) + 1;
        final second = _random.nextInt(3) + 1;
        pattern.add(first.toString());
        pattern.add(second.toString());
        int prev1 = first;
        int prev2 = second;
        for (int i = 2; i < patternLength; i++) {
          final next = prev1 + prev2;
          pattern.add(next.toString());
          prev1 = prev2;
          prev2 = next;
        }
        nextItem = (prev1 + prev2).toString();
        break;

      case 'alternating':
        // Alternating operations: 1, 3, 6, 8, 15, 17... (+2, ×2, +2, ×2...)
        final start = _random.nextInt(5) + 1;
        int current = start;
        pattern.add(current.toString());
        for (int i = 1; i < patternLength; i++) {
          if (i % 2 == 1) {
            current += 2; // Add 2
          } else {
            current = (current * 1.5).round(); // Multiply by 1.5
          }
          pattern.add(current.toString());
        }
        if (patternLength % 2 == 0) {
          nextItem = (current + 2).toString();
        } else {
          nextItem = ((current * 1.5).round()).toString();
        }
        break;

      default:
        // Fallback to simple arithmetic
        final step = _random.nextInt(5) + 1;
        final start = _random.nextInt(10) + 1;
        for (int i = 0; i < patternLength; i++) {
          pattern.add((start + (i * step)).toString());
        }
        nextItem = (start + (patternLength * step)).toString();
    }

    // Generate wrong options that are plausible but incorrect
    final options = <String>[nextItem];
    int attempts = 0;
    final nextVal = int.parse(nextItem);
    while (options.length < 4 && attempts < 100) {
      attempts++;
      // Generate wrong answers that are close to correct answer
      final offset = _random.nextInt(20) - 10;
      final wrong = (nextVal + offset).toString();
      if (wrong != nextItem && int.parse(wrong) > 0 && !options.contains(wrong)) {
        options.add(wrong);
      }
    }
    options.shuffle(_random);

    return PatternRecognitionData(
      type: PatternType.number,
      pattern: pattern,
      options: options,
      correctAnswer: nextItem,
      timeLimit: _getPatternTimeLimit(difficulty),
    );
  }

  static int _getPatternLength(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 4;
      case ExerciseDifficulty.medium:
        return 5;
      case ExerciseDifficulty.hard:
        return 6;
      case ExerciseDifficulty.expert:
        return 8;
    }
  }

  static int _getPatternTimeLimit(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 45;
      case ExerciseDifficulty.medium:
        return 35;
      case ExerciseDifficulty.hard:
        return 25;
      case ExerciseDifficulty.expert:
        return 20;
    }
  }

  // Helper methods for Sequence Recall
  static int _getSequenceLength(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 4;
      case ExerciseDifficulty.medium:
        return 6;
      case ExerciseDifficulty.hard:
        return 8;
      case ExerciseDifficulty.expert:
        return 10;
    }
  }

  static SequenceRecallData _generateVisualSequence(ExerciseDifficulty difficulty, int length) {
    final colors = ['red', 'blue', 'green', 'yellow', 'purple', 'orange'];
    final sequence = <String>[];
    
    for (int i = 0; i < length; i++) {
      sequence.add(colors[_random.nextInt(colors.length)]);
    }

    return SequenceRecallData(
      type: SequenceType.visual,
      sequence: sequence,
      displayTimeMs: _getSequenceDisplayTime(difficulty),
      timeLimit: _getSequenceTimeLimit(difficulty),
    );
  }

  static SequenceRecallData _generateAudioSequence(ExerciseDifficulty difficulty, int length) {
    final sounds = ['beep', 'click', 'ding', 'buzz', 'chime'];
    final sequence = <String>[];
    
    for (int i = 0; i < length; i++) {
      sequence.add(sounds[_random.nextInt(sounds.length)]);
    }

    return SequenceRecallData(
      type: SequenceType.audio,
      sequence: sequence,
      displayTimeMs: _getSequenceDisplayTime(difficulty),
      timeLimit: _getSequenceTimeLimit(difficulty),
    );
  }

  static SequenceRecallData _generateSpatialSequence(ExerciseDifficulty difficulty, int length) {
    final positions = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    final sequence = <String>[];
    
    for (int i = 0; i < length; i++) {
      sequence.add(positions[_random.nextInt(positions.length)]);
    }

    return SequenceRecallData(
      type: SequenceType.spatial,
      sequence: sequence,
      displayTimeMs: _getSequenceDisplayTime(difficulty),
      timeLimit: _getSequenceTimeLimit(difficulty),
    );
  }

  static int _getSequenceDisplayTime(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 1500; // 1.5 seconds per item
      case ExerciseDifficulty.medium:
        return 1000; // 1 second per item
      case ExerciseDifficulty.hard:
        return 750;  // 0.75 seconds per item
      case ExerciseDifficulty.expert:
        return 500;  // 0.5 seconds per item
    }
  }

  static int _getSequenceTimeLimit(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 60;
      case ExerciseDifficulty.medium:
        return 45;
      case ExerciseDifficulty.hard:
        return 30;
      case ExerciseDifficulty.expert:
        return 20;
    }
  }

  // Helper methods for Spatial Awareness
  static SpatialAwarenessData _generateRotationPuzzle(ExerciseDifficulty difficulty) {
    // 3D rotation puzzles - visualizing 3D objects rotated in space
    // Now using shape types instead of Unicode for accurate rendering
    final shapeTypes = ['L', 'wedge', 'triangle', 'rectangle'];
    final shapeType = shapeTypes[_random.nextInt(shapeTypes.length)];

    final rotationAngles = [0, 90, 180, 270];
    final targetRotation = rotationAngles[_random.nextInt(rotationAngles.length)];

    // For rectangle, 0 == 180 and 90 == 270, so we need unique options
    List<int> optionRotations;
    if (shapeType == 'rectangle') {
      optionRotations = [0, 90, 0, 90]; // Will show as horizontal, vertical, horizontal, vertical
    } else {
      optionRotations = [0, 90, 180, 270];
    }

    // Find all indices that match the target rotation (handles duplicates like rectangle)
    final correctAnswerIndex = optionRotations.indexOf(targetRotation);

    // Shuffle the options while tracking the correct answer
    final optionPairs = List.generate(
      4,
      (i) => {'rotation': optionRotations[i], 'index': i},
    );
    optionPairs.shuffle(_random);

    // Find new index of correct answer after shuffle
    final shuffledCorrectIndex = optionPairs.indexWhere(
      (pair) => pair['rotation'] == targetRotation,
    );

    // Fallback: if somehow not found (should never happen), use first match
    final finalCorrectIndex = shuffledCorrectIndex >= 0 ? shuffledCorrectIndex : 0;

    return SpatialAwarenessData(
      type: SpatialType.rotation,
      targetShape: shapeType,
      targetRotation: targetRotation,
      shapeType: shapeType,
      optionRotations: optionPairs.map((p) => p['rotation'] as int).toList(),
      options: List.generate(4, (i) => i.toString()),
      correctAnswer: finalCorrectIndex.toString(),
      timeLimit: _getSpatialTimeLimit(difficulty),
    );
  }

  static SpatialAwarenessData _generateFoldingPuzzle(ExerciseDifficulty difficulty) {
    // 3D paper folding and box net puzzles - which 3D shape can be formed?
    final puzzles = [
      {
        'original': '⊞',  // Cross net pattern
        'description': 'Unfold this net',
        'options': ['⬛', '⬟', '▱', '⬢'],
        'correct': '⬛',
      },
      {
        'original': '◇\n◇◇',  // Triangle net
        'description': 'Unfold this net',
        'options': ['⬟', '⬛', '▱', '◆'],
        'correct': '⬟',
      },
      {
        'original': '▭▭',  // Rectangle pattern
        'description': 'Fold this shape',
        'options': ['▱', '⬛', '⬢', '⬟'],
        'correct': '▱',
      },
      {
        'original': '▯',  // Tall rectangle
        'description': 'Fold horizontally',
        'options': ['▭', '▯', '■', '▬'],
        'correct': '▭',
      },
      {
        'original': '△△\n△△',  // Four triangles
        'description': 'Fold into 3D',
        'options': ['⬟', '⬛', '◆', '▱'],
        'correct': '⬟',
      },
    ];

    final puzzle = puzzles[_random.nextInt(puzzles.length)];

    return SpatialAwarenessData(
      type: SpatialType.folding,
      targetShape: puzzle['original'] as String,
      options: puzzle['options'] as List<String>,
      correctAnswer: puzzle['correct'] as String,
      timeLimit: _getSpatialTimeLimit(difficulty),
    );
  }

  static SpatialAwarenessData _generateNavigationPuzzle(ExerciseDifficulty difficulty) {
    // Generate a proper navigation puzzle with coordinates
    final puzzles = [
      {
        'start': 'Start at position (0,0)',
        'moves': ['2 steps east', '1 step north'],
        'options': ['(2,1)', '(1,2)', '(2,2)', '(1,1)'],
        'correct': '(2,1)',
      },
      {
        'start': 'Start at position (1,1)',
        'moves': ['1 step west', '2 steps south'],
        'options': ['(0,-1)', '(2,1)', '(0,0)', '(1,0)'],
        'correct': '(0,-1)',
      },
      {
        'start': 'Start at position (3,2)',
        'moves': ['2 steps west', '1 step north'],
        'options': ['(1,3)', '(1,2)', '(5,3)', '(2,1)'],
        'correct': '(1,3)',
      },
      {
        'start': 'Start at position (0,0)',
        'moves': ['3 steps north', '1 step east'],
        'options': ['(1,3)', '(3,1)', '(1,2)', '(0,3)'],
        'correct': '(1,3)',
      },
      {
        'start': 'Start at position (2,1)',
        'moves': ['1 step south', '2 steps west'],
        'options': ['(0,0)', '(1,2)', '(4,0)', '(2,3)'],
        'correct': '(0,0)',
      },
    ];

    final puzzle = puzzles[_random.nextInt(puzzles.length)];
    final question = '${puzzle['start']}\n${(puzzle['moves'] as List<String>).join(', ')}\nWhere do you end up?';

    return SpatialAwarenessData(
      type: SpatialType.navigation,
      targetShape: question,
      options: puzzle['options'] as List<String>,
      correctAnswer: puzzle['correct'] as String,
      timeLimit: _getSpatialTimeLimit(difficulty),
    );
  }

  static int _getSpatialTimeLimit(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 90;
      case ExerciseDifficulty.medium:
        return 60;
      case ExerciseDifficulty.hard:
        return 45;
      case ExerciseDifficulty.expert:
        return 30;
    }
  }
}

// Data classes for different exercise types
class MemoryGameData {

  MemoryGameData({
    required this.gridSize,
    required this.cardSymbols,
    required this.showTimeSeconds,
    required this.timeLimit,
  });
  final int gridSize;
  final List<String> cardSymbols;
  final int showTimeSeconds;
  final int timeLimit;
}

class WordPuzzleData {

  WordPuzzleData({
    required this.type,
    this.targetWord,
    this.scrambledLetters,
    this.grid,
    this.targetWords,
    required this.timeLimit,
  });
  final WordPuzzleType type;
  final String? targetWord;
  final List<String>? scrambledLetters;
  final List<List<String>>? grid;
  final List<String>? targetWords;
  final int timeLimit;
}

class MathProblemData {

  MathProblemData({
    required this.type,
    required this.question,
    required this.answer,
    required this.options,
    required this.timeLimit,
  });
  final MathProblemType type;
  final String question;
  final int answer;
  final List<int> options;
  final int timeLimit;
}

class PatternRecognitionData {

  PatternRecognitionData({
    required this.type,
    required this.pattern,
    required this.options,
    required this.correctAnswer,
    required this.timeLimit,
  });
  final PatternType type;
  final List<String> pattern;
  final List<String> options;
  final String correctAnswer;
  final int timeLimit;
}

class SequenceRecallData {

  SequenceRecallData({
    required this.type,
    required this.sequence,
    required this.displayTimeMs,
    required this.timeLimit,
  });
  final SequenceType type;
  final List<String> sequence;
  final int displayTimeMs;
  final int timeLimit;
}

class SpatialAwarenessData {

  SpatialAwarenessData({
    required this.type,
    required this.targetShape,
    this.targetRotation,
    this.shapeType,
    this.optionRotations,
    required this.options,
    required this.correctAnswer,
    required this.timeLimit,
  });
  final SpatialType type;
  final String targetShape; // Display identifier or Unicode (for non-rotation types)
  final int? targetRotation; // Rotation angle for the target
  final String? shapeType; // Shape type identifier (L, wedge, triangle, etc.)
  final List<int>? optionRotations; // Rotation angles for each option
  final List<String> options; // Display identifiers for the answer options
  final String correctAnswer; // The correct answer identifier
  final int timeLimit;
}

// Enums for exercise types
enum WordPuzzleType { anagram, wordSearch }
enum MathProblemType { arithmetic, sequence, comparison, algebra }
enum PatternType { shape, color, number }
enum SequenceType { visual, audio, spatial }
enum SpatialType { rotation, folding, navigation }