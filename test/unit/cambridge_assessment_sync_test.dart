import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cambridge Assessment Sync Tests', () {
    test('syncPendingData should call _syncPendingCambridgeAssessments', () {
      // This test verifies that the syncPendingData method in SupabaseService
      // includes a call to sync Cambridge assessments.
      //
      // We verify this by checking the source code directly.

      final file = File('lib/core/services/supabase_service.dart');
      final content = file.readAsStringSync();

      // Find the syncPendingData method and check it calls Cambridge sync
      final syncPendingDataMatch = RegExp(
        r'Future<void> syncPendingData\(\).*?(?=Future<void>|$)',
        dotAll: true,
      ).firstMatch(content);

      expect(syncPendingDataMatch, isNotNull,
          reason: 'syncPendingData method should exist');

      final methodBody = syncPendingDataMatch!.group(0)!;

      // Verify all 5 sync methods are called
      expect(methodBody.contains('_syncPendingUserProfile'), isTrue,
          reason: 'Should sync user profiles');
      expect(methodBody.contains('_syncPendingAssessments'), isTrue,
          reason: 'Should sync assessments');
      expect(methodBody.contains('_syncPendingCognitiveExercises'), isTrue,
          reason: 'Should sync cognitive exercises');
      expect(methodBody.contains('_syncPendingDailyGoals'), isTrue,
          reason: 'Should sync daily goals');
      expect(methodBody.contains('_syncPendingCambridgeAssessments'), isTrue,
          reason: 'Should sync Cambridge assessments - THIS IS THE BUG!');
    });

    test('_syncPendingCambridgeAssessments method should exist', () {
      final file = File('lib/core/services/supabase_service.dart');
      final content = file.readAsStringSync();

      expect(content.contains('_syncPendingCambridgeAssessments'), isTrue,
          reason: '_syncPendingCambridgeAssessments method should exist');
    });
  });
}
