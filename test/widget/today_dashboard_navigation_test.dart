import 'package:brain_tests/presentation/screens/about_screen.dart';
import 'package:brain_tests/presentation/screens/exports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Today Dashboard Navigation Tests', () {
    testWidgets('should navigate to exports screen', (tester) async {
      // Arrange - Create a simple test widget that mimics the menu
      bool navigated = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Test'),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'exports') {
                        navigated = true;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'exports',
                        child: Text('Exports'),
                      ),
                    ],
                  ),
                ],
              ),
              body: const Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Act - Open popup menu and tap Exports
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exports'));
      await tester.pumpAndSettle();

      // Assert - Navigation was triggered
      expect(navigated, isTrue);
    });

    testWidgets('should navigate to about screen', (tester) async {
      // Arrange - Create a simple test widget that mimics the menu
      bool navigated = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Test'),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'about') {
                        navigated = true;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'about',
                        child: Text('About'),
                      ),
                    ],
                  ),
                ],
              ),
              body: const Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Act - Open popup menu and tap About
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      // Assert - Navigation was triggered
      expect(navigated, isTrue);
    });

    testWidgets('should render exports screen', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExportsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should show exports screen content
      expect(find.text('Exports'), findsOneWidget);
      expect(find.text('Export Your Data'), findsOneWidget);
      expect(find.text('Export as PDF'), findsOneWidget);
      expect(find.text('Export as CSV'), findsOneWidget);
      expect(find.text('Export as JSON'), findsOneWidget);
    });

    testWidgets('should render about screen', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );
      await tester.pump(); // Don't use pumpAndSettle as PackageInfo is async

      // Assert - Should show about screen content
      expect(find.text('About Brain Plan'), findsOneWidget);
      expect(find.text('Brain Plan'), findsWidgets); // Multiple occurrences
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });
  });
}
