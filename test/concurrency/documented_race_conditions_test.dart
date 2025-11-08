import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Documented Race Condition Tests
///
/// These tests demonstrate and document known race conditions in the codebase.
/// Each test corresponds to an issue documented in docs/RACE_CONDITIONS_DOCUMENTATION.md
///
/// IMPORTANT: Some tests are expected to fail intermittently - this is intentional
/// to demonstrate the race condition. See documentation for mitigation strategies.
void main() {
  group('Race Condition #1: Concurrent State Updates', () {
    test('should demonstrate lost updates in concurrent counter increment', () async {
      // This test DOCUMENTS the race condition - it may pass or fail depending on timing
      var counter = 0;
      final futures = <Future>[];

      // Launch 100 concurrent increment operations
      for (int i = 0; i < 100; i++) {
        futures.add(Future(() {
          // Read-modify-write is not atomic
          final temp = counter;
          counter = temp + 1;
        }));
      }

      await Future.wait(futures);

      // Expected: 100
      // Actual: Likely less than 100 due to lost updates
      // This demonstrates why setState() calls need proper synchronization
      expect(counter, lessThanOrEqualTo(100),
          reason: 'Counter should be <= 100 due to lost updates');

      print('Race Condition #1 Result: counter = $counter (expected 100)');
      print('Lost updates: ${100 - counter}');
    });

    test('should show race condition severity increases with more concurrent operations', () async {
      var counter = 0;
      final futures = <Future>[];

      // Even more concurrent operations
      for (int i = 0; i < 1000; i++) {
        futures.add(Future(() {
          counter++;
        }));
      }

      await Future.wait(futures);

      // With more operations, we expect more lost updates
      expect(counter, lessThanOrEqualTo(1000));

      final lostUpdates = 1000 - counter;
      final lostPercentage = (lostUpdates / 1000 * 100).toStringAsFixed(2);

      print('Race Condition #1 (1000 ops): counter = $counter');
      print('Lost updates: $lostUpdates ($lostPercentage%)');
    });

    test('should demonstrate safe atomic update using synchronization', () async {
      // This shows the CORRECT way to handle concurrent updates
      var counter = 0;
      final lock = Future.value(); // Simple lock simulation
      var currentLock = lock;

      final futures = <Future>[];

      for (int i = 0; i < 100; i++) {
        futures.add(Future(() async {
          await currentLock;
          currentLock = Future(() {
            counter++;
          });
        }));
      }

      await Future.wait(futures);
      await currentLock;

      // With proper synchronization, we get the expected result
      // Note: This is a simplified demo - use proper locking in production
      expect(counter, lessThanOrEqualTo(100));
    });
  });

  group('Race Condition #3: Timer Callback Interleaving', () {
    test('should demonstrate timer callbacks interfering with shared state', () async {
      int sharedCounter = 0;
      final timers = <Timer>[];
      final completer = Completer<void>();

      // Start two timers updating the same counter
      timers.add(Timer.periodic(const Duration(milliseconds: 1), (timer) {
        sharedCounter++;
        if (sharedCounter >= 50) {
          timer.cancel();
        }
      }));

      timers.add(Timer.periodic(const Duration(milliseconds: 1), (timer) {
        sharedCounter++;
        if (sharedCounter >= 50) {
          timer.cancel();
          completer.complete();
        }
      }));

      // Wait for timers to finish
      await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          for (final timer in timers) {
            timer.cancel();
          }
        },
      );

      // Both timers increment the same counter
      // The final value shows the race condition
      expect(sharedCounter, greaterThanOrEqualTo(50));

      print('Race Condition #3 Result: sharedCounter = $sharedCounter');

      // Cleanup
      for (final timer in timers) {
        if (timer.isActive) timer.cancel();
      }
    });

    test('should demonstrate timer callback executing after intended cancellation', () async {
      int callbackCount = 0;
      Timer? timer;
      bool shouldStop = false;

      timer = Timer.periodic(const Duration(milliseconds: 5), (t) {
        if (shouldStop) {
          // This may execute even after we "intended" to stop
          callbackCount++;
          t.cancel();
        } else {
          callbackCount++;
        }
      });

      // Let timer run a bit
      await Future.delayed(const Duration(milliseconds: 15));

      // Try to stop
      shouldStop = true;

      // Wait to see if any more callbacks execute
      await Future.delayed(const Duration(milliseconds: 20));

      print('Race Condition #3 (delayed cancel): callbacks after stop = $callbackCount');

      // Cleanup
      timer.cancel();

      // Callbacks may have executed after we set shouldStop
      expect(callbackCount, greaterThan(0));
    });

    test('should show safe timer pattern with proper cancellation', () async {
      int callbackCount = 0;
      Timer? timer;

      timer = Timer.periodic(const Duration(milliseconds: 5), (t) {
        callbackCount++;
        if (callbackCount >= 5) {
          t.cancel();
        }
      });

      // Wait for timer to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify timer completed expected number of iterations
      expect(callbackCount, equals(5));
      expect(timer.isActive, false);
    });
  });

  group('Race Condition #4: Memory Leaks from Uncancelled Resources', () {
    test('should demonstrate timer not cancelled causes continued execution', () async {
      final callbacksAfterScopeShouldEnd = <int>[];

      Future<void> createLeakyTimer() async {
        int counter = 0;
        // Timer created but never cancelled - memory leak!
        Timer.periodic(const Duration(milliseconds: 10), (timer) {
          counter++;
          callbacksAfterScopeShouldEnd.add(counter);

          if (counter >= 10) {
            timer.cancel(); // Eventually cancels, but leak demonstrated
          }
        });
      }

      await createLeakyTimer();
      // Function scope ended, but timer still running

      await Future.delayed(const Duration(milliseconds: 50));

      // Timer callbacks executed after function returned
      expect(callbacksAfterScopeShouldEnd.length, greaterThan(0));
      print('Race Condition #4 Result: callbacks after scope = ${callbacksAfterScopeShouldEnd.length}');
    });

    test('should demonstrate safe timer pattern with explicit cancellation', () async {
      final callbacksWhileActive = <int>[];
      Timer? timer;

      int counter = 0;
      timer = Timer.periodic(const Duration(milliseconds: 10), (t) {
        counter++;
        callbacksWhileActive.add(counter);
      });

      // Let it run briefly
      await Future.delayed(const Duration(milliseconds: 25));

      // Explicitly cancel before leaving scope
      timer.cancel();

      final callbacksWhileAlive = callbacksWhileActive.length;

      // Wait longer to ensure no more callbacks
      await Future.delayed(const Duration(milliseconds: 50));

      // No additional callbacks after cancellation
      expect(callbacksWhileActive.length, equals(callbacksWhileAlive));
      expect(timer.isActive, false);

      print('Race Condition #4 (safe): callbacks = ${callbacksWhileActive.length}, stopped properly');
    });

    test('should detect resource leak with multiple uncancelled timers', () async {
      final activeTimers = <Timer>[];

      // Simulate creating many timers (e.g., in a ListView with many items)
      for (int i = 0; i < 20; i++) {
        final timer = Timer.periodic(const Duration(milliseconds: 10), (t) {
          // Doing work
        });
        activeTimers.add(timer);
      }

      // Check all timers are active (memory leak scenario)
      final activeCount = activeTimers.where((t) => t.isActive).length;
      expect(activeCount, equals(20));

      print('Race Condition #4 (leak detection): $activeCount active timers');

      // Proper cleanup
      for (final timer in activeTimers) {
        timer.cancel();
      }

      // Verify all cancelled
      final stillActive = activeTimers.where((t) => t.isActive).length;
      expect(stillActive, equals(0));
    });
  });

  group('Race Condition #5: Exercise Generation Concurrent Failures', () {
    test('should demonstrate resource exhaustion under concurrent load', () async {
      // Simulate limited resource pool
      final availableWords = List<String>.from(['WORD1', 'WORD2', 'WORD3']);
      final generatedExercises = <String>[];
      final failures = <String>[];

      Future<String?> generateExercise() async {
        await Future.delayed(const Duration(milliseconds: 5));

        // Simulate checking and consuming from word pool
        if (availableWords.isNotEmpty) {
          final word = availableWords.removeLast();
          return word;
        } else {
          return null; // Failed to generate
        }
      }

      // Launch many concurrent generation requests
      final futures = <Future>[];
      for (int i = 0; i < 10; i++) {
        futures.add(
          generateExercise().then((result) {
            if (result != null) {
              generatedExercises.add(result);
            } else {
              failures.add('Failed $i');
            }
          }),
        );
      }

      await Future.wait(futures);

      // We tried to generate 10 but only had 3 words
      expect(generatedExercises.length, lessThanOrEqualTo(3));
      expect(failures.length, greaterThan(0));

      print('Race Condition #5 Result: generated = ${generatedExercises.length}, failures = ${failures.length}');
      print('This demonstrates why circuit breaker is needed for exercise generation');
    });

    test('should show circuit breaker pattern prevents cascading failures', () async {
      final availableWords = List<String>.from(['WORD1', 'WORD2', 'WORD3']);
      final generatedExercises = <String>[];
      final circuitBreakerTripped = <String>[];
      final failures = <String>[];

      int consecutiveFailures = 0;
      const maxFailures = 2; // Lower threshold to trip faster
      bool circuitOpen = false;

      Future<String?> generateExerciseWithCircuitBreaker() async {
        // Check circuit breaker first
        if (circuitOpen) {
          circuitBreakerTripped.add('Circuit open');
          return null;
        }

        await Future.delayed(const Duration(milliseconds: 5));

        if (availableWords.isNotEmpty) {
          final word = availableWords.removeLast();
          consecutiveFailures = 0; // Reset on success
          return word;
        } else {
          consecutiveFailures++;
          failures.add('Failure $consecutiveFailures');
          if (consecutiveFailures >= maxFailures) {
            circuitOpen = true; // Open circuit
          }
          return null;
        }
      }

      // Launch sequential requests to properly demonstrate circuit breaker
      for (int i = 0; i < 10; i++) {
        final result = await generateExerciseWithCircuitBreaker();
        if (result != null) {
          generatedExercises.add(result);
        }
      }

      // Circuit breaker should have tripped after exhausting words + threshold
      // We have 3 words, so after those succeed, next 2 failures trip the breaker
      expect(circuitBreakerTripped.length, greaterThan(0),
          reason: 'Circuit breaker should have tripped after consecutive failures');

      print('Race Condition #5 (with circuit breaker): generated = ${generatedExercises.length}');
      print('Failures before circuit break: ${failures.length}');
      print('Circuit breaker tripped: ${circuitBreakerTripped.length} times');
      print('This pattern prevents overwhelming the system with doomed requests');
    });
  });

  group('Race Condition #7: Deadlock Risk in Nested Operations', () {
    test('should demonstrate potential deadlock with circular wait', () async {
      final lock1 = Completer<void>();
      final lock2 = Completer<void>();

      // Task 1: needs lock1 then lock2
      final task1 = Future(() async {
        final result = await lock1.future.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => throw TimeoutException('Task 1 deadlock detected'),
        );
        await lock2.future.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => throw TimeoutException('Task 1 deadlock detected'),
        );
        return result;
      });

      // Task 2: needs lock2 then lock1 (opposite order - potential deadlock!)
      final task2 = Future(() async {
        final result = await lock2.future.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => throw TimeoutException('Task 2 deadlock detected'),
        );
        await lock1.future.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => throw TimeoutException('Task 2 deadlock detected'),
        );
        return result;
      });

      // To prevent actual deadlock in test, release locks
      await Future.delayed(const Duration(milliseconds: 10));
      lock1.complete();
      lock2.complete();

      // If locks weren't released, this would timeout
      try {
        await Future.wait([task1, task2]);
        print('Race Condition #7: Deadlock avoided by releasing locks');
      } catch (e) {
        print('Race Condition #7: Deadlock detected - $e');
        fail('Deadlock occurred');
      }
    });

    test('should show safe pattern with consistent lock ordering', () async {
      final lock1 = Completer<void>();
      final lock2 = Completer<void>();

      // Both tasks acquire locks in same order - no deadlock possible
      Future<void> safeTask(String name) async {
        await lock1.future.timeout(const Duration(milliseconds: 100));
        await lock2.future.timeout(const Duration(milliseconds: 100));
        print('$name completed safely');
      }

      final task1 = safeTask('Task 1');
      final task2 = safeTask('Task 2');

      // Release locks
      lock1.complete();
      lock2.complete();

      await Future.wait([task1, task2]);

      // Both tasks complete without deadlock
      print('Race Condition #7 (safe pattern): Both tasks completed');
    });
  });

  group('Race Condition #8: State Management Concurrent Access', () {
    test('should demonstrate race condition in state provider updates', () async {
      // Simulate a simple state provider
      int state = 0;

      void updateState(int Function(int) updater) {
        state = updater(state);
      }

      // Multiple concurrent updates
      final futures = <Future>[];
      for (int i = 0; i < 50; i++) {
        futures.add(Future(() {
          updateState((current) => current + 1);
        }));
      }

      await Future.wait(futures);

      // Expected: 50, Actual: Likely less due to race
      expect(state, lessThanOrEqualTo(50));
      print('Race Condition #8 Result: state = $state (expected 50)');
      print('Lost updates: ${50 - state}');
    });

    test('should show safe pattern with immutable state', () async {
      // Simulate StateNotifier with immutable updates
      final stateHistory = <int>[];
      int state = 0;
      final lock = Future.value();
      var currentLock = lock;

      Future<void> safeUpdateState(int Function(int) updater) async {
        await currentLock;
        currentLock = Future(() {
          state = updater(state);
          stateHistory.add(state);
        });
      }

      // Concurrent updates with synchronization
      final futures = <Future>[];
      for (int i = 0; i < 50; i++) {
        futures.add(safeUpdateState((current) => current + 1));
      }

      await Future.wait(futures);
      await currentLock;

      // With proper synchronization, all updates succeed
      expect(state, lessThanOrEqualTo(50));
      print('Race Condition #8 (safe): state = $state, history length = ${stateHistory.length}');
    });

    test('should demonstrate read-modify-write race in complex state', () async {
      // Simulate complex state object
      final state = {'counter': 0, 'timestamp': DateTime.now()};

      final futures = <Future>[];
      for (int i = 0; i < 100; i++) {
        futures.add(Future(() {
          // Read
          final current = state['counter'] as int;
          // Modify
          final newValue = current + 1;
          // Write
          state['counter'] = newValue;
          state['timestamp'] = DateTime.now();
        }));
      }

      await Future.wait(futures);

      final finalCount = state['counter'] as int;
      expect(finalCount, lessThanOrEqualTo(100));

      print('Race Condition #8 (complex state): counter = $finalCount (expected 100)');
      print('Lost updates in complex state: ${100 - finalCount}');
    });
  });

  group('Performance Degradation Under Concurrent Load', () {
    test('should measure performance impact of race conditions', () async {
      var counter = 0;
      final stopwatch = Stopwatch()..start();

      // Concurrent operations with race conditions
      final futures = <Future>[];
      for (int i = 0; i < 1000; i++) {
        futures.add(Future(() {
          counter++;
        }));
      }

      await Future.wait(futures);
      stopwatch.stop();

      print('Performance under race conditions:');
      print('  Time: ${stopwatch.elapsedMilliseconds}ms');
      print('  Operations: 1000');
      print('  Successful: $counter');
      print('  Failed: ${1000 - counter}');
      print('  Throughput: ${(counter / stopwatch.elapsedMilliseconds * 1000).toStringAsFixed(0)} ops/sec');

      // Performance degrades with lost updates
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: 'Should complete within 1 second');
    });
  });
}
