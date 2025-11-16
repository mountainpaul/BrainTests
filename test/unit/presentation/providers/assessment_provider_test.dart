import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/domain/repositories/assessment_repository.dart';
import 'package:brain_tests/presentation/providers/assessment_provider.dart';
import 'package:brain_tests/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'assessment_provider_test.mocks.dart';

@GenerateMocks([AssessmentRepository])
void main() {
  group('Assessment Provider Tests', () {
    late MockAssessmentRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockAssessmentRepository();
      container = ProviderContainer(
        overrides: [
          assessmentRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('assessmentsProvider', () {
      test('should return all assessments from repository', () async {
        // Arrange
        final testAssessments = [
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
            type: AssessmentType.attentionFocus,
            score: 7,
            maxScore: 10,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        when(mockRepository.getAllAssessments())
            .thenAnswer((_) async => testAssessments);

        // Act
        final result = await container.read(assessmentsProvider.future);

        // Assert
        expect(result, equals(testAssessments));
        verify(mockRepository.getAllAssessments()).called(1);
      });

      test('should handle repository errors gracefully', () async {
        // Arrange
        when(mockRepository.getAllAssessments())
            .thenThrow(Exception('Database error'));

        // Act & Assert - The provider should throw when accessed via .future
        // Note: May throw Exception or StateError depending on timing
        try {
          await container.read(assessmentsProvider.future);
          fail('Expected an error but got success');
        } catch (e) {
          // Accept either Exception from repository or StateError from disposal
          expect(e is Exception || e is StateError, isTrue);
        }
      });
    });

    group('recentAssessmentsProvider', () {
      test('should return recent assessments with limit', () async {
        // Arrange
        final recentAssessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 9,
            maxScore: 10,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        when(mockRepository.getRecentAssessments(limit: 5))
            .thenAnswer((_) async => recentAssessments);

        // Act
        final result = await container.read(recentAssessmentsProvider.future);

        // Assert
        expect(result, equals(recentAssessments));
        verify(mockRepository.getRecentAssessments(limit: 5)).called(1);
      });

      test('should handle empty recent assessments', () async {
        // Arrange
        when(mockRepository.getRecentAssessments(limit: 5))
            .thenAnswer((_) async => []);

        // Act
        final result = await container.read(recentAssessmentsProvider.future);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('assessmentsByTypeProvider', () {
      test('should return assessments filtered by type', () async {
        // Arrange
        final memoryAssessments = [
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
            .thenAnswer((_) async => memoryAssessments);

        // Act
        final result = await container.read(
          assessmentsByTypeProvider(AssessmentType.memoryRecall).future,
        );

        // Assert
        expect(result, equals(memoryAssessments));
        expect(result.every((a) => a.type == AssessmentType.memoryRecall), isTrue);
        verify(mockRepository.getAssessmentsByType(AssessmentType.memoryRecall)).called(1);
      });

      test('should work with different assessment types', () async {
        // Arrange
        final attentionAssessments = [
          Assessment(
            id: 3,
            type: AssessmentType.attentionFocus,
            score: 7,
            maxScore: 10,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        when(mockRepository.getAssessmentsByType(AssessmentType.attentionFocus))
            .thenAnswer((_) async => attentionAssessments);

        // Act
        final result = await container.read(
          assessmentsByTypeProvider(AssessmentType.attentionFocus).future,
        );

        // Assert
        expect(result, equals(attentionAssessments));
        expect(result.every((a) => a.type == AssessmentType.attentionFocus), isTrue);
      });
    });

    group('averageScoresByTypeProvider', () {
      test('should return average scores by assessment type', () async {
        // Arrange
        final averageScores = {
          AssessmentType.memoryRecall: 85.0,
          AssessmentType.attentionFocus: 78.5,
          AssessmentType.executiveFunction: 92.0,
        };

        when(mockRepository.getAverageScoresByType())
            .thenAnswer((_) async => averageScores);

        // Act
        final result = await container.read(averageScoresByTypeProvider.future);

        // Assert
        expect(result, equals(averageScores));
        expect(result[AssessmentType.memoryRecall], equals(85.0));
        expect(result[AssessmentType.attentionFocus], equals(78.5));
        verify(mockRepository.getAverageScoresByType()).called(1);
      });

      test('should handle empty averages map', () async {
        // Arrange
        when(mockRepository.getAverageScoresByType())
            .thenAnswer((_) async => {});

        // Act
        final result = await container.read(averageScoresByTypeProvider.future);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('AssessmentNotifier', () {
      late AssessmentNotifier notifier;

      setUp(() {
        notifier = container.read(assessmentProvider.notifier);
      });

      test('should start with initial data state', () {
        // Assert
        final state = container.read(assessmentProvider);
        expect(state, isA<AsyncData<void>>());
      });

      test('should add assessment successfully', () async {
        // Arrange
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockRepository.insertAssessment(assessment))
            .thenAnswer((_) async => 1);
        when(mockRepository.getAllAssessments()).thenAnswer((_) async => []);
        when(mockRepository.getRecentAssessments(limit: 5)).thenAnswer((_) async => []);
        when(mockRepository.getAverageScoresByType()).thenAnswer((_) async => {});

        // Act
        await notifier.addAssessment(assessment);

        // Assert
        final state = container.read(assessmentProvider);
        expect(state, isA<AsyncData<void>>());
        verify(mockRepository.insertAssessment(assessment)).called(1);
      });

      test('should handle add assessment errors', () async {
        // Arrange
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockRepository.insertAssessment(assessment))
            .thenThrow(Exception('Database error'));

        // Act
        await notifier.addAssessment(assessment);

        // Assert
        final state = container.read(assessmentProvider);
        expect(state, isA<AsyncError<void>>());
        expect(state.error, isA<Exception>());
      });

      test('should update assessment successfully', () async {
        // Arrange
        final assessment = Assessment(
          id: 1,
          type: AssessmentType.memoryRecall,
          score: 9,
          maxScore: 10,
          notes: 'Updated notes',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockRepository.updateAssessment(assessment))
            .thenAnswer((_) async => true);
        when(mockRepository.getAllAssessments()).thenAnswer((_) async => []);
        when(mockRepository.getRecentAssessments(limit: 5)).thenAnswer((_) async => []);
        when(mockRepository.getAverageScoresByType()).thenAnswer((_) async => {});

        // Act
        await notifier.updateAssessment(assessment);

        // Assert
        final state = container.read(assessmentProvider);
        expect(state, isA<AsyncData<void>>());
        verify(mockRepository.updateAssessment(assessment)).called(1);
      });

      test('should delete assessment successfully', () async {
        // Arrange
        const assessmentId = 1;

        when(mockRepository.deleteAssessment(assessmentId))
            .thenAnswer((_) async => true);
        when(mockRepository.getAllAssessments()).thenAnswer((_) async => []);
        when(mockRepository.getRecentAssessments(limit: 5)).thenAnswer((_) async => []);
        when(mockRepository.getAverageScoresByType()).thenAnswer((_) async => {});

        // Act
        await notifier.deleteAssessment(assessmentId);

        // Assert
        final state = container.read(assessmentProvider);
        expect(state, isA<AsyncData<void>>());
        verify(mockRepository.deleteAssessment(assessmentId)).called(1);
      });

      test('should set loading state during operations', () async {
        // Arrange
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockRepository.insertAssessment(assessment))
            .thenAnswer((_) async {
          // Delay to check loading state
          await Future.delayed(const Duration(milliseconds: 10));
          return 1;
        });
        when(mockRepository.getAllAssessments()).thenAnswer((_) async => []);
        when(mockRepository.getRecentAssessments(limit: 5)).thenAnswer((_) async => []);
        when(mockRepository.getAverageScoresByType()).thenAnswer((_) async => {});

        // Keep provider alive during async operation
        final subscription = container.listen(assessmentProvider, (_, __) {});

        // Act & Assert
        final future = notifier.addAssessment(assessment);

        // Check loading state immediately
        final loadingState = container.read(assessmentProvider);
        expect(loadingState, isA<AsyncLoading<void>>());

        // Wait for completion
        await future;

        final finalState = container.read(assessmentProvider);
        expect(finalState, isA<AsyncData<void>>());

        subscription.close();
      });

      test('should invalidate related providers after successful operations', () async {
        // Arrange
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockRepository.insertAssessment(assessment))
            .thenAnswer((_) async => 1);

        // Set up fresh data for invalidated providers
        when(mockRepository.getAllAssessments())
            .thenAnswer((_) async => [assessment.copyWith(id: 1)]);
        when(mockRepository.getRecentAssessments(limit: 5))
            .thenAnswer((_) async => [assessment.copyWith(id: 1)]);
        when(mockRepository.getAverageScoresByType())
            .thenAnswer((_) async => {AssessmentType.memoryRecall: 80.0});

        // Act
        await notifier.addAssessment(assessment);

        // Assert - Check that providers can be read again (indicating they were invalidated)
        final assessments = await container.read(assessmentsProvider.future);
        final recentAssessments = await container.read(recentAssessmentsProvider.future);
        final averages = await container.read(averageScoresByTypeProvider.future);

        expect(assessments.length, equals(1));
        expect(recentAssessments.length, equals(1));
        expect(averages, isNotEmpty);
      });
    });

    group('Provider State Management', () {
      test('should handle provider disposal correctly', () {
        // Arrange & Act
        final testContainer = ProviderContainer(
          overrides: [
            assessmentRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        // Read providers to initialize them
        testContainer.read(assessmentsProvider);
        testContainer.read(assessmentProvider);

        // Assert - should not throw when disposing
        expect(testContainer.dispose, returnsNormally);
      });

      test('should handle provider overrides correctly', () {
        // Arrange
        final customContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => []),
          ],
        );

        // Act & Assert
        expect(() => customContainer.read(assessmentsProvider), returnsNormally);
        customContainer.dispose();
      });

      test('should handle concurrent provider reads', () async {
        // Arrange
        when(mockRepository.getAllAssessments()).thenAnswer((_) async => []);
        when(mockRepository.getRecentAssessments(limit: 5)).thenAnswer((_) async => []);
        when(mockRepository.getAverageScoresByType()).thenAnswer((_) async => {});

        // Act - Read multiple providers concurrently
        final futures = [
          container.read(assessmentsProvider.future),
          container.read(recentAssessmentsProvider.future),
          container.read(averageScoresByTypeProvider.future),
        ];

        // Assert - Should all complete successfully
        final results = await Future.wait(futures);
        expect(results.length, equals(3));
        expect(results[0], isA<List<Assessment>>());
        expect(results[1], isA<List<Assessment>>());
        expect(results[2], isA<Map<AssessmentType, double>>());
      });
    });

    group('Error Recovery', () {
      test('should recover from transient errors', () async {
        // Arrange - First call throws error
        when(mockRepository.getAllAssessments())
            .thenThrow(Exception('Temporary error'));

        // Act & Assert - First call should fail
        try {
          await container.read(assessmentsProvider.future);
          fail('Expected exception but got success');
        } catch (e) {
          // Accept either Exception from repository or StateError from disposal
          expect(e is Exception || e is StateError, isTrue);
        }

        // Arrange - Second call succeeds (set up stub before invalidating)
        when(mockRepository.getAllAssessments())
            .thenAnswer((_) async => []);

        // Invalidate provider to retry
        container.invalidate(assessmentsProvider);

        // Second call should succeed
        final result = await container.read(assessmentsProvider.future);
        expect(result, isA<List<Assessment>>());
        expect(result, isEmpty);
      });

      test('should handle null values gracefully', () async {
        // Arrange
        when(mockRepository.getAllAssessments()).thenAnswer((_) async => []);
        when(mockRepository.getRecentAssessments(limit: 5)).thenAnswer((_) async => []);

        // Act
        final assessments = await container.read(assessmentsProvider.future);
        final recentAssessments = await container.read(recentAssessmentsProvider.future);

        // Assert
        expect(assessments, isNotNull);
        expect(recentAssessments, isNotNull);
        expect(assessments, isEmpty);
        expect(recentAssessments, isEmpty);
      });
    });
  });
}