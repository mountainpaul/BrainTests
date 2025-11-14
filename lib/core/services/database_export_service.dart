import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/datasources/database.dart';

/// Service for exporting the complete SQLite database
class DatabaseExportService {
  /// Exports the database to a file and returns the export path
  static Future<String> exportDatabase({
    required AppDatabase database,
    required String exportPath,
  }) async {
    final sourcePath = await getDatabasePath();
    await copyDatabaseFile(
      sourcePath: sourcePath,
      destinationPath: exportPath,
    );
    return exportPath;
  }

  /// Generates a timestamped filename for database export
  static String generateExportFilename() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'brain_plan_backup_$timestamp.db';
  }

  /// Copies database file from source to destination
  static Future<void> copyDatabaseFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw FileSystemException(
        'Source database file does not exist',
        sourcePath,
      );
    }

    await sourceFile.copy(destinationPath);
  }

  /// Gets the path to the app's database file
  static Future<String> getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return p.join(dbFolder.path, 'brain_plan.db');
  }

  /// Gets the file size of the database in bytes
  static Future<int> getDatabaseFileSize(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return 0;
    }
    return await file.length();
  }

  /// Formats file size in human readable format (B, KB, MB, GB)
  static String formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    if (bytes < 1024) return '$bytes B';

    const units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Exports and shares the database file
  static Future<String> exportAndShareDatabase({
    required AppDatabase database,
  }) async {
    final exportDir = await getApplicationDocumentsDirectory();
    final filename = generateExportFilename();
    final exportPath = p.join(exportDir.path, filename);

    await exportDatabase(
      database: database,
      exportPath: exportPath,
    );

    // Share the database file
    await Share.shareXFiles(
      [XFile(exportPath)],
      subject: 'Brain Plan Database Backup',
      text: 'Complete database backup from Brain Plan app',
    );

    return exportPath;
  }

  /// Gets information about the current database
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    final dbPath = await getDatabasePath();
    final fileSize = await getDatabaseFileSize(dbPath);
    final formattedSize = formatFileSize(fileSize);

    return {
      'path': dbPath,
      'size_bytes': fileSize,
      'size_formatted': formattedSize,
      'exists': await File(dbPath).exists(),
    };
  }

  /// Validates if a file has a valid database extension
  static bool isValidDatabaseFile(String filename) {
    return filename.toLowerCase().endsWith('.db');
  }

  /// Creates a backup of the current database before importing
  static Future<String> createBackupBeforeImport() async {
    final dbPath = await getDatabasePath();
    final dbFolder = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = p.join(
      dbFolder.path,
      'backup_before_import_$timestamp.db',
    );

    await copyDatabaseFile(
      sourcePath: dbPath,
      destinationPath: backupPath,
    );

    return backupPath;
  }

  /// Restores database from a backup file
  static Future<void> restoreFromBackup(String backupPath) async {
    final dbPath = await getDatabasePath();
    await copyDatabaseFile(
      sourcePath: backupPath,
      destinationPath: dbPath,
    );
  }

  /// Imports a database from a file, replacing the current one
  /// Creates a backup before importing
  static Future<void> importDatabase({
    required AppDatabase database,
    required String importPath,
  }) async {
    // Validate file exists
    final importFile = File(importPath);
    if (!await importFile.exists()) {
      throw FileSystemException(
        'Import file does not exist',
        importPath,
      );
    }

    // Validate file format
    if (!isValidDatabaseFile(importPath)) {
      throw ArgumentError(
        'Invalid database file format. Only .db files are allowed.',
      );
    }

    // Create backup before importing
    final backupPath = await createBackupBeforeImport();

    try {
      // Close the current database connection so we can replace the file
      await database.close();

      // Get current database path
      final dbPath = await getDatabasePath();

      // Replace current database file with imported one
      await copyDatabaseFile(
        sourcePath: importPath,
        destinationPath: dbPath,
      );

      // IMPORTANT: Database will be restored on next app restart
      // The closed connection means app MUST be restarted (not just minimized)
    } catch (e) {
      // If import fails, restore from backup
      await restoreFromBackup(backupPath);
      rethrow;
    }
  }

  /// Imports and validates a database file
  /// Returns success status and any error messages
  static Future<Map<String, dynamic>> importAndValidateDatabase({
    required AppDatabase database,
    required String importPath,
  }) async {
    try {
      await importDatabase(
        database: database,
        importPath: importPath,
      );

      return {
        'success': true,
        'message': 'Database imported successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to import database: ${e.toString()}',
        'error': e,
      };
    }
  }
}
