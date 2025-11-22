import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Common test setup helpers to ensure consistency across the test suite.

/// Ensures the Flutter test binding is initialized.
/// Call this at the start of `main()` in widget and integration tests.
void ensureTestBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

/// Configures the test view to a standard large phone size (1000x2000)
/// to prevent overflow errors and off-screen widget tap failures.
/// Call this inside `testWidgets` or `setUp` when UI interaction is involved.
Future<void> configureWidgetTestScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 2000);
  tester.view.devicePixelRatio = 1.0;
  
  // Register teardown to reset view after test
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
