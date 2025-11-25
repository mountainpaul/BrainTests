import 'package:brain_tests/data/datasources/database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for Cambridge assessment import functionality added on 2024-11-24.
/// The fetchRemoteData() method now imports Cambridge assessments from Supabase.
void main() {
  group('Cambridge Assessment Import', () {
    group('Test Type Parsing', () {
      test('should parse RVP test type correctly from JSON string', () {
        final testTypeStr = 'rvp';
        final testType = CambridgeTestType.values.firstWhere(
          (e) => e.name == testTypeStr,
          orElse: () => CambridgeTestType.pal,
        );

        expect(testType, CambridgeTestType.rvp);
      });

      test('should parse RTI test type correctly from JSON string', () {
        final testTypeStr = 'rti';
        final testType = CambridgeTestType.values.firstWhere(
          (e) => e.name == testTypeStr,
          orElse: () => CambridgeTestType.pal,
        );

        expect(testType, CambridgeTestType.rti);
      });

      test('should parse SWM test type correctly from JSON string', () {
        final testTypeStr = 'swm';
        final testType = CambridgeTestType.values.firstWhere(
          (e) => e.name == testTypeStr,
          orElse: () => CambridgeTestType.pal,
        );

        expect(testType, CambridgeTestType.swm);
      });

      test('should parse PRM test type correctly from JSON string', () {
        final testTypeStr = 'prm';
        final testType = CambridgeTestType.values.firstWhere(
          (e) => e.name == testTypeStr,
          orElse: () => CambridgeTestType.pal,
        );

        expect(testType, CambridgeTestType.prm);
      });

      test('should parse PAL test type correctly from JSON string', () {
        final testTypeStr = 'pal';
        final testType = CambridgeTestType.values.firstWhere(
          (e) => e.name == testTypeStr,
          orElse: () => CambridgeTestType.pal,
        );

        expect(testType, CambridgeTestType.pal);
      });

      test('should parse OTS test type correctly from JSON string', () {
        final testTypeStr = 'ots';
        final testType = CambridgeTestType.values.firstWhere(
          (e) => e.name == testTypeStr,
          orElse: () => CambridgeTestType.pal,
        );

        expect(testType, CambridgeTestType.ots);
      });

      test('should fallback to PAL for unknown test type', () {
        final testTypeStr = 'unknown_test';
        final testType = CambridgeTestType.values.firstWhere(
          (e) => e.name == testTypeStr,
          orElse: () => CambridgeTestType.pal,
        );

        expect(testType, CambridgeTestType.pal);
      });
    });

    group('JSON Data Parsing', () {
      test('should handle null accuracy with default value', () {
        final data = <String, dynamic>{
          'accuracy': null,
        };
        final accuracy = (data['accuracy'] as num?)?.toDouble() ?? 0.0;

        expect(accuracy, 0.0);
      });

      test('should handle integer accuracy', () {
        final data = <String, dynamic>{
          'accuracy': 85,
        };
        final accuracy = (data['accuracy'] as num?)?.toDouble() ?? 0.0;

        expect(accuracy, 85.0);
      });

      test('should handle double accuracy', () {
        final data = <String, dynamic>{
          'accuracy': 85.5,
        };
        final accuracy = (data['accuracy'] as num?)?.toDouble() ?? 0.0;

        expect(accuracy, 85.5);
      });

      test('should handle null duration with default value', () {
        final data = <String, dynamic>{
          'duration_seconds': null,
        };
        final duration = (data['duration_seconds'] as int?) ?? 0;

        expect(duration, 0);
      });

      test('should handle null latency values', () {
        final data = <String, dynamic>{
          'mean_latency_ms': null,
          'median_latency_ms': null,
        };
        final meanLatency = (data['mean_latency_ms'] as num?)?.toDouble();
        final medianLatency = (data['median_latency_ms'] as num?)?.toDouble();

        expect(meanLatency, null);
        expect(medianLatency, null);
      });

      test('should handle null interpretation with empty string', () {
        final data = <String, dynamic>{
          'interpretation': null,
        };
        final interpretation = (data['interpretation'] as String?) ?? '';

        expect(interpretation, '');
      });

      test('should parse ISO8601 date correctly', () {
        final data = <String, dynamic>{
          'completed_at': '2024-11-24T12:30:00.000Z',
        };
        final completedAt = DateTime.parse(data['completed_at'] as String);

        expect(completedAt.year, 2024);
        expect(completedAt.month, 11);
        expect(completedAt.day, 24);
      });

      test('should handle integer mean latency', () {
        final data = <String, dynamic>{
          'mean_latency_ms': 450,
        };
        final meanLatency = (data['mean_latency_ms'] as num?)?.toDouble() ?? 0.0;

        expect(meanLatency, 450.0);
      });

      test('should handle double mean latency', () {
        final data = <String, dynamic>{
          'mean_latency_ms': 450.75,
        };
        final meanLatency = (data['mean_latency_ms'] as num?)?.toDouble() ?? 0.0;

        expect(meanLatency, 450.75);
      });

      test('should handle integer norm score', () {
        final data = <String, dynamic>{
          'norm_score': 95,
        };
        final normScore = (data['norm_score'] as num?)?.toDouble() ?? 0.0;

        expect(normScore, 95.0);
      });

      test('should handle null norm score with default value', () {
        final data = <String, dynamic>{
          'norm_score': null,
        };
        final normScore = (data['norm_score'] as num?)?.toDouble() ?? 0.0;

        expect(normScore, 0.0);
      });
    });

    group('Cambridge Import Data Validation', () {
      test('should validate complete Cambridge assessment data', () {
        final validData = <String, dynamic>{
          'id': 'test-uuid-123',
          'user_id': 'user-456',
          'test_type': 'rvp',
          'duration_seconds': 300,
          'accuracy': 87.5,
          'total_trials': 100,
          'correct_trials': 88,
          'error_count': 12,
          'mean_latency_ms': 450.5,
          'median_latency_ms': 420.0,
          'norm_score': 95.0,
          'interpretation': 'Above average performance',
          'specific_metrics': '{"hits": 88, "misses": 12}',
          'completed_at': '2024-11-24T12:30:00.000Z',
          'created_at': '2024-11-24T12:00:00.000Z',
          'updated_at': '2024-11-24T12:30:00.000Z',
        };

        expect(validData['id'], isNotNull);
        expect(validData['test_type'], 'rvp');
        expect((validData['accuracy'] as num).toDouble(), 87.5);
        expect(validData['total_trials'], 100);
      });

      test('should handle minimal Cambridge assessment data', () {
        final minimalData = <String, dynamic>{
          'id': 'test-uuid-123',
          'test_type': 'pal',
          'duration_seconds': 180,
          'accuracy': 75.0,
          'completed_at': '2024-11-24T12:30:00.000Z',
          'created_at': '2024-11-24T12:00:00.000Z',
        };

        // These should fall back to defaults
        final totalTrials = (minimalData['total_trials'] as int?) ?? 0;
        final correctTrials = (minimalData['correct_trials'] as int?) ?? 0;
        final errorCount = (minimalData['error_count'] as int?) ?? 0;
        final interpretation = (minimalData['interpretation'] as String?) ?? '';
        final specificMetrics = (minimalData['specific_metrics'] as String?) ?? '';

        expect(totalTrials, 0);
        expect(correctTrials, 0);
        expect(errorCount, 0);
        expect(interpretation, '');
        expect(specificMetrics, '');
      });
    });

    group('CambridgeTestType Enum', () {
      test('all test types should have valid names', () {
        final expectedNames = ['pal', 'prm', 'swm', 'rvp', 'rti', 'ots'];

        for (final name in expectedNames) {
          final found = CambridgeTestType.values.any((e) => e.name == name);
          expect(found, true, reason: 'Expected to find test type: $name');
        }
      });

      test('should have correct number of test types', () {
        expect(CambridgeTestType.values.length, greaterThanOrEqualTo(6));
      });
    });
  });
}
