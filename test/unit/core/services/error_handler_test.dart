import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/core/services/error_handler.dart';

/// TDD for Comprehensive Error Handling
///
/// Provides global error handling infrastructure to catch and handle
/// errors gracefully throughout the application.
///
/// Features:
/// - Global error handler with callbacks
/// - Error boundary pattern for UI errors
/// - Structured error logging
/// - User-friendly error messages
/// - Retry logic for transient failures
/// - Offline error queue
void main() {
  group('ErrorHandler', () {
    late ErrorHandler errorHandler;

    setUp(() {
      errorHandler = ErrorHandler();
    });

    tearDown(() {
      errorHandler.dispose();
    });

    test('should handle errors and call callback', () {
      String? capturedMessage;
      ErrorSeverity? capturedSeverity;

      errorHandler.onError = (error, severity) {
        capturedMessage = error.message;
        capturedSeverity = severity;
      };

      errorHandler.handleError(
        AppError(
          message: 'Test error',
          code: 'TEST_001',
        ),
        severity: ErrorSeverity.warning,
      );

      expect(capturedMessage, 'Test error');
      expect(capturedSeverity, ErrorSeverity.warning);
    });

    test('should log errors', () {
      errorHandler.handleError(
        AppError(
          message: 'Test error',
          code: 'TEST_001',
        ),
      );

      final logs = errorHandler.getErrorLogs();
      expect(logs.length, 1);
      expect(logs.first.error.message, 'Test error');
    });

    test('should categorize errors by severity', () {
      errorHandler.handleError(
        AppError(message: 'Info', code: 'INFO_001'),
        severity: ErrorSeverity.info,
      );
      errorHandler.handleError(
        AppError(message: 'Warning', code: 'WARN_001'),
        severity: ErrorSeverity.warning,
      );
      errorHandler.handleError(
        AppError(message: 'Error', code: 'ERR_001'),
        severity: ErrorSeverity.error,
      );

      final logs = errorHandler.getErrorLogs();
      expect(logs.where((l) => l.severity == ErrorSeverity.info).length, 1);
      expect(logs.where((l) => l.severity == ErrorSeverity.warning).length, 1);
      expect(logs.where((l) => l.severity == ErrorSeverity.error).length, 1);
    });

    test('should limit log size', () {
      final handler = ErrorHandler(maxLogs: 5);

      for (int i = 0; i < 10; i++) {
        handler.handleError(
          AppError(message: 'Error $i', code: 'ERR_$i'),
        );
      }

      final logs = handler.getErrorLogs();
      expect(logs.length, 5);
      // Should keep most recent errors
      expect(logs.first.error.message, 'Error 9');
      expect(logs.last.error.message, 'Error 5');
    });

    test('should clear error logs', () {
      errorHandler.handleError(
        AppError(message: 'Test', code: 'TEST_001'),
      );

      expect(errorHandler.getErrorLogs().length, 1);

      errorHandler.clearLogs();

      expect(errorHandler.getErrorLogs().length, 0);
    });

    test('should convert exceptions to AppErrors', () {
      String? capturedMessage;

      errorHandler.onError = (error, severity) {
        capturedMessage = error.message;
      };

      errorHandler.handleException(Exception('Test exception'));

      expect(capturedMessage, 'Test exception');
    });

    test('should handle errors with stack traces', () {
      final error = AppError(
        message: 'Test error',
        code: 'TEST_001',
        stackTrace: StackTrace.current,
      );

      errorHandler.handleError(error);

      final logs = errorHandler.getErrorLogs();
      expect(logs.first.error.stackTrace, isNotNull);
    });
  });

  group('AppError', () {
    test('should create error with message and code', () {
      final error = AppError(
        message: 'Test error',
        code: 'TEST_001',
      );

      expect(error.message, 'Test error');
      expect(error.code, 'TEST_001');
      expect(error.userMessage, isNull);
    });

    test('should have user-friendly message', () {
      final error = AppError(
        message: 'Database connection failed',
        code: 'DB_001',
        userMessage: 'Unable to save your data. Please try again.',
      );

      expect(error.userMessage, 'Unable to save your data. Please try again.');
    });

    test('should include metadata', () {
      final error = AppError(
        message: 'API error',
        code: 'API_001',
        metadata: {'endpoint': '/api/users', 'statusCode': 500},
      );

      expect(error.metadata?['endpoint'], '/api/users');
      expect(error.metadata?['statusCode'], 500);
    });

    test('should indicate if error is retryable', () {
      final retryable = AppError(
        message: 'Network timeout',
        code: 'NET_001',
        isRetryable: true,
      );

      final notRetryable = AppError(
        message: 'Invalid credentials',
        code: 'AUTH_001',
        isRetryable: false,
      );

      expect(retryable.isRetryable, true);
      expect(notRetryable.isRetryable, false);
    });

    test('should convert to string', () {
      final error = AppError(
        message: 'Test error',
        code: 'TEST_001',
      );

      expect(error.toString(), contains('TEST_001'));
      expect(error.toString(), contains('Test error'));
    });
  });

  group('ErrorBoundary', () {
    test('should catch synchronous errors', () {
      AppError? capturedError;

      final result = ErrorBoundary.run(
        () {
          throw Exception('Sync error');
        },
        onError: (error) {
          capturedError = error;
        },
      );

      expect(result, isNull);
      expect(capturedError?.message, 'Sync error');
    });

    test('should catch async errors', () async {
      AppError? capturedError;

      final result = await ErrorBoundary.runAsync(
        () async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw Exception('Async error');
        },
        onError: (error) {
          capturedError = error;
        },
      );

      expect(result, isNull);
      expect(capturedError?.message, 'Async error');
    });

    test('should return result on success', () {
      final result = ErrorBoundary.run(
        () {
          return 42;
        },
        onError: (_) {},
      );

      expect(result, 42);
    });

    test('should return async result on success', () async {
      final result = await ErrorBoundary.runAsync(
        () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 42;
        },
        onError: (_) {},
      );

      expect(result, 42);
    });

    test('should provide fallback value on error', () {
      final result = ErrorBoundary.run(
        () {
          throw Exception('Error');
        },
        onError: (_) {},
        fallback: 'default',
      );

      expect(result, 'default');
    });
  });

  group('RetryHandler', () {
    test('should retry on failure', () async {
      int attempts = 0;

      final result = await RetryHandler.retry(
        () async {
          attempts++;
          if (attempts < 3) {
            throw Exception('Fail');
          }
          return 'success';
        },
        maxAttempts: 3,
        delay: const Duration(milliseconds: 10),
      );

      expect(result, 'success');
      expect(attempts, 3);
    });

    test('should throw after max attempts', () async {
      int attempts = 0;

      expect(
        () => RetryHandler.retry(
          () async {
            attempts++;
            throw Exception('Fail');
          },
          maxAttempts: 3,
          delay: const Duration(milliseconds: 10),
        ),
        throwsException,
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(attempts, 3);
    });

    test('should use exponential backoff', () async {
      int attempts = 0;
      final delays = <int>[];
      DateTime? lastAttempt;

      try {
        await RetryHandler.retry(
          () async {
            if (lastAttempt != null) {
              delays.add(DateTime.now().difference(lastAttempt!).inMilliseconds);
            }
            lastAttempt = DateTime.now();
            attempts++;
            throw Exception('Fail');
          },
          maxAttempts: 3,
          delay: const Duration(milliseconds: 10),
          useExponentialBackoff: true,
        );
      } catch (_) {}

      expect(attempts, 3);
      // Check that delays are increasing (exponential backoff)
      // First delay should be ~10ms, second should be ~20ms
      expect(delays.length, 2); // 2 delays between 3 attempts
      if (delays.isNotEmpty && delays.length > 1) {
        expect(delays[1], greaterThan(delays[0]));
      }
    });

    test('should retry only on specific errors', () async {
      int attempts = 0;

      try {
        await RetryHandler.retry(
          () async {
            attempts++;
            if (attempts == 1) {
              throw AppError(message: 'Retryable', code: 'NET_001', isRetryable: true);
            } else {
              throw AppError(message: 'Not retryable', code: 'AUTH_001', isRetryable: false);
            }
          },
          maxAttempts: 3,
          delay: const Duration(milliseconds: 10),
          shouldRetry: (error) {
            if (error is AppError) {
              return error.isRetryable;
            }
            return false;
          },
        );
      } catch (e) {
        expect((e as AppError).code, 'AUTH_001');
      }

      expect(attempts, 2); // First attempt + one retry before non-retryable error
    });
  });

  group('OfflineErrorQueue', () {
    late OfflineErrorQueue queue;

    setUp(() {
      queue = OfflineErrorQueue();
    });

    test('should enqueue errors', () {
      queue.enqueue(AppError(message: 'Error 1', code: 'ERR_001'));
      queue.enqueue(AppError(message: 'Error 2', code: 'ERR_002'));

      expect(queue.size, 2);
    });

    test('should dequeue errors', () {
      queue.enqueue(AppError(message: 'Error 1', code: 'ERR_001'));
      queue.enqueue(AppError(message: 'Error 2', code: 'ERR_002'));

      final first = queue.dequeue();
      expect(first?.message, 'Error 1');
      expect(queue.size, 1);

      final second = queue.dequeue();
      expect(second?.message, 'Error 2');
      expect(queue.size, 0);
    });

    test('should return null when queue is empty', () {
      final error = queue.dequeue();
      expect(error, isNull);
    });

    test('should peek at next error without removing', () {
      queue.enqueue(AppError(message: 'Error 1', code: 'ERR_001'));

      final peeked = queue.peek();
      expect(peeked?.message, 'Error 1');
      expect(queue.size, 1);
    });

    test('should clear queue', () {
      queue.enqueue(AppError(message: 'Error 1', code: 'ERR_001'));
      queue.enqueue(AppError(message: 'Error 2', code: 'ERR_002'));

      queue.clear();

      expect(queue.size, 0);
    });

    test('should get all errors', () {
      queue.enqueue(AppError(message: 'Error 1', code: 'ERR_001'));
      queue.enqueue(AppError(message: 'Error 2', code: 'ERR_002'));

      final all = queue.getAllErrors();
      expect(all.length, 2);
      expect(all[0].message, 'Error 1');
      expect(all[1].message, 'Error 2');
    });

    test('should limit queue size', () {
      final limitedQueue = OfflineErrorQueue(maxSize: 3);

      for (int i = 0; i < 5; i++) {
        limitedQueue.enqueue(AppError(message: 'Error $i', code: 'ERR_$i'));
      }

      expect(limitedQueue.size, 3);
      // Should keep most recent errors
      final all = limitedQueue.getAllErrors();
      expect(all[0].message, 'Error 2');
      expect(all[2].message, 'Error 4');
    });
  });

  group('ErrorMessageMapper', () {
    test('should map error codes to user messages', () {
      final mapper = ErrorMessageMapper(
        mappings: {
          'NET_001': 'Unable to connect. Please check your internet connection.',
          'DB_001': 'Unable to save your data. Please try again.',
          'AUTH_001': 'Invalid username or password.',
        },
      );

      expect(
        mapper.getUserMessage('NET_001'),
        'Unable to connect. Please check your internet connection.',
      );
      expect(
        mapper.getUserMessage('DB_001'),
        'Unable to save your data. Please try again.',
      );
      expect(
        mapper.getUserMessage('AUTH_001'),
        'Invalid username or password.',
      );
    });

    test('should return default message for unknown codes', () {
      final mapper = ErrorMessageMapper(mappings: {});

      expect(
        mapper.getUserMessage('UNKNOWN_001'),
        'An unexpected error occurred. Please try again.',
      );
    });

    test('should allow custom default message', () {
      final mapper = ErrorMessageMapper(
        mappings: {},
        defaultMessage: 'Something went wrong.',
      );

      expect(
        mapper.getUserMessage('UNKNOWN_001'),
        'Something went wrong.',
      );
    });
  });
}
