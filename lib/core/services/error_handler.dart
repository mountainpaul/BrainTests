import 'dart:async';
import 'dart:collection';

/// Comprehensive Error Handling
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

/// Error severity levels
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

/// Application error with metadata
class AppError {
  final String message;
  final String code;
  final String? userMessage;
  final Map<String, dynamic>? metadata;
  final StackTrace? stackTrace;
  final bool isRetryable;

  AppError({
    required this.message,
    required this.code,
    this.userMessage,
    this.metadata,
    this.stackTrace,
    this.isRetryable = false,
  });

  @override
  String toString() {
    return 'AppError($code): $message';
  }
}

/// Error log entry
class ErrorLogEntry {
  final AppError error;
  final ErrorSeverity severity;
  final DateTime timestamp;

  ErrorLogEntry({
    required this.error,
    required this.severity,
    required this.timestamp,
  });
}

/// Global error handler
class ErrorHandler {
  final int maxLogs;
  final Queue<ErrorLogEntry> _logs = Queue();
  void Function(AppError error, ErrorSeverity severity)? onError;

  ErrorHandler({this.maxLogs = 100});

  /// Handle an error
  void handleError(AppError error, {ErrorSeverity severity = ErrorSeverity.error}) {
    final entry = ErrorLogEntry(
      error: error,
      severity: severity,
      timestamp: DateTime.now(),
    );

    _logs.addFirst(entry);

    // Limit log size
    while (_logs.length > maxLogs) {
      _logs.removeLast();
    }

    // Call callback
    onError?.call(error, severity);
  }

  /// Handle an exception
  void handleException(Exception exception, {ErrorSeverity severity = ErrorSeverity.error}) {
    final error = AppError(
      message: exception.toString().replaceFirst('Exception: ', ''),
      code: 'EXCEPTION',
      stackTrace: StackTrace.current,
    );
    handleError(error, severity: severity);
  }

  /// Get all error logs
  List<ErrorLogEntry> getErrorLogs() {
    return List.unmodifiable(_logs);
  }

  /// Clear error logs
  void clearLogs() {
    _logs.clear();
  }

  /// Dispose handler
  void dispose() {
    _logs.clear();
    onError = null;
  }
}

/// Error boundary for catching errors in code sections
class ErrorBoundary {
  /// Run synchronous code with error handling
  static T? run<T>(
    T Function() fn, {
    required void Function(AppError error) onError,
    T? fallback,
  }) {
    try {
      return fn();
    } catch (e, stackTrace) {
      final error = AppError(
        message: e.toString().replaceFirst('Exception: ', ''),
        code: 'BOUNDARY_ERROR',
        stackTrace: stackTrace,
      );
      onError(error);
      return fallback;
    }
  }

  /// Run asynchronous code with error handling
  static Future<T?> runAsync<T>(
    Future<T> Function() fn, {
    required void Function(AppError error) onError,
    T? fallback,
  }) async {
    try {
      return await fn();
    } catch (e, stackTrace) {
      final error = AppError(
        message: e.toString().replaceFirst('Exception: ', ''),
        code: 'BOUNDARY_ERROR',
        stackTrace: stackTrace,
      );
      onError(error);
      return fallback;
    }
  }
}

/// Retry handler for transient failures
class RetryHandler {
  /// Retry an operation with exponential backoff
  static Future<T> retry<T>(
    Future<T> Function() fn, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool useExponentialBackoff = false,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    Duration currentDelay = delay;

    while (attempts < maxAttempts) {
      attempts++;

      try {
        return await fn();
      } catch (e) {
        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        // If this was the last attempt, rethrow
        if (attempts >= maxAttempts) {
          rethrow;
        }

        // Wait before retrying
        await Future.delayed(currentDelay);

        // Update delay for exponential backoff
        if (useExponentialBackoff) {
          currentDelay = Duration(milliseconds: currentDelay.inMilliseconds * 2);
        }
      }
    }

    // This should never be reached, but needed for type safety
    throw Exception('Retry failed after $maxAttempts attempts');
  }
}

/// Queue for errors that occur offline
class OfflineErrorQueue {
  final int maxSize;
  final Queue<AppError> _queue = Queue();

  OfflineErrorQueue({this.maxSize = 50});

  /// Enqueue an error
  void enqueue(AppError error) {
    _queue.addLast(error);

    // Limit queue size (remove oldest)
    while (_queue.length > maxSize) {
      _queue.removeFirst();
    }
  }

  /// Dequeue an error
  AppError? dequeue() {
    if (_queue.isEmpty) return null;
    return _queue.removeFirst();
  }

  /// Peek at next error without removing
  AppError? peek() {
    if (_queue.isEmpty) return null;
    return _queue.first;
  }

  /// Get all errors
  List<AppError> getAllErrors() {
    return List.unmodifiable(_queue);
  }

  /// Clear queue
  void clear() {
    _queue.clear();
  }

  /// Get queue size
  int get size => _queue.length;
}

/// Maps error codes to user-friendly messages
class ErrorMessageMapper {
  final Map<String, String> mappings;
  final String defaultMessage;

  ErrorMessageMapper({
    required this.mappings,
    this.defaultMessage = 'An unexpected error occurred. Please try again.',
  });

  /// Get user-friendly message for error code
  String getUserMessage(String errorCode) {
    return mappings[errorCode] ?? defaultMessage;
  }
}
