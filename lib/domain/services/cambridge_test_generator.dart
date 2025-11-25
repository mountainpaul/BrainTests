import 'dart:math';

/// Generates Cambridge-style cognitive assessment tests
class CambridgeTestGenerator {
  static final Random _random = Random();

  /// Generate PAL (Paired Associates Learning) trial
  static PALTrial generatePALTrial(int stage) {
    // Stage determines number of patterns (1-8)
    final numPatterns = min(stage + 1, 8);
    final gridSize = stage < 4 ? 6 : 8; // 2x3 or 2x4 grid

    // Generate random positions for patterns
    final List<int> positions = [];
    while (positions.length < numPatterns) {
      final pos = _random.nextInt(gridSize);
      if (!positions.contains(pos)) {
        positions.add(pos);
      }
    }

    // Assign abstract patterns to positions
    final patterns = List.generate(numPatterns, (i) => i);
    patterns.shuffle(_random);

    return PALTrial(
      stage: stage,
      numPatterns: numPatterns,
      gridSize: gridSize,
      patternPositions: Map.fromIterables(patterns, positions),
      presentations: [],
    );
  }

  /// Generate RVP (Rapid Visual Processing) sequence
  static RVPSequence generateRVPSequence(int durationSeconds) {
    // Generate digit stream (0-9) at ~100 digits/min
    final numDigits = (durationSeconds / 0.6).round();

    // Target sequences: 3-5-7 and 2-4-6
    // Typically has 8-16 targets per 7-minute test
    // We'll aim for ~12 targets (mix of both sequences)
    final targetCount = (durationSeconds / 35).round(); // ~12 for 420s

    // First, generate all random digits
    final digits = <int>[];
    for (int i = 0; i < numDigits; i++) {
      digits.add(_random.nextInt(10));
    }

    // Now intentionally embed target sequences at random positions
    final List<int> targetIndices = [];
    final usedPositions = <int>{};

    for (int t = 0; t < targetCount && targetIndices.length < targetCount; t++) {
      // Find a valid position (not too close to start/end or other targets)
      int attempts = 0;
      while (attempts < 100) {
        // Position must leave room for 3-digit sequence and spacing
        final pos = 10 + _random.nextInt(numDigits - 20);

        // Check if position is far enough from other targets (min 15 digits apart)
        bool tooClose = false;
        for (final used in usedPositions) {
          if ((pos - used).abs() < 15) {
            tooClose = true;
            break;
          }
        }

        if (!tooClose) {
          // Randomly choose which target sequence to embed
          final useFirstSequence = _random.nextBool();

          if (useFirstSequence) {
            // Embed 3-5-7
            digits[pos] = 3;
            digits[pos + 1] = 5;
            digits[pos + 2] = 7;
          } else {
            // Embed 2-4-6
            digits[pos] = 2;
            digits[pos + 1] = 4;
            digits[pos + 2] = 6;
          }

          targetIndices.add(pos + 2); // Index of final digit in sequence
          usedPositions.add(pos);
          break;
        }
        attempts++;
      }
    }

    return RVPSequence(
      digits: digits,
      targetIndices: targetIndices.toSet(),
      intervalMs: 600,
    );
  }

  /// Generate RTI (Reaction Time) trial
  static RTITrial generateRTITrial(RTIMode mode, int trialNumber) {
    // Random delay before stimulus (1-3 seconds)
    final delayMs = 1000 + _random.nextInt(2000);

    if (mode == RTIMode.simple) {
      // Simple RT: single location
      return RTITrial(
        mode: mode,
        trialNumber: trialNumber,
        delayMs: delayMs,
        targetPosition: 0,
        numPositions: 1,
      );
    } else {
      // Choice RT: 5 positions
      return RTITrial(
        mode: mode,
        trialNumber: trialNumber,
        delayMs: delayMs,
        targetPosition: _random.nextInt(5),
        numPositions: 5,
      );
    }
  }

