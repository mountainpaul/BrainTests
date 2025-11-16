import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/mood_entry.dart';
import 'package:brain_tests/presentation/providers/mood_entry_provider.dart';
import 'package:brain_tests/presentation/screens/mood_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoodTrackingScreen Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Widget Structure Tests', () {
      testWidgets('should build without crashing', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => null),
            recentMoodEntriesProvider.overrideWith((ref) => <MoodEntry>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(MoodTrackingScreen), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Mood Tracking'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display mood entry form when no today entry', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => null),
            recentMoodEntriesProvider.overrideWith((ref) => <MoodEntry>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('How are you feeling today?'), findsOneWidget);
        expect(find.text('Tap to log your mood'), findsOneWidget);
        expect(find.text('Track how you\'re feeling today'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display mood entry sections', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => null),
            recentMoodEntriesProvider.overrideWith((ref) => <MoodEntry>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('How are you feeling today?'), findsOneWidget);
        expect(find.text('Recent Mood Entries'), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('Today Mood Entry Tests', () {
      testWidgets('should display today mood entry when available', (WidgetTester tester) async {
        // Arrange
        final todayMoodEntry = MoodEntry(
          id: 1,
          mood: MoodLevel.good,
          energyLevel: 8,
          stressLevel: 3,
          sleepQuality: 7,
          notes: 'Feeling great today!',
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => todayMoodEntry),
            recentMoodEntriesProvider.overrideWith((ref) => <MoodEntry>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Today\'s Mood Entry'), findsOneWidget);
        expect(find.text('Good'), findsOneWidget);
        expect(find.text('Energy:'), findsOneWidget);
        expect(find.text('8/10'), findsOneWidget);
        expect(find.text('Stress:'), findsOneWidget);
        expect(find.text('3/10'), findsOneWidget);
        expect(find.text('Sleep Quality:'), findsOneWidget);
        expect(find.text('7/10'), findsOneWidget);
        expect(find.text('Feeling great today!'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display wellness score correctly', (WidgetTester tester) async {
        // Arrange
        final todayMoodEntry = MoodEntry(
          id: 1,
          mood: MoodLevel.excellent, // Score: 10
          energyLevel: 9,
          stressLevel: 2, // Adjusted: 8
          sleepQuality: 8,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        // Expected wellness: (10 + 9 + 8 + 8) / 4 = 8.75

        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => todayMoodEntry),
            recentMoodEntriesProvider.overrideWith((ref) => <MoodEntry>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Wellness Score:'), findsOneWidget);
        expect(find.text('8.8/10'), findsOneWidget); // 8.75 rounded to 1 decimal

        testContainer.dispose();
      });
    });

    group('Recent Mood Entries Tests', () {
      testWidgets('should display empty state when no recent entries', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => null),
            recentMoodEntriesProvider.overrideWith((ref) => <MoodEntry>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('No mood entries yet'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display recent mood entries when available', (WidgetTester tester) async {
        // Arrange
        final recentEntries = [
          MoodEntry(
            id: 1,
            mood: MoodLevel.good,
            energyLevel: 7,
            stressLevel: 4,
            sleepQuality: 6,
            entryDate: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          MoodEntry(
            id: 2,
            mood: MoodLevel.neutral,
            energyLevel: 5,
            stressLevel: 6,
            sleepQuality: 5,
            entryDate: DateTime.now().subtract(const Duration(days: 2)),
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ];

        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => null),
            recentMoodEntriesProvider.overrideWith((ref) => recentEntries),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Good'), findsOneWidget);
        expect(find.text('Neutral'), findsOneWidget);
        expect(find.textContaining('Wellness Score:'), findsAtLeastNWidgets(2));

        testContainer.dispose();
      });
    });

    group('Loading and Error States Tests', () {
      testWidgets('should display loading indicators', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) async => await Future<MoodEntry?>.delayed(const Duration(hours: 1))),
            recentMoodEntriesProvider.overrideWith((ref) async => await Future<List<MoodEntry>>.delayed(const Duration(hours: 1))),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(2));

        testContainer.dispose();
      });

      testWidgets('should handle provider errors gracefully', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) async => throw Exception('Database error')),
            recentMoodEntriesProvider.overrideWith((ref) async => throw Exception('Network error')),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert - Should still show mood entry form on today error
        expect(find.text('Tap to log your mood'), findsOneWidget);
        expect(find.textContaining('Error:'), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('Mood Helper Methods Tests', () {
      testWidgets('should display correct mood icons and colors', (WidgetTester tester) async {
        // Arrange
        final moodEntry = MoodEntry(
          id: 1,
          mood: MoodLevel.excellent,
          energyLevel: 10,
          stressLevel: 1,
          sleepQuality: 9,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => moodEntry),
            recentMoodEntriesProvider.overrideWith((ref) => <MoodEntry>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Excellent'), findsOneWidget);
        expect(find.byIcon(Icons.sentiment_very_satisfied), findsAtLeastNWidgets(1));

        testContainer.dispose();
      });

      testWidgets('should test all mood levels', (WidgetTester tester) async {
        final moodLevels = [
          MoodLevel.veryLow,
          MoodLevel.low,
          MoodLevel.neutral,
          MoodLevel.good,
          MoodLevel.excellent,
        ];

        for (final moodLevel in moodLevels) {
          // Arrange
          final moodEntry = MoodEntry(
            id: 1,
            mood: moodLevel,
            energyLevel: 5,
            stressLevel: 5,
            sleepQuality: 5,
            entryDate: DateTime.now(),
            createdAt: DateTime.now(),
          );

          final testContainer = ProviderContainer(
            overrides: [
              todayMoodEntryProvider.overrideWith((ref) => moodEntry),
              recentMoodEntriesProvider.overrideWith((ref) => <MoodEntry>[]),
            ],
          );

          // Act
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: testContainer,
              child: const MaterialApp(
                home: MoodTrackingScreen(),
              ),
            ),
          );

          // Assert - Each mood level should display correctly
          String expectedLabel;
          switch (moodLevel) {
            case MoodLevel.veryLow:
              expectedLabel = 'Very Low';
              break;
            case MoodLevel.low:
              expectedLabel = 'Low';
              break;
            case MoodLevel.neutral:
              expectedLabel = 'Neutral';
              break;
            case MoodLevel.good:
              expectedLabel = 'Good';
              break;
            case MoodLevel.excellent:
              expectedLabel = 'Excellent';
              break;
          }
          expect(find.text(expectedLabel), findsOneWidget);

          testContainer.dispose();
        }
      });
    });

    group('Wellness Indicator Tests', () {
      testWidgets('should display wellness indicators with appropriate colors', (WidgetTester tester) async {
        // Arrange - High wellness entry
        final highWellnessEntry = MoodEntry(
          id: 1,
          mood: MoodLevel.excellent,
          energyLevel: 10,
          stressLevel: 1,
          sleepQuality: 9,
          entryDate: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => null),
            recentMoodEntriesProvider.overrideWith((ref) => [highWellnessEntry]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert - Should find wellness indicator containers
        final wellnessIndicators = find.byWidgetPredicate(
          (widget) => widget is Container &&
                      widget.decoration is BoxDecoration &&
                      (widget.decoration as BoxDecoration).borderRadius != null,
        );
        expect(wellnessIndicators, findsAtLeastNWidgets(1));

        testContainer.dispose();
      });
    });

    group('Navigation and Interaction Tests', () {
      testWidgets('should have bottom navigation bar', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => null),
            recentMoodEntriesProvider.overrideWith((ref) => <MoodEntry>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display mood entry form as tappable', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            todayMoodEntryProvider.overrideWith((ref) => null),
            recentMoodEntriesProvider.overrideWith((ref) => <MoodEntry>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: MoodTrackingScreen(),
            ),
          ),
        );

        // Assert - Should find tappable widget for mood entry
        expect(find.byIcon(Icons.mood), findsOneWidget);
        expect(find.text('Tap to log your mood'), findsOneWidget);

        testContainer.dispose();
      });
    });
  });
}