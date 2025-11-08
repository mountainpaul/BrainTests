/// Audit Logging Service
///
/// Provides immutable audit trail for data modifications.
/// Critical for security, compliance, and debugging.
///
/// Example usage:
/// ```dart
/// final logger = AuditLogger();
///
/// // Log data modification
/// logger.log(
///   actor: 'user123',
///   action: AuditAction.update,
///   resourceType: 'Assessment',
///   resourceId: '456',
///   details: {'score': 28, 'previousScore': 25},
/// );
///
/// // Query logs
/// final logs = logger.getLogsForResource('Assessment', '456');
/// print('Assessment 456 has been modified ${logs.length} times');
/// ```

/// Audit actions
enum AuditAction {
  create,
  read,
  update,
  delete,
}

/// Immutable audit log entry
class AuditLog {
  final String actor;
  final AuditAction action;
  final String resourceType;
  final String resourceId;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const AuditLog({
    required this.actor,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.timestamp,
    this.details,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'actor': actor,
        'action': action.name,
        'resourceType': resourceType,
        'resourceId': resourceId,
        'timestamp': timestamp.toIso8601String(),
        if (details != null) 'details': details,
      };

  /// Create from JSON
  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      actor: json['actor'] as String,
      action: AuditAction.values.firstWhere((a) => a.name == json['action']),
      resourceType: json['resourceType'] as String,
      resourceId: json['resourceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'AuditLog(actor: $actor, action: ${action.name}, '
        'resource: $resourceType/$resourceId, time: $timestamp)';
  }
}

/// In-memory audit logger
///
/// For production use, consider persisting to database or external service
class AuditLogger {
  final List<AuditLog> _logs = [];

  /// Log an audit event
  void log({
    required String actor,
    required AuditAction action,
    required String resourceType,
    required String resourceId,
    Map<String, dynamic>? details,
  }) {
    final auditLog = AuditLog(
      actor: actor,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      timestamp: DateTime.now(),
      details: details,
    );

    _logs.add(auditLog);
  }

  /// Get all logs (most recent first)
  List<AuditLog> getLogs({int? limit}) {
    final reversed = _logs.reversed.toList();
    if (limit != null && limit < reversed.length) {
      return reversed.take(limit).toList();
    }
    return reversed;
  }

  /// Get logs by actor
  List<AuditLog> getLogsByActor(String actor) {
    return _logs.where((log) => log.actor == actor).toList().reversed.toList();
  }

  /// Get logs by action
  List<AuditLog> getLogsByAction(AuditAction action) {
    return _logs.where((log) => log.action == action).toList().reversed.toList();
  }

  /// Get logs by resource type
  List<AuditLog> getLogsByResourceType(String resourceType) {
    return _logs.where((log) => log.resourceType == resourceType).toList().reversed.toList();
  }

  /// Get logs for specific resource
  List<AuditLog> getLogsForResource(String resourceType, String resourceId) {
    return _logs
        .where((log) => log.resourceType == resourceType && log.resourceId == resourceId)
        .toList()
        .reversed
        .toList();
  }

  /// Get logs within time range
  List<AuditLog> getLogsByTimeRange(DateTime start, DateTime end) {
    return _logs
        .where((log) =>
            (log.timestamp.isAfter(start) || log.timestamp.isAtSameMomentAs(start)) &&
            (log.timestamp.isBefore(end) || log.timestamp.isAtSameMomentAs(end)))
        .toList()
        .reversed
        .toList();
  }

  /// Clear all logs (use with caution!)
  void clear() {
    _logs.clear();
  }

  /// Export logs to JSON
  List<Map<String, dynamic>> exportToJson() {
    return _logs.map((log) => log.toJson()).toList();
  }

  /// Import logs from JSON
  void importFromJson(List<dynamic> json) {
    for (final item in json) {
      _logs.add(AuditLog.fromJson(item as Map<String, dynamic>));
    }
  }

  /// Get audit log statistics
  Map<String, dynamic> getStatistics() {
    final actors = <String>{};
    final actionCounts = <String, int>{};
    final resourceTypeCounts = <String, int>{};

    for (final log in _logs) {
      actors.add(log.actor);

      final actionName = log.action.name;
      actionCounts[actionName] = (actionCounts[actionName] ?? 0) + 1;

      resourceTypeCounts[log.resourceType] = (resourceTypeCounts[log.resourceType] ?? 0) + 1;
    }

    return {
      'totalLogs': _logs.length,
      'uniqueActors': actors.length,
      'actionCounts': actionCounts,
      'resourceTypeCounts': resourceTypeCounts,
      'oldestLog': _logs.isEmpty ? null : _logs.first.timestamp.toIso8601String(),
      'newestLog': _logs.isEmpty ? null : _logs.last.timestamp.toIso8601String(),
    };
  }
}

/// Database interceptor for automatic audit logging
///
/// Wraps database operations to automatically log modifications
class AuditLogInterceptor {
  final AuditLogger logger;
  final String defaultActor;

  const AuditLogInterceptor({
    required this.logger,
    required this.defaultActor,
  });

  /// Log database insert
  void logInsert({
    required String resourceType,
    required String resourceId,
    String? actor,
    Map<String, dynamic>? details,
  }) {
    logger.log(
      actor: actor ?? defaultActor,
      action: AuditAction.create,
      resourceType: resourceType,
      resourceId: resourceId,
      details: details,
    );
  }

  /// Log database update
  void logUpdate({
    required String resourceType,
    required String resourceId,
    String? actor,
    Map<String, dynamic>? details,
  }) {
    logger.log(
      actor: actor ?? defaultActor,
      action: AuditAction.update,
      resourceType: resourceType,
      resourceId: resourceId,
      details: details,
    );
  }

  /// Log database delete
  void logDelete({
    required String resourceType,
    required String resourceId,
    String? actor,
    Map<String, dynamic>? details,
  }) {
    logger.log(
      actor: actor ?? defaultActor,
      action: AuditAction.delete,
      resourceType: resourceType,
      resourceId: resourceId,
      details: details,
    );
  }

  /// Log database read (if needed for sensitive data)
  void logRead({
    required String resourceType,
    required String resourceId,
    String? actor,
    Map<String, dynamic>? details,
  }) {
    logger.log(
      actor: actor ?? defaultActor,
      action: AuditAction.read,
      resourceType: resourceType,
      resourceId: resourceId,
      details: details,
    );
  }
}
