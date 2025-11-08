# Brain Plan - Flutter App Development Guide

## 🚨 Development Rules
**ALWAYS follow Test-Driven Development (TDD):**
1. Write tests FIRST (before implementation code)
2. Write minimal code to make tests pass
3. Refactor with passing tests
4. Never skip writing tests for new features

## Project Overview
Brain Plan is a production-ready, offline-first Flutter app for Android focused on cognitive health tracking. The app helps users track their cognitive health journey through assessments, brain exercises, mood tracking, and medication reminders.

## Architecture
- **Pattern**: MVVM-ish with Repository pattern
- **State Management**: Riverpod
- **Database**: Drift (SQLite) for offline-first functionality
- **Navigation**: go_router
- **Charts**: fl_chart for data visualization
- **PDF Export**: pdf/printing packages
- **Notifications**: flutter_local_notifications + android_alarm_manager_plus

## Key Features
1. **Cognitive Assessments**: Memory recall, attention focus, executive function, language skills, visuospatial skills, processing speed
2. **Brain Exercises**: Memory games, word puzzles, math problems, pattern recognition, sequence recall, spatial awareness
3. **Mood Tracking**: Daily mood logging with wellness score calculation
4. **Smart Reminders**: Medication, exercise, assessment, and appointment reminders with notifications
5. **Progress Reports**: Visual charts and PDF export functionality
6. **Offline Support**: Full offline functionality with local SQLite database

## Project Structure
```
lib/
├── core/
│   ├── constants/
│   ├── utils/
│   ├── extensions/
│   └── services/         # PDF and notification services
├── data/
│   ├── models/          # Drift table definitions
│   ├── repositories/    # Repository implementations
│   └── datasources/     # Database configuration
├── domain/
│   ├── entities/        # Business objects
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic
└── presentation/
    ├── providers/       # Riverpod providers
    ├── screens/         # UI screens
    ├── widgets/         # Reusable components
    └── theme/           # App theming
```

## Development Commands

### Setup
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
flutter test                    # Run unit and widget tests
flutter drive --target=test_driver/app.dart  # Run integration tests
```

### Building
```bash
flutter build apk --release    # Build release APK
flutter build appbundle       # Build AAB for Play Store
```

### Code Generation
```bash
dart run build_runner build   # Generate Drift and Riverpod code
dart run build_runner watch   # Watch mode for development
```

## Database Schema
The app uses Drift for type-safe SQL operations with these main tables:
- **assessments**: Cognitive assessment results
- **reminders**: Smart reminders with notifications
- **cognitive_exercises**: Brain training exercises and results  
- **mood_entries**: Daily mood and wellness tracking

## Key Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.6.1        # State management
  drift: ^2.20.3                   # Database ORM
  go_router: ^14.6.2               # Navigation
  fl_chart: ^0.70.1               # Charts
  pdf: ^3.11.1                    # PDF generation
  flutter_local_notifications: ^17.2.3  # Notifications
  android_alarm_manager_plus: ^4.0.4     # Background tasks

dev_dependencies:
  build_runner: ^2.4.13           # Code generation
  drift_dev: ^2.20.1              # Drift code generation
  riverpod_generator: ^2.6.2       # Riverpod code generation
  mockito: ^5.4.4                 # Testing mocks
```

## Features Implementation Status
✅ Project structure and dependencies  
✅ Database schema and models (Drift)  
✅ Repository pattern implementation  
✅ Riverpod providers and state management  
✅ Navigation with go_router  
✅ Core UI screens and components  
✅ Charts with fl_chart  
✅ PDF export functionality  
✅ Notifications and background tasks  
✅ Unit tests for critical components  
✅ Build verification

## Testing Strategy
**⚠️ MANDATORY: Follow Test-Driven Development (TDD) for ALL new features**

### TDD Process (Red-Green-Refactor):
1. **RED**: Write failing tests first that define expected behavior
2. **GREEN**: Write minimal code to make tests pass
3. **REFACTOR**: Improve code while keeping tests green
4. **REPEAT**: Continue cycle for each feature

### Test Coverage Requirements:
- **Unit Tests**: Entity logic, business rules, utility functions, scoring algorithms
- **Widget Tests**: UI components, user interactions, state management, accessibility
- **Integration Tests**: End-to-end user workflows, navigation, data persistence

### Test Organization:
- `test/unit/` - Unit tests for logic and calculations
- `test/widget/` - Widget/UI component tests
- `test/integration/` - Full workflow integration tests
- Use `@GenerateMocks` annotations for proper mock generation
- Run `dart run build_runner build` after adding new mock annotations

## Production Considerations
- All data stored locally (GDPR compliant)
- Offline-first architecture
- Accessible UI design
- Performance optimized
- Strong typing with null safety
- Comprehensive error handling
- Background task management for reminders

## Code Quality
- Follows Flutter/Dart style guidelines
- Strong typing with null safety
- Clean architecture principles
- Comprehensive test coverage
- Clear separation of concerns
- Reusable components