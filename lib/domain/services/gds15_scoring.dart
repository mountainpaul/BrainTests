/// Geriatric Depression Scale - 15 items (GDS-15)
/// A widely used screening tool for depression in older adults
class GDS15Scoring {
  /// Questions in the GDS-15 assessment
  /// Answers are Yes (true) or No (false)
  static List<String> getQuestions() {
    return [
      'Are you basically satisfied with your life?',  // Q1 - REVERSE
      'Have you dropped many of your activities and interests?',  // Q2
      'Do you feel that your life is empty?',  // Q3
      'Do you often get bored?',  // Q4
      'Are you in good spirits most of the time?',  // Q5 - REVERSE
      'Are you afraid that something bad is going to happen to you?',  // Q6
      'Do you feel happy most of the time?',  // Q7 - REVERSE
      'Do you often feel helpless?',  // Q8
      'Do you prefer to stay at home, rather than going out and doing new things?',  // Q9 - REVERSE
      'Do you feel you have more problems with memory than most?',  // Q10
      'Do you think it is wonderful to be alive now?',  // Q11 - REVERSE
      'Do you feel pretty worthless the way you are now?',  // Q12
      'Do you feel full of energy?',  // Q13 - REVERSE
      'Do you feel that your situation is hopeless?',  // Q14
      'Do you think that most people are better off than you are?',  // Q15
    ];
  }

  /// Items that are reverse scored (Yes = 0, No = 1)
  /// These are positive/optimistic questions where "No" indicates depression
  /// Questions: 1, 5, 7, 9, 11, 13 (indices: 0, 4, 6, 8, 10, 12)
  static const Set<int> reverseScoredItems = {0, 4, 6, 8, 10, 12};

  /// Calculate total GDS-15 score from responses
  /// @param responses List of 15 boolean values (true = Yes, false = No)
  /// @return Score from 0-15, where higher scores indicate greater depression
  static int calculateScore(List<bool> responses) {
    if (responses.length != 15) {
      throw ArgumentError('GDS-15 requires exactly 15 responses');
    }

    int score = 0;

    for (int i = 0; i < responses.length; i++) {
      final isReverseScored = reverseScoredItems.contains(i);
      final response = responses[i];

      if (isReverseScored) {
        // For reverse scored items: No (false) = 1 point
        score += response ? 0 : 1;
      } else {
        // For normal items: Yes (true) = 1 point
        score += response ? 1 : 0;
      }
    }

    return score;
  }

  /// Get severity level based on total score
  static GDS15SeverityLevel getSeverityLevel(int score) {
    if (score >= 0 && score <= 4) {
      return GDS15SeverityLevel.normal;
    } else if (score >= 5 && score <= 9) {
      return GDS15SeverityLevel.mild;
    } else {
      return GDS15SeverityLevel.severe;
    }
  }

  /// Get interpretation text for a severity level
  static String getInterpretation(GDS15SeverityLevel level) {
    switch (level) {
      case GDS15SeverityLevel.normal:
        return 'No depression (Score 0-4): Normal range. No significant depressive symptoms detected.';
      case GDS15SeverityLevel.mild:
        return 'Mild depression (Score 5-9): Mild depressive symptoms. Consider monitoring and supportive interventions.';
      case GDS15SeverityLevel.severe:
        return 'Moderate to severe depression (Score 10-15): Significant depressive symptoms. Professional evaluation and treatment recommended.';
    }
  }

  /// Get recommendations based on severity level
  static String getRecommendations(GDS15SeverityLevel level) {
    switch (level) {
      case GDS15SeverityLevel.normal:
        return 'Continue with regular health maintenance. Engage in social activities and maintain healthy lifestyle habits.';
      case GDS15SeverityLevel.mild:
        return 'Consider discussing results with healthcare provider. Increase social activities, exercise, and engage in enjoyable hobbies. Monitor symptoms over time.';
      case GDS15SeverityLevel.severe:
        return 'Strongly recommend consulting with healthcare provider or mental health professional. Depression is treatable, and professional help can make a significant difference.';
    }
  }

  /// Get color indicator for severity level (for UI display)
  static String getColorIndicator(GDS15SeverityLevel level) {
    switch (level) {
      case GDS15SeverityLevel.normal:
        return 'green';
      case GDS15SeverityLevel.mild:
        return 'orange';
      case GDS15SeverityLevel.severe:
        return 'red';
    }
  }
}

/// Severity levels for GDS-15 assessment
enum GDS15SeverityLevel {
  normal,  // 0-4 points
  mild,    // 5-9 points
  severe,  // 10-15 points
}
