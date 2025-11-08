# Race Conditions and Concurrency Issues Documentation

**Last Updated**: 2025-11-07
**Status**: Active Review
**Priority**: High - Pre-Production

## Overview

This document identifies and documents known race conditions and concurrency issues in the Brain Plan application. Each issue is categorized by severity and includes reproduction steps, potential impact, and mitigation strategies.

## Known Race Conditions

### 1. **Concurrent State Updates (CRITICAL)**

**Location**: Multiple StatefulWidget screens with `setState()` calls
**Test Coverage**: `test/advanced/advanced_disabled/concurrency_race_conditions_test.dart:299-315`

**Description**:
Multiple async operations updating the same state variable without synchronization can lead to lost updates. The test at line 314 explicitly notes: "Without proper synchronization, this could fail."

**Reproduction**:
```dart
var counter = 0;
final futures = <Future>[];

for (int i = 0; i < 100; i++) {
  futures.add(Future(() {
    counter++;  // Race condition: read-modify-write not atomic
  }));
}

await Future.wait(futures);
// Expected: 100, Actual: May be less due to lost updates
```

**Impact**:
- Lost state updates in UI components
- Incorrect assessment scores
- Mood entry counts may be inaccurate
- Exercise progress tracking inconsistencies

**Affected Files**:
- `lib/presentation/screens/about_screen.dart:24` (setState in _loadPackageInfo)
- `lib/presentation/screens/feeding_window_config_screen.dart:32,38` (setState in _loadFeedingWindows)
- `lib/presentation/screens/plan_screen.dart` (setState calls)
- `lib/presentation/screens/today_dashboard_screen.dart` (setState calls)
- `lib/presentation/screens/mood_tracking_screen.dart` (setState calls)
- All Cambridge test screens (pal_test_screen.dart, rti_test_screen.dart, etc.)

**Mitigation**:
- Use Riverpod state management instead of StatefulWidget where possible
- Implement proper locking mechanisms for critical state updates
- Use `StateProvider` or `NotifierProvider` for atomic state updates
- Add synchronization primitives (Mutex/Lock) for complex state transitions

**Status**: DOCUMENTED - Requires remediation

---

### 2. **Database Transaction Conflicts (HIGH)**

**Location**: Concurrent writes to the same table
**Test Coverage**: `test/advanced/advanced_disabled/concurrency_race_conditions_test.dart:34-60`

**Description**:
SQLite has limitations with concurrent writes. While reads are fine, multiple simultaneous writes can cause lock contention or transaction serialization issues.

**Reproduction**:
```dart
final futures = <Future>[];
for (int i = 0; i < 10; i++) {
  futures.add(database.into(table).insert(data));
}
await Future.wait(futures);
```

**Impact**:
- Potential database lock timeouts
- Degraded performance during bulk operations
- Transaction failures requiring retry logic
- User-facing errors during data saves

**Current Behavior**:
- Tests show this currently works (test passes)
- SQLite handles serialization internally
- May cause performance degradation under high load

**Mitigation**:
- Already mitigated by SQLite's internal locking
- Consider batch insert operations for bulk data
- Implement retry logic with exponential backoff
- Add circuit breaker pattern for sustained failures
- Monitor database lock wait times in production

**Status**: DOCUMENTED - Low risk, monitor in production

---

### 3. **Timer Callback Interleaving (MEDIUM)**

**Location**: Multiple Timer.periodic instances running concurrently
**Test Coverage**: `test/advanced/advanced_disabled/concurrency_race_conditions_test.dart:226-254`

**Description**:
Multiple periodic timers updating shared state can interleave in unpredictable ways, especially if callbacks take longer than the timer period.

**Reproduction**:
```dart
int sharedCounter = 0;
final timer1 = Timer.periodic(Duration(milliseconds: 10), (t) {
  sharedCounter++;  // Race condition
});
final timer2 = Timer.periodic(Duration(milliseconds: 10), (t) {
  sharedCounter++;  // Race condition
});
```

**Impact**:
- Assessment timer displays may be inconsistent
- Exercise countdown timers may skip or double-count
- Reminder notifications may fire multiple times
- UI animations may stutter or behave erratically

**Affected Areas**:
- Assessment test screens with timers
- Exercise screens with countdown timers
- Reminder notification scheduling
- Animation controllers

**Mitigation**:
- Ensure timer callbacks are idempotent
- Use Completer to prevent overlapping callbacks
- Cancel timers properly in dispose()
- Use isolates for long-running timer operations
- Implement callback debouncing for rapid events

