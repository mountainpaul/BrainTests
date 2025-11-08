import 'package:brain_plan/domain/services/cambridge_test_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CambridgeTestGenerator', () {
    group('PAL Trial Generation', () {
      test('should generate PAL trial with correct stage parameters', () {
        final trial = CambridgeTestGenerator.generatePALTrial(0);

        expect(trial.stage, equals(0));
        expect(trial.numPatterns, equals(1)); // Stage 0 = 1 pattern
        expect(trial.gridSize, equals(6)); // Early stages use 2x3 grid
        expect(trial.patternPositions.length, equals(1));
      });

      test('should increase patterns with stage number', () {
        final trial1 = CambridgeTestGenerator.generatePALTrial(0);
        final trial2 = CambridgeTestGenerator.generatePALTrial(2);
        final trial3 = CambridgeTestGenerator.generatePALTrial(7);

        expect(trial1.numPatterns, equals(1));
        expect(trial2.numPatterns, equals(3));
        expect(trial3.numPatterns, equals(8)); // Max 8 patterns
      });

      test('should use larger grid for later stages', () {
        final earlyTrial = CambridgeTestGenerator.generatePALTrial(2);
        final lateTrial = CambridgeTestGenerator.generatePALTrial(5);

        expect(earlyTrial.gridSize, equals(6)); // Stage < 4
        expect(lateTrial.gridSize, equals(8)); // Stage >= 4
      });

      test('should generate unique positions for patterns', () {
        final trial = CambridgeTestGenerator.generatePALTrial(5);

        final positions = trial.patternPositions.values.toSet();
        expect(positions.length, equals(trial.numPatterns)); // All unique
      });
    });

    group('RVP Sequence Generation', () {
      test('should generate sequence with correct duration', () {
        final sequence = CambridgeTestGenerator.generateRVPSequence(60);

        // At 100 digits/min, 60 seconds = 100 digits
        expect(sequence.digits.length, greaterThan(90));
        expect(sequence.digits.length, lessThan(110));
        expect(sequence.intervalMs, equals(600));
      });

      test('should embed target sequences for 7-minute test', () {
        // Generate a 7-minute test sequence
        final sequence = CambridgeTestGenerator.generateRVPSequence(420);

        // Should have ~700 digits (420 seconds / 0.6s per digit)
        expect(sequence.digits.length, greaterThan(650));
        expect(sequence.digits.length, lessThan(750));

        // Should have approximately 12 target sequences (420 / 35 = 12)
        expect(sequence.targetIndices.length, greaterThan(8));
        expect(sequence.targetIndices.length, lessThan(16));
      });

      test('should embed target sequences for 1-minute practice', () {
        // Generate a 1-minute practice sequence
        final sequence = CambridgeTestGenerator.generateRVPSequence(60);

        // Should have ~100 digits (60 seconds / 0.6s per digit)
        expect(sequence.digits.length, greaterThan(90));
        expect(sequence.digits.length, lessThan(110));

        // Should have approximately 1-2 target sequences (60 / 35 = 1.7)
        expect(sequence.targetIndices.length, greaterThanOrEqualTo(1));
        expect(sequence.targetIndices.length, lessThan(4));
      });

      test('target sequences should be correctly embedded as 3-5-7 or 2-4-6', () {
        // Generate multiple sequences to test consistency
        for (int i = 0; i < 5; i++) {
          final sequence = CambridgeTestGenerator.generateRVPSequence(420);

          // Verify each target index actually points to the end of a valid sequence
          for (final targetIdx in sequence.targetIndices) {
            // Target index should be at least 2 (positions 0, 1, 2 for a 3-digit sequence)
            expect(targetIdx, greaterThanOrEqualTo(2));

            // Get the 3 digits that form the sequence
            final digit1 = sequence.digits[targetIdx - 2];
            final digit2 = sequence.digits[targetIdx - 1];
            final digit3 = sequence.digits[targetIdx];

            // Should be either 3-5-7 or 2-4-6
            final isValid = (digit1 == 3 && digit2 == 5 && digit3 == 7) ||
                (digit1 == 2 && digit2 == 4 && digit3 == 6);

            expect(
              isValid,
              isTrue,
              reason:
                  'Target at index $targetIdx has sequence $digit1-$digit2-$digit3, which is not 3-5-7 or 2-4-6',
            );
          }
        }
      });

      test('target sequences should be spaced appropriately', () {
        // Generate a sequence
        final sequence = CambridgeTestGenerator.generateRVPSequence(420);

        // Convert to list and sort for easier analysis
        final sortedTargets = sequence.targetIndices.toList()..sort();

        // Check spacing between consecutive targets
        for (int i = 1; i < sortedTargets.length; i++) {
          final spacing = sortedTargets[i] - sortedTargets[i - 1];

          // Targets should be at least 15 digits apart (as per implementation)
          expect(
            spacing,
            greaterThanOrEqualTo(15),
            reason:
                'Targets at indices ${sortedTargets[i - 1]} and ${sortedTargets[i]} are only $spacing digits apart',
          );
        }
      });

      test('should not have targets too close to start or end', () {
        final sequence = CambridgeTestGenerator.generateRVPSequence(420);

        for (final targetIdx in sequence.targetIndices) {
          // Targets should be at least 10 digits from start (as per implementation)
          expect(targetIdx, greaterThanOrEqualTo(12));

          // Targets should be at least 10 digits from end
          expect(targetIdx, lessThan(sequence.digits.length - 10));
        }
      });

      test('all digits should be 0-9', () {
        final sequence = CambridgeTestGenerator.generateRVPSequence(60);

        for (final digit in sequence.digits) {
          expect(digit, greaterThanOrEqualTo(0));
          expect(digit, lessThanOrEqualTo(9));
        }
      });
    });

    group('RTI Trial Generation', () {
      test('simple mode should have 1 position', () {
        final trial = CambridgeTestGenerator.generateRTITrial(RTIMode.simple, 1);

        expect(trial.mode, equals(RTIMode.simple));
        expect(trial.numPositions, equals(1));
        expect(trial.targetPosition, equals(0));
      });

      test('choice mode should have 5 positions', () {
        final trial = CambridgeTestGenerator.generateRTITrial(RTIMode.choice, 1);

        expect(trial.mode, equals(RTIMode.choice));
        expect(trial.numPositions, equals(5));
        expect(trial.targetPosition, greaterThanOrEqualTo(0));
        expect(trial.targetPosition, lessThan(5));
      });

      test('should have random delay between 1-3 seconds', () {
        final trial = CambridgeTestGenerator.generateRTITrial(RTIMode.simple, 1);

        expect(trial.delayMs, greaterThanOrEqualTo(1000));
        expect(trial.delayMs, lessThan(3000));
      });
    });

    group('SWM Trial Generation', () {
      test('should generate trial with specified number of boxes', () {
        final trial = CambridgeTestGenerator.generateSWMTrial(4);

        expect(trial.numBoxes, equals(4));
        expect(trial.boxPositions.length, equals(4));
      });

      test('should have unique box positions', () {
        final trial = CambridgeTestGenerator.generateSWMTrial(6);

        final uniquePositions = trial.boxPositions.toSet();
        expect(uniquePositions.length, equals(6));
      });

      test('should calculate between errors correctly', () {
        final trial = CambridgeTestGenerator.generateSWMTrial(4);

        // Initially no errors
        expect(trial.betweenErrors, equals(0));
      });

      test('should calculate strategy score', () {
        final trial = CambridgeTestGenerator.generateSWMTrial(4);

        // Strategy score should be in valid range (1-46)
        expect(trial.strategyScore, greaterThanOrEqualTo(0));
        expect(trial.strategyScore, lessThanOrEqualTo(46));
      });
    });

    group('PRM Trial Generation', () {
      test('should generate study and test patterns', () {
        final trial = CambridgeTestGenerator.generatePRMTrial(12);

        expect(trial.studyPatterns.length, equals(12));
        expect(trial.testPatterns.length, equals(12)); // Half old, half new
      });

      test('test patterns should be mixed old and new', () {
        final trial = CambridgeTestGenerator.generatePRMTrial(12);

        final oldPatterns = trial.testPatterns.where((p) => p.isOld).length;
        final newPatterns = trial.testPatterns.where((p) => !p.isOld).length;

        expect(oldPatterns, equals(6));
        expect(newPatterns, equals(6));
      });

      test('pattern should have visual representation', () {
        final trial = CambridgeTestGenerator.generatePRMTrial(4);

        for (final pattern in trial.studyPatterns) {
          expect(pattern.visualRepresentation.isNotEmpty, isTrue);
        }
      });

      test('test patterns should have visual properties (shape, color, size)', () {
        final trial = CambridgeTestGenerator.generatePRMTrial(12);

        // All test patterns must have visual properties
        for (final pattern in trial.testPatterns) {
          expect(pattern.shape, isNotNull,
              reason: 'Test pattern ${pattern.patternId} missing shape property');
          expect(pattern.color, isNotNull,
              reason: 'Test pattern ${pattern.patternId} missing color property');
          expect(pattern.size, isNotNull,
              reason: 'Test pattern ${pattern.patternId} missing size property');
        }
      });

      test('old test patterns should match study pattern visual properties', () {
        final trial = CambridgeTestGenerator.generatePRMTrial(12);

        final oldTestPatterns = trial.testPatterns.where((p) => p.isOld).toList();

        for (final testPattern in oldTestPatterns) {
          // Find corresponding study pattern
          final studyPattern = trial.studyPatterns.firstWhere(
            (p) => p.patternId == testPattern.patternId,
          );

          expect(testPattern.shape, equals(studyPattern.shape),
              reason: 'Old test pattern should have same shape as study pattern');
          expect(testPattern.color, equals(studyPattern.color),
              reason: 'Old test pattern should have same color as study pattern');
          expect(testPattern.size, equals(studyPattern.size),
              reason: 'Old test pattern should have same size as study pattern');
        }
      });

      test('should generate unique patterns using true random seed', () {
        final trial1 = CambridgeTestGenerator.generatePRMTrial(12);
        final trial2 = CambridgeTestGenerator.generatePRMTrial(12);

        // Different trials should have different patterns (with very high probability)
        bool allSame = true;
        for (int i = 0; i < trial1.studyPatterns.length; i++) {
          if (trial1.studyPatterns[i].shape != trial2.studyPatterns[i].shape ||
              trial1.studyPatterns[i].color != trial2.studyPatterns[i].color) {
            allSame = false;
            break;
          }
        }
        expect(allSame, isFalse,
            reason: 'Patterns should be randomly generated, not deterministic');
      });

      test('should have sufficient pattern variety (more than 48 combinations)', () {
        // Generate a large sample to check variety
        final patterns = <String>{};
        for (int i = 0; i < 100; i++) {
          final trial = CambridgeTestGenerator.generatePRMTrial(12);
          for (final pattern in trial.studyPatterns) {
            final key = '${pattern.shape}_${pattern.color}_${pattern.size}';
            patterns.add(key);
          }
        }

        // Should have significantly more than 48 unique patterns
        expect(patterns.length, greaterThan(100),
            reason: 'Should support more than 48 unique pattern combinations');
      });

      test('patterns should use abstract CANTAB-style visual representation', () {
        final trial = CambridgeTestGenerator.generatePRMTrial(4);

        for (final pattern in trial.studyPatterns) {
          // visualRepresentation should be non-empty and contain pattern data
          expect(pattern.visualRepresentation, isNotEmpty);
          // Should have format like "P0_C0_V0" indicating pattern, color, variation
          expect(pattern.visualRepresentation, matches(RegExp(r'P\d+_C\d+_V\d+')),
              reason: 'Should use CANTAB-style abstract pattern notation');
        }
      });
    });
  });
}
