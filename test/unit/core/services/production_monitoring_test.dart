import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/core/services/production_monitoring.dart';

/// TDD for Production Monitoring and Alerts
///
/// Provides monitoring infrastructure for production applications to track
/// performance, errors, and system health.
///
/// Features:
/// - Performance metrics collection
/// - Alert thresholds and notifications
/// - Health check system
/// - Metrics export for analysis
/// - Anomaly detection
void main() {
  group('PerformanceMonitor', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor();
    });

    tearDown(() {
      monitor.dispose();
    });

    test('should track operation duration', () {
      final stopwatch = monitor.startOperation('test_operation');
      stopwatch.stop();

      final metrics = monitor.getMetrics('test_operation');
      expect(metrics, isNotNull);
      expect(metrics!.count, 1);
      expect(metrics.totalDuration.inMicroseconds, greaterThan(0));
    });

    test('should calculate average duration', () async {
      for (int i = 0; i < 5; i++) {
        final stopwatch = monitor.startOperation('test_operation');
        await Future.delayed(const Duration(microseconds: 1));
        stopwatch.stop();
      }

      final metrics = monitor.getMetrics('test_operation');
      expect(metrics!.count, 5);
      expect(metrics.averageDuration.inMicroseconds, greaterThanOrEqualTo(0));
    });

    test('should track multiple operations', () {
      monitor.startOperation('op1').stop();
      monitor.startOperation('op2').stop();
      monitor.startOperation('op1').stop();

      expect(monitor.getMetrics('op1')!.count, 2);
      expect(monitor.getMetrics('op2')!.count, 1);
    });

    test('should track P50, P95, P99 percentiles', () {
      // Create operations with known durations
      for (int i = 1; i <= 100; i++) {
        final stopwatch = monitor.startOperation('test_operation');
        // Simulate variable durations
        stopwatch.stop();
      }

      final metrics = monitor.getMetrics('test_operation');
      expect(metrics!.p50, isNotNull);
      expect(metrics.p95, isNotNull);
      expect(metrics.p99, isNotNull);
      expect(metrics.p95.inMicroseconds, greaterThanOrEqualTo(metrics.p50.inMicroseconds));
      expect(metrics.p99.inMicroseconds, greaterThanOrEqualTo(metrics.p95.inMicroseconds));
    });

    test('should export all metrics', () {
      monitor.startOperation('op1').stop();
      monitor.startOperation('op2').stop();

      final allMetrics = monitor.exportMetrics();
      expect(allMetrics.length, 2);
      expect(allMetrics.containsKey('op1'), true);
      expect(allMetrics.containsKey('op2'), true);
    });

    test('should reset metrics', () {
      monitor.startOperation('test_operation').stop();
      expect(monitor.getMetrics('test_operation')!.count, 1);

      monitor.reset();
      expect(monitor.getMetrics('test_operation'), isNull);
    });

    test('should record custom metric value', () {
      monitor.recordMetric('memory_usage_mb', 150.5);
      monitor.recordMetric('memory_usage_mb', 160.2);

      final metrics = monitor.getMetrics('memory_usage_mb');
      expect(metrics!.count, 2);
    });
  });

  group('AlertManager', () {
    late AlertManager alertManager;

    setUp(() {
      alertManager = AlertManager();
    });

    test('should register alert threshold', () {
      alertManager.registerAlert(
        name: 'slow_query',
        threshold: const Duration(seconds: 1),
        severity: AlertSeverity.warning,
      );

      final alerts = alertManager.getRegisteredAlerts();
      expect(alerts.length, 1);
      expect(alerts.first.name, 'slow_query');
    });

    test('should trigger alert when threshold exceeded', () {
      bool alertTriggered = false;

      alertManager.onAlert = (alert) {
        alertTriggered = true;
      };

      alertManager.registerAlert(
        name: 'slow_query',
        threshold: const Duration(milliseconds: 10),
        severity: AlertSeverity.warning,
      );

      alertManager.checkThreshold('slow_query', const Duration(milliseconds: 20));

      expect(alertTriggered, true);
    });

    test('should not trigger alert when below threshold', () {
      bool alertTriggered = false;

      alertManager.onAlert = (alert) {
        alertTriggered = true;
      };

      alertManager.registerAlert(
        name: 'slow_query',
        threshold: const Duration(milliseconds: 100),
        severity: AlertSeverity.warning,
      );

      alertManager.checkThreshold('slow_query', const Duration(milliseconds: 50));

      expect(alertTriggered, false);
    });

    test('should categorize alerts by severity', () {
      alertManager.registerAlert(
        name: 'warning_alert',
        threshold: const Duration(milliseconds: 100),
        severity: AlertSeverity.warning,
      );
      alertManager.registerAlert(
        name: 'critical_alert',
        threshold: const Duration(milliseconds: 100),
        severity: AlertSeverity.critical,
      );

      final alerts = alertManager.getRegisteredAlerts();
      expect(alerts.where((a) => a.severity == AlertSeverity.warning).length, 1);
      expect(alerts.where((a) => a.severity == AlertSeverity.critical).length, 1);
    });

    test('should track alert history', () {
      alertManager.registerAlert(
        name: 'test_alert',
        threshold: const Duration(milliseconds: 10),
        severity: AlertSeverity.warning,
      );

      alertManager.checkThreshold('test_alert', const Duration(milliseconds: 20));
      alertManager.checkThreshold('test_alert', const Duration(milliseconds: 30));

      final history = alertManager.getAlertHistory();
      expect(history.length, 2);
    });

    test('should limit alert history size', () {
      final manager = AlertManager(maxHistorySize: 3);

      manager.registerAlert(
        name: 'test_alert',
        threshold: const Duration(milliseconds: 10),
        severity: AlertSeverity.warning,
      );

      for (int i = 0; i < 5; i++) {
        manager.checkThreshold('test_alert', const Duration(milliseconds: 20));
      }

      expect(manager.getAlertHistory().length, 3);
    });
  });

  group('HealthCheck', () {
    late HealthCheckSystem healthCheck;

    setUp(() {
      healthCheck = HealthCheckSystem();
    });

    test('should register health check', () {
      healthCheck.registerCheck(
        name: 'database',
        check: () async => HealthStatus.healthy,
      );

      final checks = healthCheck.getRegisteredChecks();
      expect(checks.length, 1);
      expect(checks.first, 'database');
    });

    test('should run health check and return healthy', () async {
      healthCheck.registerCheck(
        name: 'database',
        check: () async => HealthStatus.healthy,
      );

      final result = await healthCheck.runCheck('database');
      expect(result.status, HealthStatus.healthy);
    });

    test('should run health check and return unhealthy', () async {
      healthCheck.registerCheck(
        name: 'api',
        check: () async => HealthStatus.unhealthy,
      );

      final result = await healthCheck.runCheck('api');
      expect(result.status, HealthStatus.unhealthy);
    });

    test('should run all health checks', () async {
      healthCheck.registerCheck(
        name: 'database',
        check: () async => HealthStatus.healthy,
      );
      healthCheck.registerCheck(
        name: 'api',
        check: () async => HealthStatus.healthy,
      );

      final results = await healthCheck.runAllChecks();
      expect(results.length, 2);
      expect(results['database']?.status, HealthStatus.healthy);
      expect(results['api']?.status, HealthStatus.healthy);
    });

    test('should mark check as degraded', () async {
      healthCheck.registerCheck(
        name: 'cache',
        check: () async => HealthStatus.degraded,
      );

      final result = await healthCheck.runCheck('cache');
      expect(result.status, HealthStatus.degraded);
    });

    test('should include check duration', () async {
      healthCheck.registerCheck(
        name: 'database',
        check: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return HealthStatus.healthy;
        },
      );

      final result = await healthCheck.runCheck('database');
      expect(result.duration.inMilliseconds, greaterThanOrEqualTo(10));
    });

    test('should get overall health status', () async {
      healthCheck.registerCheck(
        name: 'database',
        check: () async => HealthStatus.healthy,
      );
      healthCheck.registerCheck(
        name: 'api',
        check: () async => HealthStatus.healthy,
      );

      final overall = await healthCheck.getOverallHealth();
      expect(overall, HealthStatus.healthy);
    });

    test('should return unhealthy if any check fails', () async {
      healthCheck.registerCheck(
        name: 'database',
        check: () async => HealthStatus.healthy,
      );
      healthCheck.registerCheck(
        name: 'api',
        check: () async => HealthStatus.unhealthy,
      );

      final overall = await healthCheck.getOverallHealth();
      expect(overall, HealthStatus.unhealthy);
    });

    test('should return degraded if any check is degraded', () async {
      healthCheck.registerCheck(
        name: 'database',
        check: () async => HealthStatus.healthy,
      );
      healthCheck.registerCheck(
        name: 'cache',
        check: () async => HealthStatus.degraded,
      );

      final overall = await healthCheck.getOverallHealth();
      expect(overall, HealthStatus.degraded);
    });
  });

  group('AnomalyDetector', () {
    late AnomalyDetector detector;

    setUp(() {
      detector = AnomalyDetector();
    });

    test('should detect anomaly when value exceeds threshold', () {
      detector.setThreshold('response_time', mean: 100, stdDev: 20);

      // Value beyond 3 standard deviations
      final isAnomaly = detector.isAnomaly('response_time', 200);
      expect(isAnomaly, true);
    });

    test('should not detect anomaly for normal values', () {
      detector.setThreshold('response_time', mean: 100, stdDev: 20);

      // Value within 3 standard deviations
      final isAnomaly = detector.isAnomaly('response_time', 110);
      expect(isAnomaly, false);
    });

    test('should learn baseline from samples', () {
      final samples = [100.0, 110.0, 95.0, 105.0, 98.0, 102.0];

      detector.learnBaseline('response_time', samples);

      // Normal value should not be anomaly
      expect(detector.isAnomaly('response_time', 103), false);

      // Outlier should be anomaly
      expect(detector.isAnomaly('response_time', 200), true);
    });

    test('should track anomaly count', () {
      detector.setThreshold('response_time', mean: 100, stdDev: 10);

      detector.isAnomaly('response_time', 200); // anomaly
      detector.isAnomaly('response_time', 105); // normal
      detector.isAnomaly('response_time', 210); // anomaly

      final count = detector.getAnomalyCount('response_time');
      expect(count, 2);
    });

    test('should reset anomaly count', () {
      detector.setThreshold('response_time', mean: 100, stdDev: 10);

      detector.isAnomaly('response_time', 200);
      expect(detector.getAnomalyCount('response_time'), 1);

      detector.resetCount('response_time');
      expect(detector.getAnomalyCount('response_time'), 0);
    });
  });

  group('MetricsExporter', () {
    test('should export metrics as JSON', () {
      final metrics = {
        'insert_time': OperationMetrics(
          operationName: 'insert_time',
          count: 100,
          totalDuration: const Duration(milliseconds: 5000),
        ),
        'query_time': OperationMetrics(
          operationName: 'query_time',
          count: 200,
          totalDuration: const Duration(milliseconds: 3000),
        ),
      };

      final json = MetricsExporter.toJson(metrics);

      expect(json, contains('insert_time'));
      expect(json, contains('query_time'));
      expect(json, contains('"count":100'));
      expect(json, contains('"count":200'));
    });

    test('should export metrics as CSV', () {
      final metrics = {
        'insert_time': OperationMetrics(
          operationName: 'insert_time',
          count: 100,
          totalDuration: const Duration(milliseconds: 5000),
        ),
      };

      final csv = MetricsExporter.toCsv(metrics);

      expect(csv, contains('operation_name'));
      expect(csv, contains('count'));
      expect(csv, contains('average_ms'));
      expect(csv, contains('insert_time'));
      expect(csv, contains('100'));
    });
  });
}
