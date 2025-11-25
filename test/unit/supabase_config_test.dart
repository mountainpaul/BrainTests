import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Supabase Configuration', () {
    final configFile = File('assets/supabase_credentials.json');

    test('Configuration file should exist', () {
      expect(configFile.existsSync(), isTrue, 
        reason: 'assets/supabase_credentials.json not found. Please run the setup commands.');
    });

    test('Configuration file should contain valid JSON', () {
      if (!configFile.existsSync()) return;
      
      final content = configFile.readAsStringSync();
      expect(() => jsonDecode(content), returnsNormally, 
        reason: 'assets/supabase_credentials.json contains invalid JSON');
    });

    test('Configuration should have required keys', () {
      if (!configFile.existsSync()) return;

      final content = configFile.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;

      expect(json.containsKey('supabaseUrl'), isTrue, reason: 'Missing "supabaseUrl" key');
      expect(json.containsKey('supabaseAnonKey'), isTrue, reason: 'Missing "supabaseAnonKey" key');
    });

    test('Credentials should be updated from placeholders', () {
      if (!configFile.existsSync()) return;

      final content = configFile.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;

      final url = json['supabaseUrl'];
      final key = json['supabaseAnonKey'];

      // This test is EXPECTED TO FAIL until the user updates the file
      expect(url, isNot(contains('YOUR_SUPABASE_URL')), 
        reason: 'Please update "supabaseUrl" in assets/supabase_credentials.json with your actual project URL');
      
      expect(key, isNot(contains('YOUR_SUPABASE_ANON_KEY')), 
        reason: 'Please update "supabaseAnonKey" in assets/supabase_credentials.json with your actual anon key');
    });
  });
}
