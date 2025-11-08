import 'validated_assessments.dart';

/// Comprehensive assessment results management system
/// Handles storage, interpretation, and longitudinal tracking of validated cognitive assessments

class CognitiveAssessmentSession {

  CognitiveAssessmentSession({
    required this.sessionId,
    required this.sessionDate,
    required this.demographics,
    this.clinicianId,
    this.patientId,
    required this.results,
    this.sessionNotes,
    this.context = AssessmentContext.routine,
  });
  final String sessionId;
  final DateTime sessionDate;
  final CognitiveDemographics demographics;
  final String? clinicianId;
  final String? patientId;
  final Map<ValidatedAssessmentType, dynamic> results;
  final String? sessionNotes;
  final AssessmentContext context;

  /// Calculate composite cognitive index across all administered tests
  double get compositeCognitiveIndex {
    if (results.isEmpty) return 0.0;

    double totalWeightedScore = 0.0;
    double totalWeight = 0.0;

    for (final entry in results.entries) {
      final weight = _getAssessmentWeight(entry.key);
      final normalizedScore = _getNormalizedScore(entry.key, entry.value);

      totalWeightedScore += normalizedScore * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? totalWeightedScore / totalWeight : 0.0;
  }

  /// Get domain-specific scores (memory, attention, language, etc.)
  Map<CognitiveDomain, double> get domainScores {
    final domainScores = <CognitiveDomain, double>{};

    for (final entry in results.entries) {
      final domains = _getAssessmentDomains(entry.key);
      final score = _getNormalizedScore(entry.key, entry.value);

      for (final domain in domains) {
        domainScores[domain] = (domainScores[domain] ?? 0.0) + score;
      }
    }

    return domainScores;
  }

  /// Generate clinical interpretation
  ClinicalInterpretation get clinicalInterpretation {
    final cci = compositeCognitiveIndex;

    if (cci >= 85) {
      return ClinicalInterpretation(
        level: CognitiveFunctionLevel.normal,
        confidence: _calculateConfidence(),
        recommendations: [
          'Cognitive function within normal range',
          'Continue routine monitoring if indicated',
        ],
      );
    } else if (cci >= 70) {
      return ClinicalInterpretation(
        level: CognitiveFunctionLevel.mildImpairment,
        confidence: _calculateConfidence(),
        recommendations: [
          'Mild cognitive impairment suggested',
          'Consider comprehensive neuropsychological evaluation',
          'Monitor for changes over time',
          'Assess reversible causes (medication, depression, medical conditions)',
        ],
      );
    } else {
      return ClinicalInterpretation(
        level: CognitiveFunctionLevel.moderateToSevereImpairment,
        confidence: _calculateConfidence(),
        recommendations: [
          'Significant cognitive impairment detected',
          'Urgent referral for comprehensive evaluation recommended',
          'Consider functional assessment and safety evaluation',
          'Discuss care planning and support services',
        ],
      );
    }
  }

  double _getAssessmentWeight(ValidatedAssessmentType type) {
    switch (type) {
      case ValidatedAssessmentType.mmse:
        return 0.3;
      case ValidatedAssessmentType.moca:
        return 0.3;
      case ValidatedAssessmentType.clockDrawing:
        return 0.2;
      case ValidatedAssessmentType.gds:
        return 0.1; // Less weight as it measures mood, not cognition
      case ValidatedAssessmentType.adascog:
        return 0.4;
    }
  }

  double _getNormalizedScore(ValidatedAssessmentType type, dynamic result) {
    switch (type) {
      case ValidatedAssessmentType.mmse:
        final mmseResult = result as MMSEResults;
        final adjustedScore = mmseResult.getAdjustedScore(
          age: demographics.age,
          educationYears: demographics.educationYears,
        );
        return (adjustedScore / 30.0) * 100.0; // Convert to 0-100 scale

      case ValidatedAssessmentType.moca:
        final mocaResult = result as MoCAResults;
        final adjustedScore = mocaResult.getEducationAdjustedScore(demographics.educationYears);
        return (adjustedScore / 30.0) * 100.0;

      case ValidatedAssessmentType.clockDrawing:
        final clockResult = result as ClockDrawingResults;
        return (clockResult.score / 6.0) * 100.0;

      case ValidatedAssessmentType.gds:
        // For GDS, lower scores are better (reverse scoring)
        final gdsScore = result as int;
        return ((15 - gdsScore) / 15.0) * 100.0;

      case ValidatedAssessmentType.adascog:
        // ADAS-Cog: lower scores are better (reverse scoring)
        final adasScore = result as int;
        return ((70 - adasScore) / 70.0) * 100.0;
    }
  }

  List<CognitiveDomain> _getAssessmentDomains(ValidatedAssessmentType type) {
    switch (type) {
      case ValidatedAssessmentType.mmse:
        return [
          CognitiveDomain.orientation,
          CognitiveDomain.memory,
          CognitiveDomain.attention,
          CognitiveDomain.language,
          CognitiveDomain.visuospatial,
        ];
      case ValidatedAssessmentType.moca:
        return [
          CognitiveDomain.executiveFunction,
          CognitiveDomain.visuospatial,
          CognitiveDomain.memory,
          CognitiveDomain.attention,
          CognitiveDomain.language,
          CognitiveDomain.orientation,
        ];
      case ValidatedAssessmentType.clockDrawing:
        return [
          CognitiveDomain.visuospatial,
          CognitiveDomain.executiveFunction,
        ];
      case ValidatedAssessmentType.gds:
        return [CognitiveDomain.mood]; // Not cognitive but affects performance
      case ValidatedAssessmentType.adascog:
        return [
          CognitiveDomain.memory,
          CognitiveDomain.language,
          CognitiveDomain.orientation,
          CognitiveDomain.attention,
        ];
    }
  }

  double _calculateConfidence() {
    // Confidence increases with more tests administered
    final numTests = results.length;
    final baseConfidence = numTests >= 3 ? 0.9 : (numTests >= 2 ? 0.8 : 0.7);

    // Adjust for demographic factors that might affect test validity
    double demographicAdjustment = 1.0;

    if (demographics.educationYears < 8) demographicAdjustment *= 0.95;
    if (demographics.age > 85) demographicAdjustment *= 0.93;
    if (demographics.primaryLanguage != null && demographics.primaryLanguage != 'English') {
      demographicAdjustment *= 0.90;
    }

    return (baseConfidence * demographicAdjustment).clamp(0.5, 1.0);
  }
}

enum AssessmentContext {
  routine,           // Regular screening/monitoring
  diagnostic,        // Part of diagnostic workup
  followUp,          // Monitoring known condition
  research,          // Research participation
  preOperative,      // Pre-surgical screening
  postTreatment,     // Treatment response monitoring
}

enum CognitiveFunctionLevel {
  normal,
  mildImpairment,
  moderateToSevereImpairment,
}

enum CognitiveDomain {
  memory,
  attention,
  executiveFunction,
  language,
  visuospatial,
  orientation,
  processingSpeed,
  mood,
}

class ClinicalInterpretation {

