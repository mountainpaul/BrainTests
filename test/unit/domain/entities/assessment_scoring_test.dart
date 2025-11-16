import 'package:brain_tests/domain/entities/validated_assessments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MMSE Assessment Scoring Tests', () {
    group('Basic Scoring Calculations', () {
      test('should calculate total score correctly', () {
        final responses = [
          MMSEResponse(
            questionId: 'orientation_time_1',
            userResponse: '2024',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'orientation_time_2',
            userResponse: 'Winter',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'orientation_place_1',
            userResponse: 'United States',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'registration_1',
            userResponse: 'Apple',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'recall_1',
            userResponse: 'Apple',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
        ];

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 15),
        );

        expect(results.totalScore, 5);
      });

      test('should calculate section scores correctly', () {
        final responses = [
          // Orientation time (2 correct out of 5)
          MMSEResponse(
            questionId: 'orientation_time_1',
            userResponse: '2024',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'orientation_time_2',
            userResponse: 'Wrong Season',
            pointsAwarded: 0,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'orientation_time_3',
            userResponse: 'January 15',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),

          // Orientation place (3 correct out of 5)
          MMSEResponse(
            questionId: 'orientation_place_1',
            userResponse: 'United States',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'orientation_place_2',
            userResponse: 'California',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'orientation_place_3',
            userResponse: 'San Francisco',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),

          // Registration (3 correct out of 3)
          MMSEResponse(
            questionId: 'registration_1',
            userResponse: 'Apple',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'registration_2',
            userResponse: 'Penny',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'registration_3',
            userResponse: 'Table',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
        ];

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 20),
        );

        final sectionScores = results.sectionScores;

        expect(sectionScores['orientation'], 5); // 2 time + 3 place
        expect(sectionScores['registration'], 3);
        expect(results.totalScore, 8);
      });

      test('should handle zero scores correctly', () {
        final responses = [
          MMSEResponse(
            questionId: 'orientation_time_1',
            userResponse: 'Wrong',
            pointsAwarded: 0,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'orientation_time_2',
            userResponse: 'Wrong',
            pointsAwarded: 0,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'recall_1',
            userResponse: 'Wrong',
            pointsAwarded: 0,
            responseTime: DateTime.now(),
          ),
        ];

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 10),
        );

        expect(results.totalScore, 0);
        expect(results.sectionScores['orientation'], 0);
        expect(results.sectionScores['recall'], 0);
      });

      test('should handle perfect score correctly', () {
        final responses = <MMSEResponse>[];

        // Create perfect score responses (30 points total)
        final sections = {
          'orientation': 10, // 5 time + 5 place
          'registration': 3,
          'attention': 5, // Serial 7s or WORLD backward
          'recall': 3,
          'language': 8, // naming 2 + repeat 1 + command 3 + reading 1 + writing 1
          'visuospatial': 1, // copy pentagons
        };

        int questionCounter = 1;
        sections.forEach((section, maxScore) {
          for (int i = 0; i < maxScore; i++) {
            responses.add(MMSEResponse(
              questionId: '${section}_$questionCounter',
              userResponse: 'Correct',
              pointsAwarded: 1,
              responseTime: DateTime.now(),
            ));
            questionCounter++;
          }
        });

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 25),
        );

        expect(results.totalScore, 30);
        expect(results.interpretation, MMSEInterpretation.normal);
      });
    });

    group('MMSE Interpretation Tests', () {
      test('should interpret normal scores correctly', () {
        final testScores = [24, 26, 28, 30];

        for (final score in testScores) {
          final responses = List.generate(score, (index) =>
            MMSEResponse(
              questionId: 'test_$index',
              userResponse: 'Correct',
              pointsAwarded: 1,
              responseTime: DateTime.now(),
            ),
          );

          final results = MMSEResults(
            responses: responses,
            completedAt: DateTime.now(),
            totalTime: const Duration(minutes: 20),
          );

          expect(results.interpretation, MMSEInterpretation.normal);
          expect(results.interpretationDescription, contains('Normal cognitive function'));
          expect(results.interpretationDescription, contains('24-30 points'));
        }
      });

      test('should interpret mild impairment scores correctly', () {
        final testScores = [18, 20, 22, 23];

        for (final score in testScores) {
          final responses = List.generate(score, (index) =>
            MMSEResponse(
              questionId: 'test_$index',
              userResponse: 'Correct',
              pointsAwarded: 1,
              responseTime: DateTime.now(),
            ),
          );

          final results = MMSEResults(
            responses: responses,
            completedAt: DateTime.now(),
            totalTime: const Duration(minutes: 20),
          );

          expect(results.interpretation, MMSEInterpretation.mildImpairment);
          expect(results.interpretationDescription, contains('Mild cognitive impairment'));
          expect(results.interpretationDescription, contains('18-23 points'));
        }
      });

      test('should interpret severe impairment scores correctly', () {
        final testScores = [0, 5, 10, 15, 17];

        for (final score in testScores) {
          final responses = List.generate(score, (index) =>
            MMSEResponse(
              questionId: 'test_$index',
              userResponse: 'Correct',
              pointsAwarded: 1,
              responseTime: DateTime.now(),
            ),
          );

          final results = MMSEResults(
            responses: responses,
            completedAt: DateTime.now(),
            totalTime: const Duration(minutes: 20),
          );

          expect(results.interpretation, MMSEInterpretation.severeImpairment);
          expect(results.interpretationDescription, contains('Severe cognitive impairment'));
          expect(results.interpretationDescription, contains('<18 points'));
        }
      });

      test('should handle boundary score cases', () {
        // Test exact boundary scores
        final boundaryTests = [
          {'score': 18, 'expected': MMSEInterpretation.mildImpairment},
          {'score': 17, 'expected': MMSEInterpretation.severeImpairment},
          {'score': 23, 'expected': MMSEInterpretation.mildImpairment},
          {'score': 24, 'expected': MMSEInterpretation.normal},
        ];

        for (final test in boundaryTests) {
          final score = test['score'] as int;
          final expected = test['expected'] as MMSEInterpretation;

          final responses = List.generate(score, (index) =>
            MMSEResponse(
              questionId: 'test_$index',
              userResponse: 'Correct',
              pointsAwarded: 1,
              responseTime: DateTime.now(),
            ),
          );

          final results = MMSEResults(
            responses: responses,
            completedAt: DateTime.now(),
            totalTime: const Duration(minutes: 20),
          );

          expect(results.interpretation, expected,
            reason: 'Score $score should be interpreted as $expected');
        }
      });
    });

    group('Age and Education Adjustments', () {
      test('should apply age adjustments correctly', () {
        const baseScore = 20;
        final responses = List.generate(baseScore, (index) =>
          MMSEResponse(
            questionId: 'test_$index',
            userResponse: 'Correct',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
        );

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 20),
        );

        // Test different age groups
        expect(results.getAdjustedScore(age: 70, educationYears: 16), 20); // No age adjustment
        expect(results.getAdjustedScore(age: 75, educationYears: 16), 20); // No age adjustment
        expect(results.getAdjustedScore(age: 80, educationYears: 16), 21); // +1 for age >= 80
        expect(results.getAdjustedScore(age: 85, educationYears: 16), 21); // +1 for age >= 80
      });

      test('should apply education adjustments correctly', () {
        const baseScore = 20;
        final responses = List.generate(baseScore, (index) =>
          MMSEResponse(
            questionId: 'test_$index',
            userResponse: 'Correct',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
        );

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 20),
        );

        // Test different education levels
        expect(results.getAdjustedScore(age: 70, educationYears: 16), 20); // No education adjustment for >12 years
        expect(results.getAdjustedScore(age: 70, educationYears: 12), 21); // +1 for 9-12 years
        expect(results.getAdjustedScore(age: 70, educationYears: 10), 21); // +1 for 9-12 years
        expect(results.getAdjustedScore(age: 70, educationYears: 8), 22); // +2 for ≤8 years
        expect(results.getAdjustedScore(age: 70, educationYears: 6), 22); // +2 for ≤8 years
      });

      test('should apply combined age and education adjustments', () {
        const baseScore = 18; // Borderline score
        final responses = List.generate(baseScore, (index) =>
          MMSEResponse(
            questionId: 'test_$index',
            userResponse: 'Correct',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
        );

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 20),
        );

        // Test combined adjustments
        expect(results.getAdjustedScore(age: 85, educationYears: 8), 21); // +1 age + +2 education
        expect(results.getAdjustedScore(age: 80, educationYears: 10), 20); // +1 age + +1 education
        expect(results.getAdjustedScore(age: 85, educationYears: 16), 19); // +1 age + 0 education
      });

      test('should clamp adjusted scores to valid range', () {
        // Test with very low base score
        const lowScore = 2;
        final lowResponses = List.generate(lowScore, (index) =>
          MMSEResponse(
            questionId: 'test_$index',
            userResponse: 'Correct',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
        );

        final lowResults = MMSEResults(
          responses: lowResponses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 20),
        );

        // Even with maximum adjustments, score shouldn't go below 0
        expect(lowResults.getAdjustedScore(age: 85, educationYears: 6), 5); // 2+1+2 = 5

        // Test with very high base score
        const highScore = 29;
        final highResponses = List.generate(highScore, (index) =>
          MMSEResponse(
            questionId: 'test_$index',
            userResponse: 'Correct',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
        );

        final highResults = MMSEResults(
          responses: highResponses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 20),
        );

        // Score should be clamped at 30
        expect(highResults.getAdjustedScore(age: 85, educationYears: 6), 30); // 29+1+2 = 32, clamped to 30
      });
    });

    group('MMSE Question Types and Validation', () {
      test('should validate MMSE constants', () {
        // Test orientation questions
        expect(MMSEAssessment.orientationTimeQuestions.length, 5);
        expect(MMSEAssessment.orientationPlaceQuestions.length, 5);

        // Test registration words
        expect(MMSEAssessment.registrationWords.length, 3);
        expect(MMSEAssessment.registrationWords, contains('Apple'));
        expect(MMSEAssessment.registrationWords, contains('Penny'));
        expect(MMSEAssessment.registrationWords, contains('Table'));

        // Test serial 7s
        expect(MMSEAssessment.serialSevensStart, 100);
        expect(MMSEAssessment.serialSevensCorrectSequence.length, 5);
        expect(MMSEAssessment.serialSevensCorrectSequence, [93, 86, 79, 72, 65]);

        // Test WORLD backward
        expect(MMSEAssessment.worldBackward, 'DLROW');

        // Test language components
        expect(MMSEAssessment.languageNamingObjects.length, 2);
        expect(MMSEAssessment.threeStageCommand.length, 3);
      });

      test('should validate serial 7s calculation', () {
        int current = MMSEAssessment.serialSevensStart;
        final calculatedSequence = <int>[];

        for (int i = 0; i < 5; i++) {
          current -= 7;
          calculatedSequence.add(current);
        }

        expect(calculatedSequence, equals(MMSEAssessment.serialSevensCorrectSequence));
      });

      test('should create valid MMSE questions', () {
        const question = MMSEQuestion(
          section: 'Orientation',
          question: 'What is the year?',
          type: MMSEQuestionType.openEnded,
          correctAnswer: '2024',
          maxPoints: 1,
          instructions: 'Ask clearly and allow 10 seconds for response',
        );

        expect(question.section, 'Orientation');
        expect(question.maxPoints, 1);
        expect(question.type, MMSEQuestionType.openEnded);
        expect(question.correctAnswer, '2024');
      });

      test('should handle different question types', () {
        const questionTypes = MMSEQuestionType.values;

        expect(questionTypes, contains(MMSEQuestionType.openEnded));
        expect(questionTypes, contains(MMSEQuestionType.multipleChoice));
        expect(questionTypes, contains(MMSEQuestionType.verbal));
        expect(questionTypes, contains(MMSEQuestionType.drawing));
        expect(questionTypes, contains(MMSEQuestionType.following));
        expect(questionTypes, contains(MMSEQuestionType.naming));
        expect(questionTypes, contains(MMSEQuestionType.repetition));
        expect(questionTypes, contains(MMSEQuestionType.calculation));

        expect(questionTypes.length, 8);
      });
    });

    group('MMSE Response Validation', () {
      test('should create valid MMSE responses', () {
        final now = DateTime.now();
        final response = MMSEResponse(
          questionId: 'orientation_time_1',
          userResponse: '2024',
          pointsAwarded: 1,
          responseTime: now,
          notes: 'Answered immediately and correctly',
        );

        expect(response.questionId, 'orientation_time_1');
        expect(response.userResponse, '2024');
        expect(response.pointsAwarded, 1);
        expect(response.responseTime, now);
        expect(response.notes, 'Answered immediately and correctly');
      });

      test('should handle partial credit responses', () {
        final response = MMSEResponse(
          questionId: 'three_stage_command',
          userResponse: 'Completed first two steps only',
          pointsAwarded: 2, // 2 out of 3 points
          responseTime: DateTime.now(),
        );

        expect(response.pointsAwarded, 2);
        expect(response.pointsAwarded, lessThan(3));
        expect(response.pointsAwarded, greaterThan(0));
      });

      test('should handle incorrect responses', () {
        final response = MMSEResponse(
          questionId: 'recall_2',
          userResponse: 'Wrong word',
          pointsAwarded: 0,
          responseTime: DateTime.now(),
          notes: 'Unable to recall second word',
        );

        expect(response.pointsAwarded, 0);
        expect(response.notes, contains('Unable to recall'));
      });
    });

    group('Section Score Analysis', () {
      test('should calculate detailed section breakdown', () {
        final responses = [
          // Perfect orientation scores
          ...List.generate(10, (index) => MMSEResponse(
            questionId: 'orientation_${index + 1}',
            userResponse: 'Correct',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          )),

          // Partial registration (2/3)
          MMSEResponse(
            questionId: 'registration_1',
            userResponse: 'Apple',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'registration_2',
            userResponse: 'Penny',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
          MMSEResponse(
            questionId: 'registration_3',
            userResponse: 'Wrong',
            pointsAwarded: 0,
            responseTime: DateTime.now(),
          ),

          // No attention/calculation
          MMSEResponse(
            questionId: 'attention_1',
            userResponse: 'Unable',
            pointsAwarded: 0,
            responseTime: DateTime.now(),
          ),

          // Partial recall (1/3)
          MMSEResponse(
            questionId: 'recall_1',
            userResponse: 'Apple',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
        ];

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 20),
        );

        final sectionScores = results.sectionScores;

        expect(sectionScores['orientation'], 10); // Perfect 10/10
        expect(sectionScores['registration'], 2); // 2/3
        expect(sectionScores['attention'], 0); // 0/5
        expect(sectionScores['recall'], 1); // 1/3
        expect(results.totalScore, 13); // 10+2+0+1
      });

      test('should handle mixed section performance', () {
        final responses = [
          // Mixed orientation (3/10)
          MMSEResponse(questionId: 'orientation_time_1', userResponse: 'Correct', pointsAwarded: 1, responseTime: DateTime.now()),
          MMSEResponse(questionId: 'orientation_time_2', userResponse: 'Wrong', pointsAwarded: 0, responseTime: DateTime.now()),
          MMSEResponse(questionId: 'orientation_place_1', userResponse: 'Correct', pointsAwarded: 1, responseTime: DateTime.now()),
          MMSEResponse(questionId: 'orientation_place_2', userResponse: 'Correct', pointsAwarded: 1, responseTime: DateTime.now()),

          // Perfect language (8/8)
          ...List.generate(8, (index) => MMSEResponse(
            questionId: 'language_${index + 1}',
            userResponse: 'Correct',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          )),
        ];

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 25),
        );

        final sectionScores = results.sectionScores;

        expect(sectionScores['orientation'], 3);
        expect(sectionScores['language'], 8);
        expect(results.totalScore, 11);
        expect(results.interpretation, MMSEInterpretation.severeImpairment); // <18
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty responses', () {
        final results = MMSEResults(
          responses: [],
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 5),
        );

        expect(results.totalScore, 0);
        expect(results.sectionScores, isEmpty);
        expect(results.interpretation, MMSEInterpretation.severeImpairment);
      });

      test('should handle responses with no section prefix', () {
        final responses = [
          MMSEResponse(
            questionId: 'malformed_question_id',
            userResponse: 'Answer',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
        ];

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 10),
        );

        expect(results.totalScore, 1);
        expect(results.sectionScores, containsPair('malformed', 1));
      });

      test('should handle negative points (should not happen in practice)', () {
        final responses = [
          MMSEResponse(
            questionId: 'test_question',
            userResponse: 'Answer',
            pointsAwarded: -1, // Invalid in practice, but test robustness
            responseTime: DateTime.now(),
          ),
        ];

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 10),
        );

        expect(results.totalScore, -1); // System handles it mathematically
        expect(results.interpretation, MMSEInterpretation.severeImpairment);
      });

      test('should handle extremely high scores (should not happen in practice)', () {
        final responses = [
          MMSEResponse(
            questionId: 'test_question',
            userResponse: 'Answer',
            pointsAwarded: 100, // Invalid in practice
            responseTime: DateTime.now(),
          ),
        ];

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 10),
        );

        expect(results.totalScore, 100);
        expect(results.interpretation, MMSEInterpretation.normal); // Still normal as >24
      });

      test('should handle adjustment edge cases', () {
        final responses = List.generate(30, (index) =>
          MMSEResponse(
            questionId: 'test_$index',
            userResponse: 'Correct',
            pointsAwarded: 1,
            responseTime: DateTime.now(),
          ),
        );

        final results = MMSEResults(
          responses: responses,
          completedAt: DateTime.now(),
          totalTime: const Duration(minutes: 20),
        );

        // Test extreme values
        expect(results.getAdjustedScore(age: 0, educationYears: 0), 30); // Clamps at max
        expect(results.getAdjustedScore(age: 200, educationYears: 0), 30); // Age > 80 still gets +1

        // Test with perfect score - adjustments should be clamped
        expect(results.getAdjustedScore(age: 85, educationYears: 5), 30); // 30+1+2=33, clamped to 30
      });
    });
  });
}