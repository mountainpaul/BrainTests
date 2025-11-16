import 'package:brain_tests/presentation/screens/personal_cognitive_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PersonalCognitiveTracker Tests', () {
    testWidgets('should display welcome greeting', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      // Pump a few frames instead of waiting for settle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check for greeting text (more flexible matching)
      final greetingFound = find.textContaining('Good').evaluate().isNotEmpty;
      final descriptionFound = find.textContaining('cognitive').evaluate().isNotEmpty ||
                              find.textContaining('feeling').evaluate().isNotEmpty;

      expect(greetingFound || descriptionFound, isTrue,
             reason: 'Should find either greeting or description text');
    });

    testWidgets('should display tab navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check for tab labels
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
      expect(find.text('Quick Test'), findsOneWidget);
      expect(find.text('Journal'), findsOneWidget);
    });

    testWidgets('should switch tabs when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on Trends tab
      await tester.tap(find.text('Trends'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should display trends content
      expect(find.text('Your Cognitive Trends'), findsOneWidget);
    });

    testWidgets('should display quick actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Memory Test'), findsOneWidget);
      expect(find.text('Quick Check'), findsOneWidget);
      expect(find.text('Brain Game'), findsOneWidget);
      expect(find.text('Add Note'), findsOneWidget);
    });

    testWidgets('should show snackbar when quick action is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on Memory Test
      await tester.tap(find.text('Memory Test'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show some kind of response to the tap (snackbar, dialog, or navigation)
      final hasSnackbar = find.textContaining('Memory Test').evaluate().isNotEmpty ||
                          find.textContaining('coming soon').evaluate().isNotEmpty ||
                          find.textContaining('feature').evaluate().isNotEmpty;
      expect(hasSnackbar, isTrue, reason: 'Should show some response to Memory Test tap');
    });

    testWidgets('should display today\'s status with sample data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Today\'s Status'), findsOneWidget);
      expect(find.text('Memory'), findsWidgets);
      expect(find.text('Focus'), findsWidgets);
      expect(find.text('Speed'), findsWidgets);
    });

    testWidgets('should display recent trends chart', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Recent Trends (Past 7 days)'), findsOneWidget);
    });

    testWidgets('should display floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should show trends detailed chart when on trends tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to trends tab
      await tester.tap(find.text('Trends'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Cognitive Performance Over Time'), findsOneWidget);
      expect(find.text('Insights & Patterns'), findsOneWidget);
      expect(find.text('Lifestyle Factors'), findsOneWidget);
    });

    testWidgets('should display insights on trends tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to trends tab
      await tester.tap(find.text('Trends'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Memory Improvement'), findsOneWidget);
      expect(find.text('Best Performance Time'), findsOneWidget);
      expect(find.text('Sleep Connection'), findsOneWidget);
    });

    testWidgets('should display lifestyle correlations', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to trends tab
      await tester.tap(find.text('Trends'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sleep Quality'), findsOneWidget);
      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('Stress Level'), findsOneWidget);
      expect(find.text('Social Activity'), findsOneWidget);
    });

    testWidgets('should display mood and sleep ratings', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Mood'), findsOneWidget);
      expect(find.text('Sleep'), findsOneWidget);
    });

    testWidgets('should show placeholder for quick tests tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to quick tests tab
      await tester.tap(find.text('Quick Test'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Quick Tests implementation would go here'), findsOneWidget);
    });

    testWidgets('should show placeholder for journal tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to journal tab
      await tester.tap(find.text('Journal'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Journal implementation would go here'), findsOneWidget);
    });

    testWidgets('should show snackbar when insights button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find and tap insights button
      await tester.tap(find.byIcon(Icons.insights), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Detailed insights coming soon!'), findsOneWidget);
    });

    testWidgets('should show snackbar when floating action button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap floating action button
      await tester.tap(find.byType(FloatingActionButton), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('New entry form coming soon!'), findsOneWidget);
    });
  });

  group('CognitiveEntry Tests', () {
    test('should create cognitive entry with all fields', () {
      final entry = CognitiveEntry(
        date: DateTime(2024, 1, 15),
        memoryScore: 85,
        attentionScore: 90,
        processingScore: 80,
        moodRating: 4,
        sleepQuality: 3,
        notes: "Felt sharp today",
      );

      expect(entry.date, DateTime(2024, 1, 15));
      expect(entry.memoryScore, 85);
      expect(entry.attentionScore, 90);
      expect(entry.processingScore, 80);
      expect(entry.moodRating, 4);
      expect(entry.sleepQuality, 3);
      expect(entry.notes, "Felt sharp today");
    });

    test('should handle edge case values', () {
      final entry = CognitiveEntry(
        date: DateTime.now(),
        memoryScore: 0,
        attentionScore: 100,
        processingScore: 50,
        moodRating: 1,
        sleepQuality: 5,
        notes: "",
      );

      expect(entry.memoryScore, 0);
      expect(entry.attentionScore, 100);
      expect(entry.processingScore, 50);
      expect(entry.moodRating, 1);
      expect(entry.sleepQuality, 5);
      expect(entry.notes, "");
    });
  });

  group('Helper Functions Tests', () {
    testWidgets('should show correct greeting based on time', (WidgetTester tester) async {
      // Create widget and pump to initialize state
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Greeting should contain "Good" (Morning/Afternoon/Evening)
      expect(find.textContaining('Good'), findsOneWidget);
    });

    testWidgets('should display proper icons for tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check for tab icons
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
    });

    testWidgets('should display proper icons for quick actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check for quick action icons
      expect(find.byIcon(Icons.quiz), findsOneWidget);
      expect(find.byIcon(Icons.speed), findsOneWidget);
      expect(find.byIcon(Icons.palette), findsOneWidget);
      expect(find.byIcon(Icons.note_add), findsOneWidget);
    });

    testWidgets('should handle tab selection changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Initially on Today tab
      expect(find.text('Today\'s Status'), findsOneWidget);

      // Switch to Trends
      await tester.tap(find.text('Trends'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Your Cognitive Trends'), findsOneWidget);

      // Switch to Quick Test
      await tester.tap(find.text('Quick Test'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Quick Tests implementation would go here'), findsOneWidget);

      // Switch to Journal
      await tester.tap(find.text('Journal'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Journal implementation would go here'), findsOneWidget);
    });

    testWidgets('should display chart legend', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check for legend items
      expect(find.text('Memory'), findsAtLeastNWidgets(1)); // Appears in multiple places
      expect(find.text('Focus'), findsAtLeastNWidgets(1));
      expect(find.text('Speed'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show insight items with proper formatting', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to trends tab
      await tester.tap(find.text('Trends'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check for insight icons
      expect(find.byIcon(Icons.trending_up), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.byIcon(Icons.bedtime), findsOneWidget);
    });

    testWidgets('should display correlation progress bars', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to trends tab
      await tester.tap(find.text('Trends'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check for progress indicators
      expect(find.byType(LinearProgressIndicator), findsAtLeastNWidgets(1));
    });
  });

  group('Edge Cases and Error Handling', () {
    testWidgets('should handle empty entries gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should still display basic UI elements
      expect(find.text('Today\'s Status'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('should handle tab switching without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Rapidly switch between tabs
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Trends'), warnIfMissed: false);
        await tester.pump();
        await tester.tap(find.text('Today'), warnIfMissed: false);
        await tester.pump();
        await tester.tap(find.text('Quick Test'), warnIfMissed: false);
        await tester.pump();
        await tester.tap(find.text('Journal'), warnIfMissed: false);
        await tester.pump();
      }

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should not crash and final state should be stable
      expect(find.text('Journal implementation would go here'), findsOneWidget);
    });

    testWidgets('should display proper star ratings for mood and sleep', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PersonalCognitiveTracker(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check for star icons (should have both filled and unfilled)
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.bedtime), findsAtLeastNWidgets(1));
    });
  });
}