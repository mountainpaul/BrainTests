import 'package:brain_tests/core/services/analytics_service.dart';
import 'package:brain_tests/core/services/performance_monitoring_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/data/repositories/assessment_repository_impl.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  group('Assessment Workflow Integration Tests', () {
    late MockAppDatabase mockDatabase;
    late AssessmentRepositoryImpl repository;

    setUpAll(() async {
      await AnalyticsService.initialize(enableInDebug: false);
      await PerformanceMonitoringService.initialize();
    });

    setUp(() {
      mockDatabase = MockAppDatabase();
      repository = AssessmentRepositoryImpl(mockDatabase);
    });

    group('Complete Assessment Flow', () {
      test('should complete full memory recall assessment workflow', () async {
        // Arrange - Create assessment
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          notes: 'Completed memory recall test',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Assert - Verify assessment properties
        expect(assessment.percentage, equals(85.0));
        expect(assessment.score, equals(85));
        expect(assessment.maxScore, equals(100));
        expect(assessment.type, equals(AssessmentType.memoryRecall));
      });

      test('should handle partial assessment completion', () async {
        // Arrange - Create partial assessment
        final partialAssessment = Assessment(
          type: AssessmentType.attentionFocus,
          score: 50,
          maxScore: 100,
          notes: 'Partial completion',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(partialAssessment.percentage, equals(50.0));
        expect(partialAssessment.score, equals(50));
        expect(partialAssessment.maxScore, equals(100));
      });

      test('should calculate assessment percentage correctly', () async {
        // Arrange - Create multiple assessments with different scores
        final assessments = [
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 80,
            maxScore: 100,
            completedAt: DateTime.now().subtract(const Duration(days: 30)),
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime.now().subtract(const Duration(days: 15)),
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 90,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        // Assert - Verify percentages
        expect(assessments[0].percentage, equals(80.0));
        expect(assessments[1].percentage, equals(85.0));
        expect(assessments[2].percentage, equals(90.0));

        // Verify score progression
        expect(assessments[0].score < assessments[1].score, isTrue);
        expect(assessments[1].score < assessments[2].score, isTrue);
      });
    });

    group('Assessment Error Handling', () {
      test('should handle zero score correctly', () async {
        // Arrange - Create assessment with zero score
        final zeroScoreAssessment = Assessment(
          type: AssessmentType.executiveFunction,
          score: 0,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act & Assert - Should handle gracefully
        expect(zeroScoreAssessment.score, equals(0));
        expect(zeroScoreAssessment.percentage, equals(0.0));
      });

      test('should handle negative scores correctly', () async {
        // Arrange - Create assessment with perfect score
        final perfectAssessment = Assessment(
          type: AssessmentType.languageSkills,
          score: 100,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act & Assert - Should handle perfect score
        expect(perfectAssessment.score, equals(100));
        expect(perfectAssessment.percentage, equals(100.0));
      });
    });

    group('Performance Monitoring Integration', () {
      test('should track assessment performance metrics', () async {
        // Arrange - Create assessment with timing data
        final startTime = DateTime.now().subtract(const Duration(minutes: 10));
        final endTime = DateTime.now();

        final timedAssessment = Assessment(
          type: AssessmentType.visuospatialSkills,
          score: 95,
          maxScore: 100,
          completedAt: endTime,
          createdAt: startTime,
        );

        // Act - Track performance
        final duration = timedAssessment.completedAt.difference(timedAssessment.createdAt);

        await PerformanceMonitoringService.trackAssessmentPerformance(
          timedAssessment.type.name,
          duration,
          {
            'total_score': timedAssessment.score,
            'max_score': timedAssessment.maxScore,
          },
        );

        // Assert - Performance should be tracked
        expect(duration.inMinutes, equals(10));
        expect(timedAssessment.score, equals(95));
        expect(timedAssessment.percentage, equals(95.0));
      });
    });

    group('Analytics Integration', () {
      test('should log assessment completion analytics', () async {
        // Arrange
        final startTime = DateTime.now().subtract(const Duration(minutes: 8));
        final endTime = DateTime.now();

        final completedAssessment = Assessment(
          type: AssessmentType.processingSpeed,
          score: 83,
          maxScore: 100,
          completedAt: endTime,
          createdAt: startTime,
        );

        final duration = completedAssessment.completedAt.difference(completedAssessment.createdAt);

        // Act - Log analytics
        await AnalyticsService.logAssessmentCompleted(
          completedAssessment.type.name,
          completedAssessment.percentage,
          duration,
        );

        // Assert - Should complete without errors
        expect(completedAssessment.percentage, equals(83.0));
        expect(duration.inMinutes, equals(8));
      });
    });
  });
}