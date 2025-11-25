/// Configuration constants for PAL (Paired Associates Learning) Test
///
/// This class centralizes all test configuration parameters for the
/// visual episodic memory assessment protocol.
/// Reference: PMC10879687
import 'pal_box_layout.dart';

class PALConfig {
  // Prevent instantiation
  const PALConfig._();

  // ============================================================================
  // Test Structure Configuration
  // ============================================================================

  /// Number of stages in the test
  /// 7 stages with 2, 4, 5, 6, 7, 8 patterns
  static const int totalStages = 8;

  /// Pattern counts for each stage: [2, 4, 5, 6, 7, 8]
  /// PAL progression
  static const List<int> stagePatternCounts = [2, 3, 4, 5, 6, 8, 10, 12];

  /// Maximum number of failed attempts before test termination
  /// 3 failed attempts stops test
  static const int maxFailedAttempts = 3;

  /// Total number of boxes available
  /// Must be >= max pattern count (8) to accommodate all patterns
  static const int totalBoxes = 12;

  /// Box layout type for each stage
  /// Stage 1 (2 patterns): Horizontal
  /// Stage 2 (4 patterns): Grid (2x2)
  /// Stages 3-7 (5-8 patterns): Circle
  static BoxLayout getLayoutForStage(int stageIndex) {
    final patternCount = stagePatternCounts[stageIndex];
    if (patternCount == 2) return BoxLayout.horizontal;
    if (patternCount == 4) return BoxLayout.grid;
    return BoxLayout.circle;
  }

  // ============================================================================
  // Timing Configuration
  // ============================================================================

  /// Duration each box is displayed during presentation phase
  /// 3 seconds per box
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
  /// 2 + 3 + 4 + 5 + 6 + 8 + 10 + 12 = 50
  static const int maxFirstAttemptScore = 50;

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