  ClinicalInterpretation({
    required this.level,
    required this.confidence,
    required this.recommendations,
    this.domainSpecificFindings,
  });
  final CognitiveFunctionLevel level;
  final double confidence;
  final List<String> recommendations;
  final Map<CognitiveDomain, String>? domainSpecificFindings;
}

/// Longitudinal tracking system for monitoring cognitive changes over time
class LongitudinalCognitiveTrends {

  LongitudinalCognitiveTrends({
    required this.patientId,
    required this.sessions,
  });
  final String patientId;
  final List<CognitiveAssessmentSession> sessions;

  /// Calculate rate of cognitive decline per year
  Map<ValidatedAssessmentType, double> get annualDeclineRates {
    final rates = <ValidatedAssessmentType, double>{};

    for (final assessmentType in ValidatedAssessmentType.values) {
      final relevantSessions = sessions
          .where((s) => s.results.containsKey(assessmentType))
          .toList();

      if (relevantSessions.length < 2) continue;

      // Sort by date
      relevantSessions.sort((a, b) => a.sessionDate.compareTo(b.sessionDate));

      final firstSession = relevantSessions.first;
      final lastSession = relevantSessions.last;

      final timeDiff = lastSession.sessionDate.difference(firstSession.sessionDate);
      final yearsElapsed = timeDiff.inDays / 365.25;

      if (yearsElapsed < 0.1) continue; // Need at least ~1 month between tests

      final firstScore = _extractScore(assessmentType, firstSession.results[assessmentType]);
      final lastScore = _extractScore(assessmentType, lastSession.results[assessmentType]);

      rates[assessmentType] = (lastScore - firstScore) / yearsElapsed;
    }

    return rates;
  }

