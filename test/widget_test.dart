// This is a basic Flutter widget test for the Brain Plan app.

import 'package:brain_tests/core/services/supabase_service.dart';
import 'package:brain_tests/core/services/sync_manager.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App should load and display MaterialApp', (WidgetTester tester) async {
    // Set up shared preferences with onboarding completion to skip onboarding
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});

    // Setup mock sync manager
    final database = AppDatabase.memory();
    final syncManager = SyncManager(SupabaseService(database));

    // Build our app and trigger a frame.
    await tester.pumpWidget(ProviderScope(
      child: BrainPlanApp(syncManager: syncManager),
    ));

    // Pump a few frames to allow initial render
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);

    // Check that the app has a basic structure (Scaffold)
    expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
  });
}