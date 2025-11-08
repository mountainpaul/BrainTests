import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../lib/presentation/screens/about_screen.dart';

void main() {
  setUp(() {
    // Mock package info
    PackageInfo.setMockInitialValues(
      appName: 'Brain Plan',
      packageName: 'com.example.brain_plan',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  group('AboutScreen Widget Tests', () {
    testWidgets('should display app name and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Brain Plan'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('should display version information', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Version'), findsOneWidget);
      expect(find.textContaining('1.0.0'), findsOneWidget);
    });

    testWidgets('should display features section header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Features'), findsOneWidget);
    });

    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Verify we can scroll
      await tester.drag(listView, const Offset(0, -200));
      await tester.pumpAndSettle();
    });

    testWidgets('should have proper navigation structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('About Brain Plan'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display app description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('comprehensive cognitive health tracking'),
        findsOneWidget,
      );
    });

    testWidgets('should display multiple custom cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Should have multiple cards for different sections
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should display feature icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.psychology), findsOneWidget); // App icon
      expect(find.byIcon(Icons.assessment), findsWidgets); // Assessments
      expect(find.byIcon(Icons.fitness_center), findsWidgets); // Exercises
      expect(find.byIcon(Icons.mood), findsWidgets); // Mood
    });

    testWidgets('should scroll to show privacy policy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to find privacy policy
      await tester.dragUntilVisible(
        find.text('Privacy Policy'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('should scroll to show medical disclaimer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to find medical disclaimer
      await tester.dragUntilVisible(
        find.text('Medical Disclaimer'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medical Disclaimer'), findsOneWidget);
    });

    testWidgets('should scroll to show contact section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to find contact section
      await tester.dragUntilVisible(
        find.text('Contact & Support'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(find.text('Contact & Support'), findsOneWidget);
    });
  });
}
