# Age-Adjusted Performance Implementation Summary

## What's Been Implemented

### 1. Database Schema (✓ Complete)
- Added `UserProfileTable` with fields: id, name, age, dateOfBirth, gender, createdAt, updatedAt
- Upgraded database schema from version 6 to 7
- Added migration to create the user_profile table

### 2. User Profile Service (✓ Complete)
**File:** `lib/core/services/user_profile_service.dart`

**Features:**
- Get/set user age in SharedPreferences and database
- Calculate age from date of birth
- Get age group (Under 40, 40-49, 50-59, 60-69, 70-79, 80+)
- Get show time multiplier based on age:
  - Under 50: 1.0x (no adjustment)
  - 50-59: 1.2x (+20%)
  - 60-69: 1.4x (+40%)
  - 70-79: 1.6x (+60%)
  - 80+: 1.8x (+80%)
- Get age-adjusted performance feedback
- Age-adjusted benchmarks by difficulty

### 3. Profile Setup Screen (✓ Complete)
**File:** `lib/presentation/screens/profile_setup_screen.dart`

**Features:**
- Form to capture name (optional) and age (required)
- Age validation (18-120 years)
- Explanation of why age is collected
- Saves to both SharedPreferences and database

### 4. Exercise Generator Updates (✓ Partial)
**File:** `lib/domain/services/exercise_generator.dart`

**Changes:**
- `generateMemoryGame()` now accepts optional `userAge` parameter
- `_getMemoryShowTime()` applies age multiplier to show times:
  - **Age 68 on Medium (4 sec base):** 4 × 1.4 = 5.6 seconds (rounded to 6)
  - **Age 68 on Easy (5 sec base):** 5 × 1.4 = 7 seconds

## What Still Needs Implementation

### 5. Memory Game Widget Updates (TODO)
**File:** `lib/presentation/screens/exercise_test_screen.dart`

**Required Changes:**
```dart
// Line ~490: Update initState to get user age and pass to generator
@override
void initState() {
  super.initState();
  _initializeGame();
  startTime = DateTime.now();
  _startShowPhase();
}

Future<void> _initializeGame() async {
  final userAge = await UserProfileService.getUserAge();
  setState(() {
    gameData = ExerciseGenerator.generateMemoryGame(
      difficulty: widget.difficulty,
      userAge: userAge,
    );
    cardRevealed = List.filled(gameData.cardSymbols.length, false);
    cardMatched = List.filled(gameData.cardSymbols.length, false);
  });
}

// Line ~628-634: Update _completeGame to show age-adjusted feedback
void _completeGame() async {
  final timeSpent = DateTime.now().difference(startTime).inSeconds;
  final efficiency = (gameData.cardSymbols.length ~/ 2) / moves;
  final score = (efficiency * 100).clamp(10, 100).round();

  // Show age-adjusted feedback
  final userAge = await UserProfileService.getUserAge();
  final feedback = UserProfileService.getPerformanceFeedback(
    score,
    userAge,
    widget.difficulty,
  );

  // Display feedback to user before calling onCompleted
  _showFeedback(feedback, score >= 60 ? Colors.green : Colors.orange);

  // Small delay to show feedback
  await Future.delayed(Duration(seconds: 2));

  widget.onCompleted(score, timeSpent);
}
```

### 6. Home Screen - Profile Prompt (TODO)
**File:** `lib/presentation/screens/home_screen.dart`

**Required Changes:**
- Add check on home screen load: if no age set, show banner/card prompting user to set up profile
- Add "Profile" button in app bar or settings
- Link to ProfileSetupScreen

Example:
```dart
FutureBuilder<int?>(
  future: UserProfileService.getUserAge(),
  builder: (context, snapshot) {
    if (snapshot.data == null) {
      return CustomCard(
        child: ListTile(
          leading: Icon(Icons.person_add, color: Colors.blue),
          title: Text('Set up your profile'),
          subtitle: Text('Get age-adjusted feedback and optimized exercises'),
          trailing: Icon(Icons.arrow_forward),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfileSetupScreen()),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  },
)
```

### 7. Settings Screen Integration (TODO)
**File:** `lib/presentation/screens/settings_screen.dart` (if exists)

**Required Changes:**
- Add "Profile" option in settings
- Show current age if set
- Allow editing profile

### 8. Router Configuration (TODO)
**File:** `lib/presentation/providers/router_provider.dart`

**Required Changes:**
- Add route for ProfileSetupScreen
```dart
GoRoute(
  path: '/profile-setup',
  name: 'profileSetup',
  builder: (context, state) => const ProfileSetupScreen(),
),
```

## Age-Adjusted Benchmarks for 68-Year-Old

| Difficulty | Base Benchmark | Age 68 Benchmark | Show Time (Base) | Show Time (Age 68) |
|------------|----------------|------------------|------------------|---------------------|
| Easy       | 90%            | 75%              | 5 sec            | 7 sec               |
| Medium     | 75%            | 60%              | 4 sec            | 6 sec               |
| Hard       | 60%            | 45%              | 3 sec            | 4 sec               |
| Expert     | 45%            | 30%              | 2 sec            | 3 sec               |

## Performance Feedback Messages (Age 68)

| Score Range    | Feedback Message                                                         |
|----------------|--------------------------------------------------------------------------|
| 75%+           | "Outstanding! Well above expected for your age group (60-69)."           |
| 60-74%         | "Excellent! At or above typical performance for age 68."                 |
| 50-59%         | "Good performance for age 68. Keep it up!"                               |
| 40-49%         | "Fair performance. Regular practice can help improve memory."            |
| Below 40%      | "Consider consulting with a healthcare provider about memory concerns."  |

## Testing Checklist

- [ ] User can set age in profile
- [ ] Age is saved to database and SharedPreferences
- [ ] Memory game show time increases for age 68 (4→6 sec on medium)
- [ ] Performance feedback reflects age-adjusted benchmarks
- [ ] Profile persists across app restarts
- [ ] Age can be edited after initial setup
- [ ] App works normally if no age is set (falls back to general feedback)

## Next Steps

1. Complete Memory Game Widget updates
2. Add profile prompt on home screen
3. Integrate ProfileSetupScreen into navigation/settings
4. Test with age 68 to verify:
   - Medium difficulty shows ~6 seconds memorization time
   - 60% score shows "Excellent" feedback
5. Deploy and verify on device
