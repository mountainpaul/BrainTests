/// Audio Verbal Learning Test (AVLT) Scoring Service
/// Provides dual scoring metrics for verbal memory assessment
///
/// Implements:
/// 1. Serial Position Score: Words recalled in correct position (strict)
/// 2. Total Recall Score: Words recalled regardless of position (lenient)
/// 3. Learning Slope: Improvement from trial 1 to trial 3
/// 4. Retention Percentage: Delayed recall vs last immediate trial

/// Calculate serial position score
/// Returns the number of words that match the target word at the same position
///
/// Features:
/// - Case-insensitive matching
/// - "skip" keyword (case-insensitive) maintains position for subsequent words
/// - Wrong words act like "skip" - they maintain position for later words
/// - Whitespace is trimmed
int calculateSerialPositionScore(List<String> targetWords, List<String> userWords) {
  int score = 0;

  // Compare up to the length of target words
  final compareLength = targetWords.length < userWords.length
      ? targetWords.length
      : userWords.length;

  for (int i = 0; i < compareLength; i++) {
    final targetWord = targetWords[i].trim().toUpperCase();
    final userWord = userWords[i].trim().toUpperCase();

    // Skip the "SKIP" keyword - it maintains position but doesn't score
    if (userWord == 'SKIP') {
      continue;
    }

    // Match if words are identical at this position
    if (targetWord == userWord) {
      score++;
    }
  }

  return score;
}

/// Calculate total recall score
/// Returns the number of unique target words recalled, regardless of position
///
/// Features:
/// - Case-insensitive matching
/// - "skip" keyword (case-insensitive) is not counted as a recall
/// - Duplicate words only counted once
/// - Wrong words are ignored
/// - Whitespace is trimmed
int calculateTotalRecallScore(List<String> targetWords, List<String> userWords) {
  // Normalize target words to uppercase for comparison
  final normalizedTargets = targetWords
      .map((word) => word.trim().toUpperCase())
      .toSet();

  // Track which target words have been recalled
  final recalledWords = <String>{};

  for (final userWord in userWords) {
    final normalized = userWord.trim().toUpperCase();

    // Skip the "SKIP" keyword
    if (normalized == 'SKIP') {
      continue;
    }

    // Check if this word is in the target list
    if (normalizedTargets.contains(normalized)) {
      recalledWords.add(normalized);
    }
  }

  return recalledWords.length;
}

/// Calculate learning slope
/// Returns the difference in total recall scores between trial 3 and trial 1
///
/// Positive value = improvement (learning)
/// Zero = no change
/// Negative value = decline
double calculateLearningSlope(int trial1Total, int trial3Total) {
  return (trial3Total - trial1Total).toDouble();
}

/// Calculate retention percentage
/// Returns the percentage of words retained from trial 3 to delayed recall
///
/// Formula: (delayedTotal / trial3Total) * 100
/// Returns 0.0 if trial3Total is 0 (cannot retain if nothing was learned)
/// Can exceed 100% if delayed recall is better than trial 3
double calculateRetentionPercentage(int trial3Total, int delayedTotal) {
  if (trial3Total == 0) {
    return 0.0;
  }

  return (delayedTotal / trial3Total) * 100.0;
}
