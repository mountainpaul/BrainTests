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

    // Add trend graphs page if we have more than a week of data
    final hasEnoughData = _hasMoreThanOneWeekOfData(assessments, cambridgeResults, exercises);
    if (hasEnoughData) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Progress Trends',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                _buildTrendCharts(assessments, cambridgeResults, exercises),
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
        ['Date', 'Type', 'Score', 'Result'],
        ...assessments.take(10).map((assessment) => [
          '${assessment.completedAt.day}/${assessment.completedAt.month}/${assessment.completedAt.year}',
          _getAssessmentTypeString(assessment.type),
          _formatAssessmentScore(assessment),
          _formatAssessmentResult(assessment),
        ]),
      ],
    );
  }

  /// Check if an assessment type is a timed test (lower score is better)
  static bool _isTimedTest(AssessmentType type) {
    return type == AssessmentType.processingSpeed ||
           type == AssessmentType.executiveFunction;
  }

  /// Format score display based on assessment type
  static String _formatAssessmentScore(Assessment assessment) {
    if (_isTimedTest(assessment.type)) {
      return '${assessment.score}s'; // Show as seconds
    }
    return '${assessment.score}/${assessment.maxScore}';
  }

  /// Format result display based on assessment type
  static String _formatAssessmentResult(Assessment assessment) {
    if (_isTimedTest(assessment.type)) {
      // For timed tests, extract errors from notes if available
      final notes = assessment.notes ?? '';
      final errorsMatch = RegExp(r'Errors: (\d+)').firstMatch(notes);
      final errors = errorsMatch != null ? errorsMatch.group(1) : '0';
      return '$errors errors';
    }
    return '${assessment.percentage.toStringAsFixed(1)}%';
  }

  static pw.Widget _buildAssessmentAverages(List<Assessment> assessments) {
    final Map<AssessmentType, List<Assessment>> groupedAssessments = {};

    for (final assessment in assessments) {
      if (!groupedAssessments.containsKey(assessment.type)) {
        groupedAssessments[assessment.type] = [];
      }
      groupedAssessments[assessment.type]!.add(assessment);
    }

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
            ['Assessment Type', 'Tests', 'Average'],
            ...groupedAssessments.entries.map((entry) {
              final type = entry.key;
              final list = entry.value;
              final count = list.length;

              if (_isTimedTest(type)) {
                // For timed tests, show average time in seconds
                final avgTime = list.map((a) => a.score).reduce((a, b) => a + b) / count;
                return [
                  _getAssessmentTypeString(type),
                  '$count',
                  '${avgTime.toStringAsFixed(1)}s',
                ];
              } else {
                // For other tests, show average percentage
                final avgPercent = list.map((a) => a.percentage).reduce((a, b) => a + b) / count;
                return [
                  _getAssessmentTypeString(type),
                  '$count',
                  '${avgPercent.toStringAsFixed(1)}%',
                ];
              }
            }),
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

  /// Check if we have more than one week of data across all sources
  static bool _hasMoreThanOneWeekOfData(
    List<Assessment> assessments,
    List<CambridgeAssessmentResult> cambridgeResults,
    List<CognitiveExercise> exercises,
  ) {
    final allDates = <DateTime>[];

    for (final a in assessments) {
      allDates.add(a.completedAt);
    }
    for (final c in cambridgeResults) {
      allDates.add(c.completedAt);
    }
    for (final e in exercises) {
      if (e.completedAt != null) {
        allDates.add(e.completedAt!);
      }
    }

    if (allDates.length < 2) return false;

    allDates.sort();
    final earliest = allDates.first;
    final latest = allDates.last;
    final daysDiff = latest.difference(earliest).inDays;

    return daysDiff >= 7;
  }

  /// Build trend charts for the PDF report
  static pw.Widget _buildTrendCharts(
    List<Assessment> assessments,
    List<CambridgeAssessmentResult> cambridgeResults,
    List<CognitiveExercise> exercises,
  ) {
    final widgets = <pw.Widget>[];

    // Assessment trends by type (non-timed tests)
    final nonTimedAssessments = assessments
        .where((a) => !_isTimedTest(a.type))
        .toList();

    if (nonTimedAssessments.length >= 2) {
      widgets.add(_buildAssessmentTrendSection(nonTimedAssessments, 'Assessment Scores Over Time'));
      widgets.add(pw.SizedBox(height: 20));
    }

    // Timed test trends (Trail Making)
    final timedAssessments = assessments
        .where((a) => _isTimedTest(a.type))
        .toList();

    if (timedAssessments.length >= 2) {
      widgets.add(_buildTimedTestTrendSection(timedAssessments, 'Timed Test Performance'));
      widgets.add(pw.SizedBox(height: 20));
    }

    // Cambridge assessment trends
    if (cambridgeResults.length >= 2) {
      widgets.add(_buildCambridgeTrendSection(cambridgeResults, 'Advanced Test Accuracy'));
      widgets.add(pw.SizedBox(height: 20));
    }

    // Exercise completion trend
    final completedExercises = exercises.where((e) => e.isCompleted && e.completedAt != null).toList();
    if (completedExercises.length >= 2) {
      widgets.add(_buildExerciseTrendSection(completedExercises, 'Brain Training Activity'));
    }

    if (widgets.isEmpty) {
      return pw.Text('Not enough data points to generate trend charts.');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: widgets,
    );
  }

  static pw.Widget _buildAssessmentTrendSection(List<Assessment> assessments, String title) {
    // Group by week and calculate weekly averages
    final weeklyData = <String, List<double>>{};

    for (final a in assessments) {
      final weekKey = '${a.completedAt.month}/${_getWeekOfMonth(a.completedAt)}';
      weeklyData.putIfAbsent(weekKey, () => []);
      weeklyData[weekKey]!.add(a.percentage);
    }

    final sortedWeeks = weeklyData.keys.toList()..sort();
    final dataRows = sortedWeeks.map((week) {
      final avg = weeklyData[week]!.reduce((a, b) => a + b) / weeklyData[week]!.length;
      return [week, '${avg.toStringAsFixed(1)}%', _buildProgressBar(avg / 100)];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          data: [
            ['Week', 'Avg Score', 'Progress'],
            ...dataRows,
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTimedTestTrendSection(List<Assessment> assessments, String title) {
    // Group by type and show trend
    final byType = <AssessmentType, List<Assessment>>{};
    for (final a in assessments) {
      byType.putIfAbsent(a.type, () => []);
      byType[a.type]!.add(a);
    }

    final rows = <List<String>>[];
    for (final entry in byType.entries) {
      final sorted = entry.value..sort((a, b) => a.completedAt.compareTo(b.completedAt));
      if (sorted.length >= 2) {
        final first = sorted.first.score;
        final last = sorted.last.score;
        final improvement = first - last; // Lower is better for timed tests
        final trend = improvement > 0 ? '↓ ${improvement}s faster' : (improvement < 0 ? '↑ ${-improvement}s slower' : '→ same');
        rows.add([
          _getAssessmentTypeString(entry.key),
          '${first}s',
          '${last}s',
          trend,
        ]);
      }
    }

    if (rows.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          data: [
            ['Test', 'First', 'Latest', 'Trend'],
            ...rows,
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCambridgeTrendSection(List<CambridgeAssessmentResult> results, String title) {
    // Group by test type and show trend
    final byType = <String, List<CambridgeAssessmentResult>>{};
    for (final r in results) {
      final key = r.testType.name;
      byType.putIfAbsent(key, () => []);
      byType[key]!.add(r);
    }

    final rows = <List<String>>[];
    for (final entry in byType.entries) {
      final sorted = entry.value..sort((a, b) => a.completedAt.compareTo(b.completedAt));
      if (sorted.length >= 2) {
        final first = sorted.first.accuracy;
        final last = sorted.last.accuracy;
        final improvement = last - first;
        final trend = improvement > 0 ? '↑ +${improvement.toStringAsFixed(1)}%' : (improvement < 0 ? '↓ ${improvement.toStringAsFixed(1)}%' : '→ same');
        rows.add([
          entry.key.toUpperCase(),
          '${first.toStringAsFixed(1)}%',
          '${last.toStringAsFixed(1)}%',
          trend,
        ]);
      }
    }

    if (rows.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          data: [
            ['Test', 'First', 'Latest', 'Trend'],
            ...rows,
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildExerciseTrendSection(List<CognitiveExercise> exercises, String title) {
    // Group by week and count exercises
    final weeklyCount = <String, int>{};

    for (final e in exercises) {
      if (e.completedAt != null) {
        final weekKey = '${e.completedAt!.month}/${_getWeekOfMonth(e.completedAt!)}';
        weeklyCount.update(weekKey, (v) => v + 1, ifAbsent: () => 1);
      }
    }

    final sortedWeeks = weeklyCount.keys.toList()..sort();
    final dataRows = sortedWeeks.map((week) {
      final count = weeklyCount[week]!;
      return [week, '$count games', _buildProgressBar(count / 35)]; // 35 = 5 games * 7 days
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          data: [
            ['Week', 'Games Played', 'Activity'],
            ...dataRows,
          ],
        ),
      ],
    );
  }

  static int _getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final dayOfMonth = date.day;
    final firstWeekday = firstDayOfMonth.weekday;
    return ((dayOfMonth + firstWeekday - 2) ~/ 7) + 1;
  }

  static String _buildProgressBar(double progress) {
    final filled = (progress.clamp(0.0, 1.0) * 10).round();
    final empty = 10 - filled;
    return '${'█' * filled}${'░' * empty}';
  }
}