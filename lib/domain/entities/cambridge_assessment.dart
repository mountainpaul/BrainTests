/// Cambridge-style cognitive assessment types (CANTAB-inspired)
enum CambridgeTestType {
  // Memory (Priority 1 - most sensitive for AD)
  pal,  // Paired Associates Learning - visual episodic memory
  prm,  // Pattern Recognition Memory
  swm,  // Spatial Working Memory

  // Attention & Speed (Priority 2)
  rvp,  // Rapid Visual Processing - sustained attention
  rti,  // Reaction Time
  mot,  // Motor Screening Task

  // Executive Function (Priority 3)
  soc,  // Stockings of Cambridge - planning
  ied,  // Intra-Extra Dimensional Set Shift
  sst,  // Stop-Signal Task - inhibition
}

/// Result data for Cambridge assessments
class CambridgeAssessmentResult {  // Clinical interpretation

  CambridgeAssessmentResult({
    required this.testType,
    required this.completedAt,
    required this.durationSeconds,
    required this.accuracy,
    required this.totalTrials,
    required this.correctTrials,
    required this.errorCount,
    required this.meanLatencyMs,
    required this.medianLatencyMs,
    required this.specificMetrics,
    required this.normScore,
    required this.interpretation,
  });
  final CambridgeTestType testType;
  final DateTime completedAt;
  final int durationSeconds;

  // Primary outcome measures
  final double accuracy;  // % correct
  final int totalTrials;
  final int correctTrials;
  final int errorCount;

  // Latency measures
  final double meanLatencyMs;  // Average reaction time
  final double medianLatencyMs;

  // Test-specific metrics
  final Map<String, dynamic> specificMetrics;

  // Derived scores
  final double normScore;  // Age-normalized score
  final String interpretation;

  /// Calculate performance level
  String get performanceLevel {
    if (accuracy >= 90) return 'Excellent';
    if (accuracy >= 75) return 'Good';
    if (accuracy >= 60) return 'Average';
    if (accuracy >= 45) return 'Below Average';
    return 'Impaired';
  }
}

/// PAL (Paired Associates Learning) specific data
class PALResult extends CambridgeAssessmentResult {

  PALResult({
    required super.completedAt,
    required super.durationSeconds,
    required super.accuracy,
    required super.totalTrials,
    required super.correctTrials,
    required super.errorCount,
    required super.meanLatencyMs,
    required super.medianLatencyMs,
    required super.normScore,
    required super.interpretation,
    required this.stagesCompleted,
    required this.firstTrialMemoryScore,
    required this.totalErrors,
  }) : super(
    testType: CambridgeTestType.pal,
    specificMetrics: {
      'stagesCompleted': stagesCompleted,
      'firstTrialMemoryScore': firstTrialMemoryScore,
      'totalErrors': totalErrors,
    },
  );
  final int stagesCompleted;
  final int firstTrialMemoryScore;
  final double totalErrors;
}

/// RVP (Rapid Visual Processing) specific data
class RVPResult extends CambridgeAssessmentResult {

  RVPResult({
    required super.completedAt,
    required super.durationSeconds,
    required super.accuracy,
    required super.totalTrials,
    required super.correctTrials,
    required super.errorCount,
    required super.meanLatencyMs,
    required super.medianLatencyMs,
    required super.normScore,
    required super.interpretation,
    required this.aPrime,
    required this.hits,
    required this.misses,
    required this.falseAlarms,
    required this.correctRejections,
  }) : super(
    testType: CambridgeTestType.rvp,
    specificMetrics: {
      'aPrime': aPrime,
      'hits': hits,
      'misses': misses,
      'falseAlarms': falseAlarms,
      'correctRejections': correctRejections,
    },
  );
  final double aPrime;  // Sensitivity measure (A')
  final int hits;
  final int misses;
  final int falseAlarms;
  final int correctRejections;
}

/// RTI (Reaction Time) specific data
class RTIResult extends CambridgeAssessmentResult {  // Responses before stimulus

  RTIResult({
    required super.completedAt,
    required super.durationSeconds,
    required super.accuracy,
    required super.totalTrials,
    required super.correctTrials,
    required super.errorCount,
    required super.meanLatencyMs,
    required super.medianLatencyMs,
    required super.normScore,
    required super.interpretation,
    required this.simpleReactionTime,
    required this.choiceReactionTime,
    required this.movementTime,
    required this.anticipations,
  }) : super(
    testType: CambridgeTestType.rti,
    specificMetrics: {
      'simpleReactionTime': simpleReactionTime,
      'choiceReactionTime': choiceReactionTime,
      'movementTime': movementTime,
      'anticipations': anticipations,
    },
  );
  final double simpleReactionTime;
  final double choiceReactionTime;
  final double movementTime;
  final int anticipations;
}

/// SWM (Spatial Working Memory) specific data
class SWMResult extends CambridgeAssessmentResult {  // 1-46 scale (lower = better)

  SWMResult({
    required super.completedAt,
    required super.durationSeconds,
    required super.accuracy,
    required super.totalTrials,
    required super.correctTrials,
    required super.errorCount,
    required super.meanLatencyMs,
    required super.medianLatencyMs,
    required super.normScore,
    required super.interpretation,
    required this.betweenErrors,
    required this.withinErrors,
    required this.strategy,
  }) : super(
    testType: CambridgeTestType.swm,
    specificMetrics: {
      'betweenErrors': betweenErrors,
      'withinErrors': withinErrors,
      'strategy': strategy,
    },
  );
  final int betweenErrors;  // Errors revisiting boxes
  final int withinErrors;  // Errors within same search
  final double strategy;
}
