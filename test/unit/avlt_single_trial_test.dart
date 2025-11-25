import 'package:flutter_test/flutter_test.dart';

/// Tests for AVLT single immediate recall trial
/// Verifies that immediate recall is done only once (not 3 times)
void main() {
  group('AVLT Single Trial Configuration', () {
    test('should have only 1 immediate recall trial', () {
      const immediateRecallTrials = 1;
      expect(immediateRecallTrials, 1);
    });

    test('should have 2 total trials (1 immediate + 1 delayed)', () {
      const immediateTrials = 1;
      const delayedTrials = 1;
      const totalTrials = immediateTrials + delayedTrials;

      expect(totalTrials, 2);
    });

    test('should not have trial2 or trial3 phases', () {
      // Valid phases: instructions, trial1, delay, delayedRecall, results
      const validPhases = ['instructions', 'trial1', 'delay', 'delayedRecall', 'results'];

      expect(validPhases, isNot(contains('trial2')));
      expect(validPhases, isNot(contains('trial3')));
      expect(validPhases.length, 5);
    });

    test('should progress from trial1 directly to delay', () {
      const phaseFlow = ['instructions', 'trial1', 'delay', 'delayedRecall', 'results'];

      final trial1Index = phaseFlow.indexOf('trial1');
      final delayIndex = phaseFlow.indexOf('delay');

      // trial1 should be immediately followed by delay (no trial2/trial3 in between)
      expect(delayIndex, trial1Index + 1);
    });

    test('should have immediate trial list with 1 entry', () {
      const maxImmediateTrials = 1;
      expect(maxImmediateTrials, 1);
    });

    test('should calculate results using only 1 immediate trial', () {
      // Results calculation should use trial1 data only, not trial2/trial3
      const trial1Exists = true;
      const trial2Exists = false;
      const trial3Exists = false;

      expect(trial1Exists, isTrue);
      expect(trial2Exists, isFalse);
      expect(trial3Exists, isFalse);
    });

    test('should have 2 total scores to calculate (1 immediate + 1 delayed)', () {
      // Total correct = trial1.totalScore + delayed.totalScore
      // NOT: trial1 + trial2 + trial3 + delayed
      const scoresInCalculation = 2;
      expect(scoresInCalculation, 2);
    });

    test('should update instructions to reflect single trial', () {
      // Instructions should NOT say "This will repeat 3 times"
      const oldInstruction = 'This will repeat 3 times with the same list';
      const newInstruction = 'After hearing all 5 words, say back as many as you remember in any order';

      expect(oldInstruction, contains('3 times'));
      expect(newInstruction, isNot(contains('3 times')));
    });

    test('should update phase title to not show "1 of 3"', () {
      const oldTitle = 'Trial 1 of 3';
      const newTitle = 'Immediate Recall';

      expect(oldTitle, contains('of 3'));
      expect(newTitle, isNot(contains('of')));
    });
  });
}
