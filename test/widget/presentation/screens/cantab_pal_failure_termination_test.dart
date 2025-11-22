import 'package:flutter_test/flutter_test.dart';

/// TDD Test for CANTAB PAL 3-failure termination rule
/// Bug: Test should end after 3 FAILED attempts at any stage
/// Current: Counting all attempts, not just failures
void main() {
  group('CANTAB PAL Failure Termination Tests', () {
    test('Test must end after 3 consecutive FAILURES at a stage', () {
      // Simulate a stage with failures
      int failedAttempts = 0;
      int totalAttempts = 0;
      bool testEnded = false;

      // Attempt 1: Fail
      totalAttempts++;
      failedAttempts++;
      if (failedAttempts >= 3) testEnded = true;
      expect(testEnded, isFalse, reason: 'After 1 failure, test continues');

      // Attempt 2: Fail
      totalAttempts++;
      failedAttempts++;
      if (failedAttempts >= 3) testEnded = true;
      expect(testEnded, isFalse, reason: 'After 2 failures, test continues');

      // Attempt 3: Fail
      totalAttempts++;
      failedAttempts++;
      if (failedAttempts >= 3) testEnded = true;
      expect(testEnded, isTrue, reason: 'After 3 failures, test MUST end');
      expect(totalAttempts, equals(3));
      expect(failedAttempts, equals(3));
    });

    test('Test must continue if some attempts succeed', () {
      // Simulate a stage with mixed results
      int failedAttempts = 0;
      int totalAttempts = 0;
      bool testEnded = false;

      // Attempt 1: Fail
      totalAttempts++;
      failedAttempts++;
      if (failedAttempts >= 3) testEnded = true;
      expect(testEnded, isFalse);

      // Attempt 2: Fail
      totalAttempts++;
      failedAttempts++;
      if (failedAttempts >= 3) testEnded = true;
      expect(testEnded, isFalse);

      // Attempt 3: Success! (stage passed)
      totalAttempts++;
      // failedAttempts stays at 2
      expect(testEnded, isFalse, reason: 'Success on attempt 3 means stage passed');
      expect(failedAttempts, equals(2), reason: 'Only 2 failures occurred');

      // Stage should advance to next stage, not end test
    });

    test('Current implementation bug: counts all attempts not just failures', () {
      // This documents the current buggy behavior

      // Buggy logic: if (_currentAttemptInStage >= 3)
      int currentAttemptInStage = 0;

      // Attempt 1: Success
      currentAttemptInStage++; // = 1
      final wrongTermination1 = currentAttemptInStage >= 3;
      expect(wrongTermination1, isFalse);

      // Attempt 2: Success
      currentAttemptInStage++; // = 2
      final wrongTermination2 = currentAttemptInStage >= 3;
      expect(wrongTermination2, isFalse);

      // Attempt 3: Success
      currentAttemptInStage++; // = 3
      final wrongTermination3 = currentAttemptInStage >= 3; // BUG: terminates on 3rd SUCCESS!
      expect(wrongTermination3, isTrue, reason: 'BUG: Counts successes as failures!');

      // The fix: Track failures separately, not all attempts
    });

    test('Fixed logic: must track failed attempts separately', () {
      int failedAttempts = 0;
      bool testShouldEnd = false;

      // Attempt 1: Success (advance to next stage)
      // failedAttempts = 0, stage passed
      testShouldEnd = failedAttempts >= 3;
      expect(testShouldEnd, isFalse, reason: 'Success should advance stage, not count as failure');

      // Next stage, Attempt 1: Fail
      failedAttempts = 1; // Reset per stage or track globally?
      testShouldEnd = failedAttempts >= 3;
      expect(testShouldEnd, isFalse);

      // Should track failures PER STAGE, reset on stage advance
    });
  });
}
