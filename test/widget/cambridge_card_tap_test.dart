import 'package:brain_plan/presentation/screens/cambridge/pal_test_screen.dart';
import 'package:brain_plan/presentation/screens/cambridge_assessments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Tapping PAL card should navigate to PAL test screen', (tester) async {
    final router = GoRouter(
      initialLocation: '/cambridge',
      routes: [
        GoRoute(
          path: '/cambridge',
          builder: (context, state) => const CambridgeAssessmentsScreen(),
        ),
        GoRoute(
          path: '/cambridge/pal',
          builder: (context, state) => const PALTestScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Scroll down to ensure the PAL section is fully visible
    await tester.dragUntilVisible(
      find.text('Simplified Version'),
      find.byType(SingleChildScrollView),
      const Offset(0, -50),
    );
    await tester.pumpAndSettle();

    // Find all InkWells and tap the one containing "Simplified Version"
    final allInkWells = find.byType(InkWell);
    final simplifiedText = find.text('Simplified Version');

    // Find the InkWell that contains the "Simplified Version" text
    final targetInkWell = find.ancestor(
      of: simplifiedText,
      matching: allInkWells,
    ).first;

    await tester.tap(targetInkWell);
    await tester.pumpAndSettle();

    // Verify navigation occurred
    // Check if PALTestScreen is now in the widget tree
    expect(find.byType(PALTestScreen), findsOneWidget);
  });
}
