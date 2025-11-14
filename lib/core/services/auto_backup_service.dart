import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'google_drive_backup_service.dart';

/// Service to handle automatic backups to Google Drive
/// Implements daily scheduled backups and event-triggered backups
class AutoBackupService {
  static const String _lastBackupKey = 'last_backup_timestamp';
  static const String _autoBackupEnabledKey = 'auto_backup_enabled';
  static const Duration _dailyBackupInterval = Duration(hours: 24);
  static const Duration _debounceInterval = Duration(minutes: 5);

  static Timer? _dailyBackupTimer;
  static Timer? _debounceTimer;
  static DateTime? _lastBackupTime;
  static bool _isBackupInProgress = false;

  /// Initialize the auto-backup service
  static Future<void> initialize() async {
    await _loadLastBackupTime();

    if (await isAutoBackupEnabled()) {
      await startDailyBackup();
    }
  }

  /// Check if auto-backup is enabled
  static Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoBackupEnabledKey) ?? true; // Enabled by default
  }

  /// Enable or disable auto-backup
  static Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupEnabledKey, enabled);

    if (enabled) {
      await startDailyBackup();
    } else {
      stopDailyBackup();
    }
  }

  /// Load the last backup timestamp from storage
  static Future<void> _loadLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastBackupKey);
    if (timestamp != null) {
      _lastBackupTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
  }

  /// Save the last backup timestamp to storage
  static Future<void> _saveLastBackupTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastBackupKey, time.millisecondsSinceEpoch);
    _lastBackupTime = time;
  }

  /// Get the last backup time
  static DateTime? getLastBackupTime() => _lastBackupTime;

  /// Check if a backup is needed (more than 24 hours since last backup)
  static bool needsBackup() {
    if (_lastBackupTime == null) return true;

    final now = DateTime.now();
    final timeSinceLastBackup = now.difference(_lastBackupTime!);
    return timeSinceLastBackup >= _dailyBackupInterval;
  }

  /// Start the daily backup scheduler
  static Future<void> startDailyBackup() async {
    // Cancel existing timer if any
    _dailyBackupTimer?.cancel();

    // Check if we need immediate backup
    if (needsBackup()) {
      await performBackup(source: 'scheduled_daily');
    }

    // Schedule next backup after 24 hours
    _dailyBackupTimer = Timer.periodic(_dailyBackupInterval, (timer) async {
      if (await isAutoBackupEnabled()) {
        await performBackup(source: 'scheduled_daily');
      }
    });

    debugPrint('Daily backup scheduler started');
  }

  /// Stop the daily backup scheduler
  static void stopDailyBackup() {
    _dailyBackupTimer?.cancel();
    _dailyBackupTimer = null;
    debugPrint('Daily backup scheduler stopped');
  }

  /// Trigger backup after significant data change (debounced)
  /// This prevents multiple backups in quick succession
  static Future<void> triggerBackupAfterChange({
    required String changeType,
  }) async {
    if (!await isAutoBackupEnabled()) {
      debugPrint('Auto-backup disabled, skipping backup after $changeType');
      return;
    }

    if (!GoogleDriveBackupService.isSignedIn) {
      debugPrint('Not signed in to Google Drive, skipping backup');
      return;
    }

    // Cancel existing debounce timer
    _debounceTimer?.cancel();

    // Schedule backup after debounce interval
    _debounceTimer = Timer(_debounceInterval, () async {
      await performBackup(source: 'data_change_$changeType');
    });

    debugPrint('Backup scheduled after $changeType (debounced ${_debounceInterval.inMinutes}min)');
  }

  /// Perform the actual backup operation
  static Future<bool> performBackup({
    required String source,
    bool force = false,
  }) async {
    // Prevent concurrent backups
    if (_isBackupInProgress) {
      debugPrint('Backup already in progress, skipping');
      return false;
    }

    // Check if user is signed in
    if (!GoogleDriveBackupService.isSignedIn) {
      debugPrint('Not signed in to Google Drive, skipping backup');
      return false;
    }

    // Check if backup is needed (unless forced)
    if (!force && !needsBackup()) {
      debugPrint('Backup not needed yet (last backup: $_lastBackupTime)');
      return false;
    }

    _isBackupInProgress = true;
    debugPrint('Starting backup (source: $source)...');

    try {
      final success = await GoogleDriveBackupService.uploadBackup();

      if (success) {
        await _saveLastBackupTime(DateTime.now());
        debugPrint('✓ Backup successful (source: $source)');
        return true;
      } else {
        debugPrint('✗ Backup failed (source: $source)');
        return false;
      }
    } catch (e) {
      debugPrint('✗ Backup error (source: $source): $e');
      return false;
    } finally {
      _isBackupInProgress = false;
    }
  }

  /// Get backup status information
  static Map<String, dynamic> getBackupStatus() {
    return {
      'auto_backup_enabled': isAutoBackupEnabled(),
      'last_backup_time': _lastBackupTime?.toIso8601String(),
      'needs_backup': needsBackup(),
      'is_backup_in_progress': _isBackupInProgress,
      'is_signed_in': GoogleDriveBackupService.isSignedIn,
      'signed_in_email': GoogleDriveBackupService.userEmail,
    };
  }

  /// Helper for debug printing
  static void debugPrint(String message) {
    // ignore: avoid_print
    print('[AutoBackup] $message');
  }

  /// Cleanup resources
  static void dispose() {
    _dailyBackupTimer?.cancel();
    _debounceTimer?.cancel();
    _dailyBackupTimer = null;
    _debounceTimer = null;
  }
}
