import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:brain_plan/domain/entities/mood_entry.dart';
import 'package:brain_plan/domain/entities/reminder.dart';
import 'package:brain_plan/presentation/providers/assessment_provider.dart';
import 'package:brain_plan/presentation/providers/mood_entry_provider.dart';
import 'package:brain_plan/presentation/providers/reminder_provider.dart';
import 'package:brain_plan/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('should display welcome message', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentAssessmentsProvider.overrideWith((ref) async => <Assessment>[]),
            upcomingRemindersProvider.overrideWith((ref) async => <Reminder>[]),
            todayMoodEntryProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Welcome to Brain Plan'), findsOneWidget);
      expect(find.text('Track your cognitive health journey'), findsOneWidget);
    });

    testWidgets('should display quick action buttons', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentAssessmentsProvider.overrideWith((ref) async => <Assessment>[]),
            upcomingRemindersProvider.overrideWith((ref) async => <Reminder>[]),
            todayMoodEntryProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Take Assessment'), findsOneWidget);
      expect(find.text('Brain Exercise'), findsOneWidget);
      expect(find.text('Log Mood'), findsOneWidget);
      expect(find.text('Set Reminder'), findsOneWidget);
    });

    testWidgets('should display mood entry when available', (WidgetTester tester) async {
      // Arrange
      final mockMoodEntry = MoodEntry(
        id: 1,
        mood: MoodLevel.good,
        energyLevel: 7,
        stressLevel: 3,
        sleepQuality: 8,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentAssessmentsProvider.overrideWith((ref) async => <Assessment>[]),
            upcomingRemindersProvider.overrideWith((ref) async => <Reminder>[]),
            todayMoodEntryProvider.overrideWith((ref) async => mockMoodEntry),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Check that mood data is displayed
      expect(find.text('Good'), findsWidgets);
      expect(find.textContaining('Mood'), findsWidgets);
    });

    testWidgets('should display upcoming reminders', (WidgetTester tester) async {
      // Arrange
      final mockReminder = Reminder(
        id: 1,
        title: 'Take Medication',
        type: ReminderType.medication,
        frequency: ReminderFrequency.daily,
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        isActive: true,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentAssessmentsProvider.overrideWith((ref) async => <Assessment>[]),
            upcomingRemindersProvider.overrideWith((ref) async => [mockReminder]),
            todayMoodEntryProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Upcoming Reminders'), findsOneWidget);
      expect(find.text('Take Medication'), findsOneWidget);
    });

    testWidgets('should display no mood card when no entry exists', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentAssessmentsProvider.overrideWith((ref) async => <Assessment>[]),
            upcomingRemindersProvider.overrideWith((ref) async => <Reminder>[]),
            todayMoodEntryProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Log Today\'s Mood'), findsOneWidget);
      expect(find.text('Tap to record how you\'re feeling today'), findsOneWidget);
    });

    testWidgets('should display no reminders message when list is empty', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentAssessmentsProvider.overrideWith((ref) async => <Assessment>[]),
            upcomingRemindersProvider.overrideWith((ref) async => <Reminder>[]),
            todayMoodEntryProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No upcoming reminders'), findsOneWidget);
    });

    testWidgets('should have bottom navigation bar', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentAssessmentsProvider.overrideWith((ref) async => <Assessment>[]),
            upcomingRemindersProvider.overrideWith((ref) async => <Reminder>[]),
            todayMoodEntryProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}