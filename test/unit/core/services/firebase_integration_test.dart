import 'package:brain_plan/core/services/analytics_service.dart';
import 'package:brain_plan/core/services/performance_monitoring_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock Firebase for testing
class MockFirebaseApp extends Mock implements FirebaseApp {}

void main() {
  group('Firebase Integration Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    group('AnalyticsService', () {
      test('should initialize without errors in test environment', () async {
        // This tests the service initializes properly when Firebase is not available
        expect(() async => await AnalyticsService.initialize(enableInDebug: false),
               returnsNormally);
      });

      test('should handle analytics logging gracefully when disabled', () async {
        await AnalyticsService.initialize(enableInDebug: false);

        // These should not throw errors even when Firebase is not initialized
        expect(() async => await AnalyticsService.logEvent('test_event'),
               returnsNormally);
        expect(() async => await AnalyticsService.logScreenView('test_screen'),
               returnsNormally);
        expect(() async => await AnalyticsService.recordError('Test error', null),
               returnsNormally);
      });

      test('should track assessment completion', () async {
        await AnalyticsService.initialize(enableInDebug: false);

        expect(() async => await AnalyticsService.logAssessmentCompleted(
          'memory_recall',
          85.5,
          const Duration(minutes: 5, seconds: 30)
        ), returnsNormally);
      });

      test('should track exercise completion', () async {
        await AnalyticsService.initialize(enableInDebug: false);

        expect(() async => await AnalyticsService.logExerciseCompleted(
          'word_puzzle',
          3,
          92.0
        ), returnsNormally);
      });
    });

    group('PerformanceMonitoringService', () {
      test('should initialize without errors', () async {
        expect(() async => await PerformanceMonitoringService.initialize(),
               returnsNormally);
      });

      test('should handle trace operations when Firebase is not available', () async {
        await PerformanceMonitoringService.initialize();

        expect(() async {
          await PerformanceMonitoringService.startTrace('test_trace');
          await PerformanceMonitoringService.stopTrace('test_trace');
        }, returnsNormally);
      });

      test('should track assessment performance', () async {
        await PerformanceMonitoringService.initialize();

        expect(() async => await PerformanceMonitoringService.trackAssessmentPerformance(
          'memory_recall',
          const Duration(seconds: 45),
          {'questions_answered': 10, 'correct_answers': 8}
        ), returnsNormally);
      });

      test('should track screen load time', () async {
        await PerformanceMonitoringService.initialize();

        expect(() async => await PerformanceMonitoringService.trackScreenLoadTime(
          'assessment_screen',
          const Duration(milliseconds: 250)
        ), returnsNormally);
      });

      test('should track database operations', () async {
        await PerformanceMonitoringService.initialize();

        expect(() async => await PerformanceMonitoringService.trackDatabaseOperation(
          'INSERT',
          'assessments',
          const Duration(milliseconds: 15),
          1
        ), returnsNormally);
      });

      test('should provide performance statistics', () {
        // Test the performance dashboard functionality
        PerformanceDashboard.addDataPoint('test_metric', const Duration(milliseconds: 100));
        PerformanceDashboard.addDataPoint('test_metric', const Duration(milliseconds: 150));
        PerformanceDashboard.addDataPoint('test_metric', const Duration(milliseconds: 125));

        final average = PerformanceDashboard.getAveragePerformance('test_metric');
        expect(average, isNotNull);
        expect(average!.inMilliseconds, equals(125)); // (100 + 150 + 125) / 3

        final stats = PerformanceDashboard.getPerformanceStats();
        expect(stats['test_metric'], isNotNull);
        expect(stats['test_metric']!['count'], equals(3));
        expect(stats['test_metric']!['average_ms'], equals(125));
        expect(stats['test_metric']!['min_ms'], equals(100));
        expect(stats['test_metric']!['max_ms'], equals(150));
      });
    });

    group('PerformanceTracker Mixin', () {
      test('should track operations with proper cleanup', () async {
        final tracker = TestPerformanceTracker();

        final result = await tracker.trackOperation('test_operation', () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'success';
        });

        expect(result, equals('success'));
      });

      test('should handle exceptions during tracking', () async {
        final tracker = TestPerformanceTracker();

        expect(() async => await tracker.trackOperation('failing_operation', () async {
          throw Exception('Test error');
        }), throwsException);
      });
    });
  });
}

// Test implementation of the PerformanceTracker mixin
class TestPerformanceTracker with PerformanceTracker {}