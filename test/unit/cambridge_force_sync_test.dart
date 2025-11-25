import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cambridge Force Sync Recovery Tests', () {
    test('forceSyncAllCambridgeAssessments method should exist for recovery', () {
      // This test verifies that a recovery method exists to force sync all
      // Cambridge assessments regardless of their syncStatus.
      // This is needed when normal sync fails due to NULL syncStatus or other issues.

      final file = File('lib/core/services/supabase_service.dart');
      final content = file.readAsStringSync();

      expect(content.contains('forceSyncAllCambridgeAssessments'), isTrue,
          reason: 'forceSyncAllCambridgeAssessments method should exist for recovery');
    });

    test('forceSyncAllCambridgeAssessments should query ALL records without filter', () {
      // The force sync should not filter by syncStatus - it should sync ALL records

      final file = File('lib/core/services/supabase_service.dart');
      final content = file.readAsStringSync();

      // Find the forceSyncAllCambridgeAssessments method
      final methodMatch = RegExp(
        r'Future<void> forceSyncAllCambridgeAssessments.*?(?=Future<void>|Future<\w+>|\}$)',
        dotAll: true,
      ).firstMatch(content);

      expect(methodMatch, isNotNull,
          reason: 'forceSyncAllCambridgeAssessments method should exist');

      final methodBody = methodMatch!.group(0)!;

      // Should query all records without syncStatus filter
      // Look for a simple select without .where on syncStatus
      expect(
        methodBody.contains('_database.select(_database.cambridgeAssessmentTable).get()'),
        isTrue,
        reason: 'Force sync should query ALL Cambridge assessments without filtering',
      );
    });
  });
}
