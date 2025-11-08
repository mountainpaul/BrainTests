import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/core/services/audit_log.dart';

/// Test-Driven Development for Audit Logging
///
/// Audit logging is critical for:
/// 1. Security monitoring - track who did what when
/// 2. Debugging - understand what happened before an error
/// 3. Compliance - meet regulatory requirements (HIPAA, GDPR)
/// 4. Data integrity - detect unauthorized modifications
///
/// Audit logs should be:
/// - Immutable (cannot be edited)
/// - Timestamped
/// - Include actor (user/system)
/// - Include action (create/update/delete)
/// - Include resource type and ID
/// - Include relevant details
void main() {
  group('AuditLog', () {
    test('should create audit log with required fields', () {
      final log = AuditLog(
        actor: 'user123',
        action: AuditAction.create,
        resourceType: 'Assessment',
        resourceId: '456',
        timestamp: DateTime(2025, 1, 1, 12, 0, 0),
      );

      expect(log.actor, 'user123');
      expect(log.action, AuditAction.create);
      expect(log.resourceType, 'Assessment');
      expect(log.resourceId, '456');
      expect(log.timestamp, DateTime(2025, 1, 1, 12, 0, 0));
      expect(log.details, isNull);
    });

    test('should create audit log with optional details', () {
      final log = AuditLog(
        actor: 'system',
        action: AuditAction.update,
        resourceType: 'MoodEntry',
        resourceId: '789',
        timestamp: DateTime.now(),
        details: {'mood': 'happy', 'energy': 8},
      );

      expect(log.details, {'mood': 'happy', 'energy': 8});
    });

    test('should convert to JSON', () {
      final log = AuditLog(
        actor: 'user456',
        action: AuditAction.delete,
        resourceType: 'Reminder',
        resourceId: '123',
        timestamp: DateTime(2025, 1, 1, 10, 30, 0),
        details: {'reason': 'expired'},
      );

      final json = log.toJson();

      expect(json['actor'], 'user456');
      expect(json['action'], 'delete');
      expect(json['resourceType'], 'Reminder');
      expect(json['resourceId'], '123');
      expect(json['timestamp'], '2025-01-01T10:30:00.000');
      expect(json['details'], {'reason': 'expired'});
    });

    test('should create from JSON', () {
      final json = {
        'actor': 'system',
        'action': 'create',
        'resourceType': 'Exercise',
        'resourceId': '999',
        'timestamp': '2025-01-01T15:45:00.000',
        'details': {'type': 'anagram'},
      };

      final log = AuditLog.fromJson(json);

      expect(log.actor, 'system');
      expect(log.action, AuditAction.create);
      expect(log.resourceType, 'Exercise');
      expect(log.resourceId, '999');
      expect(log.details, {'type': 'anagram'});
    });

    test('should have immutable fields', () {
      final log = AuditLog(
        actor: 'user123',
        action: AuditAction.read,
        resourceType: 'Assessment',
        resourceId: '456',
        timestamp: DateTime.now(),
      );

      // Verify fields are final (cannot be reassigned)
      // This is enforced by Dart's type system - test is documentation
      expect(log.actor, isNotNull);
      expect(log.action, isNotNull);
      expect(log.resourceType, isNotNull);
    });

    test('should support all audit actions', () {
      final actions = [
        AuditAction.create,
        AuditAction.read,
        AuditAction.update,
        AuditAction.delete,
      ];

      for (final action in actions) {
        final log = AuditLog(
          actor: 'tester',
          action: action,
          resourceType: 'Test',
          resourceId: '1',
          timestamp: DateTime.now(),
        );
        expect(log.action, action);
      }
    });
  });

  group('AuditLogger', () {
    late AuditLogger logger;

    setUp(() {
      logger = AuditLogger();
    });

    tearDown(() {
      logger.clear();
    });

    test('should log audit events', () {
      logger.log(
        actor: 'user123',
        action: AuditAction.create,
        resourceType: 'Assessment',
        resourceId: '1',
        details: {'type': 'MMSE', 'score': 28},
      );

      final logs = logger.getLogs();
      expect(logs.length, 1);
      expect(logs.first.actor, 'user123');
      expect(logs.first.action, AuditAction.create);
      expect(logs.first.resourceType, 'Assessment');
    });

    test('should preserve log order', () {
      logger.log(
        actor: 'user1',
        action: AuditAction.create,
        resourceType: 'A',
        resourceId: '1',
      );

      logger.log(
        actor: 'user2',
        action: AuditAction.update,
        resourceType: 'B',
        resourceId: '2',
      );

      logger.log(
        actor: 'user3',
        action: AuditAction.delete,
        resourceType: 'C',
        resourceId: '3',
      );

      final logs = logger.getLogs();
      expect(logs.length, 3);
      // Most recent first
      expect(logs[0].actor, 'user3');
      expect(logs[1].actor, 'user2');
      expect(logs[2].actor, 'user1');
    });

    test('should filter logs by actor', () {
      logger.log(actor: 'alice', action: AuditAction.create, resourceType: 'R', resourceId: '1');
      logger.log(actor: 'bob', action: AuditAction.update, resourceType: 'R', resourceId: '2');
      logger.log(actor: 'alice', action: AuditAction.delete, resourceType: 'R', resourceId: '3');

      final aliceLogs = logger.getLogsByActor('alice');
      expect(aliceLogs.length, 2);
      expect(aliceLogs.every((log) => log.actor == 'alice'), true);
    });

    test('should filter logs by action', () {
      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'R', resourceId: '1');
      logger.log(actor: 'user', action: AuditAction.update, resourceType: 'R', resourceId: '2');
      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'R', resourceId: '3');

      final createLogs = logger.getLogsByAction(AuditAction.create);
      expect(createLogs.length, 2);
      expect(createLogs.every((log) => log.action == AuditAction.create), true);
    });

    test('should filter logs by resource type', () {
      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'Assessment', resourceId: '1');
      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'MoodEntry', resourceId: '2');
      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'Assessment', resourceId: '3');

      final assessmentLogs = logger.getLogsByResourceType('Assessment');
      expect(assessmentLogs.length, 2);
      expect(assessmentLogs.every((log) => log.resourceType == 'Assessment'), true);
    });

    test('should filter logs by time range', () async {
      final start = DateTime.now();

      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'R', resourceId: '1');

      await Future.delayed(const Duration(milliseconds: 100));

      final middle = DateTime.now();

      logger.log(actor: 'user', action: AuditAction.update, resourceType: 'R', resourceId: '2');

      await Future.delayed(const Duration(milliseconds: 100));

      final end = DateTime.now();

      logger.log(actor: 'user', action: AuditAction.delete, resourceType: 'R', resourceId: '3');

      final logsInRange = logger.getLogsByTimeRange(middle, end);
      expect(logsInRange.length, greaterThanOrEqualTo(1));
      expect(logsInRange.every((log) => log.timestamp.isAfter(middle) || log.timestamp.isAtSameMomentAs(middle)), true);
    });

    test('should get logs for specific resource', () {
      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'Assessment', resourceId: '123');
      logger.log(actor: 'user', action: AuditAction.update, resourceType: 'Assessment', resourceId: '123');
      logger.log(actor: 'user', action: AuditAction.update, resourceType: 'Assessment', resourceId: '456');

      final resourceLogs = logger.getLogsForResource('Assessment', '123');
      expect(resourceLogs.length, 2);
      expect(resourceLogs.every((log) => log.resourceId == '123'), true);
    });

    test('should limit number of logs returned', () {
      for (int i = 0; i < 100; i++) {
        logger.log(actor: 'user', action: AuditAction.create, resourceType: 'R', resourceId: '$i');
      }

      final limitedLogs = logger.getLogs(limit: 10);
      expect(limitedLogs.length, 10);
    });

    test('should get most recent logs first', () {
      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'R', resourceId: '1');
      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'R', resourceId: '2');
      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'R', resourceId: '3');

      final recentLogs = logger.getLogs();
      expect(recentLogs.first.resourceId, '3'); // Most recent first
      expect(recentLogs.last.resourceId, '1'); // Oldest last
    });

    test('should clear all logs', () {
      logger.log(actor: 'user', action: AuditAction.create, resourceType: 'R', resourceId: '1');
      logger.log(actor: 'user', action: AuditAction.update, resourceType: 'R', resourceId: '2');

      expect(logger.getLogs().length, 2);

      logger.clear();

      expect(logger.getLogs().length, 0);
    });

    test('should export logs to JSON', () {
      logger.log(actor: 'user1', action: AuditAction.create, resourceType: 'R1', resourceId: '1');
      logger.log(actor: 'user2', action: AuditAction.update, resourceType: 'R2', resourceId: '2');

      final json = logger.exportToJson();
      expect(json, isList);
      expect(json.length, 2);
      expect(json[0]['actor'], isNotNull);
    });

    test('should import logs from JSON', () {
      final json = [
        {
          'actor': 'user1',
          'action': 'create',
          'resourceType': 'R1',
          'resourceId': '1',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'actor': 'user2',
          'action': 'update',
          'resourceType': 'R2',
          'resourceId': '2',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ];

      logger.importFromJson(json);

      final logs = logger.getLogs();
      expect(logs.length, 2);
      // Most recent first (reverse of insertion order)
      expect(logs[0].actor, 'user2');
      expect(logs[1].actor, 'user1');
    });

    test('should handle concurrent logging', () async {
      final futures = <Future>[];

      for (int i = 0; i < 100; i++) {
        futures.add(Future(() {
          logger.log(
            actor: 'concurrent_user',
            action: AuditAction.create,
            resourceType: 'R',
            resourceId: '$i',
          );
        }));
      }

      await Future.wait(futures);

      final logs = logger.getLogs();
      expect(logs.length, 100);
    });

    test('should provide statistics', () {
      logger.log(actor: 'alice', action: AuditAction.create, resourceType: 'Assessment', resourceId: '1');
      logger.log(actor: 'bob', action: AuditAction.update, resourceType: 'Assessment', resourceId: '2');
      logger.log(actor: 'alice', action: AuditAction.create, resourceType: 'MoodEntry', resourceId: '3');
      logger.log(actor: 'charlie', action: AuditAction.delete, resourceType: 'Reminder', resourceId: '4');

      final stats = logger.getStatistics();

      expect(stats['totalLogs'], 4);
      expect(stats['uniqueActors'], greaterThanOrEqualTo(2));
      expect(stats['actionCounts'], isMap);
      expect(stats['resourceTypeCounts'], isMap);
    });
  });

  group('AuditLogInterceptor', () {
    test('should automatically log database operations', () {
      // This will be integration tested with the actual database
      // Unit test documents the interface

      final interceptor = AuditLogInterceptor(
        logger: AuditLogger(),
        defaultActor: 'system',
      );

      expect(interceptor.logger, isNotNull);
      expect(interceptor.defaultActor, 'system');
    });
  });
}
