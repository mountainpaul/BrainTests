import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Automated audit of StatefulWidget dispose() methods
///
/// Checks all StatefulWidget files for proper resource cleanup:
/// - Timer disposal
/// - StreamSubscription cancellation
/// - AnimationController disposal
/// - TextEditingController disposal
/// - FocusNode disposal
/// - ScrollController disposal
void main() {
  group('StatefulWidget Dispose Audit', () {
    late List<File> statefulWidgetFiles;

    setUpAll(() {
      // Find all Dart files in lib directory
      final libDir = Directory('lib');
      statefulWidgetFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) {
        final content = f.readAsStringSync();
        return content.contains('StatefulWidget');
      }).toList();

      print('Found ${statefulWidgetFiles.length} files with StatefulWidget');
    });

    test('should audit all StatefulWidget files for dispose methods', () {
      final issues = <String>[];

      for (final file in statefulWidgetFiles) {
        final content = file.readAsStringSync();
        final fileName = file.path.split('/').last;

        // Check if file has State class
        if (!content.contains('State<')) {
          continue;
        }

        // Check for resources that need disposal
        final hasTimer = content.contains('Timer');
        final hasStreamSubscription = content.contains('StreamSubscription');
        final hasAnimationController = content.contains('AnimationController');
        final hasTextEditingController = content.contains('TextEditingController');
        final hasFocusNode = content.contains('FocusNode');
        final hasScrollController = content.contains('ScrollController');

        final needsDisposal = hasTimer ||
            hasStreamSubscription ||
            hasAnimationController ||
            hasTextEditingController ||
            hasFocusNode ||
            hasScrollController;

        if (needsDisposal) {
          // Check if dispose method exists
          if (!content.contains('@override') || !content.contains('void dispose()')) {
            issues.add('$fileName: Missing dispose() method but has resources');
          } else {
            // Check specific disposals
            if (hasTimer && !content.contains('.cancel()')) {
              issues.add('$fileName: Has Timer but no cancel() in dispose');
            }
            if (hasStreamSubscription && !content.contains('.cancel()')) {
              issues.add('$fileName: Has StreamSubscription but no cancel() in dispose');
            }
            if (hasAnimationController && !content.contains('.dispose()')) {
              issues.add('$fileName: Has AnimationController but no dispose() call');
            }
            if (hasTextEditingController && !content.contains('.dispose()')) {
              issues.add('$fileName: Has TextEditingController but no dispose() call');
            }
            if (hasFocusNode && !content.contains('.dispose()')) {
              issues.add('$fileName: Has FocusNode but no dispose() call');
            }
            if (hasScrollController && !content.contains('.dispose()')) {
              issues.add('$fileName: Has ScrollController but no dispose() call');
            }
          }
        }
      }

      if (issues.isNotEmpty) {
        print('\nDispose Issues Found:');
        for (final issue in issues) {
          print('  - $issue');
        }
        print('\nTotal issues: ${issues.length}');
      } else {
        print('\n✅ All StatefulWidget dispose() methods properly implemented');
      }

      // Report findings
      expect(issues, isEmpty,
          reason: 'Found ${issues.length} dispose() issues. See test output for details.');
    });

    test('should identify high-risk files with timers', () {
      final highRiskFiles = <String>[];

      for (final file in statefulWidgetFiles) {
        final content = file.readAsStringSync();
        final fileName = file.path.split('/').last;

        // High risk: Timer.periodic without proper disposal
        if (content.contains('Timer.periodic') || content.contains('Timer(')) {
          final hasDispose = content.contains('void dispose()');
          final hasCancel = content.contains('.cancel()');

          if (!hasDispose || !hasCancel) {
            highRiskFiles.add(fileName);
          }
        }
      }

      if (highRiskFiles.isNotEmpty) {
        print('\nHigh-Risk Files (Timers without proper disposal):');
        for (final file in highRiskFiles) {
          print('  - $file');
        }
        print('\nTotal high-risk files: ${highRiskFiles.length}');
      }

      // This test is informational - we don't fail but report findings
      if (highRiskFiles.isNotEmpty) {
        print('\n⚠️  RECOMMENDATION: Refactor these files to use TimerProvider');
      }
    });

    test('should generate dispose() audit report', () {
      final report = <String, Map<String, dynamic>>{};

      for (final file in statefulWidgetFiles) {
        final content = file.readAsStringSync();
        final fileName = file.path.split('/').last;

        report[fileName] = {
          'has_timer': content.contains('Timer'),
          'has_stream': content.contains('StreamSubscription'),
          'has_animation': content.contains('AnimationController'),
          'has_text_controller': content.contains('TextEditingController'),
          'has_focus_node': content.contains('FocusNode'),
          'has_scroll_controller': content.contains('ScrollController'),
          'has_dispose': content.contains('void dispose()'),
          'has_super_dispose': content.contains('super.dispose()'),
          'has_cancel': content.contains('.cancel()'),
        };
      }

      // Count files with issues
      int filesWithResources = 0;
      int filesWithDispose = 0;
      int filesWithProperCleanup = 0;

      for (final entry in report.entries) {
        final data = entry.value;
        final hasResources = data['has_timer'] ||
            data['has_stream'] ||
            data['has_animation'] ||
            data['has_text_controller'] ||
            data['has_focus_node'] ||
            data['has_scroll_controller'];

        if (hasResources) {
          filesWithResources++;

          if (data['has_dispose'] == true) {
            filesWithDispose++;

            if (data['has_super_dispose'] == true) {
              filesWithProperCleanup++;
            }
          }
        }
      }

      print('\n📊 Dispose Audit Report:');
      print('  Total StatefulWidget files: ${statefulWidgetFiles.length}');
      print('  Files with disposable resources: $filesWithResources');
      print('  Files with dispose() method: $filesWithDispose');
      print('  Files with super.dispose(): $filesWithProperCleanup');

      final coverage =
          filesWithResources > 0 ? (filesWithDispose / filesWithResources * 100).toStringAsFixed(1) : '100.0';
      print('  Dispose coverage: $coverage%');

      // Pass test - this is informational
      expect(statefulWidgetFiles, isNotEmpty);
    });
  });
}
