enum AssessmentType {
  memoryRecall,
  attentionFocus,
  executiveFunction,
  languageSkills,
  visuospatialSkills,
  processingSpeed
}

enum ReminderType {
  medication,
  exercise,
  assessment,
  appointment,
  custom
}

enum ReminderFrequency {
  once,
  daily,
  weekly,
  monthly
}

enum ExerciseType {
  memoryGame,
  wordPuzzle,
  wordSearch,
  spanishAnagram,
  mathProblem,
  patternRecognition,
  sequenceRecall,
  spatialAwareness
}

enum ExerciseDifficulty {
  easy,
  medium,
  hard,
  expert
}

enum WordLanguage {
  english,
  spanish
}

enum WordType {
  anagram,
  wordSearch,
  validationOnly
}

enum MoodLevel {
  veryLow,
  low,
  neutral,
  good,
  excellent
}

enum SyncStatus {
  synced,
  pendingInsert,
  pendingUpdate,
  pendingDelete
}