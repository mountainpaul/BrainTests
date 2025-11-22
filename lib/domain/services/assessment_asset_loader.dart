import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AssessmentAssetLoader {
  static final AssessmentAssetLoader _instance = AssessmentAssetLoader._internal();
  factory AssessmentAssetLoader() => _instance;
  AssessmentAssetLoader._internal();

  Map<String, dynamic>? _memoryRecallData;
  Map<String, dynamic>? _languageSkillsData;
  Map<String, dynamic>? _visuospatialData;
  Map<String, dynamic>? _processingSpeedData;

  Future<void> _loadJson(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final data = json.decode(jsonString);
    if (path.contains('memory_recall')) {
      _memoryRecallData = data;
    } else if (path.contains('language_skills')) {
      _languageSkillsData = data;
    } else if (path.contains('visuospatial')) {
      _visuospatialData = data;
    } else if (path.contains('processing_speed')) {
      _processingSpeedData = data;
    }
  }

  Future<Map<String, dynamic>> getMemoryRecallData() async {
    if (_memoryRecallData == null) {
      await _loadJson('assets/assessment_data/memory_recall.json');
    }
    return _memoryRecallData!;
  }

  Future<Map<String, dynamic>> getLanguageSkillsData() async {
    if (_languageSkillsData == null) {
      await _loadJson('assets/assessment_data/language_skills.json');
    }
    return _languageSkillsData!;
  }

  Future<Map<String, dynamic>> getVisuospatialData() async {
    if (_visuospatialData == null) {
      await _loadJson('assets/assessment_data/visuospatial.json');
    }
    return _visuospatialData!;
  }

  Future<Map<String, dynamic>> getProcessingSpeedData() async {
    if (_processingSpeedData == null) {
      await _loadJson('assets/assessment_data/processing_speed.json');
    }
    return _processingSpeedData!;
  }
}
