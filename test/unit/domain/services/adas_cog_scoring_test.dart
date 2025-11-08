import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/domain/services/adas_cog_scoring.dart';

void main() {
  group('ADAS-Cog Scoring', () {
    test('should calculate total score from all subscores', () {
      final scores = ADASCogScores(
        wordRecallScore: 5,
        namingScore: 2,
        commandsScore: 1,
        constructionalPraxisScore: 3,
        ideationalPraxisScore: 2,
        orientationScore: 4,
        wordRecognitionScore: 6,
        rememberingInstructionsScore: 1,
        spokenLanguageScore: 2,
        wordFindingScore: 1,
        comprehensionScore: 1,
      );

      expect(scores.totalScore, 28);
    });

    test('should calculate perfect score (no impairment)', () {
      final scores = ADASCogScores(
        wordRecallScore: 0,
        namingScore: 0,
        commandsScore: 0,
        constructionalPraxisScore: 0,
        ideationalPraxisScore: 0,
        orientationScore: 0,
        wordRecognitionScore: 0,
        rememberingInstructionsScore: 0,
        spokenLanguageScore: 0,
        wordFindingScore: 0,
        comprehensionScore: 0,
      );

      expect(scores.totalScore, 0);
      expect(ADASCogScoring.getSeverityLevel(scores.totalScore), ADASCogSeverityLevel.normal);
    });

    test('should calculate maximum score (severe impairment)', () {
      final scores = ADASCogScores(
        wordRecallScore: 10,
        namingScore: 5,
        commandsScore: 5,
        constructionalPraxisScore: 5,
        ideationalPraxisScore: 5,
        orientationScore: 8,
        wordRecognitionScore: 12,
        rememberingInstructionsScore: 5,
        spokenLanguageScore: 5,
        wordFindingScore: 5,
        comprehensionScore: 5,
      );

      expect(scores.totalScore, 70);
      expect(ADASCogScoring.getSeverityLevel(scores.totalScore), ADASCogSeverityLevel.severe);
    });

    test('should correctly categorize mild impairment', () {
      expect(ADASCogScoring.getSeverityLevel(0), ADASCogSeverityLevel.normal);
      expect(ADASCogScoring.getSeverityLevel(10), ADASCogSeverityLevel.mild);
      expect(ADASCogScoring.getSeverityLevel(17), ADASCogSeverityLevel.mild);
    });

    test('should correctly categorize moderate impairment', () {
      expect(ADASCogScoring.getSeverityLevel(18), ADASCogSeverityLevel.moderate);
      expect(ADASCogScoring.getSeverityLevel(30), ADASCogSeverityLevel.moderate);
    });

    test('should correctly categorize severe impairment', () {
      expect(ADASCogScoring.getSeverityLevel(31), ADASCogSeverityLevel.severe);
      expect(ADASCogScoring.getSeverityLevel(70), ADASCogSeverityLevel.severe);
    });

    test('should provide correct interpretation for each severity level', () {
      expect(ADASCogScoring.getInterpretation(ADASCogSeverityLevel.normal),
          contains('No cognitive impairment'));
      expect(ADASCogScoring.getInterpretation(ADASCogSeverityLevel.mild),
          contains('Mild cognitive impairment'));
      expect(ADASCogScoring.getInterpretation(ADASCogSeverityLevel.moderate),
          contains('Moderate cognitive impairment'));
      expect(ADASCogScoring.getInterpretation(ADASCogSeverityLevel.severe),
          contains('Severe cognitive impairment'));
    });

    test('should return all ADAS-Cog subtests', () {
      final subtests = ADASCogScoring.getSubtests();

      expect(subtests.length, 11);
      expect(subtests[0].name, 'Word Recall');
      expect(subtests[0].maxScore, 10);
      expect(subtests[10].name, 'Comprehension');
    });

    test('should validate score ranges for each subtest', () {
      // Word Recall: 0-10
      expect(() => ADASCogScores(
        wordRecallScore: 11,
        namingScore: 0,
        commandsScore: 0,
        constructionalPraxisScore: 0,
        ideationalPraxisScore: 0,
        orientationScore: 0,
        wordRecognitionScore: 0,
        rememberingInstructionsScore: 0,
        spokenLanguageScore: 0,
        wordFindingScore: 0,
        comprehensionScore: 0,
      ), throwsArgumentError);

      // Orientation: 0-8
      expect(() => ADASCogScores(
        wordRecallScore: 0,
        namingScore: 0,
        commandsScore: 0,
        constructionalPraxisScore: 0,
        ideationalPraxisScore: 0,
        orientationScore: 9,
        wordRecognitionScore: 0,
        rememberingInstructionsScore: 0,
        spokenLanguageScore: 0,
        wordFindingScore: 0,
        comprehensionScore: 0,
      ), throwsArgumentError);
    });

    test('should provide domain-specific interpretations', () {
      final scores = ADASCogScores(
        wordRecallScore: 8,  // High score = poor memory
        namingScore: 0,
        commandsScore: 0,
        constructionalPraxisScore: 0,
        ideationalPraxisScore: 0,
        orientationScore: 5,  // High score = poor orientation
        wordRecognitionScore: 2,
        rememberingInstructionsScore: 0,
        spokenLanguageScore: 0,
        wordFindingScore: 0,
        comprehensionScore: 0,
      );

      final analysis = ADASCogScoring.getDomainAnalysis(scores);

      expect(analysis, contains('Memory'));
      expect(analysis, contains('Orientation'));
    });
  });
}
