import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Analytics and crash reporting service for production monitoring
/// This is a framework that can be integrated with Firebase Analytics,
/// Crashlytics, or other analytics services in production
class AnalyticsService {
  static bool _isInitialized = false;
  static bool _enableAnalytics = false;
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static FirebasePerformance? _performance;

  /// Initialize analytics service
  /// Initializes Firebase Analytics, Crashlytics, and Performance monitoring
  static Future<void> initialize({bool enableInDebug = false}) async {
    try {
      // Only enable analytics in production or when explicitly enabled
      _enableAnalytics = enableInDebug || _isProductionEnvironment();

      if (_enableAnalytics) {
        // Initialize Firebase (only if not already initialized)
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }

        // Initialize Firebase services
        _analytics = FirebaseAnalytics.instance;
        _crashlytics = FirebaseCrashlytics.instance;
        _performance = FirebasePerformance.instance;

        // Enable data collection
        await _analytics!.setAnalyticsCollectionEnabled(true);
        await _crashlytics!.setCrashlyticsCollectionEnabled(true);

        // Set up crash reporting for Flutter errors
        FlutterError.onError = _crashlytics!.recordFlutterError;

        // Handle async errors
        PlatformDispatcher.instance.onError = (error, stack) {
          _crashlytics!.recordError(error, stack, fatal: true);
          return true;
        };

        developer.log('Firebase Analytics & Crashlytics initialized', name: 'AnalyticsService');
      } else {
        developer.log('Analytics disabled (debug mode)', name: 'AnalyticsService');
      }

      _isInitialized = true;
    } catch (e) {
      developer.log('Failed to initialize analytics: $e', name: 'AnalyticsService');
      // Still mark as initialized in test environments
      _isInitialized = true;
    }
  }

  /// Log custom events for user behavior tracking
  static Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (!_enableAnalytics || _analytics == null) return;

    try {
      // Convert parameters to the correct type for Firebase
      final firebaseParameters = parameters?.map<String, Object>((key, value) =>
        MapEntry(key, (value is String || value is num || value is bool ? value : value.toString()) as Object));

      await _analytics!.logEvent(name: eventName, parameters: firebaseParameters);
      developer.log('Event logged: $eventName - ${parameters ?? {}}', name: 'Analytics');
    } catch (e) {
      developer.log('Failed to log event $eventName: $e', name: 'AnalyticsService');
    }
  }

  /// Log user properties for demographic analysis
  static Future<void> setUserProperties(Map<String, String> properties) async {
    if (!_enableAnalytics || _analytics == null) return;

    try {
      for (final entry in properties.entries) {
        await _analytics!.setUserProperty(
          name: entry.key,
          value: entry.value,
        );
      }

      developer.log('User properties set: $properties', name: 'Analytics');
    } catch (e) {
      developer.log('Failed to set user properties: $e', name: 'AnalyticsService');
    }
  }

  /// Record non-fatal errors for monitoring
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      if (_enableAnalytics && _crashlytics != null) {
        await _crashlytics!.recordError(
          exception,
          stackTrace,
          reason: reason,
          fatal: fatal,
        );
      }

      developer.log(
        'Error recorded: $exception${reason != null ? ' - $reason' : ''}',
        name: 'CrashReporting',
        error: exception,
        stackTrace: stackTrace,
      );
    } catch (e) {
      developer.log('Failed to record error: $e', name: 'AnalyticsService');
    }
  }

  /// Log performance metrics
  static Future<void> logPerformanceMetric(
    String metricName,
    Duration duration, {
    Map<String, String>? attributes,
  }) async {
    if (!_enableAnalytics || _performance == null) return;

    try {
      // Create performance trace
      final trace = _performance!.newTrace(metricName);

      // Set custom attributes if provided
      if (attributes != null) {
        for (final entry in attributes.entries) {
          trace.putAttribute(entry.key, entry.value);
        }
      }

      // Set duration metric
      trace.setMetric('duration_ms', duration.inMilliseconds);

      developer.log(
        'Performance: $metricName took ${duration.inMilliseconds}ms',
        name: 'Performance',
      );
    } catch (e) {
      developer.log('Failed to log performance metric: $e', name: 'AnalyticsService');
    }
  }

  /// Track screen views
  static Future<void> logScreenView(String screenName, {String? screenClass}) async {
    if (!_enableAnalytics || _analytics == null) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );

      developer.log('Screen view logged: $screenName', name: 'Analytics');
    } catch (e) {
      developer.log('Failed to log screen view: $e', name: 'AnalyticsService');
    }
  }

  /// Track assessment completions
  static Future<void> logAssessmentCompleted(
    String assessmentType,
    double score,
    Duration timeTaken,
  ) async {
    await logEvent('assessment_completed', parameters: {
      'assessment_type': assessmentType,
      'score': score,
      'time_taken_seconds': timeTaken.inSeconds,
    });
  }

  /// Track exercise completions
  static Future<void> logExerciseCompleted(
    String exerciseType,
    int difficulty,
    double score,
  ) async {
    await logEvent('exercise_completed', parameters: {
      'exercise_type': exerciseType,
      'difficulty': difficulty,
      'score': score,
    });
  }

  /// Track mood entries
  static Future<void> logMoodEntry(String mood, int energy, int anxiety) async {
    await logEvent('mood_entry_logged', parameters: {
      'mood': mood,
      'energy_level': energy,
      'anxiety_level': anxiety,
    });
  }

  /// Track reminder interactions
  static Future<void> logReminderInteraction(String action, String reminderType) async {
    await logEvent('reminder_interaction', parameters: {
      'action': action, // 'created', 'completed', 'dismissed'
      'reminder_type': reminderType,
    });
  }

  /// Track app performance issues
  static Future<void> logAppPerformanceIssue(String issue, Map<String, dynamic> context) async {
    await recordError(
      'Performance Issue: $issue',
      StackTrace.current,
      reason: 'App performance degradation detected',
      fatal: false,
    );

    await logEvent('performance_issue', parameters: {
      'issue_type': issue,
      ...context,
    });
  }

  /// Check if we're in production environment
  static bool _isProductionEnvironment() {
    // In a real app, check build mode or environment variables
    return const bool.fromEnvironment('dart.vm.product');
  }

  /// Get analytics status
  static bool get isEnabled => _enableAnalytics && _isInitialized;
}