  /// Detect clinically significant changes
  List<ClinicalChange> get significantChanges {
    final changes = <ClinicalChange>[];

    for (int i = 1; i < sessions.length; i++) {
      final previous = sessions[i - 1];
      final current = sessions[i];

      for (final assessmentType in ValidatedAssessmentType.values) {
        if (!previous.results.containsKey(assessmentType) ||
            !current.results.containsKey(assessmentType)) {
          continue;
        }

        final previousScore = _extractScore(assessmentType, previous.results[assessmentType]);
        final currentScore = _extractScore(assessmentType, current.results[assessmentType]);

        final timeBetween = current.sessionDate.difference(previous.sessionDate);

        if (ValidatedAssessmentUtils.isClinicallySignificant(
          previousScore: previousScore.round(),
          currentScore: currentScore.round(),
          assessmentType: assessmentType,
          timeBetweenTests: timeBetween,
        )) {
          changes.add(ClinicalChange(
            assessmentType: assessmentType,
            previousScore: previousScore,
            currentScore: currentScore,
            changeAmount: currentScore - previousScore,
            timePeriod: timeBetween,
            previousDate: previous.sessionDate,
            currentDate: current.sessionDate,
            significance: _determineSignificance(currentScore - previousScore, assessmentType),
          ));
        }
      }
    }

    return changes;
  }

  /// Generate trend summary report
  TrendSummary get trendSummary {
    final declineRates = annualDeclineRates;
    final changes = significantChanges;

    // Calculate overall trajectory
    CognitiveTrajectory trajectory;
    if (declineRates.values.any((rate) => rate < -2)) {
      trajectory = CognitiveTrajectory.rapidDecline;
    } else if (declineRates.values.any((rate) => rate < -1)) {
      trajectory = CognitiveTrajectory.moderateDecline;
    } else if (declineRates.values.any((rate) => rate < -0.5)) {
      trajectory = CognitiveTrajectory.mildDecline;
    } else if (declineRates.values.every((rate) => rate >= -0.5 && rate <= 0.5)) {
      trajectory = CognitiveTrajectory.stable;
    } else {
      trajectory = CognitiveTrajectory.improvement;
    }

    return TrendSummary(
      patientId: patientId,
      assessmentPeriod: _getAssessmentPeriod(),
      trajectory: trajectory,
      annualDeclineRates: declineRates,
      significantChanges: changes,
      recommendedFollowUpInterval: _getRecommendedFollowUp(trajectory),
    );
  }

  double _extractScore(ValidatedAssessmentType type, dynamic result) {
    switch (type) {
      case ValidatedAssessmentType.mmse:
        return (result as MMSEResults).totalScore.toDouble();
      case ValidatedAssessmentType.moca:
        return (result as MoCAResults).totalScore.toDouble();
      case ValidatedAssessmentType.clockDrawing:
        return (result as ClockDrawingResults).score.toDouble();
      case ValidatedAssessmentType.gds:
        return (result as int).toDouble();
      case ValidatedAssessmentType.adascog:
        return (result as int).toDouble();
    }
  }

