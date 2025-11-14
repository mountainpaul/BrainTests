import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Architecture tests to enforce clean architecture layer boundaries
/// Ensures proper dependency flow: Presentation → Domain → Data
void main() {
  group('Architecture Layer Boundary Tests', () {
    test('presentation layer must not import from data layer directly', () {
      // Arrange
      final presentationDir = Directory('lib/presentation');
      final violations = <Map<String, String>>[];

      // Act
      if (presentationDir.existsSync()) {
        final files = presentationDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final contents = file.readAsStringSync();
          final relativePath = p.relative(file.path, from: 'lib');

          // Check for imports from data layer (except repositories via providers)
          final badImports = _findBadDataImports(contents);

          if (badImports.isNotEmpty) {
            violations.add({
              'file': relativePath,
              'imports': badImports.join(', '),
            });
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Presentation layer must not import data layer directly.\n'
            'Use domain layer and providers instead.\n'
            'Violations:\n${violations.map((v) => '${v['file']}: imports ${v['imports']}').join('\n')}',
      );
    });

    test('domain layer must not import from presentation or data layers', () {
      // Arrange
      final domainDir = Directory('lib/domain');
      final violations = <String>[];

      // Act
      if (domainDir.existsSync()) {
        final files = domainDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final contents = file.readAsStringSync();

          // Check for imports from presentation or data
          if (_importsPresentationLayer(contents) || _importsDataLayer(contents)) {
            violations.add(p.relative(file.path, from: 'lib'));
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Domain layer must be independent (no imports from presentation/data).\n'
            'Violations in: ${violations.join(', ')}',
      );
    });

    test('data layer must only import from domain layer', () {
      // Arrange
      final dataDir = Directory('lib/data');
      final violations = <String>[];

      // Act
      if (dataDir.existsSync()) {
        final files = dataDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final contents = file.readAsStringSync();

          // Check for imports from presentation
          if (_importsPresentationLayer(contents)) {
            violations.add(p.relative(file.path, from: 'lib'));
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Data layer must not import from presentation layer.\n'
            'Violations in: ${violations.join(', ')}',
      );
    });

    test('repositories must only use domain entities not data models', () {
      // Arrange
      final repoDir = Directory('lib/data/repositories');
      final violations = <Map<String, String>>[];

      // Act
      if (repoDir.existsSync()) {
        final files = repoDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.mocks.dart'));

        for (final file in files) {
          final contents = file.readAsStringSync();

          // Check method signatures return domain entities
          final issues = _checkRepositoryReturnTypes(contents);

          if (issues.isNotEmpty) {
            violations.add({
              'file': p.basename(file.path),
              'issues': issues.join('; '),
            });
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Repositories must use domain entities in public interfaces.\n'
            'Violations:\n${violations.map((v) => '${v['file']}: ${v['issues']}').join('\n')}',
      );
    });

    test('screens must use providers not direct repository instances', () {
      // Arrange
      final screensDir = Directory('lib/presentation/screens');
      final violations = <String>[];

      // Act
      if (screensDir.existsSync()) {
        final files = screensDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final contents = file.readAsStringSync();

          // Check for direct repository instantiation
          if (_hasDirectRepositoryInstantiation(contents)) {
            violations.add(p.basename(file.path));
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Screens must use providers to access repositories (ref.read/ref.watch).\n'
            'Do not instantiate repositories directly.\n'
            'Violations in: ${violations.join(', ')}',
      );
    });

    test('core services must not depend on presentation layer', () {
      // Arrange
      final coreDir = Directory('lib/core');
      final violations = <String>[];

      // Act
      if (coreDir.existsSync()) {
        final files = coreDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final contents = file.readAsStringSync();

          if (_importsPresentationLayer(contents)) {
            violations.add(p.relative(file.path, from: 'lib'));
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Core services must be independent of presentation layer.\n'
            'Violations in: ${violations.join(', ')}',
      );
    });

    test('backup service must be triggered by data layer not presentation', () {
      // Arrange
      final presentationDir = Directory('lib/presentation/screens');
      final violations = <String>[];

      // Act
      if (presentationDir.existsSync()) {
        final files = presentationDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final contents = file.readAsStringSync();

          // Check for direct backup service calls
          if (contents.contains('AutoBackupService.trigger') ||
              contents.contains('GoogleDriveBackupService.upload')) {
            violations.add(p.basename(file.path));
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Backup triggers should be in repositories, not screens.\n'
            'Violations in: ${violations.join(', ')}',
      );
    });

    test('all files must follow directory structure conventions', () {
      // Verify proper organization
      final requiredDirs = [
        'lib/core',
        'lib/data/datasources',
        'lib/data/repositories',
        'lib/domain/entities',
        'lib/domain/repositories',
        'lib/presentation/providers',
        'lib/presentation/screens',
        'lib/presentation/widgets',
      ];

      final violations = <String>[];

      for (final dirPath in requiredDirs) {
        if (!Directory(dirPath).existsSync()) {
          violations.add(dirPath);
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Required architecture directories missing: ${violations.join(', ')}',
      );
    });
  });
}

/// Find bad imports from data layer
List<String> _findBadDataImports(String contents) {
  final badImports = <String>[];

  // These are NOT allowed in presentation
  final forbiddenPatterns = [
    "import '../../data/datasources/",
    "import '../../data/models/",
    "import '../data/datasources/",
    "import '../data/models/",
  ];

  // These ARE allowed (repositories via interfaces)
  final allowedPatterns = [
    "import '../../data/repositories/",
    "import '../data/repositories/",
  ];

  final lines = contents.split('\n');
  for (final line in lines) {
    if (line.trim().startsWith('import')) {
      // Check if it's a forbidden import
      if (forbiddenPatterns.any((pattern) => line.contains(pattern))) {
        // Make sure it's not an allowed one
        if (!allowedPatterns.any((pattern) => line.contains(pattern))) {
          badImports.add(line.trim());
        }
      }
    }
  }

  return badImports;
}

/// Check if content imports presentation layer
bool _importsPresentationLayer(String contents) {
  final patterns = [
    "import '../presentation/",
    "import '../../presentation/",
    "import '../../../presentation/",
  ];

  return patterns.any((pattern) => contents.contains(pattern));
}

/// Check if content imports data layer
bool _importsDataLayer(String contents) {
  final patterns = [
    "import '../data/",
    "import '../../data/",
  ];

  return patterns.any((pattern) => contents.contains(pattern));
}

/// Check repository return types
List<String> _checkRepositoryReturnTypes(String contents) {
  final issues = <String>[];

  // Look for methods that return data models instead of entities
  final dataModelPatterns = [
    'Future<List<AssessmentTableData>>',
    'Future<ExerciseTableData>',
    'Future<MoodEntryTableData>',
    'Stream<AssessmentTableData>',
  ];

  for (final pattern in dataModelPatterns) {
    if (contents.contains(pattern)) {
      issues.add('Returns data model: $pattern');
    }
  }

  return issues;
}

/// Check for direct repository instantiation
bool _hasDirectRepositoryInstantiation(String contents) {
  final patterns = [
    'RepositoryImpl(',
    'AssessmentRepositoryImpl(',
    'CognitiveExerciseRepositoryImpl(',
    'MoodEntryRepositoryImpl(',
    '= AssessmentRepository(',
    '= CognitiveExerciseRepository(',
  ];

  return patterns.any((pattern) => contents.contains(pattern));
}
