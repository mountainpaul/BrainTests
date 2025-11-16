import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/pdf_service.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/entities/cognitive_exercise.dart';
import '../../domain/entities/cambridge_assessment.dart' show CambridgeAssessmentResult;

part 'pdf_provider.g.dart';

final pdfServiceProvider = Provider<PDFService>((ref) {
  return PDFService();
});

@riverpod
class PDFGeneratorNotifier extends _$PDFGeneratorNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> generateAndShareReport({
    required List<Assessment> assessments,
    required List<CambridgeAssessmentResult> cambridgeResults,
    required List<CognitiveExercise> exercises,
  }) async {
    state = const AsyncValue.loading();
    try {
      await PDFService.generateAndShareReport(
        assessments: assessments,
        cambridgeResults: cambridgeResults,
        exercises: exercises,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> saveReportToDevice({
    required List<Assessment> assessments,
    required List<CambridgeAssessmentResult> cambridgeResults,
    required List<CognitiveExercise> exercises,
  }) async {
    state = const AsyncValue.loading();
    try {
      await PDFService.saveReportToDevice(
        assessments: assessments,
        cambridgeResults: cambridgeResults,
        exercises: exercises,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}