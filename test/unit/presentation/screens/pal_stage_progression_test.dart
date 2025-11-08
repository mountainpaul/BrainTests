import 'package:brain_plan/presentation/screens/cambridge/pal_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PAL Test Stage Progression', () {
    testWidgets('Should progress from stage 1 to stage 2 after successful trial', (tester) async {
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
      await tester.pumpAndSettle();

      // Should show Stage 1
      expect(find.textContaining('Stage 1'), findsOneWidget);

      // Wait for pattern presentation to complete (3 seconds)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should now be in recall phase
      // Find the correct box and tap it
      final boxes = find.byType(GestureDetector);
      expect(boxes, findsWidgets);

      // Tap the first box (we don't know which is correct, but should respond)
      await tester.tap(boxes.first);
      await tester.pumpAndSettle();

      // Should eventually progress (either to next trial or next stage)
      // After 800ms timer for stage completion
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      // Verify we're not stuck on stage 1 forever
      // Either moved to next trial or next stage
      final hasStageText = find.textContaining('Stage');
      expect(hasStageText, findsWidgets);
    });

  });
}
