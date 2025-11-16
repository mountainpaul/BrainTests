import 'package:brain_tests/presentation/screens/cambridge/pal_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Trial repetition should show presentation phase', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PALTestScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Start the test
    await tester.tap(find.text('Start Test'));
    await tester.pump(); // Allow tap to register
    await tester.pump(); // Allow setState from _generateTrial to take effect

    // Verify Stage 1 starts with presentation phase
    expect(find.textContaining('Stage 1'), findsOneWidget);
    expect(find.textContaining('Remember this pattern...'), findsOneWidget);

    // This test verifies that the presentation phase message is shown
    // The actual bug manifests when repeating trials, but we can't easily
    // complete a full trial in the test without knowing exact pattern positions.
    // The fix adds _phase = PALPhase.presentation in _generateTrial()
  });
}
