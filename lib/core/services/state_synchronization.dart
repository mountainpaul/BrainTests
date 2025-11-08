import 'dart:async';

/// State Synchronization Primitives
///
/// Provides thread-safe state update mechanisms to prevent race conditions
/// when multiple async operations attempt to modify shared state.
///
/// Features:
/// - Mutex/lock for critical sections
/// - Atomic update helpers
/// - Debounce/throttle utilities
/// - State validation middleware

/// Mutex for sequential access to critical sections
///
/// Ensures that only one async operation can execute the critical section
/// at a time, preventing race conditions on shared state.
///
/// Example:
/// ```dart
/// final mutex = StateMutex();
/// await mutex.withLock(() async {
///   // Critical section - only one operation at a time
///   final current = state.value;
///   await someAsyncWork();
///   state.value = current + 1;
/// });
/// ```
class StateMutex {
  Future<void>? _lock;

  /// Execute function with exclusive lock
  ///
  /// Waits for previous lock to release before executing.
  /// Returns the value returned by the function.
  Future<T> withLock<T>(Future<T> Function() fn) async {
    // Wait for previous lock if it exists
    while (_lock != null) {
      await _lock;
    }

    // Create new lock
    final completer = Completer<void>();
    _lock = completer.future;

    try {
      return await fn();
    } finally {
      // Release lock
      completer.complete();
      _lock = null;
    }
  }
}

/// Atomic value wrapper
///
/// Provides atomic operations on a value to prevent race conditions.
///
/// Example:
/// ```dart
/// final atomic = AtomicValue<int>(0);
///
/// // Atomic update
/// await atomic.update((value) async {
///   await someWork();
///   return value + 1;
/// });
///
/// // Compare and swap
/// final swapped = atomic.compareAndSwap(expected: 5, newValue: 10);
/// ```
class AtomicValue<T> {
  T _value;
  final StateMutex _mutex = StateMutex();

  AtomicValue(this._value);

  /// Get current value
  T get value => _value;

  /// Set value
  set value(T newValue) {
    _value = newValue;
  }

  /// Update value atomically
  ///
  /// Locks value during update to prevent concurrent modifications.
  Future<T> update(Future<T> Function(T current) fn) async {
    return await _mutex.withLock(() async {
      _value = await fn(_value);
      return _value;
    });
  }

  /// Compare and swap
  ///
  /// Only updates value if current value equals expected.
  /// Returns true if swap occurred.
  bool compareAndSwap({required T expected, required T newValue}) {
    if (_value == expected) {
      _value = newValue;
      return true;
    }
    return false;
  }

  /// Get and set atomically
  ///
  /// Returns old value and sets new value.
  T getAndSet(T newValue) {
    final old = _value;
    _value = newValue;
    return old;
  }

  /// Increment and get (for int values)
  ///
  /// Only works with int values. Returns new value after increment.
  T incrementAndGet() {
    if (_value is int) {
      _value = ((_value as int) + 1) as T;
      return _value;
    }
    throw UnsupportedError('incrementAndGet only works with int values');
  }

  /// Get and increment (for int values)
  ///
  /// Only works with int values. Returns old value before increment.
  T getAndIncrement() {
    if (_value is int) {
      final old = _value;
      _value = ((_value as int) + 1) as T;
      return old;
    }
    throw UnsupportedError('getAndIncrement only works with int values');
  }
}

/// Debouncer - delays function execution until after a period of inactivity
///
/// Useful for handling rapid user input or preventing excessive API calls.
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(duration: Duration(milliseconds: 500));
///
/// // Called on every keystroke, but only executes 500ms after last keystroke
/// debouncer.run(() {
///   searchApi(query);
/// });
/// ```
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({required this.duration});

  /// Run function after debounce period
  ///
  /// Cancels previous timer if still pending.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel pending debounce
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttler - limits function execution frequency
///
/// Executes immediately on first call, then blocks subsequent calls
/// until throttle period expires.
///
/// Example:
/// ```dart
/// final throttler = Throttler(duration: Duration(milliseconds: 100));
///
/// // Called on every scroll event, but only executes max once per 100ms
/// throttler.run(() {
///   updateScrollPosition();
/// });
/// ```
class Throttler {
  final Duration duration;
  DateTime? _lastExecutionTime;

  Throttler({required this.duration});

  /// Run function if throttle period has elapsed
  ///
  /// Executes immediately on first call.
  /// Subsequent calls within throttle period are ignored.
  void run(void Function() action) {
    final now = DateTime.now();

    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) >= duration) {
      _lastExecutionTime = now;
      action();
    }
  }
}

/// State validator
///
/// Provides validation middleware for state updates.
///
/// Example:
/// ```dart
/// final validator = StateValidator<int>(
///   validators: [
///     (value) => value >= 0 ? null : 'Must be non-negative',
///     (value) => value <= 100 ? null : 'Must be <= 100',
///   ],
/// );
///
/// final error = validator.validate(newValue);
/// if (error != null) {
///   throw StateError(error);
/// }
/// ```
class StateValidator<T> {
  final List<String? Function(T value)> validators;

  StateValidator({required this.validators});

  /// Validate value against all validators
  ///
  /// Returns first error message, or null if all validators pass.
  String? validate(T value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
