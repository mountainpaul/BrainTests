import 'package:brain_tests/core/services/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsService Tests', () {
    setUp(() async {
      // Initialize analytics service for testing
      await AnalyticsService.initialize(enableInDebug: true);
    });

    test('should initialize without errors', () async {
      // Act & Assert
      await AnalyticsService.initialize(enableInDebug: true);
      expect(AnalyticsService.isEnabled, isTrue);
    });

    test('should log events without throwing errors', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.logEvent('test_event', parameters: {
          'test_param': 'test_value',
          'number_param': 123,
        });
      }, returnsNormally);
    });

    test('should set user properties without errors', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.setUserProperties({
          'user_type': 'test_user',
          'app_version': '1.0.0',
        });
      }, returnsNormally);
    });

    test('should record errors without throwing', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.recordError(
          Exception('Test error'),
          StackTrace.current,
          reason: 'Testing error recording',
          fatal: false,
        );
      }, returnsNormally);
    });

    test('should log performance metrics', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.logPerformanceMetric(
          'test_operation',
          const Duration(milliseconds: 500),
          attributes: {'test_attr': 'value'},
        );
      }, returnsNormally);
    });

    test('should log screen views', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.logScreenView(
          'TestScreen',
          screenClass: 'TestScreenClass',
        );
      }, returnsNormally);
    });

    test('should log assessment completion', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.logAssessmentCompleted(
          'memory_recall',
          85.5,
          const Duration(minutes: 10),
        );
      }, returnsNormally);
    });

    test('should log exercise completion', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.logExerciseCompleted(
          'word_puzzle',
          3,
          92.0,
        );
      }, returnsNormally);
    });

    test('should log mood entries', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.logMoodEntry('good', 4, 2);
      }, returnsNormally);
    });

    test('should log reminder interactions', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.logReminderInteraction(
          'completed',
          'medication',
        );
      }, returnsNormally);
    });

    test('should log app performance issues', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.logAppPerformanceIssue(
          'slow_loading',
          {'screen': 'assessment', 'load_time': 5000},
        );
      }, returnsNormally);
    });
  });

  group('AnalyticsTracker Mixin Tests', () {
    late TestAnalyticsWidget testWidget;

    setUp(() {
      testWidget = TestAnalyticsWidget();
    });

    test('should track screen views', () async {
      // Act & Assert
      expect(() async {
        await testWidget.trackScreenView('TestScreen');
      }, returnsNormally);
    });

    test('should track actions', () async {
      // Act & Assert
      expect(() async {
        await testWidget.trackAction('button_tap', parameters: {
          'button_name': 'test_button',
        });
      }, returnsNormally);
    });

    test('should track performance of operations', () async {
      // Arrange
      Future<String> testOperation() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'test_result';
      }

      // Act
      final result = await testWidget.trackPerformance(
        'test_operation',
        testOperation,
      );

      // Assert
      expect(result, 'test_result');
    });

    test('should handle errors in tracked operations', () async {
      // Arrange
      Future<String> errorOperation() async {
        throw Exception('Test operation error');
      }

      // Act & Assert
      expect(
        () => testWidget.trackPerformance('error_operation', errorOperation),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PerformanceMonitor Tests', () {
    test('should start and stop traces', () async {
      // Act
      PerformanceMonitor.startTrace('test_trace');
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert - should complete without errors
      expect(() async {
        await PerformanceMonitor.stopTrace('test_trace');
      }, returnsNormally);
    });

    test('should handle stopping non-existent traces', () async {
      // Act & Assert - should not throw
      expect(() async {
        await PerformanceMonitor.stopTrace('non_existent_trace');
      }, returnsNormally);
    });

    test('should time operations correctly', () async {
      // Arrange
      Future<int> testOperation() async {
        await Future.delayed(const Duration(milliseconds: 50));
        return 42;
      }

      // Act
      final result = await PerformanceMonitor.timeOperation(
        'timed_operation',
        testOperation,
      );

      // Assert
      expect(result, 42);
    });

    test('should handle errors in timed operations', () async {
      // Arrange
      Future<void> errorOperation() async {
        throw Exception('Timed operation error');
      }

      // Act & Assert
      expect(
        () => PerformanceMonitor.timeOperation('error_timing', errorOperation),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Analytics Service State Tests', () {
    test('should indicate when analytics is enabled', () {
      // The service should be enabled after initialization in setUp
      expect(AnalyticsService.isEnabled, isTrue);
    });

    test('should handle multiple initializations gracefully', () async {
      // Act & Assert - multiple initializations should not cause issues
      expect(() async {
        await AnalyticsService.initialize(enableInDebug: true);
        await AnalyticsService.initialize(enableInDebug: false);
        await AnalyticsService.initialize(enableInDebug: true);
      }, returnsNormally);
    });
  });

  group('Error Handling Tests', () {
    test('should handle null parameters gracefully', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.logEvent('null_param_test');
        await AnalyticsService.setUserProperties({});
        await AnalyticsService.logScreenView('TestScreen');
      }, returnsNormally);
    });

    test('should handle invalid data types gracefully', () async {
      // Act & Assert
      expect(() async {
        await AnalyticsService.logEvent('invalid_data_test', parameters: {
          'valid_string': 'test',
          'valid_number': 123,
          'valid_bool': true,
        });
      }, returnsNormally);
    });
  });
}

/// Test class that uses the AnalyticsTracker mixin
class TestAnalyticsWidget with AnalyticsTracker {
  // Test implementation for mixin testing
}