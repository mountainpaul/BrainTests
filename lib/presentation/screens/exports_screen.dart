import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/csv_export_service.dart';
import '../../core/services/database_export_service.dart';
import '../../core/services/json_import_service.dart';
import '../../core/services/pdf_service.dart';
import '../providers/database_provider.dart';
import '../providers/repository_providers.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';

class ExportsScreen extends ConsumerStatefulWidget {
  const ExportsScreen({super.key});

  @override
  ConsumerState<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends ConsumerState<ExportsScreen> {
  bool _isExporting = false;

  Future<void> _exportData(String format) async {
    setState(() {
      _isExporting = true;
    });

    try {
      String? exportPath;

      switch (format.toLowerCase()) {
        case 'database':
          await _exportDatabase();
          break;

        case 'pdf':
          final assessmentRepo = ref.read(assessmentRepositoryProvider);
          final cambridgeRepo = ref.read(cambridgeAssessmentRepositoryProvider);
          final exerciseRepo = ref.read(cognitiveExerciseRepositoryProvider);

          final assessments = await assessmentRepo.getAllAssessments();
          final cambridgeResults = await cambridgeRepo.getAllAssessments();
          final exercises = await exerciseRepo.getAllExercises();

          await PDFService.generateAndShareReport(
            assessments: assessments,
            cambridgeResults: cambridgeResults,
            exercises: exercises,
          );
          break;

        case 'csv':
          final assessmentRepo = ref.read(assessmentRepositoryProvider);
          final moodRepo = ref.read(moodEntryRepositoryProvider);
          final exerciseRepo = ref.read(cognitiveExerciseRepositoryProvider);

          final assessments = await assessmentRepo.getAllAssessments();
          final moodEntries = await moodRepo.getAllMoodEntries();
          final exercises = await exerciseRepo.getAllExercises();

          exportPath = await CSVExportService.exportAllDataToCSV(
            assessments: assessments,
            moodEntries: moodEntries,
            exercises: exercises,
          );
          break;

        case 'json':
          final assessmentRepo = ref.read(assessmentRepositoryProvider);
          final moodRepo = ref.read(moodEntryRepositoryProvider);
          final exerciseRepo = ref.read(cognitiveExerciseRepositoryProvider);

          final assessments = await assessmentRepo.getAllAssessments();
          final moodEntries = await moodRepo.getAllMoodEntries();
          final exercises = await exerciseRepo.getAllExercises();

          await _exportAsJSON(assessments, moodEntries, exercises);
          break;
      }

      if (!mounted) return;

      setState(() {
        _isExporting = false;
      });

      if (format.toLowerCase() == 'database') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database backup opened for sharing'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (format.toLowerCase() == 'pdf') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF report opened for sharing'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (format.toLowerCase() == 'json') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('JSON export opened for sharing'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$format files exported to:\n$exportPath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isExporting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportDatabase() async {
    final database = ref.read(databaseProvider);
    await DatabaseExportService.exportAndShareDatabase(database: database);
  }

  Future<void> _importDatabase() async {
    // Show confirmation dialog first
    final confirmed = await _showImportConfirmationDialog();
    if (!confirmed || !mounted) return;

    setState(() {
      _isExporting = true; // Reuse loading state
    });

    try {
      // Pick database file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
        dialogTitle: 'Select Database Backup',
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isExporting = false;
        });
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('Unable to access selected file');
      }

      // Import the database
      final database = ref.read(databaseProvider);
      final importResult = await DatabaseExportService.importAndValidateDatabase(
        database: database,
        importPath: filePath,
      );

      if (!mounted) return;

      setState(() {
        _isExporting = false;
      });

      if (importResult['success'] == true) {
        // Show success and restart prompt
        await _showRestartDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importResult['message'] as String),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isExporting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import database: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<bool> _showImportConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Database?'),
        content: const Text(
          'This will replace your current data with the data from the backup file.\n\n'
          'A backup of your current database will be created automatically.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _showRestartDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Import Successful'),
        content: const Text(
          'Database imported successfully!\n\n'
          'IMPORTANT: You MUST completely close and restart the app (not just minimize) for changes to take effect.\n\n'
          'Close the app from the Recent Apps menu, then reopen it.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromJSON() async {
    // Show import options dialog
    final option = await _showJSONImportOptionsDialog();
    if (option == null || !mounted) return;

    setState(() {
      _isExporting = true;
    });

    try {
      // Pick JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select JSON Export File',
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isExporting = false;
        });
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('Unable to access selected file');
      }

      // Import from JSON
      final database = ref.read(databaseProvider);
      final importResult = await JsonImportService.importFromJson(
        database: database,
        jsonPath: filePath,
        clearExisting: option == 'replace',
      );

      if (!mounted) return;

      setState(() {
        _isExporting = false;
      });

      if (importResult['success'] == true) {
        final totalImported = importResult['total_imported'] as int;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully imported $totalImported items:\n'
              '• ${importResult['assessments_imported']} assessments\n'
              '• ${importResult['mood_entries_imported']} mood entries\n'
              '• ${importResult['exercises_imported']} exercises',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import: ${importResult['error']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isExporting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import JSON: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<String?> _showJSONImportOptionsDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JSON Import Options'),
        content: const Text(
          'How would you like to import the JSON data?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('merge'),
            child: const Text('Merge with existing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('replace'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Replace all data'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAsJSON(List<dynamic> assessments, List<dynamic> moodEntries, List<dynamic> exercises) async {
    final data = {
      'export_date': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
      'assessments': assessments.map((a) => {
        'id': a.id,
        'type': a.type.toString(),
        'score': a.score,
        'max_score': a.maxScore,
        'percentage': a.percentage,
        'completed_at': a.completedAt.toIso8601String(),
        'created_at': a.createdAt.toIso8601String(),
        'notes': a.notes,
      }).toList(),
      'mood_entries': moodEntries.map((m) => {
        'id': m.id,
        'mood': m.mood.toString(),
        'energy_level': m.energyLevel,
        'stress_level': m.stressLevel,
        'sleep_quality': m.sleepQuality,
        'overall_wellness': m.overallWellness,
        'entry_date': m.entryDate.toIso8601String(),
        'notes': m.notes,
      }).toList(),
      'exercises': exercises.map((e) => {
        'id': e.id,
        'name': e.name,
        'difficulty': e.difficulty.toString(),
        'score': e.score,
        'max_score': e.maxScore,
        'time_spent_seconds': e.timeSpentSeconds,
        'completed_at': e.completedAt?.toIso8601String(),
        'created_at': e.createdAt.toIso8601String(),
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Save to temporary file for sharing
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/brain_plan_export_$timestamp.json');
    await file.writeAsString(jsonString);

    // Share the JSON file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Brain Plan Data Export (JSON)',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Your Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a format to export your cognitive assessment data, brain exercise results, and progress reports.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Database Export (Complete Backup)
            CustomCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storage, color: Colors.purple),
                ),
                title: const Text('Export Database'),
                subtitle: const Text('Complete backup of all your data'),
                trailing: _isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _isExporting ? null : () => _exportData('Database'),
              ),
            ),
            const SizedBox(height: 12),

            // Database Import
            CustomCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.upload_file, color: Colors.orange),
                ),
                title: const Text('Import Database'),
                subtitle: const Text('Restore from a backup file'),
                trailing: _isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _isExporting ? null : _importDatabase,
              ),
            ),
            const SizedBox(height: 12),

            // JSON Import
            CustomCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.input, color: Colors.teal),
                ),
                title: const Text('Import from JSON'),
                subtitle: const Text('Restore data from JSON export'),
                trailing: _isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _isExporting ? null : _importFromJSON,
              ),
            ),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),

            Text(
              'Export Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // PDF Export
            CustomCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                ),
                title: const Text('Export as PDF'),
                subtitle: const Text('Complete report with charts and analysis'),
                trailing: _isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _isExporting ? null : () => _exportData('PDF'),
              ),
            ),
            const SizedBox(height: 12),

            // CSV Export
            CustomCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.table_chart, color: Colors.green),
                ),
                title: const Text('Export as CSV'),
                subtitle: const Text('Raw data for spreadsheet analysis'),
                trailing: _isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _isExporting ? null : () => _exportData('CSV'),
              ),
            ),
            const SizedBox(height: 12),

            // JSON Export
            CustomCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.code, color: Colors.blue),
                ),
                title: const Text('Export as JSON'),
                subtitle: const Text('Structured data for developers'),
                trailing: _isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _isExporting ? null : () => _exportData('JSON'),
              ),
            ),
            const SizedBox(height: 24),

            // Export Info Card
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Export Information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Database Export: Complete backup of your entire database (recommended for backups)\n'
                      '• Database Import: Restore from a backup file (automatically creates backup before importing)\n'
                      '• JSON Import: Restore specific data (merge or replace existing data)\n'
                      '• PDF format: Best for sharing with healthcare providers\n'
                      '• CSV format: Ideal for personal analysis in spreadsheet apps\n'
                      '• JSON format: Structured data for developers and cross-platform sharing\n'
                      '• All your data remains private and stored locally on your device',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}
