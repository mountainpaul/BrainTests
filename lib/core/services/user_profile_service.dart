import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/database.dart';

/// Service to manage user profile information including age for age-adjusted performance
class UserProfileService {
  static const String _ageKey = 'user_age';
  static const String _nameKey = 'user_name';
  static const String _dobKey = 'user_dob';
  static const String _programStartDateKey = 'program_start_date';

  /// Get the user's age from SharedPreferences (fast access)
  static Future<int?> getUserAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_ageKey);
  }

  /// Set the user's age in SharedPreferences and database
  static Future<void> setUserAge(AppDatabase database, int age) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ageKey, age);

    // Also save to database
    await _saveToDatabase(database, age: age);
  }

  /// Get the user's name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  /// Set the user's name
  static Future<void> setUserName(AppDatabase database, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);

    await _saveToDatabase(database, name: name);
  }

  /// Get the user's date of birth
  static Future<DateTime?> getDateOfBirth() async {
    final prefs = await SharedPreferences.getInstance();
    final dobString = prefs.getString(_dobKey);
    if (dobString != null) {
      return DateTime.tryParse(dobString);
    }
    return null;
  }

  /// Set the user's date of birth and calculate age
  static Future<void> setDateOfBirth(AppDatabase database, DateTime dob) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dobKey, dob.toIso8601String());

    // Calculate age
    final age = _calculateAge(dob);
    await prefs.setInt(_ageKey, age);

    await _saveToDatabase(database, dateOfBirth: dob, age: age);
  }

  /// Calculate age from date of birth
  static int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  /// Get the program start date
  static Future<DateTime?> getProgramStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateString = prefs.getString(_programStartDateKey);
    if (startDateString != null) {
      return DateTime.tryParse(startDateString);
    }
    return null;
  }

  /// Set the program start date (for cycle day calculation)
  static Future<void> setProgramStartDate(AppDatabase database, DateTime startDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_programStartDateKey, startDate.toIso8601String());

    await _saveToDatabase(database, programStartDate: startDate);
  }

  /// Get age group for performance benchmarks
  static String getAgeGroup(int age) {
    if (age < 40) return 'Under 40';
    if (age < 50) return '40-49';
    if (age < 60) return '50-59';
    if (age < 70) return '60-69';
    if (age < 80) return '70-79';
    return '80+';
  }

  /// Get age-adjusted show time multiplier for memory games
  /// Older adults benefit from longer memorization periods
  static double getShowTimeMultiplier(int? age) {
    if (age == null) return 1.0;

    if (age < 50) return 1.0;      // No adjustment
    if (age < 60) return 1.2;      // +20%
    if (age < 70) return 1.4;      // +40%
    if (age < 80) return 1.6;      // +60%
    return 1.8;                     // +80% for 80+
  }

  /// Get age-adjusted performance feedback
  static String getPerformanceFeedback(int score, int? age, ExerciseDifficulty difficulty) {
    if (age == null) {
      // No age info, use general feedback
      if (score >= 80) return 'Excellent performance!';
      if (score >= 65) return 'Good job!';
      if (score >= 50) return 'Average performance.';
      if (score >= 35) return 'Keep practicing!';
      return 'Consider trying an easier level.';
    }

    // Age-adjusted feedback
    final benchmark = _getAgeBenchmark(age, difficulty);

    if (score >= benchmark + 15) {
      return 'Outstanding! Well above expected for your age group (${getAgeGroup(age)}).';
    } else if (score >= benchmark) {
      return 'Excellent! At or above typical performance for age $age.';
    } else if (score >= benchmark - 10) {
      return 'Good performance for age $age. Keep it up!';
    } else if (score >= benchmark - 20) {
      return 'Fair performance. Regular practice can help improve memory.';
    } else {
      return 'Consider consulting with a healthcare provider about memory concerns.';
    }
  }

  /// Get expected performance benchmark by age and difficulty
  static int _getAgeBenchmark(int age, ExerciseDifficulty difficulty) {
    // Base benchmarks for age 25-35 (peak cognitive performance)
    int baseBenchmark;
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        baseBenchmark = 90;
        break;
      case ExerciseDifficulty.medium:
        baseBenchmark = 75;
        break;
      case ExerciseDifficulty.hard:
        baseBenchmark = 60;
        break;
      case ExerciseDifficulty.expert:
        baseBenchmark = 45;
        break;
    }

    // Adjust for age (roughly 1% decline per year after 40)
    if (age <= 40) {
      return baseBenchmark;
    } else if (age <= 50) {
      return baseBenchmark - 5;  // ~10% decline
    } else if (age <= 60) {
      return baseBenchmark - 10; // ~15% decline
    } else if (age <= 70) {
      return baseBenchmark - 15; // ~20% decline
    } else if (age <= 80) {
      return baseBenchmark - 20; // ~25% decline
    } else {
      return baseBenchmark - 25; // ~30% decline
    }
  }

  /// Save user profile to database
  static Future<void> _saveToDatabase(
    AppDatabase database, {
    String? name,
    int? age,
    DateTime? dateOfBirth,
    DateTime? programStartDate,
  }) async {
    // Check if profile exists
    final existingProfiles = await database.select(database.userProfileTable).get();

    if (existingProfiles.isEmpty) {
      // Create new profile
      await database.into(database.userProfileTable).insert(
        UserProfileTableCompanion.insert(
          name: name != null ? Value(name) : const Value.absent(),
          age: age != null ? Value(age) : const Value.absent(),
          dateOfBirth: dateOfBirth != null ? Value(dateOfBirth) : const Value.absent(),
          programStartDate: programStartDate != null ? Value(programStartDate) : const Value.absent(),
        ),
      );
    } else {
      // Update existing profile
      final profile = existingProfiles.first;
      await (database.update(database.userProfileTable)
            ..where((tbl) => tbl.id.equals(profile.id)))
          .write(
        UserProfileTableCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          age: age != null ? Value(age) : const Value.absent(),
          dateOfBirth: dateOfBirth != null ? Value(dateOfBirth) : const Value.absent(),
          programStartDate: programStartDate != null ? Value(programStartDate) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Load profile from database to SharedPreferences on app start
  static Future<void> loadProfileFromDatabase(AppDatabase database) async {
    final profiles = await database.select(database.userProfileTable).get();
    if (profiles.isNotEmpty) {
      final profile = profiles.first;
      final prefs = await SharedPreferences.getInstance();

      if (profile.name != null) {
        await prefs.setString(_nameKey, profile.name!);
      }
      if (profile.age != null) {
        await prefs.setInt(_ageKey, profile.age!);
      }
      if (profile.dateOfBirth != null) {
        await prefs.setString(_dobKey, profile.dateOfBirth!.toIso8601String());
      }
      if (profile.programStartDate != null) {
        await prefs.setString(_programStartDateKey, profile.programStartDate!.toIso8601String());
      }
    }
  }
}
