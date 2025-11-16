import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:brain_tests/core/services/database_export_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock for PathProviderPlatform
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  late AppDatabase database;
  late Directory tempDir;

  setUp(() async {
    // Use in-memory database for testing
    database = AppDatabase.memory();

    // Create a temporary directory for testing
    tempDir = await Directory.systemTemp.createTemp('database_export_test_');

    // Mock PathProvider
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  tearDown(() async {
    // Clean up temporary files
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  tearDown(() async {
    await database.close();
  });

  group('DatabaseExportService', () {
    test('should export database to a .db file', () async {
      // Arrange
      final sourcePath = await DatabaseExportService.getDatabasePath();
      // Create a dummy source database file
      await File(sourcePath).create(recursive: true);
      await File(sourcePath).writeAsString('test database content');

      final exportPath = '${tempDir.path}/exported_database.db';

      // Act
      final result = await DatabaseExportService.exportDatabase(
        database: database,
        exportPath: exportPath,
      );

      // Assert
      expect(result, isNotNull);
      expect(result, equals(exportPath));
      expect(File(result).existsSync(), isTrue);

      // Cleanup
      await File(sourcePath).delete();
    });

    test('should generate default export filename with timestamp', () async {
      // Act
      final filename = DatabaseExportService.generateExportFilename();

      // Assert
      expect(filename, startsWith('brain_plan_backup_'));
      expect(filename, endsWith('.db'));
      expect(filename.length, greaterThan('brain_plan_backup_'.length + '.db'.length));
    });

    test('should copy database file successfully', () async {
      // Arrange
      final sourcePath = '${tempDir.path}/source.db';
      final destinationPath = '${tempDir.path}/destination.db';

      // Create a dummy source database file
      final sourceFile = File(sourcePath);
      await sourceFile.writeAsString('dummy database content');

      // Act
      await DatabaseExportService.copyDatabaseFile(
        sourcePath: sourcePath,
        destinationPath: destinationPath,
      );

      // Assert
      final destinationFile = File(destinationPath);
      expect(destinationFile.existsSync(), isTrue);
      expect(await destinationFile.readAsString(), equals('dummy database content'));
    });

    test('should throw exception when source file does not exist', () async {
      // Arrange
      final sourcePath = '${tempDir.path}/nonexistent.db';
      final destinationPath = '${tempDir.path}/destination.db';

      // Act & Assert
      expect(
        () => DatabaseExportService.copyDatabaseFile(
          sourcePath: sourcePath,
          destinationPath: destinationPath,
        ),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('should get database file path', () async {
      // Act
      final dbPath = await DatabaseExportService.getDatabasePath();

      // Assert
      expect(dbPath, isNotNull);
      expect(dbPath, endsWith('brain_plan.db'));
    });

    test('should export and share database file', () async {
      // This test would require mocking Share.shareXFiles
      // For now, we'll test the file creation part

      // Arrange
      final exportDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportPath = '${exportDir.path}/brain_plan_backup_$timestamp.db';

      // Create a mock source database file
      final sourcePath = '${tempDir.path}/brain_plan.db';
      await File(sourcePath).writeAsString('test database');

      // Act
      await DatabaseExportService.copyDatabaseFile(
        sourcePath: sourcePath,
        destinationPath: exportPath,
      );

      // Assert
      expect(File(exportPath).existsSync(), isTrue);

      // Clean up
      await File(exportPath).delete();
    });

    test('should calculate correct database file size', () async {
      // Arrange
      final testFilePath = '${tempDir.path}/test.db';
      final testFile = File(testFilePath);
      final testContent = 'x' * 1024; // 1 KB
      await testFile.writeAsString(testContent);

      // Act
      final fileSize = await DatabaseExportService.getDatabaseFileSize(testFilePath);

      // Assert
      expect(fileSize, equals(1024));
    });

    test('should format file size in human readable format', () {
      // Test bytes
      expect(DatabaseExportService.formatFileSize(500), equals('500 B'));

      // Test kilobytes
      expect(DatabaseExportService.formatFileSize(1024), equals('1.0 KB'));
      expect(DatabaseExportService.formatFileSize(2560), equals('2.5 KB'));

      // Test megabytes
      expect(DatabaseExportService.formatFileSize(1048576), equals('1.0 MB'));
      expect(DatabaseExportService.formatFileSize(5242880), equals('5.0 MB'));

      // Test gigabytes
      expect(DatabaseExportService.formatFileSize(1073741824), equals('1.0 GB'));
    });

    test('should handle zero file size', () {
      expect(DatabaseExportService.formatFileSize(0), equals('0 B'));
    });

    test('should validate database file format', () {
      // Valid database files
      expect(DatabaseExportService.isValidDatabaseFile('backup.db'), isTrue);
      expect(DatabaseExportService.isValidDatabaseFile('brain_plan.db'), isTrue);
      expect(DatabaseExportService.isValidDatabaseFile('test_123.db'), isTrue);

      // Invalid database files
      expect(DatabaseExportService.isValidDatabaseFile('backup.txt'), isFalse);
      expect(DatabaseExportService.isValidDatabaseFile('backup.json'), isFalse);
      expect(DatabaseExportService.isValidDatabaseFile('backup'), isFalse);
    });

    test('should import database from file path', () async {
      // Arrange
      final sourcePath = '${tempDir.path}/import_source.db';
      final sourceFile = File(sourcePath);
      await sourceFile.writeAsString('imported database content');

      final currentDbPath = await DatabaseExportService.getDatabasePath();
      // Create current database file for backup
      await File(currentDbPath).create(recursive: true);
      await File(currentDbPath).writeAsString('current database');

      // Act
      await DatabaseExportService.importDatabase(
        database: database,
        importPath: sourcePath,
      );

      // Assert
      final importedFile = File(currentDbPath);
      expect(importedFile.existsSync(), isTrue);
      expect(await importedFile.readAsString(), contains('imported database content'));

      // Cleanup
      await importedFile.delete();

      // Clean up backup files
      final dbFolder = await getApplicationDocumentsDirectory();
      final backupFiles = Directory(dbFolder.path)
          .listSync()
          .where((f) => f.path.contains('backup_before_import_'));
      for (var file in backupFiles) {
        await file.delete();
      }
    });

    test('should throw exception when importing non-existent file', () async {
      // Arrange
      final nonExistentPath = '${tempDir.path}/nonexistent.db';

      // Act & Assert
      expect(
        () => DatabaseExportService.importDatabase(
          database: database,
          importPath: nonExistentPath,
        ),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('should throw exception when importing invalid file format', () async {
      // Arrange
      final invalidPath = '${tempDir.path}/invalid.txt';
      await File(invalidPath).writeAsString('not a database');

      // Act & Assert
      expect(
        () => DatabaseExportService.importDatabase(
          database: database,
          importPath: invalidPath,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should create backup before importing', () async {
      // Arrange
      final sourcePath = '${tempDir.path}/import_source.db';
      await File(sourcePath).writeAsString('new database');

      final currentDbPath = await DatabaseExportService.getDatabasePath();
      await File(currentDbPath).create(recursive: true);
      await File(currentDbPath).writeAsString('old database');

      // Act
      final backupPath = await DatabaseExportService.createBackupBeforeImport();

      // Assert
      expect(backupPath, isNotNull);
      expect(File(backupPath).existsSync(), isTrue);
      expect(backupPath, contains('backup_before_import_'));

      // Cleanup
      await File(currentDbPath).delete();
      await File(backupPath).delete();
    });

    test('should restore from backup if import fails', () async {
      // Arrange
      final currentDbPath = await DatabaseExportService.getDatabasePath();
      await File(currentDbPath).create(recursive: true);
      await File(currentDbPath).writeAsString('original database');

      final backupPath = await DatabaseExportService.createBackupBeforeImport();

      // Simulate failed import by deleting current db
      await File(currentDbPath).delete();

      // Act
      await DatabaseExportService.restoreFromBackup(backupPath);

      // Assert
      expect(File(currentDbPath).existsSync(), isTrue);
      expect(await File(currentDbPath).readAsString(), equals('original database'));

      // Cleanup
      await File(currentDbPath).delete();
      await File(backupPath).delete();
    });
  });
}
