import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/user_profile_service.dart';
import '../../core/utils/cycle_day_calculator.dart';

/// Provider for the current program start date
final programStartDateProvider = FutureProvider<DateTime?>((ref) async {
  return await UserProfileService.getProgramStartDate();
});

/// Provider for the current cycle day (1-10)
/// Automatically calculates based on program start date
final cycleDayProvider = FutureProvider<int>((ref) async {
  final programStartDate = await ref.watch(programStartDateProvider.future);
  return CycleDayCalculator.calculateCycleDay(programStartDate);
});

/// Provider for cycle day as a stream that refreshes
/// Use this when you need reactive updates
final cycleDayStreamProvider = StreamProvider<int>((ref) {
  return Stream.periodic(
    const Duration(hours: 1),
    (_) async {
      final programStartDate = await UserProfileService.getProgramStartDate();
      return CycleDayCalculator.calculateCycleDay(programStartDate);
    },
  ).asyncMap((future) => future);
});
