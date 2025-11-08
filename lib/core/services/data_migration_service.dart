import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'google_drive_backup_service.dart';

/// Service to handle data backup and migration between app updates
class DataMigrationService {
  static const String _lastBackupKey = 'last_backup_timestamp';
  static const String _appVersionKey = 'app_version';
  static const String _backupFileName = 'brain_plan_backup.db';

  /// Checks if device has network connectivity
  static Future<bool> hasNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
             connectivityResult.contains(ConnectivityResult.wifi) ||
             connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Backs up the database to both Google Drive and local storage
  /// Should be called periodically or before updates
  static Future<void> backupDatabase() async {
    try {
      // Get the current database file
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'brain_plan.db'));

      if (!await dbFile.exists()) {
        print('Database file does not exist, skipping backup');
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      bool driveBackupSuccess = false;
      bool localBackupSuccess = false;

      // PRIMARY: Try Google Drive backup if network available
      final hasNetwork = await hasNetworkConnection();

      if (hasNetwork) {
        // Initialize Google Drive if not already done
        await GoogleDriveBackupService.initialize();

        // Note: Don't prompt for sign-in during backup - user can sign in manually later
        // This prevents blocking the app startup with authentication dialogs

        // Attempt backup if already signed in
        if (GoogleDriveBackupService.isSignedIn) {
          print('Attempting Google Drive backup...');
          driveBackupSuccess = await GoogleDriveBackupService.uploadBackup();
          if (driveBackupSuccess) {
            print('✓ Google Drive backup completed successfully');
          } else {
            print('✗ Google Drive backup failed, falling back to local backup');
          }
        } else {
          print('Not signed in to Google Drive, using local backup only');
        }
      } else {
        print('No network connection, skipping Google Drive backup');
      }

      // SECONDARY: Always do local backup as fallback
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final backupDir = Directory(p.join(externalDir.path, 'backups'));
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
          print('Created backup directory at ${backupDir.path}');
        }

        // Copy database to backup location with timestamp
        final backupFile = File(p.join(backupDir.path, 'backup_$timestamp.db'));
        await dbFile.copy(backupFile.path);

        // Also keep a "latest" backup for easy restoration
        final latestBackupFile = File(p.join(backupDir.path, _backupFileName));
        await dbFile.copy(latestBackupFile.path);

