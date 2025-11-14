import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/data/repositories/assessment_repository_impl.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:brain_plan/presentation/providers/assessment_provider.dart';
import 'package:brain_plan/presentation/providers/database_provider.dart';
import 'package:brain_plan/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration test for Trail Making tests appearing in Overview MCI count
/// Bug: User completed Trail Making A & B, navigated to Overview, MCI count showed 0
/// But clicking info icon showed the tests in Weekly MCI Tests dialog
void main() {
  group('Trail Making Overview Integration Tests', () {
    late AppDatabase testDb;
    late ProviderContainer container;

    setUp(() async {
      testDb = AppDatabase.memory();
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(testDb),
          assessmentRepositoryProvider.overrideWithValue(AssessmentRepositoryImpl(testDb)),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await testDb.close();
    });

    test('Trail Making A & B tests MUST appear in Overview MCI weekly count immediately after completion', () async {
      // GIVEN: User completes Trail Making Test A
      final trailMakingA = Assessment(
        type: AssessmentType.executiveFunction,
        score: 45,
        maxScore: 120,
        notes: 'Trail Making Test A - Time: 45s, Errors: 0',
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await container.read(assessmentProvider.notifier).addAssessment(trailMakingA);

      // WHEN: User navigates to Overview tab
      final weeklyCount = await container.read(weeklyMCITestCountProvider.future);

      // THEN: Weekly MCI count MUST include Trail Making Test A
      expect(weeklyCount, 1, reason: 'Trail Making Test A must count toward weekly MCI goal');

      // AND GIVEN: User completes Trail Making Test B
      final trailMakingB = Assessment(
        type: AssessmentType.executiveFunction,
        score: 90,
        maxScore: 180,
        notes: 'Trail Making Test B - Time: 90s, Errors: 1',
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await container.read(assessmentProvider.notifier).addAssessment(trailMakingB);

      // WHEN: Overview refreshes
      container.invalidate(weeklyMCITestCountProvider);
      final updatedCount = await container.read(weeklyMCITestCountProvider.future);

      // THEN: Weekly MCI count MUST show both tests
      expect(updatedCount, 2, reason: 'Both Trail Making A & B must count toward weekly MCI goal');
    });

    test('Weekly MCI dialog MUST show same tests as Overview count', () async {
      // GIVEN: User completes multiple MCI tests including Trail Making
      final tests = [
        Assessment(
          type: AssessmentType.executiveFunction, // Trail Making
          score: 45,
          maxScore: 120,
          notes: 'Trail Making Test A',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        Assessment(
          type: AssessmentType.processingSpeed, // SDMT
          score: 50,
          maxScore: 110,
          notes: 'SDMT Test',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        Assessment(
          type: AssessmentType.memoryRecall, // 5-Word Recall
          score: 4,
          maxScore: 5,
          notes: '5-Word Recall',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      for (final test in tests) {
        await container.read(assessmentProvider.notifier).addAssessment(test);
      }

      // WHEN: Check Overview count
      container.invalidate(weeklyMCITestCountProvider);
      final weeklyCount = await container.read(weeklyMCITestCountProvider.future);

      // AND: Check Weekly MCI dialog list (simulating what the dialog shows)
      final repository = container.read(assessmentRepositoryProvider);
      final allAssessments = await repository.getAllAssessments();
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);

      final dialogTests = allAssessments.where((assessment) {
        final isThisWeek = assessment.completedAt.isAfter(weekStartMidnight) ||
                           assessment.completedAt.isAtSameMomentAs(weekStartMidnight);
        final isMCITest = assessment.type == AssessmentType.processingSpeed ||
                          assessment.type == AssessmentType.executiveFunction ||
                          assessment.type == AssessmentType.memoryRecall ||
                          assessment.type == AssessmentType.languageSkills ||
                          assessment.type == AssessmentType.visuospatialSkills;
        return isThisWeek && isMCITest;
      }).toList();

      // THEN: Count and dialog list MUST match
      expect(weeklyCount, dialogTests.length,
          reason: 'Overview MCI count must equal number of tests shown in dialog');
      expect(weeklyCount, 3, reason: 'All 3 MCI tests must be counted');
    });

    test('Trail Making executive function type MUST be recognized as MCI test', () async {
      // This test verifies the bug fix: executiveFunction was missing from MCI filter
      final trailMaking = Assessment(
        type: AssessmentType.executiveFunction,
        score: 45,
        maxScore: 120,
        notes: 'Trail Making Test',
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await container.read(assessmentProvider.notifier).addAssessment(trailMaking);

      final weeklyCount = await container.read(weeklyMCITestCountProvider.future);

      expect(weeklyCount, greaterThan(0),
          reason: 'AssessmentType.executiveFunction MUST be counted as MCI test');
    });
  });
}