  ChangeSignificance _determineSignificance(double changeAmount, ValidatedAssessmentType type) {
    final absChange = changeAmount.abs();

    switch (type) {
      case ValidatedAssessmentType.mmse:
        if (absChange >= 5) return ChangeSignificance.high;
        if (absChange >= 3) return ChangeSignificance.moderate;
        return ChangeSignificance.mild;

      case ValidatedAssessmentType.moca:
        if (absChange >= 4) return ChangeSignificance.high;
        if (absChange >= 2) return ChangeSignificance.moderate;
        return ChangeSignificance.mild;

      default:
        if (absChange >= 2) return ChangeSignificance.moderate;
        return ChangeSignificance.mild;
    }
  }

  Duration _getAssessmentPeriod() {
    if (sessions.isEmpty) return Duration.zero;
    sessions.sort((a, b) => a.sessionDate.compareTo(b.sessionDate));
    return sessions.last.sessionDate.difference(sessions.first.sessionDate);
  }

  Duration _getRecommendedFollowUp(CognitiveTrajectory trajectory) {
    switch (trajectory) {
      case CognitiveTrajectory.rapidDecline:
        return const Duration(days: 90); // 3 months
      case CognitiveTrajectory.moderateDecline:
        return const Duration(days: 180); // 6 months
      case CognitiveTrajectory.mildDecline:
        return const Duration(days: 365); // 1 year
      case CognitiveTrajectory.stable:
        return const Duration(days: 365); // 1 year
      case CognitiveTrajectory.improvement:
        return const Duration(days: 180); // 6 months (to confirm improvement)
    }
  }
}

class ClinicalChange {

  ClinicalChange({
    required this.assessmentType,
    required this.previousScore,
    required this.currentScore,
    required this.changeAmount,
    required this.timePeriod,
    required this.previousDate,
    required this.currentDate,
    required this.significance,
  });
  final ValidatedAssessmentType assessmentType;
  final double previousScore;
  final double currentScore;
  final double changeAmount;
  final Duration timePeriod;
  final DateTime previousDate;
  final DateTime currentDate;
  final ChangeSignificance significance;

  bool get isImprovement => changeAmount > 0;
  bool get isDecline => changeAmount < 0;

  double get annualizedChange {
    final yearsElapsed = timePeriod.inDays / 365.25;
    return yearsElapsed > 0 ? changeAmount / yearsElapsed : 0.0;
  }
}

enum ChangeSignificance {
  mild,
  moderate,
  high,
}

enum CognitiveTrajectory {
  rapidDecline,
  moderateDecline,
  mildDecline,
  stable,
  improvement,
}

class TrendSummary {

  TrendSummary({
    required this.patientId,
    required this.assessmentPeriod,
    required this.trajectory,
    required this.annualDeclineRates,
    required this.significantChanges,
    required this.recommendedFollowUpInterval,
  });
  final String patientId;
  final Duration assessmentPeriod;
  final CognitiveTrajectory trajectory;
  final Map<ValidatedAssessmentType, double> annualDeclineRates;
  final List<ClinicalChange> significantChanges;
  final Duration recommendedFollowUpInterval;

  String get trajectoryDescription {
    switch (trajectory) {
      case CognitiveTrajectory.rapidDecline:
        return 'Rapid cognitive decline detected - urgent clinical attention recommended';
      case CognitiveTrajectory.moderateDecline:
        return 'Moderate cognitive decline observed - close monitoring indicated';
      case CognitiveTrajectory.mildDecline:
        return 'Mild cognitive decline noted - continue regular monitoring';
      case CognitiveTrajectory.stable:
        return 'Cognitive function remains stable';
      case CognitiveTrajectory.improvement:
        return 'Cognitive improvement observed - monitor to confirm trend';
    }
  }
}