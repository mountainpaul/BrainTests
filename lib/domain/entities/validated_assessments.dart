// Validated clinical assessment instruments for dementia monitoring
// Based on published clinical standards and normative data

enum ValidatedAssessmentType {
  mmse,           // Mini-Mental State Examination
  moca,           // Montreal Cognitive Assessment
  clockDrawing,   // Clock Drawing Test
  gds,            // Geriatric Depression Scale
  adascog,        // ADAS-Cog (Alzheimer's Disease Assessment Scale)
}

/// Mini-Mental State Examination (MMSE)
/// Folstein et al., 1975
/// Maximum score: 30 points
/// Cutoffs: 24-30 normal, 18-23 mild cognitive impairment, <18 severe impairment
class MMSEAssessment {
  // Orientation to time (5 points)
  static const orientationTimeQuestions = [
    'What is the year?',
    'What is the season?',
    'What is the date?',
    'What is the day of the week?',
    'What is the month?',
  ];

  // Orientation to place (5 points)
  static const orientationPlaceQuestions = [
    'What country are we in?',
    'What state/province are we in?',
    'What city are we in?',
    'What is the name of this place?',
    'What floor of the building are we on?',
  ];

  // Registration (3 points) - repeat 3 words
  static const registrationWords = ['Apple', 'Penny', 'Table'];

  // Attention and calculation (5 points) - serial 7s or spell WORLD backward
  static const serialSevensStart = 100;
  static const serialSevensCorrectSequence = [93, 86, 79, 72, 65];
  static const worldBackward = 'DLROW'; // WORLD spelled backward

  // Recall (3 points) - recall the 3 words from registration

  // Language tests
  static const languageNamingObjects = ['Watch', 'Pencil']; // 2 points
  static const languageRepeatPhrase = 'No ifs, ands, or buts'; // 1 point

  // Three-stage command (3 points)
  static const threeStageCommand = [
    'Take this paper in your right hand',
    'Fold it in half',
    'Put it on the floor'
  ];

  // Reading and writing
  static const readingCommand = 'CLOSE YOUR EYES'; // 1 point
  static const writingSentencePrompt = 'Write a complete sentence'; // 1 point

  // Visuospatial - copy intersecting pentagons (1 point)
  static const copyPentagonsTask = 'Copy this design'; // Shows intersecting pentagons
}

class MMSEQuestion {

  const MMSEQuestion({
    required this.section,
    required this.question,
    required this.type,
    this.correctAnswer,
    required this.maxPoints,
    this.instructions,
  });
  final String section;
  final String question;
  final MMSEQuestionType type;
  final dynamic correctAnswer;
  final int maxPoints;
  final String? instructions;
}

enum MMSEQuestionType {
  openEnded,
  multipleChoice,
  verbal,
  drawing,
  following,
  naming,
  repetition,
  calculation,
}

class MMSEResponse {

  MMSEResponse({
    required this.questionId,
    required this.userResponse,
    required this.pointsAwarded,
    required this.responseTime,
    this.notes,
  });
  final String questionId;
  final dynamic userResponse;
  final int pointsAwarded;
  final DateTime responseTime;
  final String? notes;
}

class MMSEResults {

  MMSEResults({
    required this.responses,
    required this.completedAt,
    required this.totalTime,
    this.administratorNotes,
  });
  final List<MMSEResponse> responses;
  final DateTime completedAt;
  final Duration totalTime;
  final String? administratorNotes;

  int get totalScore => responses.fold(0, (sum, response) => sum + response.pointsAwarded);

  Map<String, int> get sectionScores {
    final scores = <String, int>{};

    // Group responses by section and sum points
    for (final response in responses) {
      final section = response.questionId.split('_')[0];
      scores[section] = (scores[section] ?? 0) + response.pointsAwarded;
    }

    return scores;
  }

  MMSEInterpretation get interpretation {
    if (totalScore >= 24) {
      return MMSEInterpretation.normal;
    } else if (totalScore >= 18) {
      return MMSEInterpretation.mildImpairment;
    } else {
      return MMSEInterpretation.severeImpairment;
    }
  }

  String get interpretationDescription {
    switch (interpretation) {
      case MMSEInterpretation.normal:
        return 'Normal cognitive function (24-30 points)';
      case MMSEInterpretation.mildImpairment:
        return 'Mild cognitive impairment (18-23 points)';
      case MMSEInterpretation.severeImpairment:
        return 'Severe cognitive impairment (<18 points)';
    }
  }

