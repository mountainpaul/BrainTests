import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/core/services/state_synchronization.dart';

/// TDD for State Synchronization Primitives
///
/// Provides thread-safe state update mechanisms to prevent race conditions
/// when multiple async operations attempt to modify shared state.
///
/// Features:
/// - Mutex/lock for critical sections
/// - Atomic update helpers
/// - Debounce/throttle utilities
/// - State validation middleware
void main() {
  group('StateMutex', () {
    test('should allow sequential access to critical section', () async {
      final mutex = StateMutex();
      final results = <int>[];

      await mutex.withLock(() async {
        results.add(1);
        await Future.delayed(const Duration(milliseconds: 10));
        results.add(2);
      });

      await mutex.withLock(() async {
        results.add(3);
        await Future.delayed(const Duration(milliseconds: 10));
        results.add(4);
      });

      expect(results, [1, 2, 3, 4]);
    });

    test('should block concurrent access to critical section', () async {
      final mutex = StateMutex();
      final results = <int>[];

      // Start two operations concurrently
      final future1 = mutex.withLock(() async {
        results.add(1);
        await Future.delayed(const Duration(milliseconds: 50));
        results.add(2);
      });

      // Start second operation immediately
      final future2 = mutex.withLock(() async {
        results.add(3);
        await Future.delayed(const Duration(milliseconds: 50));
        results.add(4);
      });

      await Future.wait([future1, future2]);

      // Second operation should wait for first to complete
      expect(results, [1, 2, 3, 4]);
    });

    test('should return value from locked function', () async {
      final mutex = StateMutex();

      final result = await mutex.withLock(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      expect(result, 42);
    });

    test('should propagate exceptions from locked function', () async {
      final mutex = StateMutex();

      expect(
        () => mutex.withLock(() async {
          throw Exception('Test error');
        }),
        throwsException,
      );
    });

    test('should allow multiple operations in sequence', () async {
      final mutex = StateMutex();
      int counter = 0;

      for (int i = 0; i < 5; i++) {
        await mutex.withLock(() async {
          counter++;
        });
      }

      expect(counter, 5);
    });

    test('should handle concurrent increments correctly', () async {
      final mutex = StateMutex();
      int counter = 0;

      final futures = List.generate(10, (i) {
        return mutex.withLock(() async {
          final current = counter;
          await Future.delayed(const Duration(milliseconds: 1));
          counter = current + 1;
        });
      });

      await Future.wait(futures);

      expect(counter, 10);
    });
  });

  group('AtomicValue', () {
    test('should read and write atomically', () async {
      final atomic = AtomicValue<int>(0);

      expect(atomic.value, 0);

      atomic.value = 5;
      expect(atomic.value, 5);
    });

    test('should update value atomically', () async {
      final atomic = AtomicValue<int>(0);

      final result = await atomic.update((value) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return value + 1;
      });

      expect(result, 1);
      expect(atomic.value, 1);
    });

    test('should block concurrent updates', () async {
      final atomic = AtomicValue<int>(0);

      final futures = List.generate(10, (i) {
        return atomic.update((value) async {
          await Future.delayed(const Duration(milliseconds: 1));
          return value + 1;
        });
      });

      await Future.wait(futures);

      expect(atomic.value, 10);
    });

    test('should compare and swap atomically', () async {
      final atomic = AtomicValue<int>(5);

      final swapped = atomic.compareAndSwap(expected: 5, newValue: 10);

      expect(swapped, true);
      expect(atomic.value, 10);
    });

    test('should fail compare and swap when value changed', () async {
      final atomic = AtomicValue<int>(5);

      final swapped = atomic.compareAndSwap(expected: 3, newValue: 10);

      expect(swapped, false);
      expect(atomic.value, 5);
    });

    test('should get and set atomically', () async {
      final atomic = AtomicValue<int>(5);

      final old = atomic.getAndSet(10);

      expect(old, 5);
      expect(atomic.value, 10);
    });

    test('should increment and get atomically', () async {
      final atomic = AtomicValue<int>(0);

      final result = atomic.incrementAndGet();

      expect(result, 1);
      expect(atomic.value, 1);
    });

    test('should get and increment atomically', () async {
      final atomic = AtomicValue<int>(0);

      final old = atomic.getAndIncrement();

      expect(old, 0);
      expect(atomic.value, 1);
    });
  });

  group('Debouncer', () {
    test('should debounce rapid calls', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      // Call 5 times rapidly
      for (int i = 0; i < 5; i++) {
        debouncer.run(() {
          callCount++;
        });
        await Future.delayed(const Duration(milliseconds: 20));
      }

      // Wait for debounce to complete
      await Future.delayed(const Duration(milliseconds: 150));

      // Should only execute once
      expect(callCount, 1);
    });

    test('should execute after debounce period', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      bool executed = false;

      debouncer.run(() {
        executed = true;
      });

      expect(executed, false);

      await Future.delayed(const Duration(milliseconds: 70));

      expect(executed, true);
    });

    test('should cancel previous debounce', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      int value = 0;

      debouncer.run(() {
        value = 1;
      });

      await Future.delayed(const Duration(milliseconds: 20));

      debouncer.run(() {
        value = 2;
      });

      await Future.delayed(const Duration(milliseconds: 70));

      expect(value, 2);
    });

    test('should dispose and cancel pending debounce', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      bool executed = false;

      debouncer.run(() {
        executed = true;
      });

      debouncer.dispose();

      await Future.delayed(const Duration(milliseconds: 70));

      expect(executed, false);
    });
  });

  group('Throttler', () {
    test('should throttle rapid calls', () async {
      final throttler = Throttler(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      // Call 10 times rapidly
      for (int i = 0; i < 10; i++) {
        throttler.run(() {
          callCount++;
        });
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Should execute immediately and then throttle
      expect(callCount, greaterThan(0));
      expect(callCount, lessThan(10));
    });

    test('should execute immediately on first call', () async {
      final throttler = Throttler(duration: const Duration(milliseconds: 100));
      bool executed = false;

      throttler.run(() {
        executed = true;
      });

      expect(executed, true);
    });

    test('should allow execution after throttle period', () async {
      final throttler = Throttler(duration: const Duration(milliseconds: 50));
      int callCount = 0;

      throttler.run(() {
        callCount++;
      });

      expect(callCount, 1);

      await Future.delayed(const Duration(milliseconds: 70));

      throttler.run(() {
        callCount++;
      });

      expect(callCount, 2);
    });
  });

  group('StateValidator', () {
    test('should validate state before update', () {
      final validator = StateValidator<int>(
        validators: [
          (value) => value >= 0 ? null : 'Value must be non-negative',
          (value) => value <= 100 ? null : 'Value must be <= 100',
        ],
      );

      expect(validator.validate(50), isNull);
      expect(validator.validate(-1), 'Value must be non-negative');
      expect(validator.validate(101), 'Value must be <= 100');
    });

    test('should return first validation error', () {
      final validator = StateValidator<int>(
        validators: [
          (value) => value >= 0 ? null : 'Error 1',
          (value) => value <= 100 ? null : 'Error 2',
        ],
      );

      expect(validator.validate(-1), 'Error 1');
    });

    test('should handle empty validators list', () {
      final validator = StateValidator<int>(validators: []);

      expect(validator.validate(50), isNull);
    });

    test('should validate complex objects', () {
      final validator = StateValidator<Map<String, dynamic>>(
        validators: [
          (value) => value.containsKey('name') ? null : 'Name is required',
          (value) => value['name'] is String ? null : 'Name must be string',
        ],
      );

      expect(validator.validate({'name': 'Test'}), isNull);
      expect(validator.validate({}), 'Name is required');
      expect(validator.validate({'name': 123}), 'Name must be string');
    });
  });
}
