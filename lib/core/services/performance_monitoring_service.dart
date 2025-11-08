import 'dart:developer' as developer;
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';

/// Enhanced performance monitoring service for real-time dashboards
/// Provides comprehensive performance tracking for the Brain Plan app
class PerformanceMonitoringService {
  static bool _isInitialized = false;
  static FirebasePerformance? _performance;
  static final Map<String, Trace> _activeTraces = {};
  static final Map<String, Stopwatch> _localTraces = {};

  /// Initialize performance monitoring
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (!kDebugMode) {
        _performance = FirebasePerformance.instance;
        developer.log('Performance monitoring initialized', name: 'PerformanceMonitor');
      } else {
        developer.log('Performance monitoring disabled in debug mode', name: 'PerformanceMonitor');
      }
      _isInitialized = true;
    } catch (e) {
      developer.log('Failed to initialize performance monitoring: $e', name: 'PerformanceMonitor');
    }
  }

  /// Start a custom performance trace
  static Future<void> startTrace(String traceName) async {
    try {
      if (_performance != null) {
        final trace = _performance!.newTrace(traceName);
        await trace.start();
        _activeTraces[traceName] = trace;
      }

      // Always track locally for debugging
      _localTraces[traceName] = Stopwatch()..start();

      developer.log('Started trace: $traceName', name: 'PerformanceMonitor');
    } catch (e) {
      developer.log('Failed to start trace $traceName: $e', name: 'PerformanceMonitor');
    }
  }

  /// Stop a custom performance trace
  static Future<void> stopTrace(String traceName, {Map<String, String>? attributes}) async {
    try {
      // Stop Firebase trace
      final trace = _activeTraces.remove(traceName);
      if (trace != null) {
        if (attributes != null) {
          for (final entry in attributes.entries) {
            trace.putAttribute(entry.key, entry.value);
          }
        }
        await trace.stop();
      }

      // Stop local trace
      final localTrace = _localTraces.remove(traceName);
      if (localTrace != null) {
        localTrace.stop();
        developer.log(
          'Completed trace: $traceName (${localTrace.elapsedMilliseconds}ms)',
          name: 'PerformanceMonitor',
        );
      }
    } catch (e) {
      developer.log('Failed to stop trace $traceName: $e', name: 'PerformanceMonitor');
    }
  }

  /// Track assessment performance
  static Future<void> trackAssessmentPerformance(
    String assessmentType,
    Duration duration,
    Map<String, dynamic> metrics,
  ) async {
    try {
      final traceName = 'assessment_$assessmentType';

      if (_performance != null) {
        final trace = _performance!.newTrace(traceName);
        trace.putAttribute('assessment_type', assessmentType);
        trace.setMetric('duration_ms', duration.inMilliseconds);

        // Add custom metrics
        for (final entry in metrics.entries) {
          if (entry.value is int) {
            trace.setMetric(entry.key, entry.value as int);
          } else if (entry.value is String) {
            trace.putAttribute(entry.key, entry.value as String);
          }
        }
      }

      // Log comprehensive assessment metrics
      await AnalyticsService.logEvent('assessment_performance', parameters: {
        'assessment_type': assessmentType,
        'duration_seconds': duration.inSeconds,
        'duration_ms': duration.inMilliseconds,
        ...metrics.map((k, v) => MapEntry(k, v.toString())),
      });

      developer.log(
        'Assessment performance tracked: $assessmentType (${duration.inSeconds}s)',
        name: 'PerformanceMonitor',
      );
    } catch (e) {
      developer.log('Failed to track assessment performance: $e', name: 'PerformanceMonitor');
    }
  }

  /// Track screen loading performance
  static Future<void> trackScreenLoadTime(String screenName, Duration loadTime) async {
    try {
      const traceName = 'screen_load_time';

      if (_performance != null) {
        final trace = _performance!.newTrace(traceName);
        trace.putAttribute('screen_name', screenName);
        trace.setMetric('load_time_ms', loadTime.inMilliseconds);
      }

      await AnalyticsService.logEvent('screen_load_performance', parameters: {
        'screen_name': screenName,
        'load_time_ms': loadTime.inMilliseconds,
        'load_time_seconds': loadTime.inSeconds,
      });

      developer.log(
        'Screen load tracked: $screenName (${loadTime.inMilliseconds}ms)',
        name: 'PerformanceMonitor',
      );
    } catch (e) {
      developer.log('Failed to track screen load time: $e', name: 'PerformanceMonitor');
    }
  }

  /// Track database operation performance
  static Future<void> trackDatabaseOperation(
    String operation,
    String table,
    Duration duration,
    int rowCount,
  ) async {
    try {
      const traceName = 'database_operation';

      if (_performance != null) {
        final trace = _performance!.newTrace(traceName);
        trace.putAttribute('operation', operation);
        trace.putAttribute('table', table);
        trace.setMetric('duration_ms', duration.inMilliseconds);
        trace.setMetric('row_count', rowCount);
      }

      await AnalyticsService.logEvent('database_performance', parameters: {
        'operation': operation,
        'table': table,
        'duration_ms': duration.inMilliseconds,
        'row_count': rowCount,
      });

      developer.log(
        'Database operation tracked: $operation on $table (${duration.inMilliseconds}ms, $rowCount rows)',
        name: 'PerformanceMonitor',
      );
    } catch (e) {
      developer.log('Failed to track database operation: $e', name: 'PerformanceMonitor');
    }
  }

  /// Track network request performance
  static Future<void> trackNetworkRequest(
    String url,
    String method,
    Duration duration,
    int statusCode,
    int responseSize,
  ) async {
    try {
      const traceName = 'network_request';

      if (_performance != null) {
        final trace = _performance!.newTrace(traceName);
        trace.putAttribute('url', url);
        trace.putAttribute('method', method);
        trace.putAttribute('status_code', statusCode.toString());
        trace.setMetric('duration_ms', duration.inMilliseconds);
        trace.setMetric('response_size', responseSize);
      }

      await AnalyticsService.logEvent('network_performance', parameters: {
        'url': url,
        'method': method,
        'status_code': statusCode,
        'duration_ms': duration.inMilliseconds,
        'response_size': responseSize,
      });

      developer.log(
        'Network request tracked: $method $url ($statusCode, ${duration.inMilliseconds}ms)',
        name: 'PerformanceMonitor',
      );
    } catch (e) {
      developer.log('Failed to track network request: $e', name: 'PerformanceMonitor');
    }
  }

  /// Track app startup performance
  static Future<void> trackAppStartup(Duration startupTime) async {
    try {
      const traceName = 'app_startup';

      if (_performance != null) {
        final trace = _performance!.newTrace(traceName);
        trace.setMetric('startup_time_ms', startupTime.inMilliseconds);
      }

      await AnalyticsService.logEvent('app_startup_performance', parameters: {
        'startup_time_ms': startupTime.inMilliseconds,
        'startup_time_seconds': startupTime.inSeconds,
      });

      developer.log(
        'App startup tracked: ${startupTime.inMilliseconds}ms',
        name: 'PerformanceMonitor',
      );
    } catch (e) {
      developer.log('Failed to track app startup: $e', name: 'PerformanceMonitor');
    }
  }

  /// Track memory usage
  static Future<void> trackMemoryUsage(int memoryUsageMB) async {
    try {
      const traceName = 'memory_usage';

      if (_performance != null) {
        final trace = _performance!.newTrace(traceName);
        trace.setMetric('memory_usage_mb', memoryUsageMB);
      }

      await AnalyticsService.logEvent('memory_performance', parameters: {
        'memory_usage_mb': memoryUsageMB,
      });

      developer.log('Memory usage tracked: ${memoryUsageMB}MB', name: 'PerformanceMonitor');
    } catch (e) {
      developer.log('Failed to track memory usage: $e', name: 'PerformanceMonitor');
    }
  }

  /// Get active trace count for monitoring
  static int get activeTraceCount => _activeTraces.length;

  /// Check if performance monitoring is enabled
  static bool get isEnabled => _isInitialized && _performance != null;
}