  // Age and education adjusted scoring
  int getAdjustedScore({required int age, required int educationYears}) {
    int adjustedScore = totalScore;

    // Age adjustments based on normative data
    if (age >= 80) {
      adjustedScore += 1;
    } else if (age >= 75) {
      adjustedScore += 0; // No adjustment
    }

    // Education adjustments
    if (educationYears <= 8) {
      adjustedScore += 2;
    } else if (educationYears <= 12) {
      adjustedScore += 1;
    }

    return adjustedScore.clamp(0, 30);
  }
}

enum MMSEInterpretation {
  normal,
  mildImpairment,
  severeImpairment,
}

/// Montreal Cognitive Assessment (MoCA)
/// Nasreddine et al., 2005
/// Maximum score: 30 points
/// More sensitive to mild cognitive impairment than MMSE
/// Cutoff: <26 suggests cognitive impairment
class MoCAAssessment {
  // Visuospatial/Executive (5 points)
  // - Trail making B (1 point)
  // - Copy cube (1 point)
  // - Clock drawing (3 points: contour, numbers, hands)

  // Naming (3 points) - lion, rhinoceros, camel

  // Memory (5 points during registration, tested later)
  static const memoryWords = [
    ['Face', 'Velvet', 'Church', 'Daisy', 'Red'],
  ];

  // Attention (6 points)
  // - Digit span forward/backward (2 points)
  // - Vigilance (1 point) - tap when hear letter A
  // - Serial 7s (3 points)

  // Language (3 points)
  // - Sentence repetition (2 points)
  // - Phonemic fluency - F words (1 point)

  // Abstraction (2 points) - similarities
  static const abstractionPairs = [
    ['Train', 'Bicycle'], // Both are means of transportation
    ['Watch', 'Ruler'],   // Both are measuring instruments
  ];

  // Delayed recall (5 points) - recall memory words with cues if needed

  // Orientation (6 points) - date, month, year, day, place, city
}

class MoCAResults {

  MoCAResults({
    required this.responses,
    required this.completedAt,
    required this.totalTime,
  });
  final List<MMSEResponse> responses; // Reuse response structure
  final DateTime completedAt;
  final Duration totalTime;

  int get totalScore => responses.fold(0, (sum, response) => sum + response.pointsAwarded);

  // Education adjustment for MoCA
  int getEducationAdjustedScore(int educationYears) {
    int adjustedScore = totalScore;

    if (educationYears <= 12) {
      adjustedScore += 1; // Add 1 point if ≤12 years education
    }

    return adjustedScore.clamp(0, 30);
  }

  MoCAInterpretation get interpretation {
    if (totalScore >= 26) {
      return MoCAInterpretation.normal;
    } else {
      return MoCAInterpretation.impaired;
    }
  }
}

enum MoCAInterpretation {
  normal,
  impaired,
}

/// Clock Drawing Test
/// Standardized scoring based on Shulman et al., 1993
/// Scale: 1-6 (6 = perfect, 1 = severely impaired)
class ClockDrawingTest {
  static const instructions = '''
Draw a clock showing the time as 10 past 11.
Draw the circle, put in all the numbers, and set the hands to show 10 past 11.
''';

  // Scoring criteria
  static const scoringCriteria = {
    6: 'Perfect clock',
    5: 'Minor visuospatial errors',
    4: 'Moderate visuospatial disorganization',
    3: 'Numbers and clock face no longer obviously connected',
    2: 'Some evidence of instructions being received',
    1: 'Either no attempt or uninterpretable effort',
  };
}

class ClockDrawingResults {

  ClockDrawingResults({
    this.drawingData,
    required this.score,
    required this.scoringNotes,
    required this.completedAt,
    required this.drawingTime,
  });
  final String? drawingData; // Base64 encoded drawing or path to image
  final int score; // 1-6 scale
  final String scoringNotes;
  final DateTime completedAt;
  final Duration drawingTime;

  ClockDrawingInterpretation get interpretation {
    if (score >= 5) {
      return ClockDrawingInterpretation.normal;
    } else if (score >= 3) {
      return ClockDrawingInterpretation.mildImpairment;
    } else {
      return ClockDrawingInterpretation.severeImpairment;
    }
  }
}

enum ClockDrawingInterpretation {
  normal,
  mildImpairment,
  severeImpairment,
}

