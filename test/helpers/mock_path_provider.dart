import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    // Use system temp directory for testing
    return Directory.systemTemp.createTemp('brain_plan_test').then((dir) => dir.path);
  }

  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.createTemp('brain_plan_temp').then((dir) => dir.path);
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return Directory.systemTemp.createTemp('brain_plan_support').then((dir) => dir.path);
  }

  @override
  Future<String?> getApplicationCachePath() async {
    return Directory.systemTemp.createTemp('brain_plan_cache').then((dir) => dir.path);
  }

  @override
  Future<String?> getDownloadsPath() async {
    return Directory.systemTemp.createTemp('brain_plan_downloads').then((dir) => dir.path);
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return null;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return null;
  }

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async {
    return null;
  }

  @override
  Future<String?> getLibraryPath() async {
    return Directory.systemTemp.createTemp('brain_plan_library').then((dir) => dir.path);
  }
}
