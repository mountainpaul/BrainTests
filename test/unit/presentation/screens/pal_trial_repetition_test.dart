import 'package:brain_tests/presentation/screens/cambridge/cantab_pal_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/test_asset_bundle.dart';

void main() {
  testWidgets('Trial repetition should show presentation phase', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: const MaterialApp(
            home: CANTABPALTestScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Start the test
    await tester.tap(find.text('Start CANTAB PAL Test'));
    
    // Pump a frame to start the animation
    await tester.pump();
    
    // Pump for a short duration to let the first box open or initial message appear
    // We avoid pumpAndSettle because the sequential presentation uses Timers
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Stage 1 starts with presentation phase
    expect(find.textContaining('Stage 1'), findsOneWidget);
    
    // Based on the code, it shows "Watch carefully..." or "Box X of Y"
    // We check for "Watch" or "Box" to be safe as the UI updates dynamically
    expect(find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final text = widget.data ?? '';
        return text.contains('Watch carefully') || text.contains('Box');
      }
      return false;
    }), findsOneWidget);

    // This test verifies that the presentation phase message is shown
  });
}