/// Mixin for easy analytics integration in widgets and services
mixin AnalyticsTracker {
  /// Track screen view when screen is displayed
  Future<void> trackScreenView(String screenName) async {
    await AnalyticsService.logScreenView(screenName);
  }

  /// Track user action
  Future<void> trackAction(String action, {Map<String, dynamic>? parameters}) async {
    await AnalyticsService.logEvent(action, parameters: parameters);
  }

  /// Track performance of an operation
  Future<T> trackPerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      await AnalyticsService.logPerformanceMetric(
        operationName,
        stopwatch.elapsed,
      );

      return result;
    } catch (e) {
      stopwatch.stop();
      await AnalyticsService.recordError(e, StackTrace.current);
      rethrow;
    }
  }
}

/// Performance monitoring helper
class PerformanceMonitor {
  static final Map<String, Stopwatch> _activeTraces = {};

  /// Start tracking performance for an operation
  static void startTrace(String traceName) {
    _activeTraces[traceName] = Stopwatch()..start();
  }

  /// Stop tracking and log performance
  static Future<void> stopTrace(String traceName, {Map<String, String>? attributes}) async {
    final stopwatch = _activeTraces.remove(traceName);
    if (stopwatch != null) {
      stopwatch.stop();
      await AnalyticsService.logPerformanceMetric(
        traceName,
        stopwatch.elapsed,
        attributes: attributes,
      );
    }
  }

  /// Time an operation
  static Future<T> timeOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTrace(operationName);
    try {
      final result = await operation();
      await stopTrace(operationName);
      return result;
    } catch (e) {
      await stopTrace(operationName);
      await AnalyticsService.recordError(e, StackTrace.current);
      rethrow;
    }
  }
}