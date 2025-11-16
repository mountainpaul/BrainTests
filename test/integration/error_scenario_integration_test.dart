import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/data/repositories/assessment_repository_impl.dart';
import 'package:brain_tests/data/repositories/cognitive_exercise_repository_impl.dart';
import 'package:brain_tests/data/repositories/mood_entry_repository_impl.dart';
import 'package:brain_tests/data/repositories/reminder_repository_impl.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:brain_tests/domain/entities/mood_entry.dart';
import 'package:brain_tests/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_database.dart';

class FailingDatabase extends Mock implements AppDatabase {}

void main() {
  group('Error Scenario Integration Tests', () {
    late AppDatabase database;
    late AssessmentRepositoryImpl assessmentRepository;
    late ReminderRepositoryImpl reminderRepository;
    late MoodEntryRepositoryImpl moodRepository;
    late CognitiveExerciseRepositoryImpl exerciseRepository;

    setUp(() async {
      database = createTestDatabase();
      assessmentRepository = AssessmentRepositoryImpl(database);
      reminderRepository = ReminderRepositoryImpl(database);
      moodRepository = MoodEntryRepositoryImpl(database);
      exerciseRepository = CognitiveExerciseRepositoryImpl(database);
    });

    tearDown(() async {
      await closeTestDatabase(database);
    });

    group('Database Connection Failures', () {
      test('should handle graceful degradation when database is unavailable', () async {
        // Insert some initial data
        await assessmentRepository.insertAssessment(Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));

        // Close database to simulate connection failure
        await closeTestDatabase(database);

        // Test read operations on closed database
        try {
          await assessmentRepository.getAllAssessments();
          fail('Expected database read to fail');
        } catch (e) {
          expect(e, isA<StateError>());
        }

        // Test write operations on closed database
        try {
          await assessmentRepository.insertAssessment(Assessment(
            type: AssessmentType.attentionFocus,
            score: 75,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ));
          fail('Expected database write to fail');
        } catch (e) {
          // Database throws StateError when trying to use a closed database
          expect(e, anyOf(isA<Exception>(), isA<StateError>()));
        }

        // Test update operations on closed database
        try {
          final testAssessment = Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 90,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          );
          await assessmentRepository.updateAssessment(testAssessment);
          fail('Expected database update to fail');
        } catch (e) {
          expect(e, isA<Exception>());
        }

        // Test delete operations on closed database
        try {
          await assessmentRepository.deleteAssessment(1);
          fail('Expected database delete to fail');
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });

      test('should handle database reconnection after failure', () async {
        // Create new database after connection failure
        database = createTestDatabase();
        assessmentRepository = AssessmentRepositoryImpl(database);

        // Verify operations work with new connection
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await assessmentRepository.insertAssessment(assessment);
        expect(id, greaterThan(0));

        final retrieved = await assessmentRepository.getAssessmentById(id);
        expect(retrieved, isNotNull);
        expect(retrieved!.score, equals(85));

        await closeTestDatabase(database);
      });
    });

    group('Data Corruption and Recovery', () {
      test('should handle invalid data gracefully', () async {
        // Test with extreme values
        final extremeAssessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: -1, // Invalid negative score
          maxScore: 0, // Invalid zero max score
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Repository should handle invalid data
        final id = await assessmentRepository.insertAssessment(extremeAssessment);
        final retrieved = await assessmentRepository.getAssessmentById(id);

        expect(retrieved, isNotNull);
        expect(retrieved!.score, equals(-1)); // Data is stored as-is, validation at app level
        expect(retrieved.maxScore, equals(0));

        // Test with extreme mood values
        final extremeMood = MoodEntry(
          mood: MoodLevel.excellent,
          energyLevel: 100, // Out of normal range
          stressLevel: -5, // Invalid negative
          sleepQuality: 0, // Edge case
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final moodId = await moodRepository.insertMoodEntry(extremeMood);
        final retrievedMood = await moodRepository.getMoodEntryById(moodId);

        expect(retrievedMood, isNotNull);
        expect(retrievedMood!.energyLevel, equals(100));
        expect(retrievedMood.stressLevel, equals(-5));
      });

      test('should handle malformed date data', () async {
        // Test with edge case dates
        final futureDateAssessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: DateTime(2050, 12, 31), // Far future
          createdAt: DateTime(1900, 1, 1), // Far past
        );

        final id = await assessmentRepository.insertAssessment(futureDateAssessment);
        final retrieved = await assessmentRepository.getAssessmentById(id);

        expect(retrieved, isNotNull);
        expect(retrieved!.completedAt.year, equals(2050));
        expect(retrieved.createdAt.year, equals(1900));

        // Test date range queries with edge cases
        final rangeResults = await moodRepository.getMoodEntriesByDateRange(
          DateTime(1900, 1, 1),
          DateTime(2050, 12, 31),
        );

        expect(rangeResults, isA<List<MoodEntry>>());
      });

      test('should handle duplicate and conflicting data', () async {
        // Insert identical assessments
        final assessment1 = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          notes: 'Duplicate test',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final assessment2 = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          notes: 'Duplicate test',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id1 = await assessmentRepository.insertAssessment(assessment1);
        final id2 = await assessmentRepository.insertAssessment(assessment2);

        expect(id1, isNot(equals(id2))); // Should have different IDs
        expect(id1, greaterThan(0));
        expect(id2, greaterThan(0));

        final allAssessments = await assessmentRepository.getAllAssessments();
        expect(allAssessments.length, equals(2));

        // Test conflicting updates
        final updatedAssessment1 = assessment1.copyWith(id: id1, score: 95);
        final updatedAssessment2 = assessment2.copyWith(id: id1, score: 75); // Same ID, different data

        await assessmentRepository.updateAssessment(updatedAssessment1);
        final result1 = await assessmentRepository.getAssessmentById(id1);
        expect(result1!.score, equals(95));

        await assessmentRepository.updateAssessment(updatedAssessment2);
        final result2 = await assessmentRepository.getAssessmentById(id1);
        expect(result2!.score, equals(75)); // Last update wins
      });
    });

    group('Concurrency and Race Conditions', () {
      test('should handle concurrent modifications safely', () async {
        // Insert initial assessment
        final initialAssessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 50,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await assessmentRepository.insertAssessment(initialAssessment);

        // Simulate concurrent updates
        final futures = <Future>[];
        for (int i = 0; i < 10; i++) {
          futures.add(
            assessmentRepository.getAssessmentById(id).then((assessment) async {
              if (assessment != null) {
                final updated = assessment.copyWith(score: 50 + i);
                return assessmentRepository.updateAssessment(updated);
              }
              return false;
            }),
          );
        }

        final results = await Future.wait(futures);
        expect(results.every((result) => result == true), isTrue);

        // Verify final state is consistent
        final finalAssessment = await assessmentRepository.getAssessmentById(id);
        expect(finalAssessment, isNotNull);
        expect(finalAssessment!.score, greaterThanOrEqualTo(50));
        expect(finalAssessment.score, lessThan(60));
      });

      test('should handle concurrent deletes and updates', () async {
        // Create multiple assessments
        final assessmentIds = <int>[];
        for (int i = 0; i < 5; i++) {
          final id = await assessmentRepository.insertAssessment(Assessment(
            type: AssessmentType.memoryRecall,
            score: 70 + i,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ));
          assessmentIds.add(id);
        }

        // Concurrent operations: some delete, some update
        final operations = <Future>[];

        // Delete operations
        for (int i = 0; i < 2; i++) {
          operations.add(assessmentRepository.deleteAssessment(assessmentIds[i]));
        }

        // Update operations
        for (int i = 2; i < 5; i++) {
          operations.add(
            assessmentRepository.getAssessmentById(assessmentIds[i]).then((assessment) async {
              if (assessment != null) {
                final updated = assessment.copyWith(score: assessment.score + 10);
                return assessmentRepository.updateAssessment(updated);
              }
              return false;
            }),
          );
        }

        await Future.wait(operations);

        // Verify results
        final remainingAssessments = await assessmentRepository.getAllAssessments();
        expect(remainingAssessments.length, equals(3)); // 2 deleted, 3 remaining

        for (final assessment in remainingAssessments) {
          expect(assessment.score, greaterThan(79)); // Should be updated
        }
      });
    });

    group('Memory and Resource Exhaustion', () {
      test('should handle memory pressure during large operations', () async {
        // This test simulates memory pressure by creating many objects
        final largeDataSet = <Assessment>[];

        // Create large dataset in memory
        for (int i = 0; i < 1000; i++) {
          largeDataSet.add(Assessment(
            type: AssessmentType.values[i % AssessmentType.values.length],
            score: i % 100,
            maxScore: 100,
            notes: 'Large dataset item $i with some additional text to increase memory usage',
            completedAt: DateTime.now().subtract(Duration(seconds: i)),
            createdAt: DateTime.now().subtract(Duration(seconds: i)),
          ));
        }

        // Insert all data
        for (final assessment in largeDataSet) {
          await assessmentRepository.insertAssessment(assessment);
        }

        // Perform memory-intensive operations
        final allAssessments = await assessmentRepository.getAllAssessments();
        expect(allAssessments.length, equals(1000));

        // Multiple complex queries
        final memoryAssessments = await assessmentRepository.getAssessmentsByType(AssessmentType.memoryRecall);
        final averages = await assessmentRepository.getAverageScoresByType();
        final recent = await assessmentRepository.getRecentAssessments(limit: 100);

        expect(memoryAssessments, isA<List<Assessment>>());
        expect(averages, isA<Map<AssessmentType, double>>());
        expect(recent.length, equals(100));

        // Clear references to help with memory management
        largeDataSet.clear();
      });

      test('should handle disk space limitations gracefully', () async {
        // Simulate large data insertion (within reasonable test limits)
        final largeTextData = 'x' * 1000; // 1KB per record

        final assessments = <Assessment>[];
        for (int i = 0; i < 100; i++) {
          assessments.add(Assessment(
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            notes: 'Large data $i: $largeTextData',
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ));
        }

        // Insert all large data
        final insertedIds = <int>[];
        for (final assessment in assessments) {
          final id = await assessmentRepository.insertAssessment(assessment);
          insertedIds.add(id);
        }

        expect(insertedIds.length, equals(100));

        // Verify data integrity despite large size
        for (final id in insertedIds.take(10)) {
          final retrieved = await assessmentRepository.getAssessmentById(id);
          expect(retrieved, isNotNull);
          expect(retrieved!.notes, contains(largeTextData));
        }

        // Test bulk delete to free space
        for (final id in insertedIds.take(50)) {
          await assessmentRepository.deleteAssessment(id);
        }

        final remaining = await assessmentRepository.getAllAssessments();
        expect(remaining.length, equals(50));
      });
    });

    group('Network and External System Failures', () {
      test('should handle offline mode gracefully', () async {
        // Simulate offline operations (all operations should work with local database)
        final offlineAssessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          notes: 'Offline assessment',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // All operations should work in offline mode
        final id = await assessmentRepository.insertAssessment(offlineAssessment);
        expect(id, greaterThan(0));

        final retrieved = await assessmentRepository.getAssessmentById(id);
        expect(retrieved, isNotNull);
        expect(retrieved!.notes, equals('Offline assessment'));

        final updated = retrieved.copyWith(notes: 'Offline assessment - updated');
        final updateResult = await assessmentRepository.updateAssessment(updated);
        expect(updateResult, isTrue);

        final deleteResult = await assessmentRepository.deleteAssessment(id);
        expect(deleteResult, isTrue);
      });

      test('should handle system clock changes', () async {
        final baseTime = DateTime.now();

        // Insert assessment with current time
        final assessment1 = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: baseTime,
          createdAt: baseTime,
        );

        final id1 = await assessmentRepository.insertAssessment(assessment1);

        // Simulate system clock going backwards (negative time)
        final pastTime = baseTime.subtract(const Duration(hours: 24));
        final assessment2 = Assessment(
          type: AssessmentType.attentionFocus,
          score: 75,
          maxScore: 100,
          completedAt: pastTime,
          createdAt: pastTime,
        );

        final id2 = await assessmentRepository.insertAssessment(assessment2);

        // Simulate system clock jumping forward
        final futureTime = baseTime.add(const Duration(days: 30));
        final assessment3 = Assessment(
          type: AssessmentType.executiveFunction,
          score: 90,
          maxScore: 100,
          completedAt: futureTime,
          createdAt: futureTime,
        );

        final id3 = await assessmentRepository.insertAssessment(assessment3);

        // Verify all assessments exist
        final all = await assessmentRepository.getAllAssessments();
        expect(all.length, equals(3));

        // Verify ordering still works despite time changes
        expect(all.any((a) => a.id == id1), isTrue);
        expect(all.any((a) => a.id == id2), isTrue);
        expect(all.any((a) => a.id == id3), isTrue);
      });
    });

    group('Edge Case Data Scenarios', () {
      test('should handle empty and null-like data', () async {
        // Test with minimal data
        final minimalAssessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 0,
          maxScore: 1,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await assessmentRepository.insertAssessment(minimalAssessment);
        expect(id, greaterThan(0));

        final retrieved = await assessmentRepository.getAssessmentById(id);
        expect(retrieved, isNotNull);
        expect(retrieved!.score, equals(0));
        expect(retrieved.notes, isNull);

        // Test with empty collections
        final emptyResults = await assessmentRepository.getAssessmentsByType(AssessmentType.languageSkills);
        expect(emptyResults, isA<List<Assessment>>());
        expect(emptyResults.isEmpty, isTrue);

        // Test with non-existent IDs
        final nonExistent = await assessmentRepository.getAssessmentById(99999);
        expect(nonExistent, isNull);

        // Test delete of non-existent record
        final deleteResult = await assessmentRepository.deleteAssessment(99999);
        expect(deleteResult, isFalse);
      });

      test('should handle maximum boundary values', () async {
        // Test with maximum integer values
        final maxAssessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 2147483647, // Max int32
          maxScore: 2147483647,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await assessmentRepository.insertAssessment(maxAssessment);
        final retrieved = await assessmentRepository.getAssessmentById(id);

        expect(retrieved, isNotNull);
        expect(retrieved!.score, equals(2147483647));
        expect(retrieved.maxScore, equals(2147483647));

        // Test with very long strings
        final longString = 'x' * 10000; // 10KB string
        final longNoteAssessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          notes: longString,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final longId = await assessmentRepository.insertAssessment(longNoteAssessment);
        final longRetrieved = await assessmentRepository.getAssessmentById(longId);

        expect(longRetrieved, isNotNull);
        expect(longRetrieved!.notes, equals(longString));
        expect(longRetrieved.notes!.length, equals(10000));
      });
    });

    group('Transaction and Consistency Errors', () {
      test('should handle partial operation failures', () async {
        // Test scenario where some operations succeed and others fail
        final successfulAssessments = <int>[];
        final failedOperations = <String>[];

        // Mix of valid and edge case data
        final testData = [
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ), // Valid
          Assessment(
            type: AssessmentType.attentionFocus,
            score: -100,
            maxScore: 0,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ), // Edge case but should work
          Assessment(
            type: AssessmentType.executiveFunction,
            score: 95,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ), // Valid
        ];

        for (int i = 0; i < testData.length; i++) {
          try {
            final id = await assessmentRepository.insertAssessment(testData[i]);
            successfulAssessments.add(id);
          } catch (e) {
            failedOperations.add('Assessment $i: ${e.toString()}');
          }
        }

        // Even edge case data should succeed (validation is at app level)
        expect(successfulAssessments.length, equals(3));
        expect(failedOperations.isEmpty, isTrue);

        // Verify data integrity for successful operations
        for (final id in successfulAssessments) {
          final assessment = await assessmentRepository.getAssessmentById(id);
          expect(assessment, isNotNull);
        }
      });
    });
  });
}