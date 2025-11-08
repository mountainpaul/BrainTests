import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../lib/presentation/providers/cycle_day_provider.dart';

void main() {
  group('Cycle Day Provider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should return day 1 when no program start date is set', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cycleDay = await container.read(cycleDayProvider.future);

      expect(cycleDay, 1);
    });

    test('should calculate correct cycle day based on program start date', () async {
      // Set program start date to 5 days ago
      final startDate = DateTime.now().subtract(const Duration(days: 5));
      SharedPreferences.setMockInitialValues({
        'program_start_date': startDate.toIso8601String(),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cycleDay = await container.read(cycleDayProvider.future);

      // 5 days ago means cycle day should be 6
      expect(cycleDay, 6);
    });

    test('should wrap cycle day after 10 days', () async {
      // Set program start date to 12 days ago
      final startDate = DateTime.now().subtract(const Duration(days: 12));
      SharedPreferences.setMockInitialValues({
        'program_start_date': startDate.toIso8601String(),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cycleDay = await container.read(cycleDayProvider.future);

      // 12 days ago: (12 % 10) + 1 = 3
      expect(cycleDay, 3);
    });

    test('should return day 1 on exact program start date', () async {
      // Set program start date to today
      final startDate = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'program_start_date': startDate.toIso8601String(),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cycleDay = await container.read(cycleDayProvider.future);

      expect(cycleDay, 1);
    });

    test('should calculate day 10 correctly', () async {
      // Set program start date to 9 days ago
      final startDate = DateTime.now().subtract(const Duration(days: 9));
      SharedPreferences.setMockInitialValues({
        'program_start_date': startDate.toIso8601String(),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cycleDay = await container.read(cycleDayProvider.future);

      // 9 days ago: (9 % 10) + 1 = 10
      expect(cycleDay, 10);
    });
  });

  group('Program Start Date Provider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should return null when no program start date is set', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final startDate = await container.read(programStartDateProvider.future);

      expect(startDate, isNull);
    });

    test('should return program start date when set', () async {
      final expectedDate = DateTime(2024, 1, 15);
      SharedPreferences.setMockInitialValues({
        'program_start_date': expectedDate.toIso8601String(),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final startDate = await container.read(programStartDateProvider.future);

      expect(startDate, isNotNull);
      expect(startDate!.year, expectedDate.year);
      expect(startDate.month, expectedDate.month);
      expect(startDate.day, expectedDate.day);
    });
  });
}