  /// Generate SWM (Spatial Working Memory) trial
  static SWMTrial generateSWMTrial(int numBoxes) {
    // Number of boxes: 3, 4, 6, or 8
    // Number of tokens should be less than number of boxes (approximately 1/3 to 1/2)
    final positions = List.generate(8, (i) => i);
    positions.shuffle(_random);

    final selectedPositions = positions.take(numBoxes).toList();

    // Calculate number of tokens (roughly 1/3 to 1/2 of boxes, minimum 1)
    // 3 boxes -> 1-2 tokens
    // 4 boxes -> 2 tokens
    // 6 boxes -> 2-3 tokens
    // 8 boxes -> 3-4 tokens
    final numTokens = (numBoxes / 2.5).ceil().clamp(1, numBoxes - 1);

    // Randomly assign tokens to SOME boxes
    // The participant must find these tokens by process of elimination
    final tokenPositions = <int>[];
    final shuffledBoxes = List<int>.from(selectedPositions);
    shuffledBoxes.shuffle(_random);

    // Place tokens in random boxes
    for (int i = 0; i < numTokens; i++) {
      tokenPositions.add(shuffledBoxes[i]);
    }

    return SWMTrial(
      numBoxes: numBoxes,
      boxPositions: selectedPositions,
      tokenPositions: tokenPositions,
      tokensToFind: numTokens,
      tokensCollected: 0,
      searchSequence: [],
    );
  }

  /// Generate OTS (One Touch Stockings of Cambridge) trial
  static OTSTrial generateOTSTrial(int minMoves) {
    // Generate a valid configuration that requires exactly minMoves
    // 3 stockings, 3 balls (colored 0, 1, 2)

    // Start with a simple initial configuration
    final initial = _generateRandomConfiguration();

    // Generate goal configuration that requires minMoves
    final goal = _generateGoalConfiguration(initial, minMoves);

    return OTSTrial(
      problemNumber: minMoves,
      initialConfiguration: initial,
      goalConfiguration: goal,
      minimumMoves: minMoves,
    );
  }

  static List<List<int>> _generateRandomConfiguration() {
    // 3 stockings, each can hold 0-3 balls
    // Total of 3 balls (colors 0, 1, 2)
    final balls = [0, 1, 2];
    balls.shuffle(_random);

    // Distribute balls across stockings randomly
    final config = <List<int>>[[], [], []];

    // Simple distribution: put all balls in first stocking
    config[0] = balls;

    return config;
  }

  static List<List<int>> _generateGoalConfiguration(List<List<int>> initial, int moves) {
    // For simplicity, generate configurations based on move count
    final goal = <List<int>>[[], [], []];

    switch (moves) {
      case 1:
        // Move top ball to different stocking
        goal[1] = [initial[0][0]];
        goal[0] = initial[0].sublist(1);
        break;
      case 2:
        // Move top two balls
        goal[1] = [initial[0][0]];
        goal[2] = [initial[0][1]];
        goal[0] = [initial[0][2]];
        break;
      case 3:
        // More complex rearrangement
        goal[2] = [initial[0][0]];
        goal[1] = [initial[0][1]];
        goal[0] = [initial[0][2]];
        break;
      case 4:
        // Reverse order in same stocking (requires 4 moves)
        goal[0] = initial[0].reversed.toList();
        break;
      case 5:
        // Complex multi-stocking arrangement
        goal[0] = [initial[0][2]];
        goal[1] = [initial[0][1]];
        goal[2] = [initial[0][0]];
        break;
      default:
        goal[0] = List.from(initial[0]);
    }

    return goal;
  }

  /// Generate PRM (Pattern Recognition Memory) trial
  static PRMTrial generatePRMTrial(int numPatterns) {
    // Generate abstract visual patterns
    final studyPatterns = List.generate(
      numPatterns,
      _generateAbstractPattern,
    );

    // Create test set: half old, half new
    final testPatterns = <PRMPattern>[];

    // Add old patterns (copy visual properties from study patterns)
    studyPatterns.shuffle(_random);
    for (int i = 0; i < numPatterns ~/ 2; i++) {
      testPatterns.add(PRMPattern(
        patternId: studyPatterns[i].patternId,
        isOld: true,
        shape: studyPatterns[i].shape,
        color: studyPatterns[i].color,
        size: studyPatterns[i].size,
      ));
    }

    // Add new patterns (generate with visual properties)
    for (int i = 0; i < numPatterns ~/ 2; i++) {
      final newPattern = _generateAbstractPattern(numPatterns + i);
      testPatterns.add(PRMPattern(
        patternId: newPattern.patternId,
        isOld: false,
        shape: newPattern.shape,
        color: newPattern.color,
        size: newPattern.size,
      ));
    }

    testPatterns.shuffle(_random);

    return PRMTrial(
      studyPatterns: studyPatterns,
      testPatterns: testPatterns,
    );
  }