        localBackupSuccess = true;
        print('✓ Local backup saved to ${latestBackupFile.path}');
      } else {
        print('✗ External storage not available for local backup');
      }

      // Save backup timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastBackupKey, timestamp);

      // Summary
      if (driveBackupSuccess && localBackupSuccess) {
        print('=== BACKUP SUCCESS: Both Google Drive and local backups completed ===');
      } else if (driveBackupSuccess) {
        print('=== BACKUP SUCCESS: Google Drive backup completed (local backup unavailable) ===');
      } else if (localBackupSuccess) {
        print('=== BACKUP SUCCESS: Local backup completed (Google Drive unavailable) ===');
      } else {
        print('=== BACKUP FAILURE: All backup methods failed ===');
      }
    } catch (e) {
      print('Error backing up database: $e');
    }
  }

  /// Restores the database from backup if available
  /// Should be called on app startup after an update
  static Future<bool> restoreFromBackupIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVersion = await _getAppVersion();
      final savedVersion = prefs.getString(_appVersionKey);

      print('=== DATA MIGRATION CHECK ===');
      print('Current version: $currentVersion');
      print('Saved version: $savedVersion');

      // Check if this is a fresh install or update
      if (savedVersion != null && savedVersion != currentVersion) {
        print('✓ App version changed from $savedVersion to $currentVersion');
        print('Attempting to restore from backup...');

        final restored = await _restoreFromBackup();
        if (restored) {
          print('✓ Database restored successfully from backup');
        } else {
          print('✗ No backup found or restore failed');
        }

        // Update stored version
        await prefs.setString(_appVersionKey, currentVersion);
        print('Version updated in preferences to: $currentVersion');
        return restored;
      } else if (savedVersion == null) {
        // First install OR reinstall after uninstall
        // Check if backup exists (indicates reinstall)
        print('First install OR reinstall detected');
        print('Checking for existing backups...');

        final restored = await _restoreFromBackup();
        if (restored) {
          print('✓ Found and restored backup from previous install');
        } else {
          print('No backup found - this is a genuine first install');
        }

        // Save the version
        await prefs.setString(_appVersionKey, currentVersion);
        print('Version saved: $currentVersion');
        return restored;
      } else {
        print('No version change detected, skipping restore');
      }

      return false;
    } catch (e) {
      print('✗ Error in restoreFromBackupIfNeeded: $e');
      return false;
    }
  }

  /// Internal method to restore database from backup
  /// Tries Google Drive first, then local backup
  static Future<bool> _restoreFromBackup() async {
    try {
      bool restored = false;

      // PRIMARY: Try Google Drive restore if signed in
      if (GoogleDriveBackupService.isSignedIn) {
        print('Checking for Google Drive backup...');
        final hasCloudBackup = await GoogleDriveBackupService.hasBackup();

        if (hasCloudBackup) {
          print('Found backup in Google Drive, attempting restore...');
          restored = await GoogleDriveBackupService.downloadBackup();

          if (restored) {
            print('✓ Database restored from Google Drive');
            return true;
          } else {
            print('✗ Google Drive restore failed, trying local backup...');
          }
        } else {
          print('No backup found in Google Drive, trying local backup...');
        }
      } else {
        print('Not signed in to Google Drive, trying local backup...');
      }

      // SECONDARY: Try local backup
      final externalDir = await getExternalStorageDirectory();
      File? backupFile;

      if (externalDir != null) {
        final appBackupFile = File(p.join(externalDir.path, 'backups', _backupFileName));
        if (await appBackupFile.exists()) {
          print('Found backup in app-specific external storage');
          backupFile = appBackupFile;
        }
      }

      if (backupFile == null || !await backupFile.exists()) {
        print('✗ No local backup file found');
        return false;
      }

      // Get database location
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'brain_plan.db'));

      // If current database exists and is not empty, create a safety backup
      if (await dbFile.exists()) {
        final fileSize = await dbFile.length();
        if (fileSize > 0) {
          final safetyBackup = File(p.join(dbFolder.path, 'brain_plan_pre_restore.db'));
          await dbFile.copy(safetyBackup.path);
          print('Created safety backup at ${safetyBackup.path}');
        }
      }

      // Restore from local backup
      await backupFile.copy(dbFile.path);
      print('✓ Database restored from local backup: ${backupFile.path}');
      return true;
    } catch (e) {
      print('✗ Error restoring from backup: $e');
      return false;
    }
  }

  /// Gets the current app version/build number
  static Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      // Return version+buildNumber format (e.g., "1.0.0+2")
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      print('Error getting app version: $e');
      // Fallback to a default version if PackageInfo fails
      return '1.0.0+1';
    }
  }

  /// Manual restore function for user-initiated restore
  static Future<bool> manualRestore() async {
    try {
      print('Manual restore initiated');
      return await _restoreFromBackup();
    } catch (e) {
      print('Error in manual restore: $e');
      return false;
    }
  }

  /// Gets the last backup timestamp
  static Future<DateTime?> getLastBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastBackupKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      print('Error getting last backup time: $e');
      return null;
    }
  }

  /// Lists all available backups
  static Future<List<File>> listBackups() async {
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        return [];
      }

      final backupDir = Directory(p.join(externalDir.path, 'backups'));
      if (!await backupDir.exists()) {
        return [];
      }

      final files = await backupDir.list().toList();
      return files
          .whereType<File>()
          .where((f) => f.path.endsWith('.db'))
          .toList();
    } catch (e) {
      print('Error listing backups: $e');
      return [];
    }
  }
}
