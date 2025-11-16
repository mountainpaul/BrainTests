import 'package:brain_tests/presentation/screens/cambridge/pal_test_screen.dart';
import 'package:brain_tests/presentation/screens/cambridge_assessments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cambridge Assessments Navigation', () {
    testWidgets('CambridgeAssessmentsScreen should display all test cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CambridgeAssessmentsScreen(),
          ),
        ),
      );

      // Should have header
      expect(find.text('CANTAB-Style Tests'), findsOneWidget);

      // Should have all 5 test cards
      expect(find.text('PAL - Paired Associates Learning'), findsOneWidget);
      expect(find.text('RVP - Rapid Visual Processing'), findsOneWidget);
      expect(find.text('RTI - Reaction Time'), findsOneWidget);
      expect(find.text('SWM - Spatial Working Memory'), findsOneWidget);
      expect(find.text('PRM - Pattern Recognition'), findsOneWidget);
    });

    testWidgets('PAL card should show correct details', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CambridgeAssessmentsScreen(),
          ),
        ),
      );

      expect(find.text('Visual episodic memory'), findsOneWidget);
      expect(find.text('~8 min'), findsOneWidget);
      expect(find.text('Highly sensitive for AD'), findsOneWidget);
    });

    testWidgets('PALTestScreen should display introduction phase', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PALTestScreen(),
          ),
        ),
      );

      await tester.pump();

      // Should show introduction text
      expect(find.text('Paired Associates Learning'), findsWidgets);
      expect(find.text('Start Test'), findsOneWidget);
      expect(find.textContaining('Instructions'), findsOneWidget);
    });

    testWidgets('Start Test button should advance to presentation phase', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PALTestScreen(),
          ),
        ),
      );

      await tester.pump();

      // Tap Start Test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Should show pattern presentation, not intro anymore
      expect(find.text('Start Test'), findsNothing);
    });
  });
}
