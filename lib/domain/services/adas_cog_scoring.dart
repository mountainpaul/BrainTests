/// Alzheimer's Disease Assessment Scale - Cognitive (ADAS-Cog)
/// Standard cognitive assessment for Alzheimer's disease
/// Total score: 0-70, where higher scores indicate greater impairment
class ADASCogScoring {
  /// Get all ADAS-Cog subtests with their scoring ranges
  static List<ADASCogSubtest> getSubtests() {
    return [
      ADASCogSubtest(
        name: 'Word Recall',
        description: 'Recall of 10 words after three learning trials',
        maxScore: 10,
        domain: CognitiveDomain.memory,
      ),
      ADASCogSubtest(
        name: 'Naming Objects and Fingers',
        description: 'Naming objects and fingers shown',
        maxScore: 5,
        domain: CognitiveDomain.language,
      ),
      ADASCogSubtest(
        name: 'Following Commands',
        description: 'Following 5 one-stage commands',
        maxScore: 5,
        domain: CognitiveDomain.praxis,
      ),
      ADASCogSubtest(
        name: 'Constructional Praxis',
        description: 'Copying 4 geometric forms',
        maxScore: 5,
        domain: CognitiveDomain.praxis,
      ),
      ADASCogSubtest(
        name: 'Ideational Praxis',
        description: 'Mailing a letter (multi-step task)',
        maxScore: 5,
        domain: CognitiveDomain.praxis,
      ),
      ADASCogSubtest(
        name: 'Orientation',
        description: 'Person, time, place orientation',
        maxScore: 8,
        domain: CognitiveDomain.orientation,
      ),
      ADASCogSubtest(
        name: 'Word Recognition',
        description: 'Recognition of 12 words from recall test',
        maxScore: 12,
        domain: CognitiveDomain.memory,
      ),
      ADASCogSubtest(
        name: 'Remembering Test Instructions',
        description: 'Remembering instructions for word recognition',
        maxScore: 5,
        domain: CognitiveDomain.memory,
      ),
      ADASCogSubtest(
        name: 'Spoken Language Ability',
        description: 'Quality of spontaneous speech',
        maxScore: 5,
        domain: CognitiveDomain.language,
      ),
      ADASCogSubtest(
        name: 'Word Finding Difficulty',
        description: 'Difficulty finding words in spontaneous speech',
        maxScore: 5,
        domain: CognitiveDomain.language,
      ),
      ADASCogSubtest(
        name: 'Comprehension',
        description: 'Understanding of spoken language',
        maxScore: 5,
        domain: CognitiveDomain.language,
      ),
    ];
  }

  /// Get severity level based on total ADAS-Cog score
  /// Scoring: 0-70 (higher = more impairment)
  static ADASCogSeverityLevel getSeverityLevel(int totalScore) {
    if (totalScore < 0 || totalScore > 70) {
      throw ArgumentError('ADAS-Cog score must be between 0 and 70');
    }

    if (totalScore >= 0 && totalScore < 10) {
      return ADASCogSeverityLevel.normal;
    } else if (totalScore >= 10 && totalScore < 18) {
      return ADASCogSeverityLevel.mild;
    } else if (totalScore >= 18 && totalScore < 31) {
      return ADASCogSeverityLevel.moderate;
    } else {
      return ADASCogSeverityLevel.severe;
    }
  }

  /// Get interpretation text for a severity level
  static String getInterpretation(ADASCogSeverityLevel level) {
    switch (level) {
      case ADASCogSeverityLevel.normal:
        return 'No cognitive impairment (Score 0-9): Normal cognitive function. Performance within expected range for age.';
      case ADASCogSeverityLevel.mild:
        return 'Mild cognitive impairment (Score 10-17): Mild deficits detected. May indicate early-stage cognitive decline or mild dementia.';
      case ADASCogSeverityLevel.moderate:
        return 'Moderate cognitive impairment (Score 18-30): Moderate deficits across multiple domains. Consistent with moderate dementia.';
      case ADASCogSeverityLevel.severe:
        return 'Severe cognitive impairment (Score 31-70): Significant impairment across cognitive domains. Consistent with severe dementia.';
    }
  }

  /// Get recommendations based on severity level
  static String getRecommendations(ADASCogSeverityLevel level) {
    switch (level) {
      case ADASCogSeverityLevel.normal:
        return 'Continue regular cognitive activities. Maintain healthy lifestyle with exercise, social engagement, and mental stimulation.';
      case ADASCogSeverityLevel.mild:
        return 'Consult with healthcare provider for comprehensive evaluation. Consider cognitive training programs and lifestyle interventions. Monitor for changes over time.';
      case ADASCogSeverityLevel.moderate:
        return 'Professional medical evaluation recommended. Discuss treatment options with healthcare provider. Consider support services and caregiver resources.';
      case ADASCogSeverityLevel.severe:
        return 'Comprehensive medical care required. Work with healthcare team for treatment plan. Caregiver support and safety planning essential.';
    }
  }

