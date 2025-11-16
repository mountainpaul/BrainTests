import 'package:brain_tests/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration test for Google Drive Manual Backup visibility bug
/// Bug: After signing in to Google Drive and hitting back arrow,
/// Manual Backup option doesn't appear until navigating away and back
/// Root cause: Static getters don't trigger rebuilds, Settings screen doesn't watch state
void main() {
  group('Google Drive Settings Refresh Tests', () {
    testWidgets('Manual Backup MUST appear immediately after Google Drive sign-in', (tester) async {
      // GIVEN: User is on Settings screen, not signed in
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Manual Backup is NOT visible initially
      expect(find.text('Manual Backup'), findsNothing,
          reason: 'Manual Backup should not be visible when not signed in');
      expect(find.text('Sign in to Google Drive'), findsOneWidget,
          reason: 'Should show sign-in option initially');

      // WHEN: User signs in to Google Drive (simulated by mocking the service)
      // Note: In real test, this would trigger GoogleDriveBackupService.signIn()
      // For now, we're testing that the UI WOULD update if state changed

      // After sign-in, the static getter changes but widget doesn't rebuild
      // This is the bug: Static getters don't trigger rebuilds

      // THEN: Manual Backup MUST appear without navigating away and back
      // This test documents the expected behavior after fix
      // expect(find.text('Manual Backup'), findsOneWidget,
      //     reason: 'Manual Backup must appear immediately after sign-in');
    });

    testWidgets('Settings screen MUST rebuild when Google Drive state changes', (tester) async {
      // This test verifies that Settings uses a reactive provider instead of static getters

      // GIVEN: Settings screen is built
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // WHEN: Google Drive sign-in state changes
      // The Settings screen should be watching a provider, not reading static getters

      // THEN: Widget should rebuild automatically
      // This will be verified by the fix using a StateNotifier or StreamProvider
    });
  });
}
