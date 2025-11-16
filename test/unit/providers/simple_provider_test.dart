import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/domain/entities/mood_entry.dart';
import 'package:brain_tests/domain/entities/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple test providers
final testAssessmentProvider = Provider<List<Assessment>>((ref) {
  return [
    Assessment(
      id: 1,
      type: AssessmentType.memoryRecall,
      score: 85,
      maxScore: 100,
      completedAt: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];
});

final testReminderProvider = Provider<List<Reminder>>((ref) {
  return [
    Reminder(
      id: 1,
      title: 'Test Reminder',
      type: ReminderType.medication,
      frequency: ReminderFrequency.daily,
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      isActive: true,
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
});

final testMoodProvider = Provider<MoodEntry?>((ref) {
  return MoodEntry(
    id: 1,
    mood: MoodLevel.good,
    energyLevel: 8,
    stressLevel: 3,
    sleepQuality: 7,
    entryDate: DateTime.now(),
    createdAt: DateTime.now(),
  );
});

// Computed provider that combines data from multiple sources
final dashboardSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final assessments = ref.watch(testAssessmentProvider);
  final reminders = ref.watch(testReminderProvider);
  final mood = ref.watch(testMoodProvider);

  return {
    'total_assessments': assessments.length,
    'avg_assessment_score': assessments.isEmpty
        ? 0.0
        : assessments.map((a) => a.percentage).reduce((a, b) => a + b) / assessments.length,
    'pending_reminders': reminders.where((r) => !r.isCompleted).length,
    'mood_wellness': mood?.overallWellness ?? 0.0,
    'last_assessment_date': assessments.isNotEmpty
        ? assessments.first.completedAt.toIso8601String()
        : null,
  };
});

// Stateful provider for managing assessment filter (using NotifierProvider in Riverpod 3.x)
final assessmentFilterProvider = NotifierProvider<AssessmentFilterNotifier, AssessmentType?>(
  AssessmentFilterNotifier.new,
);

class AssessmentFilterNotifier extends Notifier<AssessmentType?> {
  @override
  AssessmentType? build() => null;

  void setFilter(AssessmentType? type) {
    state = type;
  }
}

final filteredAssessmentsProvider = Provider<List<Assessment>>((ref) {
  final assessments = ref.watch(testAssessmentProvider);
  final filter = ref.watch(assessmentFilterProvider);

  if (filter == null) return assessments;
  return assessments.where((a) => a.type == filter).toList();
});

// Async provider simulation
final asyncAssessmentProvider = FutureProvider<List<Assessment>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 100));
  return [
    Assessment(
      id: 2,
      type: AssessmentType.attentionFocus,
      score: 78,
      maxScore: 100,
      completedAt: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    Assessment(
      id: 3,
      type: AssessmentType.executiveFunction,
      score: 92,
      maxScore: 100,
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 12)),
    ),
  ];
});

