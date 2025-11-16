import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:brain_tests/core/services/json_import_service.dart';
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
    database = AppDatabase.memory();
    tempDir = await Directory.systemTemp.createTemp('json_import_test_');
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  tearDown(() async {
    await database.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('JsonImportService', () {
    test('should validate JSON file format', () {
      expect(JsonImportService.isValidJsonFile('export.json'), isTrue);
      expect(JsonImportService.isValidJsonFile('backup.JSON'), isTrue);

      expect(JsonImportService.isValidJsonFile('export.txt'), isFalse);
      expect(JsonImportService.isValidJsonFile('export.db'), isFalse);
    });

    test('should parse valid JSON file', () async {
      // Arrange
      final jsonPath = '${tempDir.path}/test_export.json';
      final jsonData = {
        'export_date': '2025-01-01T00:00:00.000',
        'app_version': '1.0.0',
        'assessments': [],
        'mood_entries': [],
        'exercises': [],
      };
      await File(jsonPath).writeAsString(jsonEncode(jsonData));

      // Act
      final result = await JsonImportService.parseJsonFile(jsonPath);

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('assessments'), isTrue);
      expect(result.containsKey('mood_entries'), isTrue);
      expect(result.containsKey('exercises'), isTrue);
    });

    test('should throw exception for non-existent file', () async {
      // Arrange
      final nonExistentPath = '${tempDir.path}/nonexistent.json';

      // Act & Assert
      expect(
        () => JsonImportService.parseJsonFile(nonExistentPath),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('should throw exception for invalid JSON format', () async {
      // Arrange
      final jsonPath = '${tempDir.path}/invalid.json';
      await File(jsonPath).writeAsString('not valid json {');

      // Act & Assert
      expect(
        () => JsonImportService.parseJsonFile(jsonPath),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw exception for JSON without required fields', () async {
      // Arrange
      final jsonPath = '${tempDir.path}/empty.json';
      await File(jsonPath).writeAsString('{"foo": "bar"}');

      // Act & Assert
      expect(
        () => JsonImportService.parseJsonFile(jsonPath),
        throwsA(isA<FormatException>()),
      );
    });

    test('should import assessments from JSON', () async {
      // Arrange
      final assessmentsData = [
        {
          'type': 'AssessmentType.memoryRecall',
          'score': 8,
          'max_score': 10,
          'completed_at': '2025-01-01T12:00:00.000',
          'notes': 'Test assessment',
        },
      ];

      // Act
      final imported = await JsonImportService.importAssessments(
        database,
        assessmentsData,
      );

      // Assert
      expect(imported, equals(1));

      final assessments = await database.select(database.assessmentTable).get();
      expect(assessments.length, equals(1));
      expect(assessments.first.score, equals(8));
      expect(assessments.first.maxScore, equals(10));
    });

    test('should import mood entries from JSON', () async {
      // Arrange
      final moodEntriesData = [
        {
          'mood': 'MoodLevel.good',
          'energy_level': 7,
          'stress_level': 3,
          'sleep_quality': 8,
          'entry_date': '2025-01-01T12:00:00.000',
          'notes': 'Feeling great',
        },
      ];

      // Act
      final imported = await JsonImportService.importMoodEntries(
        database,
        moodEntriesData,
      );

      // Assert
      expect(imported, equals(1));

      final moods = await database.select(database.moodEntryTable).get();
      expect(moods.length, equals(1));
      expect(moods.first.energyLevel, equals(7));
      expect(moods.first.stressLevel, equals(3));
    });

    test('should import exercises from JSON', () async {
      // Arrange
      final exercisesData = [
        {
          'name': 'Memory Game',
          'difficulty': 'ExerciseDifficulty.medium',
          'score': 85,
          'max_score': 100,
          'time_spent_seconds': 120,
          'completed_at': '2025-01-01T12:00:00.000',
        },
      ];

      // Act
      final imported = await JsonImportService.importExercises(
        database,
        exercisesData,
      );

      // Assert
      expect(imported, equals(1));

      final exercises = await database.select(database.cognitiveExerciseTable).get();
      expect(exercises.length, equals(1));
      expect(exercises.first.name, equals('Memory Game'));
      expect(exercises.first.score, equals(85));
    });

    test('should import complete JSON file', () async {
      // Arrange
      final jsonPath = '${tempDir.path}/complete_export.json';
      final jsonData = {
        'export_date': '2025-01-01T00:00:00.000',
        'app_version': '1.0.0',
        'assessments': [
          {
            'type': 'AssessmentType.memoryRecall',
            'score': 8,
            'max_score': 10,
            'completed_at': '2025-01-01T12:00:00.000',
            'notes': null,
          },
        ],
        'mood_entries': [
          {
            'mood': 'MoodLevel.good',
            'energy_level': 7,
            'stress_level': 3,
            'sleep_quality': 8,
            'entry_date': '2025-01-01T12:00:00.000',
            'notes': null,
          },
        ],
        'exercises': [
          {
            'name': 'Test Exercise',
            'difficulty': 'ExerciseDifficulty.easy',
            'score': 100,
            'max_score': 100,
            'time_spent_seconds': 60,
            'completed_at': '2025-01-01T12:00:00.000',
          },
        ],
      };
      await File(jsonPath).writeAsString(jsonEncode(jsonData));

      // Act
      final result = await JsonImportService.importFromJson(
        database: database,
        jsonPath: jsonPath,
      );

      // Assert
      expect(result['success'], isTrue);
      expect(result['assessments_imported'], equals(1));
      expect(result['mood_entries_imported'], equals(1));
      expect(result['exercises_imported'], equals(1));
      expect(result['total_imported'], equals(3));
    });

    test('should clear existing data when requested', () async {
      // Arrange
      // Add some existing data
      await database.into(database.assessmentTable).insert(
        AssessmentTableCompanion.insert(
          type: AssessmentType.memoryRecall,
          score: 5,
          maxScore: 10,
          completedAt: DateTime.now(),
        ),
      );

      final jsonPath = '${tempDir.path}/new_data.json';
      final jsonData = {
        'assessments': [
          {
            'type': 'AssessmentType.attentionFocus',
            'score': 9,
            'max_score': 10,
            'completed_at': '2025-01-01T12:00:00.000',
            'notes': null,
          },
        ],
        'mood_entries': [],
        'exercises': [],
      };
      await File(jsonPath).writeAsString(jsonEncode(jsonData));

      // Act
      final result = await JsonImportService.importFromJson(
        database: database,
        jsonPath: jsonPath,
        clearExisting: true,
      );

      // Assert
      expect(result['success'], isTrue);

      final assessments = await database.select(database.assessmentTable).get();
      expect(assessments.length, equals(1));
      expect(assessments.first.type, equals(AssessmentType.attentionFocus));
    });

    test('should handle import errors gracefully', () async {
      // Arrange
      final jsonPath = '${tempDir.path}/invalid_data.json';
      final jsonData = {
        'assessments': [
          {
            'type': 'InvalidType',
            'score': 8,
            'max_score': 10,
            'completed_at': '2025-01-01T12:00:00.000',
          },
        ],
        'mood_entries': [],
        'exercises': [],
      };
      await File(jsonPath).writeAsString(jsonEncode(jsonData));

      // Act
      final result = await JsonImportService.importFromJson(
        database: database,
        jsonPath: jsonPath,
      );

      // Assert - should still succeed but with 0 imports
      expect(result['success'], isTrue);
      expect(result['assessments_imported'], equals(0));
    });
  });
}