**Status**: DOCUMENTED - Requires code review

---

### 4. **Memory Leaks from Uncancelled Resources (HIGH)**

**Location**: StatefulWidget screens with timers, streams, and listeners
**Test Coverage**: `test/advanced/advanced_disabled/concurrency_race_conditions_test.dart:274-295`

**Description**:
Failing to cancel timers, close streams, or remove listeners in dispose() causes memory leaks and can lead to callbacks executing after widget disposal.

**Reproduction**:
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {});  // Will crash if widget disposed
    });
  }

  // Missing dispose() - memory leak!
}
```

**Impact**:
- Memory leaks over time
- Crashes from setState() calls after dispose
- Battery drain from background timers
- Degraded performance over long app sessions

**Mitigation**:
- Audit all StatefulWidget classes for proper dispose()
- Use Riverpod providers to manage lifecycle automatically
- Implement linter rules to catch missing dispose()
- Add runtime checks for widget.mounted before setState()
- Use WidgetsBindingObserver to detect app lifecycle events

**Status**: DOCUMENTED - Requires full codebase audit

---

### 5. **Exercise Generation Concurrent Failures (MEDIUM)**

**Location**: Exercise generation services
**Test Coverage**: `test/advanced/advanced_disabled/concurrency_race_conditions_test.dart:153-187`

**Description**:
Multiple concurrent requests to generate exercises from the same word pool can cause contention and failures, especially with low-frequency words.

**Reproduction**:
```dart
final futures = <Future>[];
for (int i = 0; i < 10; i++) {
  futures.add(generateAnagramExercise(difficulty: ExerciseDifficulty.hard));
}
await Future.wait(futures);  // May fail if word pool exhausted
```

**Impact**:
- Exercise generation failures for users
- Inconsistent difficulty levels
- Empty exercise sets
- Poor user experience during brain training

**Mitigation**:
- Implement circuit breaker pattern (see Immediate Action #2)
- Add retry logic with jitter
- Pre-generate exercise pools
- Implement fallback to easier difficulties
- Cache generated exercises

**Status**: DOCUMENTED - Circuit breaker implementation pending

---

### 6. **Concurrent Read-While-Write Consistency (LOW)**

**Location**: Database queries during active writes
**Test Coverage**: `test/advanced/advanced_disabled/concurrency_race_conditions_test.dart:62-104`

**Description**:
Reading from database while concurrent writes are happening may return stale or inconsistent data depending on transaction isolation level.

**Current Behavior**:
- SQLite provides snapshot isolation by default
- Reads return consistent view of data
- Tests show this works correctly

**Impact**:
- Minimal impact due to SQLite's MVCC
- May see slightly stale data in rare cases
- No data corruption risk

**Mitigation**:
- Already mitigated by SQLite's ACID properties
- Consider using transactions for multi-step operations
- Document expected consistency guarantees

**Status**: DOCUMENTED - Working as designed, no action needed

---

### 7. **Deadlock Risk in Nested Transactions (MEDIUM)**

**Location**: Complex operations spanning multiple repositories
**Test Coverage**: `test/advanced/advanced_disabled/concurrency_race_conditions_test.dart:383-404`

**Description**:
Nested or overlapping transactions can potentially deadlock if lock acquisition order is inconsistent.

**Reproduction**:
```dart
await database.transaction(() async {
  await database.transaction(() async {  // Nested transaction
    // May deadlock depending on implementation
  });
});
```

**Impact**:
- Transaction timeouts
- Application hangs
- User-facing errors
- Data consistency issues if partial commits

**Current Status**:
- Drift/SQLite handles nested transactions safely
- Converts nested transactions to savepoints
- Low risk with current implementation

**Mitigation**:
- Avoid nested transactions where possible
- Use savepoints explicitly if needed
- Add timeout limits on all transactions
- Implement deadlock detection and retry logic

**Status**: DOCUMENTED - Low risk with Drift, monitor

---

### 8. **State Management Under Concurrent Access (HIGH)**

**Location**: Riverpod providers with mutable state
**Test Coverage**: `test/advanced/advanced_disabled/concurrency_race_conditions_test.dart:298-328`

**Description**:
Riverpod providers that hold mutable state without proper synchronization can experience race conditions when accessed concurrently.

**Reproduction**:
```dart
final counterProvider = StateProvider<int>((ref) => 0);

