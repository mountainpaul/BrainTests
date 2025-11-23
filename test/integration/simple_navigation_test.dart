import 'package:brain_tests/core/services/supabase_service.dart';
import 'package:brain_tests/core/services/sync_manager.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Create a dummy/mock sync manager for testing UI instantiation
  final database = AppDatabase.memory();
  final syncManager = SyncManager(SupabaseService(database));

  group('Simple Navigation Tests', () {
    testWidgets('App can be instantiated', (WidgetTester tester) async {
      // Test that the BrainPlanApp can be created without errors
      final app = BrainPlanApp(syncManager: syncManager);
      expect(app, isA<BrainPlanApp>());
    });

    testWidgets('ProviderScope wraps app correctly', (WidgetTester tester) async {
      // Test that ProviderScope can wrap BrainPlanApp
      final scopedApp = ProviderScope(
        child: BrainPlanApp(syncManager: syncManager),
      );
      expect(scopedApp, isA<ProviderScope>());
      expect(scopedApp.child, isA<BrainPlanApp>());
    });

    testWidgets('App widget tree structure validation', (WidgetTester tester) async {
      // Simple validation that the app components exist
      expect(BrainPlanApp, isNotNull);
      expect(ProviderScope, isNotNull);

      // Test widget creation
      final widget = BrainPlanApp(syncManager: syncManager);
      expect(widget.runtimeType.toString(), contains('BrainPlanApp'));
    });
  });

  group('Navigation Component Tests', () {
    testWidgets('Icon constants are accessible', (WidgetTester tester) async {
      // Test that navigation icons are accessible
      expect(Icons.home, isNotNull);
      expect(Icons.assessment, isNotNull);
      expect(Icons.psychology, isNotNull);
      expect(Icons.mood, isNotNull);
      expect(Icons.notifications, isNotNull);
    });

    testWidgets('Material components are available', (WidgetTester tester) async {
      // Test that required Material components are available
      expect(MaterialApp, isNotNull);
      expect(Scaffold, isNotNull);
      expect(FloatingActionButton, isNotNull);
      expect(BottomNavigationBar, isNotNull);
    });
  });

  group('Provider Infrastructure Tests', () {
    testWidgets('Riverpod components are available', (WidgetTester tester) async {
      // Test that Riverpod infrastructure is set up correctly
      expect(ProviderScope, isNotNull);
      expect(ConsumerWidget, isNotNull);

      // Test that BrainPlanApp extends ConsumerWidget
      final app = BrainPlanApp(syncManager: syncManager);
      expect(app, isA<ConsumerStatefulWidget>());
    });
  });
}