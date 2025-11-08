// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Safe timer notifier using Riverpod
///
/// Replaces unsafe Timer + setState patterns:
/// - Automatic cleanup on dispose
/// - Thread-safe state updates
/// - No setState() after dispose errors
/// - Memory leak prevention

@ProviderFor(CountdownTimer)
const countdownTimerProvider = CountdownTimerFamily._();

/// Safe timer notifier using Riverpod
///
/// Replaces unsafe Timer + setState patterns:
/// - Automatic cleanup on dispose
/// - Thread-safe state updates
/// - No setState() after dispose errors
/// - Memory leak prevention
final class CountdownTimerProvider
    extends $NotifierProvider<CountdownTimer, TimerState> {
  /// Safe timer notifier using Riverpod
  ///
  /// Replaces unsafe Timer + setState patterns:
  /// - Automatic cleanup on dispose
  /// - Thread-safe state updates
  /// - No setState() after dispose errors
  /// - Memory leak prevention
  const CountdownTimerProvider._(
      {required CountdownTimerFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'countdownTimerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$countdownTimerHash();

  @override
  String toString() {
    return r'countdownTimerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CountdownTimer create() => CountdownTimer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CountdownTimerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$countdownTimerHash() => r'25710cc1a81c1827482b2a7a214ec2dc986d50c4';

/// Safe timer notifier using Riverpod
///
/// Replaces unsafe Timer + setState patterns:
/// - Automatic cleanup on dispose
/// - Thread-safe state updates
/// - No setState() after dispose errors
/// - Memory leak prevention

final class CountdownTimerFamily extends $Family
    with
        $ClassFamilyOverride<CountdownTimer, TimerState, TimerState, TimerState,
            int> {
  const CountdownTimerFamily._()
      : super(
          retry: null,
          name: r'countdownTimerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Safe timer notifier using Riverpod
  ///
  /// Replaces unsafe Timer + setState patterns:
  /// - Automatic cleanup on dispose
  /// - Thread-safe state updates
  /// - No setState() after dispose errors
  /// - Memory leak prevention

  CountdownTimerProvider call(
    int durationSeconds,
  ) =>
      CountdownTimerProvider._(argument: durationSeconds, from: this);

  @override
  String toString() => r'countdownTimerProvider';
}

/// Safe timer notifier using Riverpod
///
/// Replaces unsafe Timer + setState patterns:
/// - Automatic cleanup on dispose
/// - Thread-safe state updates
/// - No setState() after dispose errors
/// - Memory leak prevention

abstract class _$CountdownTimer extends $Notifier<TimerState> {
  late final _$args = ref.$arg as int;
  int get durationSeconds => _$args;

  TimerState build(
    int durationSeconds,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<TimerState, TimerState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TimerState, TimerState>, TimerState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

/// Stopwatch notifier (counts up)

@ProviderFor(Stopwatch)
const stopwatchProvider = StopwatchProvider._();

/// Stopwatch notifier (counts up)
final class StopwatchProvider
    extends $NotifierProvider<Stopwatch, StopwatchState> {
  /// Stopwatch notifier (counts up)
  const StopwatchProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'stopwatchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$stopwatchHash();

  @$internal
  @override
  Stopwatch create() => Stopwatch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StopwatchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StopwatchState>(value),
    );
  }
}

String _$stopwatchHash() => r'b15e92bfc3bdddbf4205314169a0ae2ff3a4035e';

/// Stopwatch notifier (counts up)

abstract class _$Stopwatch extends $Notifier<StopwatchState> {
  StopwatchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<StopwatchState, StopwatchState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<StopwatchState, StopwatchState>,
        StopwatchState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
