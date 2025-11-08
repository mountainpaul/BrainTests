import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

/// Production Monitoring and Alerts
///
/// Provides monitoring infrastructure for production applications to track
/// performance, errors, and system health.

/// Operation metrics
class OperationMetrics {
  final String operationName;
  final int count;
  final Duration totalDuration;
  final List<Duration> _durations = [];

  OperationMetrics({
    required this.operationName,
    required this.count,
    required this.totalDuration,
  });

  Duration get averageDuration {
    if (count == 0) return Duration.zero;
    return Duration(microseconds: totalDuration.inMicroseconds ~/ count);
  }

  Duration get p50 => _percentile(0.50);
  Duration get p95 => _percentile(0.95);
  Duration get p99 => _percentile(0.99);

  Duration _percentile(double p) {
    if (_durations.isEmpty) return Duration.zero;
    final sorted = List<Duration>.from(_durations)..sort((a, b) => a.compareTo(b));
    final index = (sorted.length * p).ceil() - 1;
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  void _addDuration(Duration duration) {
    _durations.add(duration);
  }
}

/// Tracked stopwatch that records metrics on stop
class _TrackedStopwatch extends Stopwatch {
  final String operationName;
  final void Function(String, Duration) onStop;

  _TrackedStopwatch(this.operationName, this.onStop);

  @override
  void stop() {
    super.stop();
    onStop(operationName, elapsed);
  }
}

/// Performance monitor
class PerformanceMonitor {
  final Map<String, OperationMetrics> _metrics = {};
  final Map<String, List<Duration>> _durations = {};

  /// Start tracking an operation
  Stopwatch startOperation(String operationName) {
    final stopwatch = _TrackedStopwatch(operationName, _recordDuration)..start();
    return stopwatch;
  }

  /// Record a custom metric value
  void recordMetric(String name, double value) {
    _recordDuration(name, Duration(microseconds: (value * 1000).toInt()));
  }

  void _recordDuration(String operationName, Duration duration) {
    _durations.putIfAbsent(operationName, () => []);
    _durations[operationName]!.add(duration);

    final existing = _metrics[operationName];
    if (existing == null) {
      final metrics = OperationMetrics(
        operationName: operationName,
        count: 1,
        totalDuration: duration,
      );
      metrics._addDuration(duration);
      _metrics[operationName] = metrics;
    } else {
      final metrics = OperationMetrics(
        operationName: operationName,
        count: existing.count + 1,
        totalDuration: existing.totalDuration + duration,
      );
      // Copy existing durations
      for (final d in existing._durations) {
        metrics._addDuration(d);
      }
      metrics._addDuration(duration);
      _metrics[operationName] = metrics;
    }
  }

  /// Get metrics for an operation
  OperationMetrics? getMetrics(String operationName) {
    return _metrics[operationName];
  }

  /// Export all metrics
  Map<String, OperationMetrics> exportMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// Reset all metrics
  void reset() {
    _metrics.clear();
    _durations.clear();
  }

  /// Dispose monitor
  void dispose() {
    reset();
  }
}

/// Alert severity
enum AlertSeverity {
  info,
  warning,
  critical,
}

/// Alert definition
class AlertDefinition {
  final String name;
  final Duration threshold;
  final AlertSeverity severity;

  AlertDefinition({
    required this.name,
    required this.threshold,
    required this.severity,
  });
}

/// Alert event
class AlertEvent {
  final String name;
  final Duration value;
  final Duration threshold;
  final AlertSeverity severity;
  final DateTime timestamp;

  AlertEvent({
    required this.name,
    required this.value,
    required this.threshold,
    required this.severity,
    required this.timestamp,
  });
}

/// Alert manager
class AlertManager {
  final int maxHistorySize;
  final Map<String, AlertDefinition> _alerts = {};
  final Queue<AlertEvent> _history = Queue();
  void Function(AlertEvent event)? onAlert;

  AlertManager({this.maxHistorySize = 100});

  /// Register an alert threshold
  void registerAlert({
    required String name,
    required Duration threshold,
    required AlertSeverity severity,
  }) {
    _alerts[name] = AlertDefinition(
      name: name,
      threshold: threshold,
      severity: severity,
    );
  }

  /// Check if value exceeds threshold
  void checkThreshold(String name, Duration value) {
    final alert = _alerts[name];
    if (alert == null) return;

    if (value > alert.threshold) {
      final event = AlertEvent(
        name: name,
        value: value,
        threshold: alert.threshold,
        severity: alert.severity,
        timestamp: DateTime.now(),
      );

      _history.addFirst(event);
      while (_history.length > maxHistorySize) {
        _history.removeLast();
      }

      onAlert?.call(event);
    }
  }

  /// Get registered alerts
  List<AlertDefinition> getRegisteredAlerts() {
    return List.unmodifiable(_alerts.values);
  }

