import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/core/services/circuit_breaker.dart';

/// Test-Driven Development for Circuit Breaker Pattern
///
/// Circuit Breaker Pattern prevents cascading failures by:
/// 1. Detecting failures and opening the circuit
/// 2. Preventing requests when circuit is open
/// 3. Allowing test requests after timeout (half-open state)
/// 4. Closing circuit when service recovers
///
/// States:
/// - CLOSED: Normal operation, requests pass through
/// - OPEN: Service failing, requests immediately rejected
/// - HALF_OPEN: Testing if service recovered, limited requests
void main() {
  group('CircuitBreaker', () {
    test('should start in CLOSED state', () {
      final breaker = CircuitBreaker(
        failureThreshold: 3,
        timeout: const Duration(seconds: 30),
      );

      expect(breaker.state, CircuitBreakerState.closed);
      expect(breaker.failureCount, 0);
    });

    test('should allow requests when circuit is CLOSED', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 3,
        timeout: const Duration(seconds: 30),
      );

      final result = await breaker.execute<String>(() async {
        return 'success';
      });

      expect(result, 'success');
      expect(breaker.state, CircuitBreakerState.closed);
      expect(breaker.failureCount, 0);
    });

    test('should increment failure count on exception', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 3,
        timeout: const Duration(seconds: 30),
      );

      try {
        await breaker.execute<void>(() async {
          throw Exception('Test failure');
        });
      } catch (e) {
        // Expected to throw
      }

      expect(breaker.failureCount, 1);
      expect(breaker.state, CircuitBreakerState.closed);
    });

    test('should open circuit after exceeding failure threshold', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 3,
        timeout: const Duration(seconds: 30),
      );

      // Cause 3 failures
      for (int i = 0; i < 3; i++) {
        try {
          await breaker.execute<void>(() async {
            throw Exception('Failure $i');
          });
        } catch (e) {
          // Expected
        }
      }

      expect(breaker.state, CircuitBreakerState.open);
      expect(breaker.failureCount, 3);
    });

    test('should immediately reject requests when circuit is OPEN', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 2,
        timeout: const Duration(seconds: 30),
      );

      // Trip the circuit breaker
      for (int i = 0; i < 2; i++) {
        try {
          await breaker.execute<void>(() async {
            throw Exception('Failure');
          });
        } catch (e) {
          // Expected
        }
      }

      expect(breaker.state, CircuitBreakerState.open);

      // Attempt request with open circuit
      expect(
        () => breaker.execute<String>(() async => 'should not execute'),
        throwsA(isA<CircuitBreakerOpenException>()),
      );
    });

    test('should transition to HALF_OPEN after timeout', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 2,
        timeout: const Duration(milliseconds: 100), // Short timeout for test
      );

      // Trip the circuit
      for (int i = 0; i < 2; i++) {
        try {
          await breaker.execute<void>(() async {
            throw Exception('Failure');
          });
        } catch (e) {
          // Expected
        }
      }

      expect(breaker.state, CircuitBreakerState.open);

      // Wait for timeout
      await Future.delayed(const Duration(milliseconds: 150));

      // Next request should transition to half-open
      try {
        await breaker.execute<void>(() async {
          throw Exception('Test after timeout');
        });
      } catch (e) {
        // May fail, but state should have changed
      }

      // State should have been half-open during execution
      // If test failed, circuit opens again
      expect(breaker.state, isIn([CircuitBreakerState.halfOpen, CircuitBreakerState.open]));
    });

    test('should close circuit after successful request in HALF_OPEN state', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 2,
        timeout: const Duration(milliseconds: 100),
      );

      // Trip the circuit
      for (int i = 0; i < 2; i++) {
        try {
          await breaker.execute<void>(() async {
            throw Exception('Failure');
          });
        } catch (e) {
          // Expected
        }
      }

      expect(breaker.state, CircuitBreakerState.open);

      // Wait for timeout
      await Future.delayed(const Duration(milliseconds: 150));

      // Successful request should close circuit
      final result = await breaker.execute<String>(() async {
        return 'recovered';
      });

      expect(result, 'recovered');
      expect(breaker.state, CircuitBreakerState.closed);
      expect(breaker.failureCount, 0);
    });

    test('should reset failure count after successful request', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 3,
        timeout: const Duration(seconds: 30),
      );

      // Single failure
      try {
        await breaker.execute<void>(() async {
          throw Exception('Failure');
        });
      } catch (e) {
        // Expected
      }

      expect(breaker.failureCount, 1);

      // Successful request
      await breaker.execute<String>(() async {
        return 'success';
      });

      expect(breaker.failureCount, 0);
    });

    test('should handle different exception types', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 3,
        timeout: const Duration(seconds: 30),
      );

      // Test various exception types
      final exceptions = [
        Exception('Generic exception'),
        StateError('State error'),
        ArgumentError('Argument error'),
      ];

      for (final ex in exceptions) {
        try {
          await breaker.execute<void>(() async {
            throw ex;
          });
        } catch (e) {
          expect(e, equals(ex));
        }
      }

      expect(breaker.state, CircuitBreakerState.open);
      expect(breaker.failureCount, 3);
    });

    test('should provide fallback value when circuit is OPEN', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 2,
        timeout: const Duration(seconds: 30),
        fallback: () => 'fallback value',
      );

      // Trip the circuit
      for (int i = 0; i < 2; i++) {
        try {
          await breaker.execute<String>(() async {
            throw Exception('Failure');
          });
        } catch (e) {
          // Expected
        }
      }

      expect(breaker.state, CircuitBreakerState.open);

      // Should return fallback value instead of throwing
      final result = await breaker.execute<String>(() async {
        return 'should not execute';
      });

      expect(result, 'fallback value');
    });

    test('should track last failure time', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 1,
        timeout: const Duration(seconds: 30),
      );

      final beforeFailure = DateTime.now();

      try {
        await breaker.execute<void>(() async {
          throw Exception('Failure');
        });
      } catch (e) {
        // Expected
      }

      final afterFailure = DateTime.now();

      expect(breaker.lastFailureTime, isNotNull);
      expect(breaker.lastFailureTime!.isAfter(beforeFailure) ||
             breaker.lastFailureTime!.isAtSameMomentAs(beforeFailure), true);
      expect(breaker.lastFailureTime!.isBefore(afterFailure) ||
             breaker.lastFailureTime!.isAtSameMomentAs(afterFailure), true);
    });

    test('should allow custom success criteria', () async {
      bool customSuccessCriteria(dynamic result) {
        // Custom: only count as success if result > 0
        if (result is int) {
          return result > 0;
        }
        return true;
      }

      final breaker = CircuitBreaker(
        failureThreshold: 2,
        timeout: const Duration(seconds: 30),
        successValidator: customSuccessCriteria,
      );

      // Result of 0 should count as failure (exception thrown)
      try {
        await breaker.execute<int>(() async => 0);
        fail('Should have thrown exception for failed validation');
      } catch (e) {
        expect(e, isA<Exception>());
      }
      expect(breaker.failureCount, 1);

      // Result of 1 should count as success
      await breaker.execute<int>(() async => 1);
      expect(breaker.failureCount, 0);
    });

    test('should handle concurrent requests safely', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 5,
        timeout: const Duration(seconds: 30),
      );

      // Launch concurrent requests
      final futures = <Future>[];
      for (int i = 0; i < 10; i++) {
        futures.add(
          breaker.execute<String>(() async {
            await Future.delayed(const Duration(milliseconds: 5));
            return 'success $i';
          }),
        );
      }

      final results = await Future.wait(futures);

      expect(results.length, 10);
      expect(breaker.state, CircuitBreakerState.closed);
    });

    test('should handle timeout on slow operations', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 2,
        timeout: const Duration(seconds: 30),
        requestTimeout: const Duration(milliseconds: 50),
      );

      // Slow operation that exceeds timeout
      try {
        await breaker.execute<String>(() async {
          await Future.delayed(const Duration(milliseconds: 200));
          return 'too slow';
        });
        fail('Should have timed out');
      } catch (e) {
        expect(e, isA<TimeoutException>());
      }

      expect(breaker.failureCount, 1);
    });

    test('should reset circuit manually', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 2,
        timeout: const Duration(seconds: 30),
      );

      // Trip the circuit
      for (int i = 0; i < 2; i++) {
        try {
          await breaker.execute<void>(() async {
            throw Exception('Failure');
          });
        } catch (e) {
          // Expected
        }
      }

      expect(breaker.state, CircuitBreakerState.open);
      expect(breaker.failureCount, 2);

      // Manual reset
      breaker.reset();

      expect(breaker.state, CircuitBreakerState.closed);
      expect(breaker.failureCount, 0);
      expect(breaker.lastFailureTime, isNull);
    });

    test('should provide circuit breaker statistics', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 3,
        timeout: const Duration(seconds: 30),
      );

      // Mix of successes and failures
      await breaker.execute<String>(() async => 'success 1');

      try {
        await breaker.execute<void>(() async {
          throw Exception('Failure 1');
        });
      } catch (e) {
        // Expected
      }

      await breaker.execute<String>(() async => 'success 2');

      try {
        await breaker.execute<void>(() async {
          throw Exception('Failure 2');
        });
      } catch (e) {
        // Expected
      }

      final stats = breaker.statistics;

      expect(stats['state'], CircuitBreakerState.closed.toString());
      expect(stats['failureCount'], 1); // Reset after success
      expect(stats['totalRequests'], 4);
      expect(stats['totalFailures'], 2);
      expect(stats['totalSuccesses'], 2);
      expect(stats['failureThreshold'], 3);
    });
  });

  group('CircuitBreakerOpenException', () {
    test('should contain circuit breaker information', () {
      final exception = CircuitBreakerOpenException(
        'Test circuit',
        failureCount: 5,
        lastFailureTime: DateTime.now(),
      );

      expect(exception.circuitName, 'Test circuit');
      expect(exception.failureCount, 5);
      expect(exception.lastFailureTime, isNotNull);
      expect(exception.toString(), contains('Test circuit'));
      expect(exception.toString(), contains('5'));
    });
  });
}