/// Geriatric Depression Scale (GDS-15) - Short form
/// Yesavage et al., 1982
/// Important because depression can mimic or exacerbate cognitive impairment
class GDSAssessment {
  static const questions = [
    'Are you basically satisfied with your life?', // No = 1 point
    'Have you dropped many of your activities and interests?', // Yes = 1 point
    'Do you feel that your life is empty?', // Yes = 1 point
    'Do you often get bored?', // Yes = 1 point
    'Are you in good spirits most of the time?', // No = 1 point
    'Are you afraid that something bad is going to happen to you?', // Yes = 1 point
    'Do you feel happy most of the time?', // No = 1 point
    'Do you often feel helpless?', // Yes = 1 point
    'Do you prefer to stay at home, rather than going out and doing new things?', // Yes = 1 point
    'Do you feel you have more problems with memory than most?', // Yes = 1 point
    'Do you think it is wonderful to be alive now?', // No = 1 point
    'Do you feel pretty worthless the way you are now?', // Yes = 1 point
    'Do you feel full of energy?', // No = 1 point
    'Do you feel that your situation is hopeless?', // Yes = 1 point
    'Do you think that most people are better off than you are?', // Yes = 1 point
  ];

  // Scoring: 0-4 normal, 5-8 mild depression, 9-11 moderate, 12-15 severe
  static Map<String, String> getInterpretation(int score) {
    if (score <= 4) {
      return {'level': 'Normal', 'description': 'No significant depressive symptoms'};
    } else if (score <= 8) {
      return {'level': 'Mild', 'description': 'Mild depressive symptoms'};
    } else if (score <= 11) {
      return {'level': 'Moderate', 'description': 'Moderate depressive symptoms'};
    } else {
      return {'level': 'Severe', 'description': 'Severe depressive symptoms'};
    }
  }
}

/// Normative data and adjustment factors
class CognitiveDemographics {

  CognitiveDemographics({
    required this.age,
    required this.educationYears,
    required this.gender,
    this.ethnicity,
    this.primaryLanguage,
  });
  final int age;
  final int educationYears;
  final String gender;
  final String? ethnicity;
  final String? primaryLanguage;
}

/// Clinical utility functions
class ValidatedAssessmentUtils {
  /// Calculate percentile rank based on normative data
  static int calculatePercentile({
    required int score,
    required ValidatedAssessmentType assessmentType,
    required CognitiveDemographics demographics,
  }) {
    // Simplified percentile calculation
    // In real implementation, would use comprehensive normative databases

    switch (assessmentType) {
      case ValidatedAssessmentType.mmse:
        return _calculateMMSEPercentile(score, demographics);
      case ValidatedAssessmentType.moca:
        return _calculateMoCAPercentile(score, demographics);
      default:
        return 50; // Default median
    }
  }

  static int _calculateMMSEPercentile(int score, CognitiveDemographics demographics) {
    // Simplified MMSE percentile calculation based on age and education
    // Real implementation would use published normative tables

    double adjustedScore = score.toDouble();

    // Age adjustments
    if (demographics.age >= 80) {
      adjustedScore += 1.5;
    } else if (demographics.age >= 70) adjustedScore += 0.5;

    // Education adjustments
    if (demographics.educationYears <= 8) {
      adjustedScore += 2.0;
    } else if (demographics.educationYears <= 12) adjustedScore += 1.0;

    // Convert to percentile (simplified)
    if (adjustedScore >= 29) {
      return 90;
    } else if (adjustedScore >= 27) return 75;
    else if (adjustedScore >= 25) return 50;
    else if (adjustedScore >= 23) return 25;
    else if (adjustedScore >= 20) return 10;
    else return 5;
  }

  static int _calculateMoCAPercentile(int score, CognitiveDemographics demographics) {
    // MoCA percentile calculation
    double adjustedScore = score.toDouble();

    if (demographics.educationYears <= 12) adjustedScore += 1;

    if (adjustedScore >= 28) {
      return 85;
    } else if (adjustedScore >= 26) return 50;
    else if (adjustedScore >= 23) return 25;
    else if (adjustedScore >= 20) return 10;
    else return 5;
  }

  /// Determine if score change is clinically significant
  static bool isClinicallySignificant({
    required int previousScore,
    required int currentScore,
    required ValidatedAssessmentType assessmentType,
    required Duration timeBetweenTests,
  }) {
    final scoreDifference = currentScore - previousScore;

    switch (assessmentType) {
      case ValidatedAssessmentType.mmse:
        // MMSE: 3+ point change is typically considered significant
        return scoreDifference.abs() >= 3;
      case ValidatedAssessmentType.moca:
        // MoCA: 2+ point change may be significant
        return scoreDifference.abs() >= 2;
      default:
        return false;
    }
  }

  /// Calculate annualized rate of change
  static double calculateAnnualizedChange({
    required int previousScore,
    required int currentScore,
    required Duration timeBetweenTests,
  }) {
    final scoreDifference = currentScore - previousScore;
    final yearsElapsed = timeBetweenTests.inDays / 365.25;

    if (yearsElapsed == 0) return 0.0;

    return scoreDifference / yearsElapsed;
  }
}