  /// Get alert history
  List<AlertEvent> getAlertHistory() {
    return List.unmodifiable(_history);
  }
}

/// Health check status
enum HealthStatus {
  healthy,
  degraded,
  unhealthy,
}

/// Health check result
class HealthCheckResult {
  final String name;
  final HealthStatus status;
  final Duration duration;
  final DateTime timestamp;
  final String? message;

  HealthCheckResult({
    required this.name,
    required this.status,
    required this.duration,
    required this.timestamp,
    this.message,
  });
}

/// Health check system
class HealthCheckSystem {
  final Map<String, Future<HealthStatus> Function()> _checks = {};

  /// Register a health check
  void registerCheck({
    required String name,
    required Future<HealthStatus> Function() check,
  }) {
    _checks[name] = check;
  }

  /// Run a specific health check
  Future<HealthCheckResult> runCheck(String name) async {
    final check = _checks[name];
    if (check == null) {
      throw ArgumentError('Health check not found: $name');
    }

    final stopwatch = Stopwatch()..start();
    final status = await check();
    stopwatch.stop();

    return HealthCheckResult(
      name: name,
      status: status,
      duration: stopwatch.elapsed,
      timestamp: DateTime.now(),
    );
  }

  /// Run all health checks
  Future<Map<String, HealthCheckResult>> runAllChecks() async {
    final results = <String, HealthCheckResult>{};

    for (final name in _checks.keys) {
      results[name] = await runCheck(name);
    }

    return results;
  }

  /// Get overall health status
  Future<HealthStatus> getOverallHealth() async {
    final results = await runAllChecks();

    if (results.values.any((r) => r.status == HealthStatus.unhealthy)) {
      return HealthStatus.unhealthy;
    }

    if (results.values.any((r) => r.status == HealthStatus.degraded)) {
      return HealthStatus.degraded;
    }

    return HealthStatus.healthy;
  }

  /// Get list of registered check names
  List<String> getRegisteredChecks() {
    return List.unmodifiable(_checks.keys);
  }
}

/// Anomaly detector using statistical methods
class AnomalyDetector {
  final Map<String, _ThresholdConfig> _thresholds = {};
  final Map<String, int> _anomalyCounts = {};

  /// Set threshold for anomaly detection
  void setThreshold(String metric, {required double mean, required double stdDev}) {
    _thresholds[metric] = _ThresholdConfig(mean: mean, stdDev: stdDev);
  }

  /// Learn baseline from sample data
  void learnBaseline(String metric, List<double> samples) {
    if (samples.isEmpty) return;

    final mean = samples.reduce((a, b) => a + b) / samples.length;
    final variance = samples.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / samples.length;
    final stdDev = math.sqrt(variance);

    setThreshold(metric, mean: mean, stdDev: stdDev);
  }

  /// Check if value is an anomaly
  bool isAnomaly(String metric, double value) {
    final config = _thresholds[metric];
    if (config == null) return false;

    // Using 3-sigma rule: value is anomaly if beyond 3 standard deviations
    final distance = (value - config.mean).abs();
    final isAnomalous = distance > (config.stdDev * 3);

    if (isAnomalous) {
      _anomalyCounts[metric] = (_anomalyCounts[metric] ?? 0) + 1;
    }

    return isAnomalous;
  }

  /// Get anomaly count for metric
  int getAnomalyCount(String metric) {
    return _anomalyCounts[metric] ?? 0;
  }

  /// Reset anomaly count
  void resetCount(String metric) {
    _anomalyCounts[metric] = 0;
  }
}

class _ThresholdConfig {
  final double mean;
  final double stdDev;

  _ThresholdConfig({required this.mean, required this.stdDev});
}

/// Metrics exporter
class MetricsExporter {
  /// Export metrics as JSON
  static String toJson(Map<String, OperationMetrics> metrics) {
    final data = metrics.map((key, value) => MapEntry(
          key,
          {
            'operation_name': value.operationName,
            'count': value.count,
            'total_duration_ms': value.totalDuration.inMilliseconds,
            'average_duration_ms': value.averageDuration.inMilliseconds,
            'p50_ms': value.p50.inMilliseconds,
            'p95_ms': value.p95.inMilliseconds,
            'p99_ms': value.p99.inMilliseconds,
          },
        ));

    return jsonEncode(data);
  }

  /// Export metrics as CSV
  static String toCsv(Map<String, OperationMetrics> metrics) {
    final lines = <String>[
      'operation_name,count,total_ms,average_ms,p50_ms,p95_ms,p99_ms',
    ];

    for (final metric in metrics.values) {
      lines.add([
        metric.operationName,
        metric.count,
        metric.totalDuration.inMilliseconds,
        metric.averageDuration.inMilliseconds,
        metric.p50.inMilliseconds,
        metric.p95.inMilliseconds,
        metric.p99.inMilliseconds,
      ].join(','));
    }

    return lines.join('\n');
  }
}
