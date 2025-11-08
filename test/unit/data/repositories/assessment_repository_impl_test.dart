import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/data/repositories/assessment_repository_impl.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  group('AssessmentRepositoryImpl Integration Tests', () {
    late AppDatabase database;
    late AssessmentRepositoryImpl repository;

    setUp(() async {
      // Create an in-memory database for testing
      database = createTestDatabase();
      repository = AssessmentRepositoryImpl(database);
    });

    tearDown(() async {
      await closeTestDatabase(database);
    });

    group('CRUD Operations', () {
      test('should insert and retrieve assessment', () async {
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          notes: 'Good performance',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertAssessment(assessment);

        expect(id, greaterThan(0));

        final retrieved = await repository.getAssessmentById(id);

        expect(retrieved, isNotNull);
        expect(retrieved!.type, equals(AssessmentType.memoryRecall));
        expect(retrieved.score, equals(8));
        expect(retrieved.maxScore, equals(10));
        expect(retrieved.notes, equals('Good performance'));
        expect(retrieved.percentage, equals(80.0));
      });

      test('should update existing assessment', () async {
        // Insert initial assessment
        final assessment = Assessment(
          type: AssessmentType.attentionFocus,
          score: 6,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertAssessment(assessment);
        final inserted = await repository.getAssessmentById(id);

        // Update the assessment
        final updated = inserted!.copyWith(
          score: 9,
          notes: 'Improved performance',
        );

        final result = await repository.updateAssessment(updated);

        expect(result, isTrue);

        final retrieved = await repository.getAssessmentById(id);

        expect(retrieved!.score, equals(9));
        expect(retrieved.notes, equals('Improved performance'));
        expect(retrieved.percentage, equals(90.0));
      });

      test('should delete assessment', () async {
        // Insert assessment
        final assessment = Assessment(
          type: AssessmentType.executiveFunction,
          score: 7,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertAssessment(assessment);

        // Verify it exists
        final retrieved = await repository.getAssessmentById(id);
        expect(retrieved, isNotNull);

        // Delete it
        final result = await repository.deleteAssessment(id);
        expect(result, isTrue);

        // Verify it's gone
        final afterDelete = await repository.getAssessmentById(id);
        expect(afterDelete, isNull);
      });

      test('should return false when updating non-existent assessment', () async {
        final assessment = Assessment(
          id: 999, // Non-existent ID
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final result = await repository.updateAssessment(assessment);

        expect(result, isFalse);
      });

      test('should return false when updating assessment without ID', () async {
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final result = await repository.updateAssessment(assessment);

        expect(result, isFalse);
      });

      test('should return false when deleting non-existent assessment', () async {
        final result = await repository.deleteAssessment(999);

        expect(result, isFalse);
      });
    });

    group('Query Operations', () {
      setUp(() async {
        // Insert test data
        final testAssessments = [
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 8,
            maxScore: 10,
            completedAt: DateTime.now().subtract(const Duration(days: 5)),
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 9,
            maxScore: 10,
            completedAt: DateTime.now().subtract(const Duration(days: 3)),
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          Assessment(
            type: AssessmentType.attentionFocus,
            score: 7,
            maxScore: 10,
            completedAt: DateTime.now().subtract(const Duration(days: 2)),
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          Assessment(
            type: AssessmentType.executiveFunction,
            score: 6,
            maxScore: 10,
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 10,
            maxScore: 10,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        for (final assessment in testAssessments) {
          await repository.insertAssessment(assessment);
        }
      });

      test('should get all assessments', () async {
        final result = await repository.getAllAssessments();

        expect(result.length, equals(5));
      });

      test('should get assessments by type', () async {
        final memoryRecallAssessments = await repository.getAssessmentsByType(
          AssessmentType.memoryRecall);

        expect(memoryRecallAssessments.length, equals(3));
        expect(memoryRecallAssessments.every(
          (a) => a.type == AssessmentType.memoryRecall), isTrue);

        final attentionFocusAssessments = await repository.getAssessmentsByType(
          AssessmentType.attentionFocus);

        expect(attentionFocusAssessments.length, equals(1));
        expect(attentionFocusAssessments.first.type, equals(AssessmentType.attentionFocus));
      });

      test('should get assessments by date range', () async {
        final startDate = DateTime.now().subtract(const Duration(days: 4));
        final endDate = DateTime.now().subtract(const Duration(days: 2));

        final result = await repository.getAssessmentsByDateRange(startDate, endDate);

        expect(result.length, equals(2));
        // Should be ordered by completedAt descending
        expect(result[0].completedAt.isAfter(result[1].completedAt), isTrue);
      });

      test('should get recent assessments with default limit', () async {
        final result = await repository.getRecentAssessments();

        expect(result.length, equals(5)); // All assessments since we have less than 10
        // Should be ordered by completedAt descending (most recent first)
        expect(result[0].completedAt.isAfter(result[1].completedAt), isTrue);
        expect(result[1].completedAt.isAfter(result[2].completedAt), isTrue);
      });

      test('should get recent assessments with custom limit', () async {
        final result = await repository.getRecentAssessments(limit: 3);

        expect(result.length, equals(3));
        // Should be ordered by completedAt descending
        for (int i = 0; i < result.length - 1; i++) {
          expect(result[i].completedAt.isAfter(result[i + 1].completedAt), isTrue);
        }
      });

      test('should calculate average scores by type', () async {
        final averages = await repository.getAverageScoresByType();

        // Memory recall: 8, 9, 10 = average 90%
        expect(averages[AssessmentType.memoryRecall], closeTo(90.0, 0.01));

        // Attention focus: 7 = 70%
        expect(averages[AssessmentType.attentionFocus], equals(70.0));

        // Executive function: 6 = 60%
        expect(averages[AssessmentType.executiveFunction], equals(60.0));

        // Types with no assessments should not be in the map
        expect(averages.containsKey(AssessmentType.languageSkills), isFalse);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty database', () async {
        final allAssessments = await repository.getAllAssessments();
        final averages = await repository.getAverageScoresByType();
        final recent = await repository.getRecentAssessments();

        expect(allAssessments.isEmpty, isTrue);
        expect(averages.isEmpty, isTrue);
        expect(recent.isEmpty, isTrue);
      });

      test('should handle assessments with null notes', () async {
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          notes: null, // Explicitly null
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertAssessment(assessment);
        final retrieved = await repository.getAssessmentById(id);

        expect(retrieved!.notes, isNull);
      });

      test('should handle date range with no results', () async {
        // Insert one assessment
        await repository.insertAssessment(Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));

        // Query for a range in the future
        final futureStart = DateTime.now().add(const Duration(days: 1));
        final futureEnd = DateTime.now().add(const Duration(days: 7));

        final result = await repository.getAssessmentsByDateRange(futureStart, futureEnd);

        expect(result.isEmpty, isTrue);
      });

      test('should handle assessments with same completion time', () async {
        final completionTime = DateTime.now();

        // Insert multiple assessments with same completion time
        await repository.insertAssessment(Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: completionTime,
          createdAt: completionTime,
        ));

        await repository.insertAssessment(Assessment(
          type: AssessmentType.attentionFocus,
          score: 7,
          maxScore: 10,
          completedAt: completionTime,
          createdAt: completionTime,
        ));

        final result = await repository.getRecentAssessments();

        expect(result.length, equals(2));
      });

      test('should handle assessments with zero and perfect scores', () async {
        await repository.insertAssessment(Assessment(
          type: AssessmentType.memoryRecall,
          score: 0,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));

        await repository.insertAssessment(Assessment(
          type: AssessmentType.memoryRecall,
          score: 10,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));

        final averages = await repository.getAverageScoresByType();

        // Average of 0% and 100% should be 50%
        expect(averages[AssessmentType.memoryRecall], equals(50.0));
      });
    });

    group('Data Integrity', () {
      test('should preserve all assessment types', () async {
        const types = AssessmentType.values;

        for (final type in types) {
          await repository.insertAssessment(Assessment(
            type: type,
            score: 5,
            maxScore: 10,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ));
        }

        final allAssessments = await repository.getAllAssessments();
        final foundTypes = allAssessments.map((a) => a.type).toSet();

        expect(foundTypes.length, equals(types.length));
        for (final type in types) {
          expect(foundTypes.contains(type), isTrue);
        }
      });

      test('should maintain score precision', () async {
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 123,
          maxScore: 456,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertAssessment(assessment);
        final retrieved = await repository.getAssessmentById(id);

        expect(retrieved!.score, equals(123));
        expect(retrieved.maxScore, equals(456));
        expect(retrieved.percentage, closeTo(26.97, 0.01));
      });

      test('should handle long notes', () async {
        final longNotes = 'A' * 1000; // Very long notes

        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          notes: longNotes,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertAssessment(assessment);
        final retrieved = await repository.getAssessmentById(id);

        expect(retrieved!.notes, equals(longNotes));
        expect(retrieved.notes!.length, equals(1000));
      });
    });
  });
}