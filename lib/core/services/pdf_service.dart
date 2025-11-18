import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/datasources/database.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/entities/cognitive_exercise.dart';
import '../../domain/entities/cambridge_assessment.dart' show CambridgeAssessmentResult;

class PDFService {
  static Future<void> generateAndShareReport({
    required List<Assessment> assessments,
    required List<CambridgeAssessmentResult> cambridgeResults,
    required List<CognitiveExercise> exercises,
  }) async {
    final pdf = pw.Document();

    // Add cover page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Brain Plan Report',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Cognitive Health Summary',
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Add assessment summary page
    if (assessments.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Assessment Summary',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                _buildAssessmentTable(assessments),
                pw.SizedBox(height: 20),
                _buildAssessmentAverages(assessments),
              ],
            );
          },
        ),
      );
    }

    // Add Cambridge assessments page
    if (cambridgeResults.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Advanced Cognitive Tests',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                _buildCambridgeTable(cambridgeResults),
              ],
            );
          },
        ),
      );
    }

    // Add exercise summary page
    if (exercises.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Brain Exercise Summary',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                _buildExerciseTable(exercises),
              ],
            );
          },
        ),
      );
    }

    // Save and share the PDF
    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'brain_plan_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static Future<void> saveReportToDevice({
    required List<Assessment> assessments,
    required List<CambridgeAssessmentResult> cambridgeResults,
    required List<CognitiveExercise> exercises,
  }) async {
    final pdf = pw.Document();

    // Add cover page (same as above)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Brain Plan Report',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Cognitive Health Summary',
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Add content pages (same as above)
    if (assessments.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Assessment Summary',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                _buildAssessmentTable(assessments),
                pw.SizedBox(height: 20),
                _buildAssessmentAverages(assessments),
              ],
            );
          },
        ),
      );
    }

    // Save to device
    final Uint8List bytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/brain_plan_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
  }

  static pw.Widget _buildAssessmentTable(List<Assessment> assessments) {
    return pw.Table.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      data: [
        ['Date', 'Type', 'Score', 'Percentage'],
        ...assessments.take(10).map((assessment) => [
          '${assessment.completedAt.day}/${assessment.completedAt.month}/${assessment.completedAt.year}',
          _getAssessmentTypeString(assessment.type),
          '${assessment.score}/${assessment.maxScore}',
          '${assessment.percentage.toStringAsFixed(1)}%',
        ]),
      ],
    );
  }

  static pw.Widget _buildAssessmentAverages(List<Assessment> assessments) {
    final Map<AssessmentType, List<Assessment>> groupedAssessments = {};
    
    for (final assessment in assessments) {
      if (!groupedAssessments.containsKey(assessment.type)) {
        groupedAssessments[assessment.type] = [];
      }
      groupedAssessments[assessment.type]!.add(assessment);
    }

    final Map<AssessmentType, double> averages = {};
    groupedAssessments.forEach((type, assessmentList) {
      final totalPercentage = assessmentList
          .map((a) => a.percentage)
          .reduce((a, b) => a + b);
      averages[type] = totalPercentage / assessmentList.length;
    });

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Average Scores by Type',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          data: [
            ['Assessment Type', 'Average Score'],
            ...averages.entries.map((entry) => [
              _getAssessmentTypeString(entry.key),
              '${entry.value.toStringAsFixed(1)}%',
            ]),
          ],
        ),
      ],
    );
  }

  // Mood tracking removed - stub methods for compatibility
  static pw.Widget _buildMoodTable(List<dynamic> moodEntries) {
    return pw.SizedBox.shrink();
  }

  static pw.Widget _buildMoodAverages(List<dynamic> moodEntries) {
    return pw.SizedBox.shrink();
  }

  static pw.Widget _buildExerciseTable(List<CognitiveExercise> exercises) {
    final completedExercises = exercises.where((e) => e.isCompleted).toList();
    
    return pw.Table.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      data: [
        ['Date', 'Exercise', 'Difficulty', 'Score', 'Time'],
        ...completedExercises.take(10).map((exercise) => [
          exercise.completedAt != null
              ? '${exercise.completedAt!.day}/${exercise.completedAt!.month}/${exercise.completedAt!.year}'
              : 'N/A',
          exercise.name,
          _getDifficultyString(exercise.difficulty),
          exercise.score != null ? '${exercise.score}/${exercise.maxScore}' : 'N/A',
          exercise.formattedTime,
        ]),
      ],
    );
  }

  static String _getAssessmentTypeString(AssessmentType type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return 'Memory Recall';
      case AssessmentType.attentionFocus:
        return 'Attention Focus';
      case AssessmentType.executiveFunction:
        return 'Executive Function';
      case AssessmentType.languageSkills:
        return 'Language Skills';
      case AssessmentType.visuospatialSkills:
        return 'Visuospatial Skills';
      case AssessmentType.processingSpeed:
        return 'Processing Speed';
    }
  }

  static String _getMoodLevelString(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return 'Excellent';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.neutral:
        return 'Neutral';
      case MoodLevel.low:
        return 'Low';
      case MoodLevel.veryLow:
        return 'Very Low';
    }
  }

  static String _getDifficultyString(difficulty) {
    switch (difficulty.toString()) {
      case 'ExerciseDifficulty.easy':
        return 'Easy';
      case 'ExerciseDifficulty.medium':
        return 'Medium';
      case 'ExerciseDifficulty.hard':
        return 'Hard';
      case 'ExerciseDifficulty.expert':
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  static pw.Widget _buildCambridgeTable(List<CambridgeAssessmentResult> results) {
    return pw.Table.fromTextArray(
      headers: ['Test', 'Accuracy', 'Errors', 'Time', 'Norm Score', 'Date'],
      data: results.map((result) {
        return [
          result.testType.name.toUpperCase(),
          '${result.accuracy.toStringAsFixed(1)}%',
          '${result.errorCount}',
          '${result.durationSeconds}s',
          result.normScore.toStringAsFixed(1),
          '${result.completedAt.month}/${result.completedAt.day}/${result.completedAt.year}',
        ];
      }).toList(),
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }
}