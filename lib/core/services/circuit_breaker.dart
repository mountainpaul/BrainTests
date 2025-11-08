import 'dart:async';

/// Circuit Breaker State
///
/// - CLOSED: Normal operation, requests pass through
/// - OPEN: Too many failures, rejecting requests
/// - HALF_OPEN: Testing if service recovered
enum CircuitBreakerState {
  closed,
  open,
  halfOpen,
}

/// Exception thrown when circuit breaker is open
class CircuitBreakerOpenException implements Exception {
  final String circuitName;
  final int failureCount;
  final DateTime? lastFailureTime;

  const CircuitBreakerOpenException(
    this.circuitName, {
    required this.failureCount,
    this.lastFailureTime,
  });

  @override
  String toString() {
    return 'CircuitBreakerOpenException: Circuit "$circuitName" is open '
        '(failures: $failureCount, last failure: $lastFailureTime)';
  }
}

/// Circuit Breaker Pattern Implementation
///
/// Prevents cascading failures by monitoring operations and:
/// 1. Opening circuit after threshold failures
/// 2. Rejecting requests while open (fail fast)
/// 3. Testing service recovery after timeout
/// 4. Closing circuit when service recovers
///
/// Example usage:
/// ```dart
/// final breaker = CircuitBreaker(
///   name: 'exercise_generation',
///   failureThreshold: 5,
///   timeout: Duration(seconds: 60),
/// );
///
/// try {
///   final exercise = await breaker.execute(() async {
///     return await generateExercise();
///   });
/// } on CircuitBreakerOpenException {
///   // Use cached exercise or show error
/// }
/// ```
class CircuitBreaker {
  final String name;
  final int failureThreshold;
  final Duration timeout;
  final Duration? requestTimeout;
  final dynamic Function()? fallback;
  final bool Function(dynamic)? successValidator;

  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  int _totalRequests = 0;
  int _totalFailures = 0;
  int _totalSuccesses = 0;

  CircuitBreaker({
    this.name = 'default',
    required this.failureThreshold,
    required this.timeout,
    this.requestTimeout,
    this.fallback,
    this.successValidator,
  }) {
    if (failureThreshold <= 0) {
      throw ArgumentError('failureThreshold must be positive');
    }
    if (timeout.inMilliseconds <= 0) {
      throw ArgumentError('timeout must be positive');
    }
  }

  /// Current state of the circuit breaker
  CircuitBreakerState get state => _state;

  /// Number of consecutive failures
  int get failureCount => _failureCount;

  /// Time of last failure
  DateTime? get lastFailureTime => _lastFailureTime;

  /// Execute operation through circuit breaker
  ///
  /// Throws [CircuitBreakerOpenException] if circuit is open and no fallback provided
  /// Throws original exception if operation fails
  Future<T> execute<T>(Future<T> Function() operation) async {
    _totalRequests++;

    // Check if circuit should transition from open to half-open
    if (_state == CircuitBreakerState.open) {
      final timeSinceFailure = DateTime.now().difference(_lastFailureTime!);
      if (timeSinceFailure >= timeout) {
        _state = CircuitBreakerState.halfOpen;
      } else {
        // Circuit still open, reject request
        if (fallback != null) {
          return fallback!() as T;
        }
        throw CircuitBreakerOpenException(
          name,
          failureCount: _failureCount,
          lastFailureTime: _lastFailureTime,
        );
      }
    }

    try {
      // Execute operation with optional timeout
      final T result;
      if (requestTimeout != null) {
        result = await operation().timeout(requestTimeout!);
      } else {
        result = await operation();
      }

      // Validate success if custom validator provided
      if (successValidator != null && !successValidator!(result)) {
        throw Exception('Operation failed custom success criteria');
      }

      // Operation succeeded
      _onSuccess();
      return result;
    } catch (e) {
      // Operation failed
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    _totalSuccesses++;
    _failureCount = 0;

    if (_state == CircuitBreakerState.halfOpen) {
      // Service recovered, close circuit
      _state = CircuitBreakerState.closed;
    }
  }

  void _onFailure() {
    _totalFailures++;
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_state == CircuitBreakerState.halfOpen) {
      // Test failed, reopen circuit
      _state = CircuitBreakerState.open;
    } else if (_failureCount >= failureThreshold) {
      // Threshold exceeded, open circuit
      _state = CircuitBreakerState.open;
    }
  }

  /// Manually reset the circuit breaker
  void reset() {
    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _lastFailureTime = null;
  }

  /// Get circuit breaker statistics
  Map<String, dynamic> get statistics => {
        'name': name,
        'state': _state.toString(),
        'failureCount': _failureCount,
        'lastFailureTime': _lastFailureTime?.toIso8601String(),
        'totalRequests': _totalRequests,
        'totalSuccesses': _totalSuccesses,
        'totalFailures': _totalFailures,
        'failureThreshold': failureThreshold,
        'timeoutSeconds': timeout.inSeconds,
        'successRate': _totalRequests > 0
            ? (_totalSuccesses / _totalRequests * 100).toStringAsFixed(2) + '%'
            : '0%',
      };
}
