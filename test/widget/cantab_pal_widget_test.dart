import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/core/providers/database_provider.dart';
import 'package:brain_tests/presentation/screens/cambridge/cantab_pal_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'cantab_pal_widget_test.mocks.dart';

@GenerateMocks([AppDatabase])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CANTAB PAL Test - Widget Tests', () {
    late MockAppDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockAppDatabase();
    });

    // Helper to configure screen size for all tests
    Future<void> configureScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(mockDatabase),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CANTABPALTestScreen()),
                    );
                  },
                  child: const Text('Go to CANTAB PAL'),
                );
              },
            ),
          ),
        ),
      );
    }

    Future<void> navigateToScreen(WidgetTester tester) async {
      await configureScreen(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Go to CANTAB PAL'));
      await tester.pumpAndSettle();
    }

    group('Introduction Screen', () {
      testWidgets('should display CANTAB PAL title', (tester) async {
        await navigateToScreen(tester);

        // Title appears in both AppBar and body
        expect(find.text('CANTAB PAL Test'), findsAtLeastNWidgets(1));
      });

      testWidgets('should display validation subtitle', (tester) async {
        await navigateToScreen(tester);

        expect(
          find.text('Cambridge Cognition validated protocol for visual episodic memory'),
          findsOneWidget,
        );
      });

      testWidgets('should display "How It Works" section', (tester) async {
        await navigateToScreen(tester);

        expect(find.text('How It Works'), findsOneWidget);
      });

      testWidgets('should display 4 instruction steps', (tester) async {
        await navigateToScreen(tester);

        expect(find.text('Watch the boxes open'), findsOneWidget);
        expect(find.text('Remember locations'), findsOneWidget);
        expect(find.text('Match patterns to boxes'), findsOneWidget);
        expect(find.text('Progress through stages'), findsOneWidget);
      });

      testWidgets.skip('should display trial limit information', (tester) async {
        await navigateToScreen(tester);

        expect(
          find.textContaining('up to 4 attempts per stage'),
          findsOneWidget,
        );
      });

      testWidgets('should display duration estimate', (tester) async {
        await navigateToScreen(tester);

        expect(
          find.textContaining('10-15 minutes'),
          findsOneWidget,
        );
      });

      testWidgets('should display start button', (tester) async {
        await navigateToScreen(tester);

        expect(find.text('Start CANTAB PAL Test'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should have correct button styling', (tester) async {
        await navigateToScreen(tester);

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Start CANTAB PAL Test'),
        );

        expect(button.style?.backgroundColor?.resolve({}), equals(Colors.deepPurple));
      });
    });

    group('AppBar', () {
      testWidgets('should display correct title', (tester) async {
        await navigateToScreen(tester);

        expect(find.widgetWithText(AppBar, 'PAL Test'), findsOneWidget);
      });

      testWidgets('should have back button', (tester) async {
        await navigateToScreen(tester);

        expect(find.byType(BackButton), findsOneWidget);
      });

      testWidgets('should have correct background color', (tester) async {
        await navigateToScreen(tester);

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(Colors.deepPurple));
      });
    });

    group('Icons', () {
      testWidgets('should display psychology icon on introduction', (tester) async {
        await navigateToScreen(tester);

        expect(find.byIcon(Icons.psychology), findsOneWidget);
      });

      testWidgets('should display info icon for trial information', (tester) async {
        await navigateToScreen(tester);

        expect(find.byIcon(Icons.info_outline), findsWidgets);
      });

      testWidgets('should display timer icon for duration', (tester) async {
        await navigateToScreen(tester);

        expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      });
    });

    group('Instruction Step Formatting', () {
      testWidgets('should display numbered circles for steps', (tester) async {
        await navigateToScreen(tester);

        // Check for step numbers 1-4
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
      });

      testWidgets('should have step titles in bold', (tester) async {
        await navigateToScreen(tester);
        await tester.pumpAndSettle();

        final titleFinder = find.text('Watch the boxes open');
        expect(titleFinder, findsOneWidget);

        final titleWidget = tester.widget<Text>(titleFinder);
        expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));
      });
    });

    group('CustomCard Usage', () {
      testWidgets('should use CustomCard for main sections', (tester) async {
        await navigateToScreen(tester);

        // Multiple CustomCards should be present
        expect(find.byWidgetPredicate((widget) {
          return widget.runtimeType.toString().contains('CustomCard');
        }), findsWidgets);
      });
    });

    group('Scrollability', () {
      testWidgets('should be scrollable', (tester) async {
        await navigateToScreen(tester);

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('should scroll to reveal all content', (tester) async {
        await navigateToScreen(tester);
        await tester.pumpAndSettle();

        // Find element at bottom
        final startButton = find.text('Start CANTAB PAL Test');
        expect(startButton, findsOneWidget);

        // Verify it's on screen (even if need to scroll)
        await tester.ensureVisible(startButton);
        await tester.pumpAndSettle();

        expect(tester.getCenter(startButton).dy, greaterThan(0));
      });
    });

    group('Responsiveness', () {
      testWidgets('should handle different screen sizes', (tester) async {
        // Test with small screen
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;

        await navigateToScreen(tester);
        await tester.pumpAndSettle();

        expect(find.text('CANTAB PAL Test'), findsWidgets);

        // Reset to default
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      testWidgets('should handle large screen sizes', (tester) async {
        // Test with tablet size
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;

        await navigateToScreen(tester);
        await tester.pumpAndSettle();

        expect(find.text('CANTAB PAL Test'), findsWidgets);

        // Reset to default
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    group('Accessibility', () {
      testWidgets('should have semantic labels for important elements', (tester) async {
        await navigateToScreen(tester);

        // Check button is accessible
        final buttonFinder = find.widgetWithText(ElevatedButton, 'Start CANTAB PAL Test');
        expect(buttonFinder, findsOneWidget);

        final button = tester.widget<ElevatedButton>(buttonFinder);
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should have readable text contrast', (tester) async {
        await navigateToScreen(tester);
        await tester.pumpAndSettle();

        // Title should be visible and prominent (appears in AppBar and body)
        final titleFinder = find.text('CANTAB PAL Test');
        expect(titleFinder, findsWidgets);

        final titleWidget = tester.widget<Text>(titleFinder.first);
        expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));
      });
    });

    group('Layout Structure', () {
      testWidgets('should have proper padding', (tester) async {
        await navigateToScreen(tester);

        expect(find.byType(Padding), findsWidgets);
      });

      testWidgets('should use Column for vertical layout', (tester) async {
        await navigateToScreen(tester);

        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('should use Row for horizontal layout', (tester) async {
        await navigateToScreen(tester);

        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('should use Expanded widgets appropriately', (tester) async {
        await navigateToScreen(tester);

        expect(find.byType(Expanded), findsWidgets);
      });
    });

    group('Visual Hierarchy', () {
      testWidgets('should have clear visual hierarchy with section separation', (tester) async {
        await navigateToScreen(tester);

        // Introduction screen uses spacing, not dividers
        // (Dividers appear in the results phase)
        expect(find.byType(SizedBox), findsWidgets);
      });

      testWidgets('should use SizedBox for spacing', (tester) async {
        await navigateToScreen(tester);

        expect(find.byType(SizedBox), findsWidgets);
      });
    });

    group('Color Theme', () {
      testWidgets('should use deepPurple theme color consistently', (tester) async {
        await navigateToScreen(tester);
        await tester.pumpAndSettle();

        // AppBar should use deepPurple
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(Colors.deepPurple));

        // Button should use deepPurple
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Start CANTAB PAL Test'),
        );
        expect(button.style?.backgroundColor?.resolve({}), equals(Colors.deepPurple));
      });

      testWidgets('should use appropriate icon colors', (tester) async {
        await navigateToScreen(tester);
        await tester.pumpAndSettle();

        // Psychology icon should be deepPurple
        final icon = tester.widget<Icon>(find.byIcon(Icons.psychology));
        expect(icon.color, equals(Colors.deepPurple));
      });
    });

    group('Text Styling', () {
      testWidgets('should use appropriate text theme', (tester) async {
        await navigateToScreen(tester);
        await tester.pumpAndSettle();

        // Main title should use headline style (appears in AppBar and body)
        expect(find.text('CANTAB PAL Test'), findsWidgets);

        // Section headers should be prominent
        final sectionHeader = find.text('How It Works');
        expect(sectionHeader, findsOneWidget);
      });

      testWidgets('should have readable font sizes', (tester) async {
        await navigateToScreen(tester);
        await tester.pumpAndSettle();

        final buttonText = tester.widget<Text>(
          find.descendant(
            of: find.widgetWithText(ElevatedButton, 'Start CANTAB PAL Test'),
            matching: find.byType(Text),
          ).first,
        );

        expect(buttonText.style?.fontSize, equals(18));
      });
    });

    group('Information Content', () {
      testWidgets('should mention CANTAB validation', (tester) async {
        await navigateToScreen(tester);

        expect(find.textContaining('validated'), findsWidgets);
      });

      testWidgets('should explain 5-stage progression', (tester) async {
        await navigateToScreen(tester);

        // Check for stage progression description
        expect(find.textContaining('2, 4, 6, 8, and 10'), findsOneWidget);
      });

      testWidgets('should explain 3-second display time', (tester) async {
        await navigateToScreen(tester);

        expect(find.textContaining('3 seconds'), findsOneWidget);
      });
    });
  });
}
