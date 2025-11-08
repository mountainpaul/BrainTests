import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Assessment Entity Tests', () {
    test('should calculate percentage correctly', () {
      // Arrange
      final assessment = Assessment(
        type: AssessmentType.memoryRecall,
        score: 80,
        maxScore: 100,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Assert
      expect(assessment.percentage, 80.0);
    });

    test('should calculate percentage correctly with different scores', () {
      // Arrange
      final assessment = Assessment(
        type: AssessmentType.attentionFocus,
        score: 15,
        maxScore: 20,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Assert
      expect(assessment.percentage, 75.0);
    });

    test('should create copy with updated values', () {
      // Arrange
      final originalAssessment = Assessment(
        id: 1,
        type: AssessmentType.memoryRecall,
        score: 80,
        maxScore: 100,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
        notes: 'Original notes',
      );

      // Act
      final updatedAssessment = originalAssessment.copyWith(
        score: 90,
        notes: 'Updated notes',
      );

      // Assert
      expect(updatedAssessment.id, 1);
      expect(updatedAssessment.score, 90);
      expect(updatedAssessment.notes, 'Updated notes');
      expect(updatedAssessment.type, AssessmentType.memoryRecall);
      expect(updatedAssessment.maxScore, 100);
    });

    test('should maintain equality with same properties', () {
      // Arrange
      final dateTime = DateTime.now();
      final assessment1 = Assessment(
        id: 1,
        type: AssessmentType.memoryRecall,
        score: 80,
        maxScore: 100,
        completedAt: dateTime,
        createdAt: dateTime,
      );
      
      final assessment2 = Assessment(
        id: 1,
        type: AssessmentType.memoryRecall,
        score: 80,
        maxScore: 100,
        completedAt: dateTime,
        createdAt: dateTime,
      );

      // Assert
      expect(assessment1, equals(assessment2));
    });

    test('should not be equal with different properties', () {
      // Arrange
      final dateTime = DateTime.now();
      final assessment1 = Assessment(
        id: 1,
        type: AssessmentType.memoryRecall,
        score: 80,
        maxScore: 100,
        completedAt: dateTime,
        createdAt: dateTime,
      );
      
      final assessment2 = Assessment(
        id: 2,
        type: AssessmentType.memoryRecall,
        score: 80,
        maxScore: 100,
        completedAt: dateTime,
        createdAt: dateTime,
      );

      // Assert
      expect(assessment1, isNot(equals(assessment2)));
    });
  });
}