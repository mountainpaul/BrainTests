import 'package:brain_plan/domain/entities/validated_assessments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidatedAssessments Tests', () {
    late CognitiveDemographics demographics;
    late MMSEResults mmseResults;
    late MoCAResults mocaResults;
    late ClockDrawingResults clockResults;

    setUp(() {
      demographics = CognitiveDemographics(
        age: 75,
        educationYears: 12,
        gender: 'Female',
        ethnicity: 'Caucasian',
        primaryLanguage: 'English',
      );

      final mmseResponses = [
        MMSEResponse(
          questionId: 'orientation_1',
          userResponse: 'Correct',
          pointsAwarded: 5,
          responseTime: DateTime.now(),
          notes: 'Perfect orientation to time',
        ),
        MMSEResponse(
          questionId: 'registration_1',
          userResponse: 'Apple, Penny, Table',
          pointsAwarded: 3,
          responseTime: DateTime.now(),
        ),
        MMSEResponse(
          questionId: 'attention_1',
          userResponse: '93, 86, 79, 72, 65',
          pointsAwarded: 5,
          responseTime: DateTime.now(),
        ),
      ];

      mmseResults = MMSEResults(
        responses: mmseResponses,
        completedAt: DateTime.now(),
        totalTime: const Duration(minutes: 15),
        administratorNotes: 'Patient was cooperative',
      );

      final mocaResponses = [
        MMSEResponse(
          questionId: 'visuospatial_1',
          userResponse: 'Correct cube copy',
          pointsAwarded: 4,
          responseTime: DateTime.now(),
        ),
        MMSEResponse(
          questionId: 'naming_1',
          userResponse: 'Lion, Rhino, Camel',
          pointsAwarded: 3,
          responseTime: DateTime.now(),
        ),
      ];

      mocaResults = MoCAResults(
        responses: mocaResponses,
        completedAt: DateTime.now(),
        totalTime: const Duration(minutes: 20),
      );

      clockResults = ClockDrawingResults(
        drawingData: 'base64_encoded_drawing',
        score: 5,
        scoringNotes: 'Good clock with minor spacing issues',
        completedAt: DateTime.now(),
        drawingTime: const Duration(minutes: 3),
      );
    });

    group('CognitiveDemographics', () {
      test('should create demographics with all fields', () {
        expect(demographics.age, 75);
        expect(demographics.educationYears, 12);
        expect(demographics.gender, 'Female');
        expect(demographics.ethnicity, 'Caucasian');
        expect(demographics.primaryLanguage, 'English');
      });

      test('should create demographics with required fields only', () {
        final minimalDemographics = CognitiveDemographics(
          age: 65,
          educationYears: 16,
          gender: 'Male',
        );

        expect(minimalDemographics.age, 65);
        expect(minimalDemographics.educationYears, 16);
        expect(minimalDemographics.gender, 'Male');
        expect(minimalDemographics.ethnicity, null);
        expect(minimalDemographics.primaryLanguage, null);
      });
    });

    group('MMSEResults', () {
      test('should calculate total score correctly', () {
        expect(mmseResults.totalScore, 13);
      });

      test('should group section scores correctly', () {
        final sectionScores = mmseResults.sectionScores;
        expect(sectionScores['orientation'], 5);
        expect(sectionScores['registration'], 3);
        expect(sectionScores['attention'], 5);
      });

      test('should interpret scores correctly', () {
        // Score of 13 should be severe impairment
        expect(mmseResults.interpretation, MMSEInterpretation.severeImpairment);
        expect(mmseResults.interpretationDescription, 'Severe cognitive impairment (<18 points)');
      });

      test('should interpret normal scores correctly', () {
        final highScoreResponses = [
          MMSEResponse(
            questionId: 'test_1',
            userResponse: 'Correct',
            pointsAwarded: 25,
            responseTime: DateTime.now(),
          ),
        ];

        final highScoreResults = MMSEResults(
          responses: highScoreResponses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 15),
        );

        expect(highScoreResults.interpretation, MMSEInterpretation.normal);
        expect(highScoreResults.interpretationDescription, 'Normal cognitive function (24-30 points)');
      });

      test('should interpret mild impairment correctly', () {
        final mildScoreResponses = [
          MMSEResponse(
            questionId: 'test_1',
            userResponse: 'Partial',
            pointsAwarded: 20,
            responseTime: DateTime.now(),
          ),
        ];

        final mildResults = MMSEResults(
          responses: mildScoreResponses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 15),
        );

        expect(mildResults.interpretation, MMSEInterpretation.mildImpairment);
        expect(mildResults.interpretationDescription, 'Mild cognitive impairment (18-23 points)');
      });

      test('should apply age adjustments correctly', () {
        final adjustedScore = mmseResults.getAdjustedScore(age: 85, educationYears: 12);
        expect(adjustedScore, 15); // 13 + 1 for age 85 + 1 for education <= 12
      });

      test('should apply education adjustments correctly', () {
        final adjustedScore = mmseResults.getAdjustedScore(age: 65, educationYears: 6);
        expect(adjustedScore, 15); // 13 + 2 for education <= 8
      });

      test('should clamp adjusted scores to valid range', () {
        final highResponses = [
          MMSEResponse(
            questionId: 'test_1',
            userResponse: 'Perfect',
            pointsAwarded: 30,
            responseTime: DateTime.now(),
          ),
        ];

        final highResults = MMSEResults(
          responses: highResponses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 15),
        );

        final adjustedScore = highResults.getAdjustedScore(age: 85, educationYears: 6);
        expect(adjustedScore, 30); // Should not exceed 30
      });
    });

    group('MoCAResults', () {
      test('should calculate total score correctly', () {
        expect(mocaResults.totalScore, 7);
      });

      test('should apply education adjustment correctly', () {
        final adjustedScore = mocaResults.getEducationAdjustedScore(10);
        expect(adjustedScore, 8); // 7 + 1 for education <= 12
      });

      test('should not adjust for higher education', () {
        final adjustedScore = mocaResults.getEducationAdjustedScore(16);
        expect(adjustedScore, 7); // No adjustment for education > 12
      });

      test('should clamp adjusted scores correctly', () {
        final highResponses = [
          MMSEResponse(
            questionId: 'test_1',
            userResponse: 'Perfect',
            pointsAwarded: 30,
            responseTime: DateTime.now(),
          ),
        ];

        final highResults = MoCAResults(
          responses: highResponses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 20),
        );

        final adjustedScore = highResults.getEducationAdjustedScore(10);
        expect(adjustedScore, 30); // Should not exceed 30
      });

      test('should interpret normal scores correctly', () {
        final normalResponses = [
          MMSEResponse(
            questionId: 'test_1',
            userResponse: 'Excellent',
            pointsAwarded: 26,
            responseTime: DateTime.now(),
          ),
        ];

        final normalResults = MoCAResults(
          responses: normalResponses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 20),
        );

        expect(normalResults.interpretation, MoCAInterpretation.normal);
      });

      test('should interpret impaired scores correctly', () {
        expect(mocaResults.interpretation, MoCAInterpretation.impaired);
      });
    });

    group('ClockDrawingResults', () {
      test('should create clock drawing results correctly', () {
        expect(clockResults.score, 5);
        expect(clockResults.scoringNotes, 'Good clock with minor spacing issues');
        expect(clockResults.drawingData, 'base64_encoded_drawing');
        expect(clockResults.drawingTime, const Duration(minutes: 3));
      });

      test('should interpret normal scores correctly', () {
        expect(clockResults.interpretation, ClockDrawingInterpretation.normal);
      });

      test('should interpret mild impairment correctly', () {
        final mildResults = ClockDrawingResults(
          score: 3,
          scoringNotes: 'Some organizational issues',
          completedAt: DateTime.now(),
          drawingTime: const Duration(minutes: 4),
        );

        expect(mildResults.interpretation, ClockDrawingInterpretation.mildImpairment);
      });

      test('should interpret severe impairment correctly', () {
        final severeResults = ClockDrawingResults(
          score: 1,
          scoringNotes: 'Very poor clock drawing',
          completedAt: DateTime.now(),
          drawingTime: const Duration(minutes: 5),
        );

        expect(severeResults.interpretation, ClockDrawingInterpretation.severeImpairment);
      });
    });

    group('MMSEResponse', () {
      test('should create MMSE response correctly', () {
        final response = MMSEResponse(
          questionId: 'test_question',
          userResponse: 'User answer',
          pointsAwarded: 3,
          responseTime: DateTime.now(),
          notes: 'Additional notes',
        );

        expect(response.questionId, 'test_question');
        expect(response.userResponse, 'User answer');
        expect(response.pointsAwarded, 3);
        expect(response.notes, 'Additional notes');
      });

      test('should create MMSE response without notes', () {
        final response = MMSEResponse(
          questionId: 'test_question',
          userResponse: 'User answer',
          pointsAwarded: 2,
          responseTime: DateTime.now(),
        );

        expect(response.notes, null);
      });
    });

    group('MMSEQuestion', () {
      test('should create MMSE question correctly', () {
        const question = MMSEQuestion(
          section: 'Orientation',
          question: 'What year is it?',
          type: MMSEQuestionType.openEnded,
          correctAnswer: 2024,
          maxPoints: 1,
          instructions: 'Ask the patient for the current year',
        );

        expect(question.section, 'Orientation');
        expect(question.question, 'What year is it?');
        expect(question.type, MMSEQuestionType.openEnded);
        expect(question.correctAnswer, 2024);
        expect(question.maxPoints, 1);
        expect(question.instructions, 'Ask the patient for the current year');
      });

      test('should create MMSE question without optional fields', () {
        const question = MMSEQuestion(
          section: 'Language',
          question: 'Repeat this phrase',
          type: MMSEQuestionType.repetition,
          maxPoints: 1,
        );

        expect(question.correctAnswer, null);
        expect(question.instructions, null);
      });
    });

    group('ValidatedAssessmentUtils', () {
      test('should calculate MMSE percentile correctly', () {
        final percentile = ValidatedAssessmentUtils.calculatePercentile(
          score: 25,
          assessmentType: ValidatedAssessmentType.mmse,
          demographics: demographics,
        );

        expect(percentile, greaterThan(0));
        expect(percentile, lessThanOrEqualTo(100));
      });

      test('should calculate MoCA percentile correctly', () {
        final percentile = ValidatedAssessmentUtils.calculatePercentile(
          score: 26,
          assessmentType: ValidatedAssessmentType.moca,
          demographics: demographics,
        );

        expect(percentile, greaterThan(0));
        expect(percentile, lessThanOrEqualTo(100));
      });

      test('should return default percentile for unsupported assessments', () {
        final percentile = ValidatedAssessmentUtils.calculatePercentile(
          score: 20,
          assessmentType: ValidatedAssessmentType.gds,
          demographics: demographics,
        );

        expect(percentile, 50);
      });

      test('should detect clinically significant MMSE changes', () {
        final isSignificant = ValidatedAssessmentUtils.isClinicallySignificant(
          previousScore: 25,
          currentScore: 21,
          assessmentType: ValidatedAssessmentType.mmse,
          timeBetweenTests: const Duration(days: 180),
        );

        expect(isSignificant, true); // 4-point change is significant
      });

      test('should detect non-significant MMSE changes', () {
        final isSignificant = ValidatedAssessmentUtils.isClinicallySignificant(
          previousScore: 25,
          currentScore: 23,
          assessmentType: ValidatedAssessmentType.mmse,
          timeBetweenTests: const Duration(days: 180),
        );

        expect(isSignificant, false); // 2-point change is not significant
      });

      test('should detect clinically significant MoCA changes', () {
        final isSignificant = ValidatedAssessmentUtils.isClinicallySignificant(
          previousScore: 26,
          currentScore: 23,
          assessmentType: ValidatedAssessmentType.moca,
          timeBetweenTests: const Duration(days: 180),
        );

        expect(isSignificant, true); // 3-point change is significant
      });

      test('should calculate annualized change correctly', () {
        final annualizedChange = ValidatedAssessmentUtils.calculateAnnualizedChange(
          previousScore: 25,
          currentScore: 21,
          timeBetweenTests: const Duration(days: 730), // 2 years
        );

        expect(annualizedChange, closeTo(-2.0, 0.1)); // -4 points over 2 years = -2 per year
      });

      test('should handle zero time duration', () {
        final annualizedChange = ValidatedAssessmentUtils.calculateAnnualizedChange(
          previousScore: 25,
          currentScore: 21,
          timeBetweenTests: Duration.zero,
        );

        expect(annualizedChange, 0.0);
      });
    });

    group('GDSAssessment', () {
      test('should have correct number of questions', () {
        expect(GDSAssessment.questions.length, 15);
      });

      test('should interpret normal scores correctly', () {
        final interpretation = GDSAssessment.getInterpretation(3);
        expect(interpretation['level'], 'Normal');
        expect(interpretation['description'], 'No significant depressive symptoms');
      });

      test('should interpret mild depression correctly', () {
        final interpretation = GDSAssessment.getInterpretation(6);
        expect(interpretation['level'], 'Mild');
        expect(interpretation['description'], 'Mild depressive symptoms');
      });

      test('should interpret moderate depression correctly', () {
        final interpretation = GDSAssessment.getInterpretation(10);
        expect(interpretation['level'], 'Moderate');
        expect(interpretation['description'], 'Moderate depressive symptoms');
      });

      test('should interpret severe depression correctly', () {
        final interpretation = GDSAssessment.getInterpretation(13);
        expect(interpretation['level'], 'Severe');
        expect(interpretation['description'], 'Severe depressive symptoms');
      });
    });

    group('MMSEAssessment Constants', () {
      test('should have correct orientation time questions', () {
        expect(MMSEAssessment.orientationTimeQuestions.length, 5);
        expect(MMSEAssessment.orientationTimeQuestions.contains('What is the year?'), true);
        expect(MMSEAssessment.orientationTimeQuestions.contains('What is the month?'), true);
      });

      test('should have correct orientation place questions', () {
        expect(MMSEAssessment.orientationPlaceQuestions.length, 5);
        expect(MMSEAssessment.orientationPlaceQuestions.contains('What country are we in?'), true);
        expect(MMSEAssessment.orientationPlaceQuestions.contains('What city are we in?'), true);
      });

      test('should have correct registration words', () {
        expect(MMSEAssessment.registrationWords.length, 3);
        expect(MMSEAssessment.registrationWords, ['Apple', 'Penny', 'Table']);
      });

      test('should have correct serial sevens sequence', () {
        expect(MMSEAssessment.serialSevensStart, 100);
        expect(MMSEAssessment.serialSevensCorrectSequence, [93, 86, 79, 72, 65]);
      });

      test('should have correct language tests', () {
        expect(MMSEAssessment.languageNamingObjects, ['Watch', 'Pencil']);
        expect(MMSEAssessment.languageRepeatPhrase, 'No ifs, ands, or buts');
      });

      test('should have correct three-stage command', () {
        expect(MMSEAssessment.threeStageCommand.length, 3);
        expect(MMSEAssessment.threeStageCommand[0], 'Take this paper in your right hand');
        expect(MMSEAssessment.threeStageCommand[1], 'Fold it in half');
        expect(MMSEAssessment.threeStageCommand[2], 'Put it on the floor');
      });
    });

    group('MoCAAssessment Constants', () {
      test('should have correct memory words', () {
        expect(MoCAAssessment.memoryWords.length, 1);
        expect(MoCAAssessment.memoryWords[0].length, 5);
        expect(MoCAAssessment.memoryWords[0], ['Face', 'Velvet', 'Church', 'Daisy', 'Red']);
      });

      test('should have correct abstraction pairs', () {
        expect(MoCAAssessment.abstractionPairs.length, 2);
        expect(MoCAAssessment.abstractionPairs[0], ['Train', 'Bicycle']);
        expect(MoCAAssessment.abstractionPairs[1], ['Watch', 'Ruler']);
      });
    });

    group('ClockDrawingTest Constants', () {
      test('should have correct instructions', () {
        expect(ClockDrawingTest.instructions, contains('Draw a clock'));
        expect(ClockDrawingTest.instructions, contains('10 past 11'));
      });

      test('should have correct scoring criteria', () {
        expect(ClockDrawingTest.scoringCriteria.length, 6);
        expect(ClockDrawingTest.scoringCriteria[6], 'Perfect clock');
        expect(ClockDrawingTest.scoringCriteria[1], 'Either no attempt or uninterpretable effort');
      });
    });

    group('Enums', () {
      test('should have all ValidatedAssessmentType values', () {
        expect(ValidatedAssessmentType.values.length, 5);
        expect(ValidatedAssessmentType.values.contains(ValidatedAssessmentType.mmse), true);
        expect(ValidatedAssessmentType.values.contains(ValidatedAssessmentType.moca), true);
        expect(ValidatedAssessmentType.values.contains(ValidatedAssessmentType.clockDrawing), true);
        expect(ValidatedAssessmentType.values.contains(ValidatedAssessmentType.gds), true);
        expect(ValidatedAssessmentType.values.contains(ValidatedAssessmentType.adascog), true);
      });

      test('should have all MMSEQuestionType values', () {
        expect(MMSEQuestionType.values.length, 8);
        expect(MMSEQuestionType.values.contains(MMSEQuestionType.openEnded), true);
        expect(MMSEQuestionType.values.contains(MMSEQuestionType.calculation), true);
      });

      test('should have all interpretation enums', () {
        expect(MMSEInterpretation.values.length, 3);
        expect(MoCAInterpretation.values.length, 2);
        expect(ClockDrawingInterpretation.values.length, 3);
      });
    });
  });
}