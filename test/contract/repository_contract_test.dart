import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Contract tests to verify all screens use repositories correctly
/// These tests enforce architectural boundaries and prevent direct database access
void main() {
  group('Repository Usage Contract Tests', () {
    test('presentation screens must not directly access database', () {
      // Arrange
      final screensDir = Directory('lib/presentation/screens');
      final violations = <String>[];

      // Act - Scan all screen files
      if (screensDir.existsSync()) {
        final files = screensDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final contents = file.readAsStringSync();

          // Check for direct database access patterns
          if (_containsDirectDatabaseAccess(contents)) {
            violations.add(file.path);
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Screens must use repositories, not direct database access.\n'
            'Violations found in:\n${violations.join('\n')}',
      );
    });

    test('screens must import repository providers not database', () {
      // Arrange
      final screensDir = Directory('lib/presentation/screens');
      final violations = <Map<String, String>>[];

      // Act
      if (screensDir.existsSync()) {
        final files = screensDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final contents = file.readAsStringSync();
          final fileName = p.basename(file.path);

          // Check if imports database but not repository_providers
          final importsDatabase = contents.contains("import '../../data/datasources/database.dart'") ||
                                 contents.contains('import \'../../data/datasources/database.dart\'');
          final importsRepoProviders = contents.contains('repository_providers.dart');
          final importsRepoProvider = contents.contains('assessment_provider.dart') ||
                                     contents.contains('cognitive_exercise_provider.dart') ||
                                     contents.contains('mood_entry_provider.dart');

          // Skip if file is just a widget or doesn't deal with data
          final isDataScreen = contents.contains('Assessment') ||
                             contents.contains('Exercise') ||
                             contents.contains('MoodEntry') ||
                             contents.contains('Reminder');

          if (importsDatabase && !importsRepoProviders && !importsRepoProvider && isDataScreen) {
            violations.add({
              'file': fileName,
              'issue': 'Imports database directly without repository provider',
            });
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Screens that work with data must import repository providers.\n'
            'Violations:\n${violations.map((v) => '${v['file']}: ${v['issue']}').join('\n')}',
      );
    });

    test('all assessment screens must use AssessmentRepository', () {
      // Arrange
      final screensDir = Directory('lib/presentation/screens');
      final assessmentScreens = <String>[];
      final violations = <String>[];

      // Act - Find all assessment-related screens
      if (screensDir.existsSync()) {
        final files = screensDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final contents = file.readAsStringSync();
          final fileName = p.basename(file.path);

          // Check if it's an assessment screen
          if (_isAssessmentScreen(fileName, contents)) {
            assessmentScreens.add(fileName);

            // Verify it uses the repository
            if (!_usesAssessmentRepository(contents)) {
              violations.add(fileName);
            }
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'All assessment screens must use AssessmentRepository.\n'
            'Found ${assessmentScreens.length} assessment screens.\n'
            'Violations in: ${violations.join(', ')}',
      );
    });

    test('exercise screens must use CognitiveExerciseRepository', () {
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
          final fileName = p.basename(file.path);

          // Check if it's an exercise screen
          if (_isExerciseScreen(fileName, contents)) {
            // Verify it uses the repository if it saves data
            if (_savesExerciseData(contents) && !_usesExerciseRepository(contents)) {
              violations.add(fileName);
            }
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Exercise screens must use CognitiveExerciseRepository.\n'
            'Violations in: ${violations.join(', ')}',
      );
    });

    test('screens must not use Drift Companion classes directly', () {
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

          // Check for Drift Companion usage (sign of direct DB access)
          if (contents.contains('Companion.insert') ||
              contents.contains('TableCompanion')) {
            violations.add(p.basename(file.path));
          }
        }
      }

      // Assert
      expect(
        violations,
        isEmpty,
        reason: 'Screens must use domain entities, not Drift Companions.\n'
            'Use Assessment/Exercise/MoodEntry entities instead.\n'
            'Violations in: ${violations.join(', ')}',
      );
    });
  });
}

/// Check if contents contain direct database access patterns
bool _containsDirectDatabaseAccess(String contents) {
  final patterns = [
    'database.into(',
    'database.select(',
    'database.update(',
    'database.delete(',
    '.into(database.',
    '.select(database.',
  ];

  return patterns.any((pattern) => contents.contains(pattern));
}

/// Check if file is an assessment screen
bool _isAssessmentScreen(String fileName, String contents) {
  final assessmentKeywords = [
    'assessment',
    'test_screen',
    'trail_making',
    'moca',
    'memory_recall',
    'attention',
  ];

  final isAssessmentFile = assessmentKeywords.any((keyword) =>
    fileName.toLowerCase().contains(keyword));

  final createsAssessment = contents.contains('AssessmentType') ||
                           contents.contains('Assessment(');

  return isAssessmentFile && createsAssessment;
}

/// Check if screen uses AssessmentRepository
bool _usesAssessmentRepository(String contents) {
  return contents.contains('assessmentRepositoryProvider') ||
         contents.contains('AssessmentRepository') ||
         contents.contains('insertAssessment') ||
         contents.contains('repository.insert');
}

/// Check if file is an exercise screen
bool _isExerciseScreen(String fileName, String contents) {
  final exerciseKeywords = [
    'exercise',
    'game',
    'puzzle',
    'memory_game',
  ];

  return exerciseKeywords.any((keyword) =>
    fileName.toLowerCase().contains(keyword)) &&
    contents.contains('Exercise');
}

/// Check if screen saves exercise data
bool _savesExerciseData(String contents) {
  return contents.contains('CognitiveExercise(') ||
         contents.contains('ExerciseType');
}

/// Check if screen uses ExerciseRepository
bool _usesExerciseRepository(String contents) {
  return contents.contains('cognitiveExerciseRepositoryProvider') ||
         contents.contains('CognitiveExerciseRepository') ||
         contents.contains('insertExercise');
}