// Multiple widgets updating simultaneously
ref.read(counterProvider.notifier).state++;  // Race condition
```

**Impact**:
- Lost state updates
- Inconsistent UI state
- Assessment score calculation errors
- Progress tracking inaccuracies

**Mitigation**:
- Use immutable state with copy-on-write
- Implement StateNotifier with proper update methods
- Use AsyncNotifier for async state updates
- Add state validation and consistency checks
- Consider using state machines for complex state

**Status**: DOCUMENTED - Requires provider audit

---

## Testing Strategy

### Current Test Coverage

1. **Concurrency Tests**: `test/advanced/advanced_disabled/concurrency_race_conditions_test.dart`
   - 9 test groups covering major concurrency scenarios
   - Tests are disabled (in `advanced_disabled` folder)
   - Need to be enabled and run regularly

2. **Performance Tests**: `test/integration/performance_stress_test.dart`
   - Tests concurrent operations at scale
   - Validates data integrity under load
   - Performance benchmarks established

### Gaps in Testing

1. **UI State Race Conditions**: Need widget tests with concurrent setState
2. **Provider Race Conditions**: Need tests for concurrent provider updates
3. **Real-world Scenarios**: Need integration tests for actual user workflows
4. **Long-running Tests**: Need soak tests (24+ hours) to detect slow leaks

### Recommended Test Additions

1. Create `test/concurrency/widget_state_race_conditions_test.dart`
2. Create `test/concurrency/provider_concurrent_access_test.dart`
3. Enable existing concurrency tests in CI/CD pipeline
4. Add chaos testing for random timing variations

---

## Monitoring and Detection

### Production Monitoring

To detect race conditions in production:

1. **Crash Analytics**: Monitor for setState() after dispose errors
2. **Performance Metrics**: Track slow database operations
3. **User Reports**: Look for inconsistent behavior patterns
4. **Automated Alerts**: Set up alerts for:
   - High database lock wait times
   - Memory usage growth over time
   - Timer callback failures
   - State update failures

### Detection Strategies

1. **Code Review Checklist**:
   - [ ] All StatefulWidget classes have proper dispose()
   - [ ] All Timer instances are cancelled
   - [ ] All Stream subscriptions are closed
   - [ ] setState() calls check widget.mounted
   - [ ] Database writes use transactions appropriately
   - [ ] Concurrent operations have proper error handling

2. **Static Analysis**:
   - Enable `cancel_subscriptions` lint rule
   - Enable `close_sinks` lint rule
   - Add custom lint rules for setState safety

3. **Runtime Checks**:
   - Add assertions in debug mode for concurrent access
   - Log all database transaction durations
   - Track timer creation and cancellation

---

## Remediation Priorities

### Immediate (This Sprint)

1. **Document all known race conditions** ✅ COMPLETE
2. **Audit StatefulWidget dispose() methods** - PENDING
3. **Enable concurrency tests in CI/CD** - PENDING
4. **Implement circuit breaker for exercise generation** - PENDING

### Short-term (Next Sprint)

1. **Refactor high-risk setState() usage to Riverpod**
2. **Add state update synchronization primitives**
3. **Implement comprehensive error handling**
4. **Add production monitoring and alerts**

### Long-term (Before Production)

1. **Full codebase audit for concurrency issues**
2. **Soak testing (24+ hours)**
3. **Chaos testing with random failures**
4. **Performance testing under realistic load**

---

## References

- SQLite Concurrency: https://www.sqlite.org/lockingv3.html
- Dart Async Programming: https://dart.dev/codelabs/async-await
- Flutter State Management: https://docs.flutter.dev/development/data-and-backend/state-mgmt
- Riverpod Best Practices: https://riverpod.dev/docs/concepts/reading

---

## Appendix: Code Examples

### Safe setState Pattern

```dart
class SafeWidget extends StatefulWidget {
  @override
  State<SafeWidget> createState() => _SafeWidgetState();
}

class _SafeWidgetState extends State<SafeWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), _onTimer);
  }

  void _onTimer(Timer timer) {
    if (!mounted) return;  // Safety check
    setState(() {
      // Update state
    });
  }

  @override
  void dispose() {
    _timer.cancel();  // Clean up
    super.dispose();
  }
}
```

### Safe Provider Pattern

```dart
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  // Atomic increment - no race condition
  void increment() {
    state = state + 1;
  }
}

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});
```

### Safe Database Pattern

```dart
Future<void> safeBulkInsert(List<Item> items) async {
  await database.transaction(() async {
    for (final item in items) {
      await database.into(database.items).insert(item);
    }
  });
}
```
