// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CountdownTimer)
const countdownTimerProvider = CountdownTimerFamily._();

final class CountdownTimerProvider
    extends $NotifierProvider<CountdownTimer, TimerState> {
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

String _$countdownTimerHash() => r'c37aa33fb4ff1b64300c8afd20ddec752983567f';

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

  CountdownTimerProvider call(
    int initialSeconds,
  ) =>
      CountdownTimerProvider._(argument: initialSeconds, from: this);

  @override
  String toString() => r'countdownTimerProvider';
}

abstract class _$CountdownTimer extends $Notifier<TimerState> {
  late final _$args = ref.$arg as int;
  int get initialSeconds => _$args;

  TimerState build(
    int initialSeconds,
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

@ProviderFor(Stopwatch)
const stopwatchProvider = StopwatchProvider._();

final class StopwatchProvider extends $NotifierProvider<Stopwatch, TimerState> {
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
  Override overrideWithValue(TimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimerState>(value),
    );
  }
}

String _$stopwatchHash() => r'10bfaeeb511baa2b67eec73c2493bfcce1fb08a5';

abstract class _$Stopwatch extends $Notifier<TimerState> {
  TimerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TimerState, TimerState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TimerState, TimerState>, TimerState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