  static PRMPattern _generateAbstractPattern(int seed) {
    // Generate abstract pattern using TRUE random (not seeded)
    // This ensures patterns are different each time, preventing memorization
    // Total combinations: 12 patterns × 20 colors × 5 variations = 1,200 unique patterns
    return PRMPattern(
      patternId: seed,
      isOld: true,
      shape: _random.nextInt(12),  // 12 different abstract pattern types
      color: _random.nextInt(20),  // 20 color pair combinations
      size: _random.nextInt(5),    // 5 variations (size/rotation/etc)
    );
  }
}

/// PAL Trial Data
class PALTrial {

  PALTrial({
    required this.stage,
    required this.numPatterns,
    required this.gridSize,
    required this.patternPositions,
    required this.presentations,
  });
  final int stage;
  final int numPatterns;
  final int gridSize;
  final Map<int, int> patternPositions; // pattern -> position
  final List<int> presentations;
}

/// RVP Sequence Data
class RVPSequence {

  RVPSequence({
    required this.digits,
    required this.targetIndices,
    required this.intervalMs,
  });
  final List<int> digits;
  final Set<int> targetIndices;
  final int intervalMs;
}

/// RTI Trial Data
enum RTIMode { simple, choice }

class RTITrial {

  RTITrial({
    required this.mode,
    required this.trialNumber,
    required this.delayMs,
    required this.targetPosition,
    required this.numPositions,
  });
  final RTIMode mode;
  final int trialNumber;
  final int delayMs;
  final int targetPosition;
  final int numPositions;
}

/// SWM Trial Data
class SWMTrial { // Track all searches to calculate between-errors

  SWMTrial({
    required this.numBoxes,
    required this.boxPositions,
    required this.tokenPositions,
    required this.tokensToFind,
    required this.tokensCollected,
    required this.searchSequence,
  });
  final int numBoxes;
  final List<int> boxPositions;
  final List<int> tokenPositions; // Which boxes actually contain tokens
  final int tokensToFind;
  final int tokensCollected;
  final List<int> searchSequence;

  int get betweenErrors {
    // Count times revisiting boxes already searched
    // Between-errors = searching the same box twice
    int errors = 0;
    final searchedBoxes = <int>{};
    for (final pos in searchSequence) {
      if (searchedBoxes.contains(pos)) {
        errors++;
      }
      searchedBoxes.add(pos);
    }
    return errors;
  }

  double get strategyScore {
    // Lower is better: measures sequential search efficiency (1-46 scale)
    if (searchSequence.isEmpty) return 46.0;

    // Simple heuristic: reward sequential searching
    int sequentialCount = 0;
    for (int i = 0; i < searchSequence.length - 1; i++) {
      if ((searchSequence[i + 1] - searchSequence[i]).abs() == 1) {
        sequentialCount++;
      }
    }

    final efficiency = sequentialCount / searchSequence.length;
    return 46.0 * (1.0 - efficiency);
  }
}

/// PRM Pattern Data
class PRMPattern {         // Size/rotation/variation (0-4 for 5 variations)

  PRMPattern({
    required this.patternId,
    required this.isOld,
    this.shape,
    this.color,
    this.size,
  });
  final int patternId;
  final bool isOld;
  final int? shape;        // Pattern type (0-11 for 12 different abstract patterns)
  final int? color;        // Color pair index (0-19 for 20 color combinations)
  final int? size;

  String get visualRepresentation {
    if (shape == null || color == null || size == null) return '?';
    // Complex representation: pattern_type + color_pair + variation
    // This creates unique identifiers for abstract patterns
    return 'P${shape}_C${color}_V$size';
  }
}

/// PRM Trial Data
class PRMTrial {

  PRMTrial({
    required this.studyPatterns,
    required this.testPatterns,
  });
  final List<PRMPattern> studyPatterns;
  final List<PRMPattern> testPatterns;
}

/// OTS Trial Data
class OTSTrial {

  OTSTrial({
    required this.problemNumber,
    required this.initialConfiguration,
    required this.goalConfiguration,
    required this.minimumMoves,
  });
  final int problemNumber;
  final List<List<int>> initialConfiguration; // 3 stockings, each containing balls (by color index)
  final List<List<int>> goalConfiguration;
  final int minimumMoves;
}
