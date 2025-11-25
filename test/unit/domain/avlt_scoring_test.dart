import 'package:brain_tests/domain/services/avlt_scoring_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for Audio Verbal Learning Test (AVLT) dual scoring logic
/// Added on 2024-11-24
///
/// Tests both scoring metrics:
/// 1. Serial Position Score: Words in correct position (strict)
/// 2. Total Recall Score: Words recalled regardless of position (lenient)
///
/// Allows "skip" as placeholder to maintain position for subsequent words
void main() {
  group('AVLT Scoring Logic', () {
    group('Serial Position Scoring', () {
      test('perfect recall - all words in correct positions', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);

        expect(serialScore, 5, reason: 'All 5 words in correct positions');
      });

      test('partial serial recall - some words in correct positions', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'TABLE', 'ENGINEER', 'COW', 'FIRE'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);

        // APPLE (position 0) ✓, ENGINEER (position 2) ✓, FIRE (position 4) ✓
        expect(serialScore, 3, reason: 'Positions 0, 2, 4 are correct');
      });

      test('no serial recall - all words in wrong positions', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['FIRE', 'TABLE', 'COW', 'APPLE', 'ENGINEER'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);

        expect(serialScore, 0, reason: 'No words in correct positions');
      });

      test('handles "skip" keyword - maintains position for later words', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'COW', 'ENGINEER', 'SKIP', 'FIRE'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);

        // APPLE ✓, COW ✓, ENGINEER ✓, FIRE ✓ (skip maintains position)
        expect(serialScore, 4, reason: 'Skip maintains position, FIRE stays at position 4');
      });

      test('multiple skips maintain positions', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['SKIP', 'COW', 'SKIP', 'TABLE', 'FIRE'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);

        // COW ✓, TABLE ✓, FIRE ✓
        expect(serialScore, 3, reason: 'Skips maintain positions for later words');
      });

      test('wrong word acts like skip for serial position', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'COW', 'ENGINEER', 'BANANA', 'FIRE'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);

        // APPLE ✓, COW ✓, ENGINEER ✓, FIRE ✓ (BANANA maintains position)
        expect(serialScore, 4, reason: 'Wrong word maintains position like skip');
      });

      test('case insensitive matching', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['apple', 'cow', 'engineer', 'table', 'fire'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);

        expect(serialScore, 5, reason: 'Case should not matter');
      });

      test('empty user response scores 0', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = <String>[];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);

        expect(serialScore, 0, reason: 'No words provided');
      });

      test('partial response with fewer words', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'COW', 'ENGINEER'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);

        expect(serialScore, 3, reason: 'First 3 words correct');
      });

      test('partial response with more words than target', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE', 'EXTRA', 'WORDS'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);

        expect(serialScore, 5, reason: 'Only first 5 words counted');
      });
    });

    group('Total Recall Scoring', () {
      test('perfect recall - all words recalled regardless of position', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['FIRE', 'TABLE', 'COW', 'APPLE', 'ENGINEER'];

        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(totalScore, 5, reason: 'All 5 words recalled');
      });

      test('partial recall - some words missing', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'COW', 'BANANA', 'ORANGE'];

        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(totalScore, 2, reason: 'Only APPLE and COW are from target list');
      });

      test('"skip" keyword does not count as recall', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'COW', 'SKIP', 'TABLE', 'FIRE'];

        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(totalScore, 4, reason: 'Skip does not count, 4 real words recalled');
      });

      test('duplicate words only counted once', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'APPLE', 'COW', 'COW', 'ENGINEER'];

        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(totalScore, 3, reason: 'APPLE, COW, ENGINEER counted once each');
      });

      test('case insensitive matching', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['apple', 'cow', 'engineer', 'table', 'fire'];

        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(totalScore, 5, reason: 'Case should not matter');
      });

      test('empty user response scores 0', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = <String>[];

        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(totalScore, 0, reason: 'No words provided');
      });

      test('all wrong words scores 0', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['BANANA', 'ORANGE', 'GRAPE', 'PEACH', 'MANGO'];

        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(totalScore, 0, reason: 'No target words recalled');
      });

      test('mixed correct and wrong words', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'BANANA', 'COW', 'ORANGE', 'FIRE'];

        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(totalScore, 3, reason: 'APPLE, COW, FIRE are correct');
      });
    });

    group('Dual Scoring Comparison', () {
      test('serial score should be <= total score', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];

        // Test case 1: Wrong order
        final userWords1 = ['FIRE', 'TABLE', 'COW', 'APPLE', 'ENGINEER'];
        final serial1 = calculateSerialPositionScore(targetWords, userWords1);
        final total1 = calculateTotalRecallScore(targetWords, userWords1);
        expect(serial1, lessThanOrEqualTo(total1),
            reason: 'Serial score cannot exceed total score');

        // Test case 2: With skip
        final userWords2 = ['APPLE', 'COW', 'SKIP', 'TABLE', 'FIRE'];
        final serial2 = calculateSerialPositionScore(targetWords, userWords2);
        final total2 = calculateTotalRecallScore(targetWords, userWords2);
        expect(serial2, lessThanOrEqualTo(total2),
            reason: 'Serial score cannot exceed total score with skip');
      });

      test('example from user: APPLE, COW, ENGINEER, SKIP, FIRE', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'COW', 'ENGINEER', 'SKIP', 'FIRE'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);
        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(serialScore, 4, reason: 'APPLE, COW, ENGINEER, FIRE in correct positions');
        expect(totalScore, 4, reason: 'APPLE, COW, ENGINEER, FIRE recalled (skip not counted)');
      });

      test('example from user: APPLE, COW, ENGINEER, FIRE (no skip)', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'COW', 'ENGINEER', 'FIRE'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);
        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        // Serial: APPLE ✓, COW ✓, ENGINEER ✓, FIRE ✗ (position 3 vs 4)
        expect(serialScore, 3, reason: 'APPLE, COW, ENGINEER in correct positions, FIRE is not');
        expect(totalScore, 4, reason: 'All 4 words recalled');
      });
    });

    group('Edge Cases', () {
      test('whitespace trimming', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['  APPLE  ', ' COW', 'ENGINEER ', '  TABLE  ', 'FIRE'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);
        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(serialScore, 5, reason: 'Whitespace should be trimmed');
        expect(totalScore, 5, reason: 'Whitespace should be trimmed');
      });

      test('mixed case skip keyword', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APPLE', 'skip', 'ENGINEER', 'Skip', 'FIRE'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);
        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(serialScore, 3, reason: 'Skip case-insensitive, APPLE, ENGINEER, FIRE correct');
        expect(totalScore, 3, reason: 'Skip not counted');
      });

      test('partial words should not match', () {
        final targetWords = ['APPLE', 'COW', 'ENGINEER', 'TABLE', 'FIRE'];
        final userWords = ['APP', 'CO', 'ENG', 'TAB', 'FIR'];

        final serialScore = calculateSerialPositionScore(targetWords, userWords);
        final totalScore = calculateTotalRecallScore(targetWords, userWords);

        expect(serialScore, 0, reason: 'Partial words should not match');
        expect(totalScore, 0, reason: 'Partial words should not match');
      });
    });
  });

  group('Learning Slope Calculation', () {
    test('positive learning slope - improvement from trial 1 to 3', () {
      final trial1Total = 2;
      final trial3Total = 4;

      final learningSlope = calculateLearningSlope(trial1Total, trial3Total);

      expect(learningSlope, 2.0, reason: 'Improved by 2 words');
    });

    test('zero learning slope - no improvement', () {
      final trial1Total = 3;
      final trial3Total = 3;

      final learningSlope = calculateLearningSlope(trial1Total, trial3Total);

      expect(learningSlope, 0.0, reason: 'No improvement');
    });

    test('negative learning slope - performance declined', () {
      final trial1Total = 4;
      final trial3Total = 2;

      final learningSlope = calculateLearningSlope(trial1Total, trial3Total);

      expect(learningSlope, -2.0, reason: 'Declined by 2 words');
    });
  });

  group('Retention Percentage Calculation', () {
    test('perfect retention - delayed equals trial 3', () {
      final trial3Total = 4;
      final delayedTotal = 4;

      final retention = calculateRetentionPercentage(trial3Total, delayedTotal);

      expect(retention, 100.0, reason: '100% retention');
    });

    test('partial retention', () {
      final trial3Total = 4;
      final delayedTotal = 2;

      final retention = calculateRetentionPercentage(trial3Total, delayedTotal);

      expect(retention, 50.0, reason: '50% retention');
    });

    test('zero retention', () {
      final trial3Total = 4;
      final delayedTotal = 0;

      final retention = calculateRetentionPercentage(trial3Total, delayedTotal);

      expect(retention, 0.0, reason: '0% retention');
    });

    test('handles zero trial 3 score', () {
      final trial3Total = 0;
      final delayedTotal = 0;

      final retention = calculateRetentionPercentage(trial3Total, delayedTotal);

      expect(retention, 0.0, reason: 'Cannot retain if nothing learned');
    });

    test('retention can exceed 100% if delayed > trial 3', () {
      final trial3Total = 3;
      final delayedTotal = 4;

      final retention = calculateRetentionPercentage(trial3Total, delayedTotal);

      expect(retention, greaterThan(100.0), reason: 'Improved after delay');
    });
  });
}
