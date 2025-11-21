import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_provider.g.dart';

/// State class for timers
class TimerState {
  final int remainingSeconds;
  final bool isRunning;
  final bool isCompleted;
  final int elapsedSeconds; // For stopwatch

  const TimerState({
    this.remainingSeconds = 0,
    this.isRunning = false,
    this.isCompleted = false,
    this.elapsedSeconds = 0,
  });

  String get formattedTime {
    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  TimerState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    bool? isCompleted,
    int? elapsedSeconds,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

@riverpod
class CountdownTimer extends _$CountdownTimer {
  Timer? _timer;

  @override
  TimerState build(int initialSeconds) {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return TimerState(remainingSeconds: initialSeconds);
  }

  void start() {
    if (state.isRunning || state.isCompleted) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(
          remainingSeconds: 0,
          isRunning: false,
          isCompleted: true,
        );
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    // initialSeconds is available as 'arg' in Riverpod 2.x family notifiers
    // but generated code handles it. For now, we'll just reset to what we started with if possible,
    // or 0 if we don't track initial.
    // Actually, the build arg is 'initialSeconds', so we can reuse it if we tracked it?
    // Riverpod family providers rebuild when parameters change.
    // But 'reset' usually means go back to start.
    // Let's reset to the initial value passed to build.
    state = TimerState(remainingSeconds: initialSeconds);
  }

  void addTime(int seconds) {
    state = state.copyWith(
      remainingSeconds: state.remainingSeconds + seconds,
      isCompleted: false,
    );
  }

  void subtractTime(int seconds) {
    final newTime = state.remainingSeconds - seconds;
    if (newTime <= 0) {
      _timer?.cancel();
      state = state.copyWith(
        remainingSeconds: 0,
        isCompleted: true,
        isRunning: false,
      );
    } else {
      state = state.copyWith(remainingSeconds: newTime);
    }
  }
}

@riverpod
class Stopwatch extends _$Stopwatch {
  Timer? _timer;

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const TimerState();
  }

  void start() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    state = const TimerState();
  }
}