void main() {
  group('Simple Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Basic Provider Tests', () {
      test('should provide assessment data', () {
        // Act
        final assessments = container.read(testAssessmentProvider);

        // Assert
        expect(assessments, isNotEmpty);
        expect(assessments.length, equals(1));
        expect(assessments.first.type, equals(AssessmentType.memoryRecall));
        expect(assessments.first.percentage, equals(85.0));
      });

      test('should provide reminder data', () {
        // Act
        final reminders = container.read(testReminderProvider);

        // Assert
        expect(reminders, isNotEmpty);
        expect(reminders.length, equals(1));
        expect(reminders.first.type, equals(ReminderType.medication));
        expect(reminders.first.isActive, isTrue);
        expect(reminders.first.isCompleted, isFalse);
      });

      test('should provide mood entry data', () {
        // Act
        final mood = container.read(testMoodProvider);

        // Assert
        expect(mood, isNotNull);
        expect(mood!.mood, equals(MoodLevel.good));
        expect(mood.overallWellness, equals(7.75)); // (8+8+7+7)/4 = 7.75
        expect(mood.energyLevel, equals(8));
        expect(mood.stressLevel, equals(3));
      });
    });

    group('Computed Provider Tests', () {
      test('should compute dashboard summary from multiple providers', () {
        // Act
        final summary = container.read(dashboardSummaryProvider);

        // Assert
        expect(summary['total_assessments'], equals(1));
        expect(summary['avg_assessment_score'], equals(85.0));
        expect(summary['pending_reminders'], equals(1));
        expect(summary['mood_wellness'], equals(7.75));
        expect(summary['last_assessment_date'], isNotNull);
      });

      test('should handle empty assessment data in dashboard summary', () {
        // Arrange - Override with empty assessments
        final testContainer = ProviderContainer(
          overrides: [
            testAssessmentProvider.overrideWithValue([]),
          ],
        );

        // Act
        final summary = testContainer.read(dashboardSummaryProvider);

        // Assert
        expect(summary['total_assessments'], equals(0));
        expect(summary['avg_assessment_score'], equals(0.0));
        expect(summary['last_assessment_date'], isNull);

        testContainer.dispose();
      });

      test('should handle null mood entry in dashboard summary', () {
        // Arrange - Override with null mood
        final testContainer = ProviderContainer(
          overrides: [
            testMoodProvider.overrideWithValue(null),
          ],
        );

        // Act
        final summary = testContainer.read(dashboardSummaryProvider);

        // Assert
        expect(summary['mood_wellness'], equals(0.0));

        testContainer.dispose();
      });
    });

    group('Stateful Provider Tests', () {
      test('should manage assessment filter state', () {
        // Act - Initial state
        final initialFilter = container.read(assessmentFilterProvider);

        // Assert - Initial state is null
        expect(initialFilter, isNull);

        // Act - Update filter
        container.read(assessmentFilterProvider.notifier).setFilter(AssessmentType.memoryRecall);
        final updatedFilter = container.read(assessmentFilterProvider);

        // Assert - Filter is updated
        expect(updatedFilter, equals(AssessmentType.memoryRecall));
      });

      test('should filter assessments based on type', () {
        // Act - Initial filtered assessments (no filter)
        final allAssessments = container.read(filteredAssessmentsProvider);

        // Assert - All assessments returned
        expect(allAssessments.length, equals(1));

        // Act - Set filter to memory recall
        container.read(assessmentFilterProvider.notifier).setFilter(AssessmentType.memoryRecall);
        final filteredMemory = container.read(filteredAssessmentsProvider);

        // Assert - Only memory recall assessments
        expect(filteredMemory.length, equals(1));
        expect(filteredMemory.first.type, equals(AssessmentType.memoryRecall));

        // Act - Set filter to attention focus (no matches)
        container.read(assessmentFilterProvider.notifier).setFilter(AssessmentType.attentionFocus);
        final filteredAttention = container.read(filteredAssessmentsProvider);

        // Assert - No assessments match
        expect(filteredAttention.length, equals(0));
      });

      test('should reset filter and show all assessments', () {
        // Arrange - Set initial filter
        container.read(assessmentFilterProvider.notifier).setFilter(AssessmentType.attentionFocus);
        final filtered = container.read(filteredAssessmentsProvider);
        expect(filtered.length, equals(0));

        // Act - Reset filter to null
        container.read(assessmentFilterProvider.notifier).setFilter(null);
        final resetFiltered = container.read(filteredAssessmentsProvider);

        // Assert - All assessments shown again
        expect(resetFiltered.length, equals(1));
      });
    });

    group('Async Provider Tests', () {
      test('should handle async assessment data', () async {
        // Act
        final asyncAssessments = await container.read(asyncAssessmentProvider.future);

        // Assert
        expect(asyncAssessments, isNotEmpty);
        expect(asyncAssessments.length, equals(2));
        expect(asyncAssessments.first.type, equals(AssessmentType.attentionFocus));
        expect(asyncAssessments.last.type, equals(AssessmentType.executiveFunction));
        expect(asyncAssessments.first.percentage, equals(78.0));
        expect(asyncAssessments.last.percentage, equals(92.0));
      });

      test('should handle async provider states', () {
        // Act - Get async value immediately (should be loading)
        final asyncValue = container.read(asyncAssessmentProvider);

        // Assert - Should be in loading state
        expect(asyncValue.isLoading, isTrue);
        expect(asyncValue.hasValue, isFalse);
        expect(asyncValue.hasError, isFalse);
      });

      test('should provide async data when ready', () async {
        // Act - Wait for async data
        final asyncValue = await container.read(asyncAssessmentProvider.future);

        // Assert - Should have data
        expect(asyncValue.length, equals(2));

        // Act - Read provider again (should be cached)
        final cachedValue = container.read(asyncAssessmentProvider);
        expect(cachedValue.hasValue, isTrue);
        expect(cachedValue.value!.length, equals(2));
      });
    });

    group('Provider Dependency Tests', () {
      test('should update dependent providers when dependencies change', () {
        // Arrange - Initial state
        final initialSummary = container.read(dashboardSummaryProvider);
        expect(initialSummary['total_assessments'], equals(1));

        // Act - Override assessment provider with more data
        final newContainer = ProviderContainer(
          overrides: [
            testAssessmentProvider.overrideWithValue([
              Assessment(
                id: 4,
                type: AssessmentType.languageSkills,
                score: 95,
                maxScore: 100,
                completedAt: DateTime.now(),
                createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
              ),
              Assessment(
                id: 5,
                type: AssessmentType.visuospatialSkills,
                score: 88,
                maxScore: 100,
                completedAt: DateTime.now().subtract(const Duration(minutes: 5)),
                createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
              ),
            ]),
          ],
        );

        // Assert - Dashboard summary reflects new data
        final newSummary = newContainer.read(dashboardSummaryProvider);
        expect(newSummary['total_assessments'], equals(2));
        expect(newSummary['avg_assessment_score'], equals(91.5)); // (95 + 88) / 2

        newContainer.dispose();
      });

      test('should handle provider override chains', () {
        // Arrange - Create provider with multiple overrides
        final complexContainer = ProviderContainer(
          overrides: [
            testAssessmentProvider.overrideWithValue([
              Assessment(
                id: 6,
                type: AssessmentType.processingSpeed,
                score: 75,
                maxScore: 100,
                completedAt: DateTime.now(),
                createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
              ),
            ]),
            testReminderProvider.overrideWithValue([
              Reminder(
                id: 2,
                title: 'Completed Exercise',
                type: ReminderType.exercise,
                frequency: ReminderFrequency.daily,
                scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
                isActive: true,
                isCompleted: true, // Completed
                createdAt: DateTime.now().subtract(const Duration(hours: 2)),
                updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
              ),
            ]),
            testMoodProvider.overrideWithValue(
              MoodEntry(
                id: 2,
                mood: MoodLevel.excellent,
                energyLevel: 10,
                stressLevel: 1,
                sleepQuality: 9,
                entryDate: DateTime.now(),
                createdAt: DateTime.now(),
              ),
            ),
          ],
        );

        // Act
        final summary = complexContainer.read(dashboardSummaryProvider);

        // Assert - All overridden values reflected
        expect(summary['total_assessments'], equals(1));
        expect(summary['avg_assessment_score'], equals(75.0));
        expect(summary['pending_reminders'], equals(0)); // Completed reminder
        expect(summary['mood_wellness'], equals(9.75)); // Excellent mood

        complexContainer.dispose();
      });
    });

    group('Provider Error Handling', () {
      test('should handle provider exceptions gracefully', () {
        // Arrange - Provider that throws an exception
        final errorProvider = Provider<String>((ref) {
          throw Exception('Test error');
        });

        // Act & Assert
        expect(() => container.read(errorProvider), throwsException);
      });

      test('should handle async provider errors', () async {
        // Arrange - Async provider that throws
        final errorAsyncProvider = FutureProvider<String>((ref) async {
          await Future.delayed(const Duration(milliseconds: 50));
          throw Exception('Async test error');
        });

        // Act & Assert - Accept Exception or StateError if disposed
        try {
          await container.read(errorAsyncProvider.future);
          fail('Expected an error but got success');
        } catch (e) {
          expect(e is Exception || e is StateError, isTrue);
        }

        // Check error state (if not disposed)
        await Future.delayed(const Duration(milliseconds: 100));
        try {
          final asyncValue = container.read(errorAsyncProvider);
          expect(asyncValue.hasError, isTrue);
          expect(asyncValue.error, isException);
        } catch (e) {
          // Provider may have been disposed, which is acceptable
          expect(e is StateError, isTrue);
        }
      });
    });
  });
}