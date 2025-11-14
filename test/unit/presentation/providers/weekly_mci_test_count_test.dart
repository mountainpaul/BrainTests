import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:brain_plan/domain/repositories/assessment_repository.dart';
import 'package:brain_plan/presentation/providers/assessment_provider.dart';
import 'package:brain_plan/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'weekly_mci_test_count_test.mocks.dart';

@GenerateMocks([AssessmentRepository])
void main() {
  group('weeklyMCITestCountProvider', () {
    late MockAssessmentRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockAssessmentRepository();
    });

    tearDown(() {
      container.dispose();
    });

    test('should return 0 when no assessments completed', () async {
      // Arrange
      when(mockRepository.getAllAssessments()).thenAnswer((_) async => []);

      container = ProviderContainer(
        overrides: [
          assessmentRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Act
      final count = await container.read(weeklyMCITestCountProvider.future);

      // Assert
      expect(count, 0);
    });

    test('should return 1 when 1 assessment completed this week', () async {
      // Arrange
      final now = DateTime.now();
      final thisWeekMonday = now.subtract(Duration(days: now.weekday - 1));

      final assessment = Assessment(
        id: 1,
        type: AssessmentType.processingSpeed, // Trail Making Test A
        score: 45,
        maxScore: 50,
        completedAt: thisWeekMonday.add(const Duration(days: 1)),
        createdAt: thisWeekMonday.add(const Duration(days: 1)),
      );

      when(mockRepository.getAllAssessments()).thenAnswer((_) async => [assessment]);

      container = ProviderContainer(
        overrides: [
          assessmentRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Act
      final count = await container.read(weeklyMCITestCountProvider.future);

      // Assert
      expect(count, 1);
    });

    test('should return 2 when 2 assessments completed this week', () async {
      // Arrange
      final now = DateTime.now();
      final thisWeekMonday = now.subtract(Duration(days: now.weekday - 1));

      final assessments = [
        Assessment(
          id: 1,
          type: AssessmentType.processingSpeed, // Trail Making Test A
          score: 45,
          maxScore: 50,
          completedAt: thisWeekMonday.add(const Duration(days: 1)),
          createdAt: thisWeekMonday.add(const Duration(days: 1)),
        ),
        Assessment(
          id: 2,
          type: AssessmentType.executiveFunction, // Trail Making Test B
          score: 90,
          maxScore: 100,
          completedAt: thisWeekMonday.add(const Duration(days: 2)),
          createdAt: thisWeekMonday.add(const Duration(days: 2)),
        ),
      ];

      when(mockRepository.getAllAssessments()).thenAnswer((_) async => assessments);

      container = ProviderContainer(
        overrides: [
          assessmentRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Act
      final count = await container.read(weeklyMCITestCountProvider.future);

      // Assert
      expect(count, 2);
    });

    test('should NOT count assessments from last week', () async {
      // Arrange
      final now = DateTime.now();
      final lastWeekMonday = now.subtract(Duration(days: now.weekday + 6));

      final assessment = Assessment(
        id: 1,
        type: AssessmentType.languageSkills,
        score: 15,
        maxScore: 20,
        completedAt: lastWeekMonday.add(const Duration(days: 2)),
        createdAt: lastWeekMonday.add(const Duration(days: 2)),
      );

      when(mockRepository.getAllAssessments()).thenAnswer((_) async => [assessment]);

      container = ProviderContainer(
        overrides: [
          assessmentRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Act
      final count = await container.read(weeklyMCITestCountProvider.future);

      // Assert
      expect(count, 0);
    });

    test('should count all 5 MCI test types (not attentionFocus)', () async {
      // Arrange
      final now = DateTime.now();
      final thisWeekMonday = now.subtract(Duration(days: now.weekday - 1));

      final assessments = [
        // MCI tests (SHOULD be counted - 5 types)
        Assessment(
          id: 1,
          type: AssessmentType.memoryRecall,
          score: 4,
          maxScore: 5,
          completedAt: thisWeekMonday.add(const Duration(days: 1)),
          createdAt: thisWeekMonday.add(const Duration(days: 1)),
        ),
        // Non-MCI test (should NOT be counted)
        Assessment(
          id: 2,
          type: AssessmentType.attentionFocus,
          score: 85,
          maxScore: 100,
          completedAt: thisWeekMonday.add(const Duration(days: 1)),
          createdAt: thisWeekMonday.add(const Duration(days: 1)),
        ),
        Assessment(
          id: 3,
          type: AssessmentType.executiveFunction, // Trail Making Test B
          score: 90,
          maxScore: 100,
          completedAt: thisWeekMonday.add(const Duration(days: 2)),
          createdAt: thisWeekMonday.add(const Duration(days: 2)),
        ),
        Assessment(
          id: 4,
          type: AssessmentType.languageSkills,
          score: 15,
          maxScore: 20,
          completedAt: thisWeekMonday.add(const Duration(days: 2)),
          createdAt: thisWeekMonday.add(const Duration(days: 2)),
        ),
        Assessment(
          id: 5,
          type: AssessmentType.visuospatialSkills,
          score: 8,
          maxScore: 10,
          completedAt: thisWeekMonday.add(const Duration(days: 3)),
          createdAt: thisWeekMonday.add(const Duration(days: 3)),
        ),
        Assessment(
          id: 6,
          type: AssessmentType.processingSpeed, // Trail Making Test A
          score: 45,
          maxScore: 50,
          completedAt: thisWeekMonday.add(const Duration(days: 3)),
          createdAt: thisWeekMonday.add(const Duration(days: 3)),
        ),
      ];

      when(mockRepository.getAllAssessments()).thenAnswer((_) async => assessments);

      container = ProviderContainer(
        overrides: [
          assessmentRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Act
      final count = await container.read(weeklyMCITestCountProvider.future);

      // Assert - All 5 MCI test types should be counted
      // (processingSpeed, executiveFunction, languageSkills, visuospatialSkills, memoryRecall)
      expect(count, 5);
    });
  });
}
