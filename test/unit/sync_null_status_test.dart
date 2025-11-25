import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sync NULL Status Tests', () {
    test('sync queries should handle NULL syncStatus values', () {
      // This test documents the bug:
      // When syncStatus is NULL (for migrated rows), the query:
      //   WHERE syncStatus != 0  (synced)
      // Will NOT match NULL values because NULL != 0 is NULL, not TRUE.
      //
      // The fix: use COALESCE or OR IS NULL in the query

      final file = File('lib/core/services/supabase_service.dart');
      final content = file.readAsStringSync();

      // Check that Cambridge assessment sync handles NULL syncStatus
      // Either by using isNull() or by using a different approach
      final cambridgeSyncMatch = RegExp(
        r'_syncPendingCambridgeAssessments.*?(?=Future<void>|$)',
        dotAll: true,
      ).firstMatch(content);

      expect(cambridgeSyncMatch, isNotNull);

      final methodBody = cambridgeSyncMatch!.group(0)!;

      // The query should handle NULL values - either with:
      // 1. .isNull() check
      // 2. OR condition
      // 3. Using .isNotValue() which handles NULL
      // For now, we check that it doesn't ONLY use equals().not()

      // This is the buggy pattern that doesn't handle NULL:
      final hasBuggyPattern = methodBody.contains('syncStatus.equals(SyncStatus.synced.index).not()');

      // Should have a fix for NULL handling
      final hasNullHandling = methodBody.contains('isNull') ||
                              methodBody.contains('isNotValue') ||
                              methodBody.contains('| t.syncStatus.isNull');

      expect(hasBuggyPattern && !hasNullHandling, isFalse,
          reason: 'Sync query should handle NULL syncStatus values for migrated rows');
    });
  });
}