/// Mixin for easy performance tracking in widgets and services
mixin PerformanceTracker {
  /// Track widget build performance
  Future<T> trackWidgetBuild<T>(String widgetName, Future<T> Function() buildOperation) async {
    final traceName = 'widget_build_$widgetName';
    await PerformanceMonitoringService.startTrace(traceName);

    try {
      final result = await buildOperation();
      await PerformanceMonitoringService.stopTrace(traceName);
      return result;
    } catch (e) {
      await PerformanceMonitoringService.stopTrace(traceName);
      rethrow;
    }
  }

  /// Track operation performance with automatic cleanup
  Future<T> trackOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    await PerformanceMonitoringService.startTrace(operationName);

    try {
      final result = await operation();
      await PerformanceMonitoringService.stopTrace(operationName, attributes: attributes);
      return result;
    } catch (e) {
      await PerformanceMonitoringService.stopTrace(operationName, attributes: attributes);
      rethrow;
    }
  }
}

/// Performance dashboard metrics aggregator
class PerformanceDashboard {
  static final Map<String, List<Duration>> _performanceHistory = {};

  /// Add performance data point
  static void addDataPoint(String metric, Duration duration) {
    _performanceHistory.putIfAbsent(metric, () => <Duration>[]);
    _performanceHistory[metric]!.add(duration);

    // Keep only last 100 data points for each metric
    if (_performanceHistory[metric]!.length > 100) {
      _performanceHistory[metric]!.removeAt(0);
    }
  }

  /// Get average performance for a metric
  static Duration? getAveragePerformance(String metric) {
    final durations = _performanceHistory[metric];
    if (durations == null || durations.isEmpty) return null;

    final totalMs = durations.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ durations.length);
  }

  /// Get performance statistics
  static Map<String, Map<String, dynamic>> getPerformanceStats() {
    final stats = <String, Map<String, dynamic>>{};

    for (final entry in _performanceHistory.entries) {
      final durations = entry.value;
      if (durations.isEmpty) continue;

      final sortedDurations = List<Duration>.from(durations)..sort((a, b) => a.compareTo(b));
      final totalMs = durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);

      stats[entry.key] = {
        'count': durations.length,
        'average_ms': totalMs ~/ durations.length,
        'min_ms': sortedDurations.first.inMilliseconds,
        'max_ms': sortedDurations.last.inMilliseconds,
        'median_ms': sortedDurations[sortedDurations.length ~/ 2].inMilliseconds,
      };
    }

    return stats;
  }

  /// Clear performance history
  static void clearHistory() {
    _performanceHistory.clear();
  }
}