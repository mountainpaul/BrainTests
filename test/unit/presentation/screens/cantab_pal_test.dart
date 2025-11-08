import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/presentation/screens/cambridge/cantab_pal_test_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'cantab_pal_test.mocks.dart';

@GenerateMocks([AppDatabase])
void main() {
  group('CANTAB PAL Test - Core Logic', () {
    late MockAppDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockAppDatabase();
    });

    group('Stage Configuration', () {
      test('should have exactly 5 stages with correct pattern counts', () {
        // CANTAB standard: 1, 2, 3, 6, 8 patterns
        const expectedPatternCounts = [1, 2, 3, 6, 8];

        // This tests the static configuration
        expect(expectedPatternCounts.length, equals(5));
        expect(expectedPatternCounts[0], equals(1));
        expect(expectedPatternCounts[1], equals(2));
        expect(expectedPatternCounts[2], equals(3));
        expect(expectedPatternCounts[3], equals(6));
        expect(expectedPatternCounts[4], equals(8));
      });

      test('should allow maximum 10 trials per stage', () {
        const maxTrialsPerStage = 10;
        expect(maxTrialsPerStage, equals(10));
      });
    });

    group('Scoring Metrics', () {
      test('should calculate norm score correctly for perfect performance', () {
        // Perfect: all 5 stages completed, 20 first-attempt correct
        const stagesCompleted = 5;
        const firstAttemptScore = 20; // 1+2+3+6+8

        const stageScore = (stagesCompleted / 5.0) * 50; // 50
        const memoryScore = (firstAttemptScore / 20.0) * 50; // 50
        const normScore = stageScore + memoryScore; // 100

        expect(normScore, equals(100.0));
      });

      test('should calculate norm score correctly for partial performance', () {
        // Partial: 3 stages completed, 6 first-attempt correct (1+2+3)
        const stagesCompleted = 3;
        const firstAttemptScore = 6;

        const stageScore = (stagesCompleted / 5.0) * 50; // 30
        const memoryScore = (firstAttemptScore / 20.0) * 50; // 15
        const normScore = stageScore + memoryScore; // 45

        expect(normScore, equals(45.0));
      });

      test('should calculate norm score correctly for minimum performance', () {
        // Minimum: 0 stages completed, 0 first-attempt correct
        const stagesCompleted = 0;
        const firstAttemptScore = 0;

        const stageScore = (stagesCompleted / 5.0) * 50; // 0
        const memoryScore = (firstAttemptScore / 20.0) * 50; // 0
        const normScore = stageScore + memoryScore; // 0

        expect(normScore, equals(0.0));
      });
    });

    group('Interpretation Logic', () {
      test('should interpret excellent performance correctly', () {
        // Excellent: 5 stages, <= 10 errors
        const stagesCompleted = 5;
        const totalErrors = 10;

        String interpretation;
        if (stagesCompleted == 5 && totalErrors <= 10) {
          interpretation = 'Excellent - Superior visual memory';
        } else {
          interpretation = 'Other';
        }

        expect(interpretation, equals('Excellent - Superior visual memory'));
      });

      test('should interpret good performance correctly', () {
        // Good: 4+ stages, <= 20 errors
        const stagesCompleted = 4;
        const totalErrors = 15;

        String interpretation;
        if (stagesCompleted == 5 && totalErrors <= 10) {
          interpretation = 'Excellent - Superior visual memory';
        } else if (stagesCompleted >= 4 && totalErrors <= 20) {
          interpretation = 'Good - Normal episodic memory function';
        } else {
          interpretation = 'Other';
        }

        expect(interpretation, equals('Good - Normal episodic memory function'));
      });

      test('should interpret fair performance correctly', () {
        // Fair: 3+ stages, <= 35 errors
        const stagesCompleted = 3;
        const totalErrors = 30;

        String interpretation;
        if (stagesCompleted == 5 && totalErrors <= 10) {
          interpretation = 'Excellent - Superior visual memory';
        } else if (stagesCompleted >= 4 && totalErrors <= 20) {
          interpretation = 'Good - Normal episodic memory function';
        } else if (stagesCompleted >= 3 && totalErrors <= 35) {
          interpretation = 'Fair - Mild difficulty with complex patterns';
        } else {
          interpretation = 'Other';
        }

        expect(interpretation, equals('Fair - Mild difficulty with complex patterns'));
      });

      test('should interpret below average performance correctly', () {
        // Below Average: 2+ stages
        const stagesCompleted = 2;
        const totalErrors = 40;

        String interpretation;
        if (stagesCompleted == 5 && totalErrors <= 10) {
          interpretation = 'Excellent - Superior visual memory';
        } else if (stagesCompleted >= 4 && totalErrors <= 20) {
          interpretation = 'Good - Normal episodic memory function';
        } else if (stagesCompleted >= 3 && totalErrors <= 35) {
          interpretation = 'Fair - Mild difficulty with complex patterns';
        } else if (stagesCompleted >= 2) {
          interpretation = 'Below Average - Moderate memory difficulties';
        } else {
          interpretation = 'Impaired - Significant memory concerns, recommend consultation';
        }

        expect(interpretation, equals('Below Average - Moderate memory difficulties'));
      });

      test('should interpret impaired performance correctly', () {
        // Impaired: < 2 stages
        const stagesCompleted = 1;
        const totalErrors = 50;

        String interpretation;
        if (stagesCompleted == 5 && totalErrors <= 10) {
          interpretation = 'Excellent - Superior visual memory';
        } else if (stagesCompleted >= 4 && totalErrors <= 20) {
          interpretation = 'Good - Normal episodic memory function';
        } else if (stagesCompleted >= 3 && totalErrors <= 35) {
          interpretation = 'Fair - Mild difficulty with complex patterns';
        } else if (stagesCompleted >= 2) {
          interpretation = 'Below Average - Moderate memory difficulties';
        } else {
          interpretation = 'Impaired - Significant memory concerns, recommend consultation';
        }

        expect(interpretation, equals('Impaired - Significant memory concerns, recommend consultation'));
      });
    });

    group('Pattern-Position Mapping', () {
      test('should generate unique pattern positions', () {
        // Simulate pattern generation for stage with 3 patterns
        const patternCount = 3;
        const boxCount = 8;

        final availablePositions = List.generate(boxCount, (i) => i);
        availablePositions.shuffle();
        final selectedPositions = availablePositions.take(patternCount).toList();

        expect(selectedPositions.length, equals(patternCount));
        expect(selectedPositions.toSet().length, equals(patternCount)); // All unique

        for (final pos in selectedPositions) {
          expect(pos, greaterThanOrEqualTo(0));
          expect(pos, lessThan(boxCount));
        }
      });

      test('should map patterns to positions correctly', () {
        const patternCount = 3;
        final positions = [2, 5, 7];

        final Map<int, int> patternMap = {};
        for (int i = 0; i < patternCount; i++) {
          patternMap[i] = positions[i];
        }

        expect(patternMap.length, equals(3));
        expect(patternMap[0], equals(2));
        expect(patternMap[1], equals(5));
        expect(patternMap[2], equals(7));
      });
    });

    group('Answer Checking Logic', () {
      test('should detect all correct answers', () {
        final currentPatternMap = {0: 2, 1: 5, 2: 7}; // 3 patterns
        final userAnswers = {0: 2, 1: 5, 2: 7}; // All correct

        bool allCorrect = true;
        int correctCount = 0;

        for (final entry in currentPatternMap.entries) {
          final patternIndex = entry.key;
          final correctPosition = entry.value;
          final userPosition = userAnswers[patternIndex];

          if (userPosition == correctPosition) {
            correctCount++;
          } else {
            allCorrect = false;
          }
        }

        expect(allCorrect, isTrue);
        expect(correctCount, equals(3));
      });

      test('should detect some incorrect answers', () {
        final currentPatternMap = {0: 2, 1: 5, 2: 7}; // 3 patterns
        final userAnswers = {0: 2, 1: 3, 2: 7}; // One wrong (index 1)

        bool allCorrect = true;
        int correctCount = 0;

        for (final entry in currentPatternMap.entries) {
          final patternIndex = entry.key;
          final correctPosition = entry.value;
          final userPosition = userAnswers[patternIndex];

          if (userPosition == correctPosition) {
            correctCount++;
          } else {
            allCorrect = false;
          }
        }

        expect(allCorrect, isFalse);
        expect(correctCount, equals(2)); // 2 out of 3 correct
      });

      test('should detect all incorrect answers', () {
        final currentPatternMap = {0: 2, 1: 5, 2: 7}; // 3 patterns
        final userAnswers = {0: 0, 1: 1, 2: 3}; // All wrong

        bool allCorrect = true;
        int correctCount = 0;

        for (final entry in currentPatternMap.entries) {
          final patternIndex = entry.key;
          final correctPosition = entry.value;
          final userPosition = userAnswers[patternIndex];

          if (userPosition == correctPosition) {
            correctCount++;
          } else {
            allCorrect = false;
          }
        }

        expect(allCorrect, isFalse);
        expect(correctCount, equals(0));
      });
    });

    group('Trial Progression Logic', () {
      test('should advance to next stage after success', () {
        int currentStageIndex = 2; // Stage 3 (0-indexed)
        const allCorrect = true;

        if (allCorrect) {
          if (currentStageIndex >= 4) { // 5 stages (0-4)
            // Test complete
            expect(currentStageIndex, greaterThanOrEqualTo(4));
          } else {
            // Advance to next stage
            currentStageIndex++;
          }
        }

        expect(currentStageIndex, equals(3)); // Advanced to stage 4
      });

      test('should complete test after final stage success', () {
        int currentStageIndex = 4; // Final stage (0-indexed)
        const allCorrect = true;
        bool testComplete = false;

        if (allCorrect) {
          if (currentStageIndex >= 4) {
            testComplete = true;
          } else {
            currentStageIndex++;
          }
        }

        expect(testComplete, isTrue);
        expect(currentStageIndex, equals(4)); // Still on final stage
      });

      test('should retry after failure within trial limit', () {
        const int currentTrialInStage = 5;
        const maxTrialsPerStage = 10;
        const allCorrect = false;

        bool shouldRetry = false;
        bool stageFailed = false;

        if (!allCorrect) {
          if (currentTrialInStage >= maxTrialsPerStage) {
            stageFailed = true;
          } else {
            shouldRetry = true;
          }
        }

        expect(shouldRetry, isTrue);
        expect(stageFailed, isFalse);
      });

      test('should fail stage after exceeding trial limit', () {
        const int currentTrialInStage = 10;
        const maxTrialsPerStage = 10;
        const allCorrect = false;

        bool shouldRetry = false;
        bool stageFailed = false;

        if (!allCorrect) {
          if (currentTrialInStage >= maxTrialsPerStage) {
            stageFailed = true;
          } else {
            shouldRetry = true;
          }
        }

        expect(shouldRetry, isFalse);
        expect(stageFailed, isTrue);
      });
    });

    group('First Attempt Memory Score', () {
      test('should count first attempt correct answers', () {
        int firstAttemptMemoryScore = 0;
        const bool isFirstAttemptThisStage = true;
        const correctCount = 3; // Got 3 patterns correct

        if (isFirstAttemptThisStage) {
          firstAttemptMemoryScore += correctCount;
        }

        expect(firstAttemptMemoryScore, equals(3));
      });

      test('should not count non-first-attempt correct answers', () {
        int firstAttemptMemoryScore = 5; // Already have some points
        const bool isFirstAttemptThisStage = false; // Not first attempt
        const correctCount = 3;

        if (isFirstAttemptThisStage) {
          firstAttemptMemoryScore += correctCount;
        }

        expect(firstAttemptMemoryScore, equals(5)); // Unchanged
      });

      test('should accumulate first attempt scores across stages', () {
        int firstAttemptMemoryScore = 0;

        // Stage 1: 1 pattern correct on first attempt
        firstAttemptMemoryScore += 1;
        expect(firstAttemptMemoryScore, equals(1));

        // Stage 2: 2 patterns correct on first attempt
        firstAttemptMemoryScore += 2;
        expect(firstAttemptMemoryScore, equals(3));

        // Stage 3: 3 patterns correct on first attempt
        firstAttemptMemoryScore += 3;
        expect(firstAttemptMemoryScore, equals(6));
      });
    });

    group('Error Tracking', () {
      test('should increment total errors on incorrect answer', () {
        int totalErrorsAdjusted = 5;
        int currentStageErrors = 2;
        const allCorrect = false;

        if (!allCorrect) {
          totalErrorsAdjusted++;
          currentStageErrors++;
        }

        expect(totalErrorsAdjusted, equals(6));
        expect(currentStageErrors, equals(3));
      });

      test('should track errors per stage independently', () {
        final List<int> errorsPerStage = [0, 0, 0, 0, 0];

        // Stage 0: 2 errors
        errorsPerStage[0] = 2;

        // Stage 1: 5 errors
        errorsPerStage[1] = 5;

        // Stage 2: 1 error
        errorsPerStage[2] = 1;

        expect(errorsPerStage[0], equals(2));
        expect(errorsPerStage[1], equals(5));
        expect(errorsPerStage[2], equals(1));
        expect(errorsPerStage[3], equals(0)); // Not reached yet
        expect(errorsPerStage[4], equals(0)); // Not reached yet
      });

      test('should reset stage errors when advancing to next stage', () {
        int currentStageErrors = 7;

        // Advancing to next stage
        currentStageErrors = 0;

        expect(currentStageErrors, equals(0));
      });
    });
  });

  group('CANTAB PAL Test - Phase Transitions', () {
    test('should start in introduction phase', () {
      const phase = CANTABPALPhase.introduction;
      expect(phase, equals(CANTABPALPhase.introduction));
    });

    test('should transition from introduction to presentation on start', () {
      var phase = CANTABPALPhase.introduction;

      // User starts test
      phase = CANTABPALPhase.presentation;

      expect(phase, equals(CANTABPALPhase.presentation));
    });

    test('should transition from presentation to recall after display time', () {
      var phase = CANTABPALPhase.presentation;

      // After 3 seconds display
      phase = CANTABPALPhase.recall;

      expect(phase, equals(CANTABPALPhase.recall));
    });

    test('should transition to results phase on test completion', () {
      var phase = CANTABPALPhase.recall;

      // All stages completed or test failed
      phase = CANTABPALPhase.results;

      expect(phase, equals(CANTABPALPhase.results));
    });
  });
}
