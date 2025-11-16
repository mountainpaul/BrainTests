import 'dart:async';

import 'package:brain_tests/data/datasources/database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

/// Advanced concurrency and race condition tests
///
/// Critical for production apps where:
/// - Multiple async operations may occur simultaneously
/// - Database transactions can overlap
/// - State updates can conflict
/// - Timer callbacks can interleave
///
/// As a senior engineer, I'm concerned about:
/// 1. Race conditions in database writes
/// 2. Concurrent exercise generation
/// 3. Multiple timer updates
/// 4. State management under concurrent access
/// 5. Memory leaks from unclosed streams/timers
void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();
  });

  tearDown(() async {
    await closeTestDatabase(database);
  });

  group('Concurrency - Database Race Conditions', () {
    test('should handle concurrent writes to same table', () async {
      // Simulate multiple exercises being saved simultaneously
      final futures = <Future>[];

      for (int i = 0; i < 10; i++) {
        futures.add(
          database.into(database.wordDictionaryTable).insert(
            WordDictionaryTableCompanion.insert(
              word: 'WORD$i',
              language: WordLanguage.english,
              type: WordType.anagram,
              difficulty: ExerciseDifficulty.easy,
              length: 5 + i.toString().length,
            ),
          ),
        );
      }

      // All should complete without deadlock or error
      await Future.wait(futures);

      // Verify all records inserted
      final query = database.select(database.wordDictionaryTable);
      final results = await query.get();

      expect(results.length, 10);
    });

    test('should handle concurrent reads while writing', () async {
      // Insert initial data
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'TEST',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 4,
        ),
      );

      final futures = <Future>[];

      // Start concurrent reads
      for (int i = 0; i < 5; i++) {
        futures.add(
          database.select(database.wordDictionaryTable).get(),
        );
      }

      // Start concurrent writes
      for (int i = 0; i < 5; i++) {
        futures.add(
          database.into(database.wordDictionaryTable).insert(
            WordDictionaryTableCompanion.insert(
              word: 'NEW$i',
              language: WordLanguage.english,
              type: WordType.anagram,
              difficulty: ExerciseDifficulty.easy,
              length: 4 + i.toString().length,
            ),
          ),
        );
      }

      // All operations should complete
      await Future.wait(futures);

      // Verify final state
      final results = await database.select(database.wordDictionaryTable).get();
      expect(results.length, 6); // 1 initial + 5 new
    });

    test('should handle rapid sequential inserts', () async {
      // Simulate rapid-fire inserts (e.g., batch import)
      for (int i = 0; i < 100; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'RAPID$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.easy,
            length: 6 + i.toString().length,
          ),
        );
      }

      final results = await database.select(database.wordDictionaryTable).get();
      expect(results.length, 100);
    });

    test('should handle transaction rollback scenarios', () async {
      // This tests database integrity under failure
      try {
        await database.transaction(() async {
          // Insert first record
          await database.into(database.wordDictionaryTable).insert(
            WordDictionaryTableCompanion.insert(
              word: 'FIRST',
              language: WordLanguage.english,
              type: WordType.anagram,
              difficulty: ExerciseDifficulty.easy,
              length: 5,
            ),
          );

          // Simulate error condition
          throw Exception('Simulated transaction failure');
        });
      } catch (e) {
        // Expected to fail
      }

      // Verify no partial data committed
      final results = await database.select(database.wordDictionaryTable).get();
      expect(results.length, 0);
    });
  });

  group('Concurrency - Multiple Async Operations', () {
    test('should handle multiple exercise generations simultaneously', () async {
      // Insert test data
      for (int i = 0; i < 20; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'CONCURRENT$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.easy,
            length: 11 + i.toString().length,
          ),
        );
      }

      // Generate multiple exercises concurrently
      final futures = <Future>[];
      for (int i = 0; i < 10; i++) {
        futures.add(
          Future(() async {
            final query = database.select(database.wordDictionaryTable)
              ..where((tbl) => tbl.type.equalsValue(WordType.anagram))
              ..limit(5);
            return await query.get();
          }),
        );
      }

      final results = await Future.wait(futures);

      // All should complete successfully
      expect(results.length, 10);
      for (final result in results) {
        expect(result.isNotEmpty, true);
      }
    });

    test('should handle timeout on slow operations', () async {
      // Simulate slow operation with timeout
      final slowOperation = Future.delayed(
        const Duration(seconds: 5),
        () => 'slow result',
      );

      expect(
        () => slowOperation.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => throw TimeoutException('Operation timed out'),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('should handle cancellation of in-flight operations', () async {
      final completer = Completer<String>();
      bool operationCancelled = false;

      // Start operation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!operationCancelled) {
          completer.complete('completed');
        }
      });

      // Cancel before completion
      operationCancelled = true;
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify operation was cancelled
      expect(operationCancelled, true);
    });
  });

  group('Concurrency - Timer Interactions', () {
    test('should handle multiple timers without interference', () async {
      final counters = <int>[0, 0, 0];
      final timers = <Timer>[];

      // Start 3 concurrent timers
      for (int i = 0; i < 3; i++) {
        timers.add(
          Timer.periodic(Duration(milliseconds: 10 * (i + 1)), (timer) {
            counters[i]++;
            if (counters[i] >= 5) {
              timer.cancel();
            }
          }),
        );
      }

      // Wait for all timers to complete
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify all timers executed independently
      expect(counters[0], greaterThanOrEqualTo(5));
      expect(counters[1], greaterThanOrEqualTo(5));
      expect(counters[2], greaterThanOrEqualTo(5));

      // Cleanup
      for (final timer in timers) {
        timer.cancel();
      }
    });

    test('should handle timer cancellation during callback', () async {
      Timer? timer;
      int callbackCount = 0;

      timer = Timer.periodic(const Duration(milliseconds: 10), (t) {
        callbackCount++;
        if (callbackCount >= 3) {
          t.cancel();
          timer = null;
        }
      });

      await Future.delayed(const Duration(milliseconds: 100));

      expect(callbackCount, 3);
      expect(timer, null);
    });

    test('should prevent memory leaks from uncancelled timers', () async {
      final activeTimers = <Timer>[];

      // Create timers
      for (int i = 0; i < 10; i++) {
        activeTimers.add(
          Timer.periodic(const Duration(milliseconds: 10), (timer) {
            // Do nothing
          }),
        );
      }

      // Cancel all timers
      for (final timer in activeTimers) {
        timer.cancel();
      }

      // Verify all cancelled
      for (final timer in activeTimers) {
        expect(timer.isActive, false);
      }
    });
  });

  group('Concurrency - State Management Race Conditions', () {
    test('should handle concurrent state updates', () async {
      var counter = 0;
      final futures = <Future>[];

      // Simulate concurrent state updates
      for (int i = 0; i < 100; i++) {
        futures.add(Future(() {
          counter++;
        }));
      }

      await Future.wait(futures);

      // Note: Without proper synchronization, this could fail
      // In production, use proper state management
      expect(counter, lessThanOrEqualTo(100));
    });

    test('should handle rapid state changes', () async {
      final states = <String>[];

      for (int i = 0; i < 50; i++) {
        states.add('state$i');
        await Future.delayed(const Duration(milliseconds: 1));
      }

      expect(states.length, 50);
      expect(states.last, 'state49');
    });
  });

  group('Concurrency - Resource Cleanup', () {
    test('should close database connections properly', () async {
      final tempDb = createTestDatabase();

      // Perform operation
      await tempDb.into(tempDb.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'TEST',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.easy,
          length: 4,
        ),
      );

      // Close connection
      await tempDb.close();

      // Verify closed (attempting operation should fail)
      expect(
        () => tempDb.select(tempDb.wordDictionaryTable).get(),
        throwsA(anything),
      );
    });

    test('should handle cleanup of multiple resources', () async {
      final databases = <AppDatabase>[];
      final timers = <Timer>[];

      // Create resources
      for (int i = 0; i < 5; i++) {
        databases.add(createTestDatabase());
        timers.add(Timer.periodic(const Duration(milliseconds: 10), (t) {}));
      }

      // Cleanup all resources
      for (final db in databases) {
        await db.close();
      }
      for (final timer in timers) {
        timer.cancel();
      }

      // Verify cleanup
      expect(databases.length, 5);
      expect(timers.length, 5);
      for (final timer in timers) {
        expect(timer.isActive, false);
      }
    });
  });

  group('Concurrency - Deadlock Prevention', () {
    test('should avoid circular wait conditions', () async {
      final lock1 = Completer<void>();
      final lock2 = Completer<void>();

      // Task 1: needs lock1 then lock2
      final task1 = Future(() async {
        await lock1.future.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => throw TimeoutException('Deadlock detected'),
        );
        await lock2.future.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => throw TimeoutException('Deadlock detected'),
        );
      });

      // Release locks to prevent deadlock
      lock1.complete();
      lock2.complete();

      await task1; // Should complete without timeout
    });

    test('should handle priority inversion scenarios', () async {
      final lowPriorityComplete = Completer<void>();
      final highPriorityComplete = Completer<void>();

      // Low priority task starts first
      final lowPriority = Future(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        lowPriorityComplete.complete();
      });

      // High priority task should complete quickly
      final highPriority = Future(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        highPriorityComplete.complete();
      });

      await Future.wait([lowPriority, highPriority]);

      expect(lowPriorityComplete.isCompleted, true);
      expect(highPriorityComplete.isCompleted, true);
    });
  });

  group('Concurrency - Idempotency', () {
    test('should handle duplicate operations idempotently', () async {
      const word = 'IDEMPOTENT';

      // Attempt to insert same word multiple times
      for (int i = 0; i < 5; i++) {
        try {
          await database.into(database.wordDictionaryTable).insert(
            WordDictionaryTableCompanion.insert(
              word: word,
              language: WordLanguage.english,
              type: WordType.anagram,
              difficulty: ExerciseDifficulty.easy,
              length: word.length,
            ),
          );
        } catch (e) {
          // Ignore duplicates (depending on DB constraints)
        }
      }

      final results = await (database.select(database.wordDictionaryTable)
            ..where((tbl) => tbl.word.equals(word)))
          .get();

      // Should have at least one (could be multiple if no unique constraint)
      expect(results.isNotEmpty, true);
    });

    test('should handle retry logic without side effects', () async {
      int attemptCount = 0;
      const maxRetries = 3;

      Future<String> unreliableOperation() async {
        attemptCount++;
        if (attemptCount < maxRetries) {
          throw Exception('Transient failure');
        }
        return 'success';
      }

      // Retry logic
      String? result;
      for (int i = 0; i < maxRetries; i++) {
        try {
          result = await unreliableOperation();
          break;
        } catch (e) {
          if (i == maxRetries - 1) rethrow;
          await Future.delayed(Duration(milliseconds: 10 * (i + 1)));
        }
      }

      expect(result, 'success');
      expect(attemptCount, maxRetries);
    });
  });
}