  /// Analyze performance by cognitive domain
  static String getDomainAnalysis(ADASCogScores scores) {
    final buffer = StringBuffer();
    final domains = <CognitiveDomain, List<String>>{};

    // Group concerns by domain
    if (scores.wordRecallScore >= 5 || scores.wordRecognitionScore >= 6 || scores.rememberingInstructionsScore >= 3) {
      domains[CognitiveDomain.memory] = [];
      if (scores.wordRecallScore >= 5) domains[CognitiveDomain.memory]!.add('Word Recall');
      if (scores.wordRecognitionScore >= 6) domains[CognitiveDomain.memory]!.add('Word Recognition');
      if (scores.rememberingInstructionsScore >= 3) domains[CognitiveDomain.memory]!.add('Remembering Instructions');
    }

    if (scores.namingScore >= 3 || scores.spokenLanguageScore >= 3 || scores.wordFindingScore >= 3 || scores.comprehensionScore >= 3) {
      domains[CognitiveDomain.language] = [];
      if (scores.namingScore >= 3) domains[CognitiveDomain.language]!.add('Naming');
      if (scores.spokenLanguageScore >= 3) domains[CognitiveDomain.language]!.add('Spoken Language');
      if (scores.wordFindingScore >= 3) domains[CognitiveDomain.language]!.add('Word Finding');
      if (scores.comprehensionScore >= 3) domains[CognitiveDomain.language]!.add('Comprehension');
    }

    if (scores.commandsScore >= 3 || scores.constructionalPraxisScore >= 3 || scores.ideationalPraxisScore >= 3) {
      domains[CognitiveDomain.praxis] = [];
      if (scores.commandsScore >= 3) domains[CognitiveDomain.praxis]!.add('Following Commands');
      if (scores.constructionalPraxisScore >= 3) domains[CognitiveDomain.praxis]!.add('Constructional Praxis');
      if (scores.ideationalPraxisScore >= 3) domains[CognitiveDomain.praxis]!.add('Ideational Praxis');
    }

    if (scores.orientationScore >= 4) {
      domains[CognitiveDomain.orientation] = [];
      domains[CognitiveDomain.orientation]!.add('Orientation');
    }

    if (domains.isEmpty) {
      return 'No significant domain-specific concerns detected.';
    }

    buffer.writeln('Domain-Specific Analysis:\n');

    domains.forEach((domain, concerns) {
      buffer.writeln('${_getDomainName(domain)}:');
      for (final concern in concerns) {
        buffer.writeln('  • $concern: Impaired');
      }
      buffer.writeln();
    });

    return buffer.toString().trim();
  }

  static String _getDomainName(CognitiveDomain domain) {
    switch (domain) {
      case CognitiveDomain.memory:
        return 'Memory';
      case CognitiveDomain.language:
        return 'Language';
      case CognitiveDomain.praxis:
        return 'Praxis (Motor Skills)';
      case CognitiveDomain.orientation:
        return 'Orientation';
    }
  }
}

/// Container for ADAS-Cog subscores
class ADASCogScores {
  final int wordRecallScore;
  final int namingScore;
  final int commandsScore;
  final int constructionalPraxisScore;
  final int ideationalPraxisScore;
  final int orientationScore;
  final int wordRecognitionScore;
  final int rememberingInstructionsScore;
  final int spokenLanguageScore;
  final int wordFindingScore;
  final int comprehensionScore;

  ADASCogScores({
    required this.wordRecallScore,
    required this.namingScore,
    required this.commandsScore,
    required this.constructionalPraxisScore,
    required this.ideationalPraxisScore,
    required this.orientationScore,
    required this.wordRecognitionScore,
    required this.rememberingInstructionsScore,
    required this.spokenLanguageScore,
    required this.wordFindingScore,
    required this.comprehensionScore,
  }) {
    // Validate score ranges
    if (wordRecallScore < 0 || wordRecallScore > 10) {
      throw ArgumentError('Word Recall score must be 0-10');
    }
    if (namingScore < 0 || namingScore > 5) {
      throw ArgumentError('Naming score must be 0-5');
    }
    if (commandsScore < 0 || commandsScore > 5) {
      throw ArgumentError('Commands score must be 0-5');
    }
    if (constructionalPraxisScore < 0 || constructionalPraxisScore > 5) {
      throw ArgumentError('Constructional Praxis score must be 0-5');
    }
    if (ideationalPraxisScore < 0 || ideationalPraxisScore > 5) {
      throw ArgumentError('Ideational Praxis score must be 0-5');
    }
    if (orientationScore < 0 || orientationScore > 8) {
      throw ArgumentError('Orientation score must be 0-8');
    }
    if (wordRecognitionScore < 0 || wordRecognitionScore > 12) {
      throw ArgumentError('Word Recognition score must be 0-12');
    }
    if (rememberingInstructionsScore < 0 || rememberingInstructionsScore > 5) {
      throw ArgumentError('Remembering Instructions score must be 0-5');
    }
    if (spokenLanguageScore < 0 || spokenLanguageScore > 5) {
      throw ArgumentError('Spoken Language score must be 0-5');
    }
    if (wordFindingScore < 0 || wordFindingScore > 5) {
      throw ArgumentError('Word Finding score must be 0-5');
    }
    if (comprehensionScore < 0 || comprehensionScore > 5) {
      throw ArgumentError('Comprehension score must be 0-5');
    }
  }

  int get totalScore =>
      wordRecallScore +
      namingScore +
      commandsScore +
      constructionalPraxisScore +
      ideationalPraxisScore +
      orientationScore +
      wordRecognitionScore +
      rememberingInstructionsScore +
      spokenLanguageScore +
      wordFindingScore +
      comprehensionScore;
}

/// ADAS-Cog subtest definition
class ADASCogSubtest {
  final String name;
  final String description;
  final int maxScore;
  final CognitiveDomain domain;

  ADASCogSubtest({
    required this.name,
    required this.description,
    required this.maxScore,
    required this.domain,
  });
}

/// Cognitive domains assessed by ADAS-Cog
enum CognitiveDomain {
  memory,
  language,
  praxis,
  orientation,
}

/// Severity levels for ADAS-Cog
enum ADASCogSeverityLevel {
  normal,    // 0-9
  mild,      // 10-17
  moderate,  // 18-30
  severe,    // 31-70
}
