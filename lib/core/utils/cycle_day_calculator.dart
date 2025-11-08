/// Utility class for calculating current cycle day based on program start date
class CycleDayCalculator {
  /// Calculate the current cycle day based on program start date
  /// Returns a value from 1-10
  ///
  /// If programStartDate is null, defaults to day 1
  static int calculateCycleDay(DateTime? programStartDate, [DateTime? currentDate]) {
    if (programStartDate == null) {
      return 1; // Default to day 1 if no start date set
    }

    final now = currentDate ?? DateTime.now();
    final daysSinceStart = now.difference(programStartDate).inDays;
    return (daysSinceStart % 10) + 1;
  }
}
