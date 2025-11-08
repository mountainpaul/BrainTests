/// Configuration constants for CANTAB PAL (Paired Associates Learning) Test
///
/// This class centralizes all test configuration parameters following the
/// official Cambridge Cognition CANTAB PAL protocol.
/// Reference: PMC10879687
class CANTABPALConfig {
  // Prevent instantiation
  const CANTABPALConfig._();

  // ============================================================================
  // Test Structure Configuration
  // ============================================================================

  /// Number of stages in the test
  /// Modified: 8 stages with increasing difficulty
  static const int totalStages = 8;

  /// Pattern counts for each stage: [2, 3, 4, 5, 6, 8, 10]
  /// Progressive difficulty with more granular steps
  static const List<int> stagePatternCounts = [2, 3, 4, 5, 6, 8, 10];

  /// Maximum number of attempts allowed per stage before test termination
  /// CANTAB standard: 4 attempts
  static const int maxAttemptsPerStage = 4;

  /// Total number of boxes in the circular arrangement
  /// Must be >= max pattern count (10) to accommodate all patterns
  static const int totalBoxes = 10;

  // ============================================================================
  // Timing Configuration
  // ============================================================================

  /// Duration each box is displayed during presentation phase
  /// CANTAB standard: 3 seconds per box
  static const Duration boxDisplayDuration = Duration(seconds: 3);

  /// Duration to show feedback message after user response
  static const Duration feedbackDuration = Duration(seconds: 2);

  /// Duration to show all patterns when reopening boxes after error
  static const Duration reopenDisplayDuration = Duration(seconds: 3);

  /// Delay before transitioning to next stage after success
  static const Duration stageTransitionDelay = Duration(seconds: 1);

  // ============================================================================
  // UI Layout Configuration
  // ============================================================================

  /// Size of each box in the circular arrangement (dp)
  static const double boxSize = 60.0;

  /// Ratio of screen width used for the box grid
  static const double availableWidthRatio = 0.85;

  /// Ratio of screen height used for the box grid
  static const double availableHeightRatio = 0.4;

  /// Ratio used to calculate circular arrangement radius
  static const double circleRadiusRatio = 0.35;

  /// Pattern display size when shown in center during recall
  static const double centerPatternSize = 80.0;

  /// Border width for highlighted pattern during recall
  static const double patternBorderWidth = 3.0;

  // ============================================================================
  // Scoring Configuration
  // ============================================================================

  /// Maximum possible first-attempt memory score (sum of all pattern counts)
  /// 2 + 3 + 4 + 5 + 6 + 8 + 10 = 38
  static const int maxFirstAttemptScore = 38;

  /// Weight of stage completion in norm score calculation (0-100)
  static const double stageCompletionWeight = 50.0;

  /// Weight of memory accuracy in norm score calculation (0-100)
  static const double memoryAccuracyWeight = 50.0;

  // ============================================================================
  // Interpretation Thresholds
  // ============================================================================

  /// Minimum stages completed for "Excellent" rating
  static const int excellentStagesThreshold = 8;

  /// Maximum errors allowed for "Excellent" rating
  static const int excellentErrorsThreshold = 12;

  /// Minimum stages completed for "Good" rating
  static const int goodStagesThreshold = 6;

  /// Maximum errors allowed for "Good" rating
  static const int goodErrorsThreshold = 24;

  /// Minimum stages completed for "Fair" rating
  static const int fairStagesThreshold = 4;

  /// Maximum errors allowed for "Fair" rating
  static const int fairErrorsThreshold = 40;

  /// Minimum stages completed for "Below Average" rating
  static const int belowAverageStagesThreshold = 3;

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Calculate maximum possible score for the test
  static int get maxPossibleScore {
    return stagePatternCounts.reduce((a, b) => a + b);
  }

  /// Get pattern count for a specific stage (0-indexed)
  static int getPatternCountForStage(int stageIndex) {
    assert(stageIndex >= 0 && stageIndex < totalStages,
           'Stage index must be 0-${totalStages - 1}');
    return stagePatternCounts[stageIndex];
  }

  /// Check if a stage index is valid
  static bool isValidStageIndex(int stageIndex) {
    return stageIndex >= 0 && stageIndex < totalStages;
  }

  /// Check if a box position is valid
  static bool isValidBoxPosition(int position) {
    return position >= 0 && position < totalBoxes;
  }

  /// Calculate norm score based on completion and memory performance
  static double calculateNormScore(int stagesCompleted, int firstAttemptScore) {
    final stageScore = (stagesCompleted / totalStages) * stageCompletionWeight;
    final memoryScore = (firstAttemptScore / maxFirstAttemptScore) * memoryAccuracyWeight;
    return stageScore + memoryScore;
  }

  /// Get performance interpretation based on completion and errors
  static String getInterpretation(int stagesCompleted, int totalErrors) {
    if (stagesCompleted >= excellentStagesThreshold &&
        totalErrors <= excellentErrorsThreshold) {
      return 'Excellent - Superior visual memory';
    } else if (stagesCompleted >= goodStagesThreshold &&
               totalErrors <= goodErrorsThreshold) {
      return 'Good - Normal episodic memory function';
    } else if (stagesCompleted >= fairStagesThreshold &&
               totalErrors <= fairErrorsThreshold) {
      return 'Fair - Mild difficulty with complex patterns';
    } else if (stagesCompleted >= belowAverageStagesThreshold) {
      return 'Below Average - Moderate memory difficulties';
    } else {
      return 'Impaired - Significant memory concerns, recommend consultation';
    }
  }

  /// Get estimated test duration range as a formatted string
  static String get estimatedDuration => '10-15 minutes';
}
