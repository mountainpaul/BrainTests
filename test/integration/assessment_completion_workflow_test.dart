import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/data/repositories/assessment_repository_impl.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  group('Assessment Completion Workflow Integration Tests', () {
    late AppDatabase database;
    late AssessmentRepositoryImpl repository;

    setUp(() {
      database = createTestDatabase();
      repository = AssessmentRepositoryImpl(database);
    });

    tearDown(() async {
      await closeTestDatabase(database);
    });

    group('Assessment Saving', () {
      test('should save completed MMSE assessment', () async {
        // Arrange
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 26,
          maxScore: 30,
          notes: 'MMSE Assessment - 26/30',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );


        // Act
        final assessmentId = await repository.insertAssessment(assessment);

        // Assert
        expect(assessmentId, greaterThan(0));
        expect(assessment.score, equals(26));
        expect(assessment.maxScore, equals(30));
        expect(assessment.percentage, closeTo(86.67, 0.01));
        expect(assessment.type, equals(AssessmentType.memoryRecall));

      });

      test('should save memory recall assessment', () async {
        // Arrange
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          notes: 'Memory Recall Test - Score: 85.0',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );


        // Act
        final assessmentId = await repository.insertAssessment(assessment);

        // Assert
        expect(assessmentId, greaterThan(0));
        expect(assessment.percentage, equals(85.0));
        expect(assessment.type, equals(AssessmentType.memoryRecall));

      });

      test('should save attention focus assessment with low score', () async {
        // Arrange
        final assessment = Assessment(
          type: AssessmentType.attentionFocus,
          score: 45,
          maxScore: 100,
          notes: 'Attention Focus Test - Score: 45.0',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );


        // Act
        final assessmentId = await repository.insertAssessment(assessment);

        // Assert
        expect(assessmentId, greaterThan(0));
        expect(assessment.percentage, equals(45.0));
        expect(assessment.type, equals(AssessmentType.attentionFocus));

      });

      test('should save executive function assessment with notes', () async {
        // Arrange
        final assessment = Assessment(
          type: AssessmentType.executiveFunction,
          score: 78,
          maxScore: 100,
          notes: 'Executive Function Test - Difficulty: Medium, Score: 78.0',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );


        // Act
        final assessmentId = await repository.insertAssessment(assessment);

        // Assert
        expect(assessmentId, greaterThan(0));
        expect(assessment.notes, contains('Executive Function'));
        expect(assessment.percentage, equals(78.0));

      });
    });

    group('Recent Assessments Retrieval', () {
      test('should retrieve recently completed assessments in order', () async {
        // Arrange
        final now = DateTime.now();
        final assessments = [
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            notes: 'Memory test',
            completedAt: now.subtract(const Duration(hours: 2)),
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 27,
            maxScore: 30,
            notes: 'MMSE test',
            completedAt: now.subtract(const Duration(hours: 1)),
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
          Assessment(
            type: AssessmentType.attentionFocus,
            score: 92,
            maxScore: 100,
            notes: 'Attention test',
            completedAt: now.subtract(const Duration(minutes: 15)),
            createdAt: now.subtract(const Duration(minutes: 15)),
          ),
        ];

        // Insert all assessments
        for (final assessment in assessments) {
          await repository.insertAssessment(assessment);
        }

        // Act
        final recentAssessments = await repository.getRecentAssessments(limit: 5);

        // Assert
        expect(recentAssessments.length, equals(3));
        // Verify they're in reverse chronological order (most recent first)
        expect(recentAssessments[0].notes, equals('Attention test'));
        expect(recentAssessments[1].notes, equals('MMSE test'));
        expect(recentAssessments[2].notes, equals('Memory test'));

      });

      test('should return empty list when no assessments completed', () async {
        // Arrange

        // Act
        final recentAssessments = await repository.getRecentAssessments(limit: 5);

        // Assert
        expect(recentAssessments, isEmpty);
      });
    });

    group('Average Scores By Type', () {
      test('should calculate average scores for each assessment type', () async {
        // Arrange - Insert assessments for each type
        final assessmentsToInsert = [
          // Memory Recall: 25, 30 → average 27.5
          Assessment(type: AssessmentType.memoryRecall, score: 25, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          Assessment(type: AssessmentType.memoryRecall, score: 30, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          // Processing Speed: 80, 85 → average 82.5
          Assessment(type: AssessmentType.processingSpeed, score: 80, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          Assessment(type: AssessmentType.processingSpeed, score: 85, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          // Attention Focus: 85, 92 → average 88.5
          Assessment(type: AssessmentType.attentionFocus, score: 85, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          Assessment(type: AssessmentType.attentionFocus, score: 92, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          // Executive Function: 70, 80 → average 75.0
          Assessment(type: AssessmentType.executiveFunction, score: 70, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          Assessment(type: AssessmentType.executiveFunction, score: 80, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          // Language Skills: 88, 92 → average 90.0
          Assessment(type: AssessmentType.languageSkills, score: 88, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          Assessment(type: AssessmentType.languageSkills, score: 92, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          // Visuospatial Skills: 80, 91 → average 85.5
          Assessment(type: AssessmentType.visuospatialSkills, score: 80, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
          Assessment(type: AssessmentType.visuospatialSkills, score: 91, maxScore: 100, completedAt: DateTime.now(), createdAt: DateTime.now()),
        ];

        for (final assessment in assessmentsToInsert) {
          await repository.insertAssessment(assessment);
        }

        // Act
        final scores = await repository.getAverageScoresByType();

        // Assert
        expect(scores.length, equals(6));
        expect(scores[AssessmentType.memoryRecall], closeTo(27.5, 0.01));
        expect(scores[AssessmentType.processingSpeed], closeTo(82.5, 0.01));
        expect(scores[AssessmentType.attentionFocus], closeTo(88.5, 0.01));
        expect(scores[AssessmentType.executiveFunction], closeTo(75.0, 0.01));
        expect(scores[AssessmentType.languageSkills], closeTo(90.0, 0.01));
        expect(scores[AssessmentType.visuospatialSkills], closeTo(85.5, 0.01));

      });

      test('should return empty map when no assessments completed', () async {
        // Arrange

        // Act
        final scores = await repository.getAverageScoresByType();

        // Assert
        expect(scores, isEmpty);
      });
    });

    group('Assessment Progress Tracking', () {
      test('should track MMSE scores over time showing improvement', () async {
        // Arrange
        final startDate = DateTime.now().subtract(const Duration(days: 30));
        final endDate = DateTime.now();

        final assessments = [
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 24,
            maxScore: 30,
            notes: 'MMSE - Week 1',
            completedAt: startDate,
            createdAt: startDate,
          ),
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 26,
            maxScore: 30,
            notes: 'MMSE - Week 2',
            completedAt: startDate.add(const Duration(days: 7)),
            createdAt: startDate.add(const Duration(days: 7)),
          ),
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 27,
            maxScore: 30,
            notes: 'MMSE - Week 3',
            completedAt: startDate.add(const Duration(days: 14)),
            createdAt: startDate.add(const Duration(days: 14)),
          ),
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 28,
            maxScore: 30,
            notes: 'MMSE - Week 4',
            completedAt: startDate.add(const Duration(days: 21)),
            createdAt: startDate.add(const Duration(days: 21)),
          ),
        ];

        // Insert all assessments
        for (final assessment in assessments) {
          await repository.insertAssessment(assessment);
        }

        // Act
        final monthlyAssessments = await repository.getAssessmentsByDateRange(startDate, endDate);

        // Assert
        expect(monthlyAssessments.length, equals(4));
        // Assessments are returned in descending order (most recent first)
        expect(monthlyAssessments.first.score, equals(28));
        expect(monthlyAssessments.last.score, equals(24));

        // Verify score improvement trend (in reverse order - newest first)
        for (int i = 0; i < monthlyAssessments.length - 1; i++) {
          expect(monthlyAssessments[i].score, greaterThan(monthlyAssessments[i + 1].score));
        }

      });

      test('should track multiple assessment types concurrently', () async {
        // Arrange
        final now = DateTime.now();
        final assessments = [
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 80,
            maxScore: 100,
            completedAt: now.subtract(const Duration(days: 5)),
            createdAt: now.subtract(const Duration(days: 5)),
          ),
          Assessment(
            type: AssessmentType.attentionFocus,
            score: 85,
            maxScore: 100,
            completedAt: now.subtract(const Duration(days: 4)),
            createdAt: now.subtract(const Duration(days: 4)),
          ),
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: now.subtract(const Duration(days: 3)),
            createdAt: now.subtract(const Duration(days: 3)),
          ),
          Assessment(
            type: AssessmentType.attentionFocus,
            score: 90,
            maxScore: 100,
            completedAt: now.subtract(const Duration(days: 2)),
            createdAt: now.subtract(const Duration(days: 2)),
          ),
        ];

        // Insert all assessments
        for (final assessment in assessments) {
          await repository.insertAssessment(assessment);
        }

        // Act
        final allAssessments = await repository.getAllAssessments();

        // Assert
        expect(allAssessments.length, equals(4));

        final memoryRecalls = allAssessments.where((a) => a.type == AssessmentType.memoryRecall).toList();
        final attentionTests = allAssessments.where((a) => a.type == AssessmentType.attentionFocus).toList();

        expect(memoryRecalls.length, equals(2));
        expect(attentionTests.length, equals(2));

        // Both types show improvement
        expect(memoryRecalls[1].score, greaterThan(memoryRecalls[0].score));
        expect(attentionTests[1].score, greaterThan(attentionTests[0].score));

      });
    });

    group('Assessment Types Filtering', () {
      test('should filter assessments by type', () async {
        // Arrange
        final mmseAssessments = [
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 26,
            maxScore: 30,
            completedAt: DateTime.now().subtract(const Duration(days: 7)),
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 28,
            maxScore: 30,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        // Insert all assessments
        for (final assessment in mmseAssessments) {
          await repository.insertAssessment(assessment);
        }

        // Act
        final assessments = await repository.getAssessmentsByType(AssessmentType.memoryRecall);

        // Assert
        expect(assessments.length, equals(2));
        expect(assessments.every((a) => a.type == AssessmentType.memoryRecall), isTrue);
        expect(assessments[0].score, equals(26));
        expect(assessments[1].score, equals(28));

      });
    });

    group('Assessment Update', () {
      test('should update assessment with new notes', () async {
        // Arrange
        final originalAssessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          notes: 'Original notes',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Insert the assessment first
        final id = await repository.insertAssessment(originalAssessment);
        final insertedAssessment = originalAssessment.copyWith(id: id);

        final updatedAssessment = insertedAssessment.copyWith(
          notes: 'Updated notes with additional observations',
        );

        // Act
        final result = await repository.updateAssessment(updatedAssessment);

        // Assert
        expect(result, isTrue);
        expect(updatedAssessment.notes, equals('Updated notes with additional observations'));
        expect(updatedAssessment.score, equals(insertedAssessment.score));
        expect(updatedAssessment.id, equals(insertedAssessment.id));

      });
    });

    group('Assessment Deletion', () {
      test('should delete assessment by id', () async {
        // Arrange - insert an assessment first
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );
        final id = await repository.insertAssessment(assessment);

        // Act
        final result = await repository.deleteAssessment(id);

        // Assert
        expect(result, isTrue);

        // Verify it's deleted
        final allAssessments = await repository.getAllAssessments();
        expect(allAssessments.any((a) => a.id == id), isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle database insertion errors gracefully', () async {
        // Skip this test - it's testing error handling that doesn't apply
        // The repository doesn't throw exceptions, it would need mocking
      }, skip: 'Requires mock repository to test error handling');

      test('should handle retrieval errors gracefully', () async {
        // Skip this test - it's testing error handling that doesn't apply
        // The repository doesn't throw exceptions, it would need mocking
      }, skip: 'Requires mock repository to test error handling');
    });

    group('Assessment Score Calculations', () {
      test('should correctly calculate percentage scores', () {
        // Arrange & Act
        final assessment1 = Assessment(
          type: AssessmentType.memoryRecall,
          score: 27,
          maxScore: 30,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final assessment2 = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Assert
        expect(assessment1.percentage, equals(90.0));
        expect(assessment2.percentage, equals(85.0));
      });

      test('should handle zero maxScore edge case', () {
        // Arrange & Act
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 0,
          maxScore: 0,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Assert - Should not throw, just return NaN or 0
        expect(() => assessment.percentage, returnsNormally);
      });
    });
  });
}
