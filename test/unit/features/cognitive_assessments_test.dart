import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:brain_plan/domain/repositories/assessment_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([AssessmentRepository])
import 'cognitive_assessments_test.mocks.dart';

void main() {
  group('Cognitive Assessments Tests', () {
    late MockAssessmentRepository mockRepository;

    setUp(() {
      mockRepository = MockAssessmentRepository();
    });

    group('Assessment Entity Tests', () {
      test('should calculate percentage correctly', () {
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(assessment.percentage, equals(80.0));
      });

      test('should handle zero max score gracefully', () {
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 0,
          maxScore: 0,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(assessment.percentage, isNaN);
      });

      test('should create proper copy with changes', () {
        final original = Assessment(
          id: 1,
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          notes: 'Original notes',
          completedAt: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
        );

        final copy = original.copyWith(
          score: 9,
          notes: 'Updated notes',
        );

        expect(copy.id, equals(1));
        expect(copy.type, equals(AssessmentType.memoryRecall));
        expect(copy.score, equals(9));
        expect(copy.maxScore, equals(10));
        expect(copy.notes, equals('Updated notes'));
        expect(copy.completedAt, equals(DateTime(2024, 1, 1)));
        expect(copy.createdAt, equals(DateTime(2024, 1, 1)));
      });
    });

    group('Assessment Types Coverage', () {
      test('should support all assessment types', () {
        final types = [
          AssessmentType.memoryRecall,
          AssessmentType.attentionFocus,
          AssessmentType.executiveFunction,
          AssessmentType.languageSkills,
          AssessmentType.visuospatialSkills,
          AssessmentType.processingSpeed,
        ];

        for (final type in types) {
          final assessment = Assessment(
            type: type,
            score: 5,
            maxScore: 10,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          );

          expect(assessment.type, equals(type));
          expect(assessment.percentage, equals(50.0));
        }
      });
    });

    group('Assessment Repository Integration', () {
      test('should save assessment successfully', () async {
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final savedAssessment = assessment.copyWith(id: 1);
        when(mockRepository.insertAssessment(assessment))
            .thenAnswer((_) async => 1);

        final result = await mockRepository.insertAssessment(assessment);

        expect(result, equals(1));
        verify(mockRepository.insertAssessment(assessment)).called(1);
      });

      test('should retrieve assessments by type', () async {
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 8,
            maxScore: 10,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          Assessment(
            id: 2,
            type: AssessmentType.memoryRecall,
            score: 9,
            maxScore: 10,
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        when(mockRepository.getAssessmentsByType(AssessmentType.memoryRecall))
            .thenAnswer((_) async => assessments);

        final result = await mockRepository.getAssessmentsByType(AssessmentType.memoryRecall);

        expect(result.length, equals(2));
        expect(result.every((a) => a.type == AssessmentType.memoryRecall), isTrue);
        verify(mockRepository.getAssessmentsByType(AssessmentType.memoryRecall)).called(1);
      });

      test('should calculate average score for assessment type', () async {
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 8,
            maxScore: 10,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          Assessment(
            id: 2,
            type: AssessmentType.memoryRecall,
            score: 6,
            maxScore: 10,
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        when(mockRepository.getAssessmentsByType(AssessmentType.memoryRecall))
            .thenAnswer((_) async => assessments);

        final result = await mockRepository.getAssessmentsByType(AssessmentType.memoryRecall);
        final averagePercentage = result
            .map((a) => a.percentage)
            .reduce((a, b) => a + b) / result.length;

        expect(averagePercentage, equals(70.0));
      });
    });

    group('Assessment Progress Tracking', () {
      test('should track improvement over time', () async {
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 5,
            maxScore: 10,
            completedAt: DateTime.now().subtract(const Duration(days: 7)),
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          Assessment(
            id: 2,
            type: AssessmentType.memoryRecall,
            score: 7,
            maxScore: 10,
            completedAt: DateTime.now().subtract(const Duration(days: 3)),
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          Assessment(
            id: 3,
            type: AssessmentType.memoryRecall,
            score: 9,
            maxScore: 10,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        when(mockRepository.getAssessmentsByType(AssessmentType.memoryRecall))
            .thenAnswer((_) async => assessments);

        final result = await mockRepository.getAssessmentsByType(AssessmentType.memoryRecall);
        final sortedByDate = result
          ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

        expect(sortedByDate[0].percentage, equals(50.0));
        expect(sortedByDate[1].percentage, equals(70.0));
        expect(sortedByDate[2].percentage, equals(90.0));

        final improvement = sortedByDate.last.percentage - sortedByDate.first.percentage;
        expect(improvement, equals(40.0));
      });

      test('should handle assessments with notes', () {
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          notes: 'Patient showed good recall but struggled with sequence',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(assessment.notes, contains('recall'));
        expect(assessment.notes, contains('sequence'));
      });
    });

    group('Assessment Edge Cases', () {
      test('should handle perfect scores', () {
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 10,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(assessment.percentage, equals(100.0));
      });

      test('should handle zero scores', () {
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 0,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(assessment.percentage, equals(0.0));
      });

      test('should handle large scores', () {
        final assessment = Assessment(
          type: AssessmentType.processingSpeed,
          score: 150,
          maxScore: 200,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(assessment.percentage, equals(75.0));
      });
    });
  });
}