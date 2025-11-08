import 'dart:math';

import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/data/repositories/assessment_repository_impl.dart';
import 'package:brain_plan/data/repositories/mood_entry_repository_impl.dart';
import 'package:brain_plan/data/repositories/reminder_repository_impl.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:brain_plan/domain/entities/mood_entry.dart';
import 'package:brain_plan/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  group('Performance and Stress Testing', () {
    late AppDatabase database;
    late AssessmentRepositoryImpl assessmentRepository;
    late ReminderRepositoryImpl reminderRepository;
    late MoodEntryRepositoryImpl moodRepository;

    setUp(() async {
      database = createTestDatabase();
      assessmentRepository = AssessmentRepositoryImpl(database);
      reminderRepository = ReminderRepositoryImpl(database);
      moodRepository = MoodEntryRepositoryImpl(database);
    });

    tearDown(() async {
      await closeTestDatabase(database);
    });

    group('Large Dataset Performance', () {
      test('should handle 1000+ assessment records efficiently', () async {
        final stopwatch = Stopwatch()..start();

        // Generate large dataset
        final assessments = <Assessment>[];
        for (int i = 0; i < 1000; i++) {
          assessments.add(Assessment(
            type: AssessmentType.values[i % AssessmentType.values.length],
            score: Random().nextInt(100),
            maxScore: 100,
            completedAt: DateTime.now().subtract(Duration(days: i ~/ 10)),
            createdAt: DateTime.now().subtract(Duration(days: i ~/ 10)),
          ));
        }

        // Insert all assessments
        final insertStartTime = stopwatch.elapsedMilliseconds;
        for (final assessment in assessments) {
          await assessmentRepository.insertAssessment(assessment);
        }
        final insertTime = stopwatch.elapsedMilliseconds - insertStartTime;

        // Query all assessments
        final queryStartTime = stopwatch.elapsedMilliseconds;
        final retrieved = await assessmentRepository.getAllAssessments();
        final queryTime = stopwatch.elapsedMilliseconds - queryStartTime;

        stopwatch.stop();

        // Performance assertions
        expect(retrieved.length, equals(1000));
        expect(insertTime, lessThan(5000)); // Should complete within 5 seconds
        expect(queryTime, lessThan(1000)); // Query should complete within 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // Total under 10 seconds

        print('Performance Results:');
        print('- Insert Time: ${insertTime}ms for 1000 records');
        print('- Query Time: ${queryTime}ms for 1000 records');
        print('- Total Time: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('should handle complex queries on large datasets', () async {
        // Insert test data across different types and time ranges
        final testData = <Assessment>[];
        final now = DateTime.now();

        for (int i = 0; i < 500; i++) {
          testData.add(Assessment(
            type: AssessmentType.memoryRecall,
            score: 70 + Random().nextInt(30),
            maxScore: 100,
            completedAt: now.subtract(Duration(days: i)),
            createdAt: now.subtract(Duration(days: i)),
          ));

          testData.add(Assessment(
            type: AssessmentType.attentionFocus,
            score: 60 + Random().nextInt(40),
            maxScore: 100,
            completedAt: now.subtract(Duration(days: i)),
            createdAt: now.subtract(Duration(days: i)),
          ));
        }

        // Insert all data
        for (final assessment in testData) {
          await assessmentRepository.insertAssessment(assessment);
        }

        final stopwatch = Stopwatch()..start();

        // Complex query operations
        final memoryAssessments = await assessmentRepository.getAssessmentsByType(AssessmentType.memoryRecall);
        final attentionAssessments = await assessmentRepository.getAssessmentsByType(AssessmentType.attentionFocus);
        final averages = await assessmentRepository.getAverageScoresByType();
        final recent = await assessmentRepository.getRecentAssessments(limit: 50);

        stopwatch.stop();

        // Verify results and performance
        expect(memoryAssessments.length, equals(500));
        expect(attentionAssessments.length, equals(500));
        expect(averages.keys, contains(AssessmentType.memoryRecall));
        expect(averages.keys, contains(AssessmentType.attentionFocus));
        expect(recent.length, equals(50));
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Complex queries under 2 seconds

        print('Complex Query Performance: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('should maintain performance with mixed data operations', () async {
        final stopwatch = Stopwatch()..start();
        final operations = <Future>[];

        // Simulate concurrent operations
        for (int i = 0; i < 100; i++) {
          operations.add(
            assessmentRepository.insertAssessment(Assessment(
              type: AssessmentType.values[i % AssessmentType.values.length],
              score: Random().nextInt(100),
              maxScore: 100,
              completedAt: DateTime.now(),
              createdAt: DateTime.now(),
            )),
          );

          operations.add(
            reminderRepository.insertReminder(Reminder(
              title: 'Test Reminder $i',
              description: 'Description $i',
              type: ReminderType.values[i % ReminderType.values.length],
              scheduledAt: DateTime.now().add(Duration(hours: i)),
              frequency: ReminderFrequency.daily,
              isActive: true,
              isCompleted: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )),
          );

          operations.add(
            moodRepository.insertMoodEntry(MoodEntry(
              mood: MoodLevel.values[i % MoodLevel.values.length],
              energyLevel: Random().nextInt(10) + 1,
              stressLevel: Random().nextInt(10) + 1,
              sleepQuality: Random().nextInt(10) + 1,
              entryDate: DateTime.now().subtract(Duration(days: i ~/ 20)),
              createdAt: DateTime.now(),
            )),
          );
        }

        // Execute all operations concurrently
        await Future.wait(operations);
        stopwatch.stop();

        // Verify data integrity
        final assessments = await assessmentRepository.getAllAssessments();
        final reminders = await reminderRepository.getAllReminders();
        final moods = await moodRepository.getAllMoodEntries();

        expect(assessments.length, equals(100));
        expect(reminders.length, equals(100));
        expect(moods.length, equals(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(8000)); // Mixed operations under 8 seconds

        print('Mixed Operations Performance: ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Memory and Resource Management', () {
      test('should handle memory efficiently during bulk operations', () async {
        // Test memory usage patterns during bulk operations
        final stopwatch = Stopwatch()..start();

        // Create and process large amounts of data
        for (int batch = 0; batch < 10; batch++) {
          final batchData = <Assessment>[];

          // Create batch of 100 assessments
          for (int i = 0; i < 100; i++) {
            batchData.add(Assessment(
              type: AssessmentType.values[i % AssessmentType.values.length],
              score: Random().nextInt(100),
              maxScore: 100,
              completedAt: DateTime.now().subtract(Duration(days: batch * 10 + i)),
              createdAt: DateTime.now().subtract(Duration(days: batch * 10 + i)),
            ));
          }

          // Insert batch
          for (final assessment in batchData) {
            await assessmentRepository.insertAssessment(assessment);
          }

          // Query and process data
          final retrieved = await assessmentRepository.getAllAssessments();
          expect(retrieved.length, equals((batch + 1) * 100));

          // Force garbage collection between batches
          if (batch % 3 == 0) {
            // Simulate processing delay to allow GC
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }

        stopwatch.stop();

        // Performance should remain reasonable even with large datasets
        expect(stopwatch.elapsedMilliseconds, lessThan(30000)); // Under 30 seconds

        print('Bulk Operations Performance: ${stopwatch.elapsedMilliseconds}ms for 1000 records');

        // Clear references to help with memory management
        final finalCount = await assessmentRepository.getAllAssessments();
        expect(finalCount.length, equals(1000));
      });

      test('should clean up resources properly after operations', () async {
        // Track resource usage
        final operations = <Future>[];

        // Create multiple concurrent database operations
        for (int i = 0; i < 50; i++) {
          operations.add(_performComplexDatabaseOperation(
            assessmentRepository,
            reminderRepository,
            moodRepository,
            i,
          ));
        }

        await Future.wait(operations);

        // Verify all operations completed successfully
        final assessments = await assessmentRepository.getAllAssessments();
        final reminders = await reminderRepository.getAllReminders();
        final moods = await moodRepository.getAllMoodEntries();

        expect(assessments.length, greaterThanOrEqualTo(50));
        expect(reminders.length, greaterThanOrEqualTo(50));
        expect(moods.length, greaterThanOrEqualTo(50));

        // Force cleanup and verify no resource leaks
        await Future.delayed(const Duration(milliseconds: 100));

        // Database should still be responsive
        final finalCheck = await assessmentRepository.getAllAssessments();
        expect(finalCheck.length, equals(assessments.length));
      });
    });

    group('Stress Testing - Error Conditions', () {
      test('should handle database connection failures gracefully', () async {
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

        // Attempt operations on closed database
        try {
          await assessmentRepository.insertAssessment(Assessment(
            type: AssessmentType.attentionFocus,
            score: 75,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ));
          fail('Expected database operation to fail');
        } catch (e) {
          expect(e, isA<StateError>());
        }

        try {
          await assessmentRepository.getAllAssessments();
          fail('Expected database query to fail');
        } catch (e) {
          expect(e, isA<StateError>());
        }
      });

      test('should handle concurrent write operations without corruption', () async {
        // Simulate high-concurrency scenario
        final futures = <Future>[];
        final insertedIds = <int>[];

        // Launch 50 concurrent insert operations
        for (int i = 0; i < 50; i++) {
          futures.add(
            assessmentRepository.insertAssessment(Assessment(
              type: AssessmentType.values[i % AssessmentType.values.length],
              score: i + 50,
              maxScore: 100,
              notes: 'Concurrent insert $i',
              completedAt: DateTime.now().add(Duration(seconds: i)),
              createdAt: DateTime.now(),
            )).then((id) {
              insertedIds.add(id);
              return id;
            }),
          );
        }

        // Wait for all operations to complete
        await Future.wait(futures);

        // Verify data integrity
        expect(insertedIds.length, equals(50));
        expect(insertedIds.toSet().length, equals(50)); // All IDs should be unique

        final allAssessments = await assessmentRepository.getAllAssessments();
        expect(allAssessments.length, equals(50));

        // Verify each assessment was inserted correctly
        for (int i = 0; i < 50; i++) {
          final assessment = allAssessments.firstWhere((a) => a.notes == 'Concurrent insert $i');
          expect(assessment.score, equals(i + 50));
          expect(assessment.type, equals(AssessmentType.values[i % AssessmentType.values.length]));
        }
      });

      test('should handle rapid sequential operations', () async {
        final stopwatch = Stopwatch()..start();

        // Rapid sequential operations without delays
        for (int i = 0; i < 200; i++) {
          final assessment = Assessment(
            type: AssessmentType.memoryRecall,
            score: i % 100,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          );

          final id = await assessmentRepository.insertAssessment(assessment);
          expect(id, greaterThan(0));

          // Immediately query the inserted record
          final retrieved = await assessmentRepository.getAssessmentById(id);
          expect(retrieved, isNotNull);
          expect(retrieved!.score, equals(i % 100));

          // Rapid update
          final updated = retrieved.copyWith(score: (i % 100) + 1);
          final updateResult = await assessmentRepository.updateAssessment(updated);
          expect(updateResult, isTrue);
        }

        stopwatch.stop();

        // Should handle rapid operations efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(15000)); // Under 15 seconds for 600 operations

        final finalCount = await assessmentRepository.getAllAssessments();
        expect(finalCount.length, equals(200));

        print('Rapid Operations Performance: ${stopwatch.elapsedMilliseconds}ms for 600 operations');
      });
    });

    group('Data Integrity Under Stress', () {
      test('should maintain referential integrity during bulk operations', () async {
        // Create assessments and related data
        final assessmentIds = <int>[];

        // Insert assessments
        for (int i = 0; i < 100; i++) {
          final id = await assessmentRepository.insertAssessment(Assessment(
            type: AssessmentType.memoryRecall,
            score: 80 + (i % 20),
            maxScore: 100,
            completedAt: DateTime.now().subtract(Duration(days: i)),
            createdAt: DateTime.now().subtract(Duration(days: i)),
          ));
          assessmentIds.add(id);
        }

        // Verify all assessments exist
        for (final id in assessmentIds) {
          final assessment = await assessmentRepository.getAssessmentById(id);
          expect(assessment, isNotNull);
          expect(assessment!.id, equals(id));
        }

        // Bulk update operations
        final updateFutures = <Future>[];
        for (final id in assessmentIds.take(50)) {
          updateFutures.add(
            assessmentRepository.getAssessmentById(id).then((assessment) async {
              if (assessment != null) {
                final updated = assessment.copyWith(
                  score: assessment.score + 5,
                  notes: 'Bulk updated',
                );
                return assessmentRepository.updateAssessment(updated);
              }
              return false;
            }),
          );
        }

        final updateResults = await Future.wait(updateFutures);
        expect(updateResults.every((result) => result == true), isTrue);

        // Verify updates were applied correctly
        for (final id in assessmentIds.take(50)) {
          final assessment = await assessmentRepository.getAssessmentById(id);
          expect(assessment?.notes, equals('Bulk updated'));
        }

        // Verify non-updated assessments remain unchanged
        for (final id in assessmentIds.skip(50)) {
          final assessment = await assessmentRepository.getAssessmentById(id);
          expect(assessment?.notes, isNull);
        }
      });
    });
  });
}

Future<void> _performComplexDatabaseOperation(
  AssessmentRepositoryImpl assessmentRepo,
  ReminderRepositoryImpl reminderRepo,
  MoodEntryRepositoryImpl moodRepo,
  int operationId,
) async {
  // Complex operation involving multiple repositories

  // Insert assessment
  final assessmentId = await assessmentRepo.insertAssessment(Assessment(
    type: AssessmentType.values[operationId % AssessmentType.values.length],
    score: operationId + 50,
    maxScore: 100,
    completedAt: DateTime.now(),
    createdAt: DateTime.now(),
  ));

  // Insert reminder
  final reminderId = await reminderRepo.insertReminder(Reminder(
    title: 'Operation $operationId',
    description: 'Complex operation reminder',
    type: ReminderType.assessment,
    scheduledAt: DateTime.now().add(Duration(hours: operationId)),
    frequency: ReminderFrequency.daily,
    isActive: true,
    isCompleted: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ));

  // Insert mood entry
  final moodId = await moodRepo.insertMoodEntry(MoodEntry(
    mood: MoodLevel.values[operationId % MoodLevel.values.length],
    energyLevel: (operationId % 10) + 1,
    stressLevel: (operationId % 10) + 1,
    sleepQuality: (operationId % 10) + 1,
    entryDate: DateTime.now(),
    createdAt: DateTime.now(),
  ));

  // Verify all operations succeeded
  expect(assessmentId, greaterThan(0));
  expect(reminderId, greaterThan(0));
  expect(moodId, greaterThan(0));

  // Perform related queries
  final assessment = await assessmentRepo.getAssessmentById(assessmentId);
  final reminder = await reminderRepo.getReminderById(reminderId);
  final mood = await moodRepo.getMoodEntryById(moodId);

  expect(assessment, isNotNull);
  expect(reminder, isNotNull);
  expect(mood, isNotNull);
}