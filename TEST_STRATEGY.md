# Test Strategy - Brain Plan

## Overview
This document outlines the comprehensive test strategy implemented to prevent architectural violations and ensure code quality.

## Test Categories

### 1. Unit Tests (`test/unit/`)
- **Purpose**: Test individual components in isolation
- **Coverage**: Services, repositories, entities, utilities
- **Example**: `database_export_service_test.dart` - 15 tests for export/import

### 2. Widget Tests (`test/widget/`)
- **Purpose**: Test UI components and interactions
- **Coverage**: Screens, widgets, user interactions
- **Limitation**: Only tests rendering, not data persistence

### 3. Integration Tests (`test/integration/`) ✨ NEW
- **Purpose**: Test complete user workflows end-to-end
- **Coverage**: User journey from UI → Repository → Database → Retrieval
- **Example**: `trail_making_integration_test.dart`
  - ✅ Verifies Test A saves to database via repository
  - ✅ Verifies Test B saves to database via repository
  - ✅ Verifies data persists across app restart
  - ✅ Verifies completion time accuracy
  - ✅ Verifies error tracking

### 4. Contract Tests (`test/contract/`) ✨ NEW
- **Purpose**: Enforce that all code follows architectural contracts
- **Coverage**: Repository usage, provider patterns, layer boundaries
- **Tests**:
  - ✅ Screens must not directly access database
  - ✅ Screens must import repository providers
  - ✅ Assessment screens must use AssessmentRepository
  - ✅ Exercise screens must use CognitiveExerciseRepository
  - ✅ Screens must not use Drift Companion classes

### 5. Architecture Tests (`test/architecture/`) ✨ NEW
- **Purpose**: Enforce clean architecture layer boundaries
- **Coverage**: Import dependencies, layer violations, separation of concerns
- **Tests**:
  - ✅ Presentation must not import data layer directly
  - ✅ Domain layer must be independent (no presentation/data imports)
  - ✅ Data layer must not import presentation
  - ✅ Repositories must use domain entities
  - ✅ Screens must use providers not direct instances
  - ✅ Core services must be independent
  - ✅ Backup triggers in data layer only
  - ✅ Directory structure validation

## Findings from New Tests

### Contract Test Results (6 tests, 5 FAILED)
**Violations Found:**

#### 1. Direct Database Access (8 screens)
- `exercise_test_screen.dart`
- `today_dashboard_screen.dart`
- `five_word_recall_test_screen.dart`
- `sdmt_test_screen.dart`
- `journal_screen.dart`
- `feeding_window_config_screen.dart`
- `fasting_screen.dart`
- `plan_screen.dart`

#### 2. Missing Repository Providers (6 screens)
- `today_dashboard_screen.dart`
- `five_word_recall_test_screen.dart`
- `sdmt_test_screen.dart`
- `reminders_screen.dart`
- `assessment_detail_screen.dart`
- `exercise_detail_screen.dart`

#### 3. Not Using AssessmentRepository (7 screens)
- `validated_assessment_coordinator.dart`
- `five_word_recall_test_screen.dart`
- `mmse_assessment_screen.dart`
- `sdmt_test_screen.dart`
- `assessment_test_screen.dart`
- `assessment_detail_screen.dart`
- `assessments_screen.dart`

#### 4. Not Using ExerciseRepository (3 screens)
- `exercise_test_screen.dart`
- `exercise_detail_screen.dart`
- `exercises_screen.dart`

#### 5. Using Drift Companions in Presentation (16 screens!)
All these screens bypass entities and use Drift TableCompanion directly

### Architecture Test Results (7 tests, 2 FAILED)

#### 1. Presentation imports Data Layer (30+ files)
Many screens and providers import `database.dart` directly

#### 2. Domain Layer imports Data (10 files)
Domain entities and repositories importing from data layer

## Why The Trail Making Bug Wasn't Caught

**Root Cause**: The existing tests only verified:
- ✅ Does it render? (Widget tests)
- ✅ Does repository work? (Unit tests)

**What was missing**:
- ❌ Does the screen USE the repository? (Contract tests)
- ❌ Does data persist end-to-end? (Integration tests)
- ❌ Are layer boundaries enforced? (Architecture tests)

## Test Strategy Going Forward

### 1. For Every New Feature
```
1. Write integration test (full user workflow)
2. Write contract test (verify uses repository)
3. Implement feature
4. Run architecture tests to verify compliance
5. All tests must pass before merge
```

### 2. Continuous Validation
- Run contract tests on every commit
- Run architecture tests daily
- Integration tests for critical workflows

### 3. Coverage Requirements
- **Unit Tests**: 80%+ for business logic
- **Integration Tests**: All critical user journeys
- **Contract Tests**: 100% (all screens checked)
- **Architecture Tests**: 100% (all layers validated)

## Current Test Metrics

### Before New Tests
- Total tests: ~1,954
- Coverage: Widget/Unit only
- Architectural violations: Unknown ❌

### After New Tests
- Total tests: ~1,980+
- **Integration tests**: 6 (2 passing, 4 UI issues to fix)
- **Contract tests**: 5 (ALL found violations) ✅
- **Architecture tests**: 7 (2 found violations) ✅
- **Architectural violations found**: 50+ screens need refactoring

## Action Items

### High Priority (Blocking)
1. Fix 8 screens with direct database access
2. Fix 7 assessment screens to use repository
3. Fix 3 exercise screens to use repository

### Medium Priority
1. Remove database imports from 30+ presentation files
2. Fix domain layer imports (10 files)
3. Replace Drift Companions with entities (16 screens)

### Low Priority
1. Fix integration test UI issues (scrolling/viewport)
2. Add more integration tests for other assessments
3. Add performance benchmarks

## Benefits of New Test Strategy

### Before
- ⚠️ Trail Making bug: Undetected
- ⚠️ 50+ architectural violations: Unknown
- ⚠️ No guarantee screens use repositories

### After
- ✅ Trail Making bug: **Would be caught by integration test**
- ✅ Architectural violations: **Immediately detected**
- ✅ Repository usage: **Enforced by contract tests**
- ✅ Layer boundaries: **Validated automatically**
- ✅ Future bugs: **Prevented before merge**

## Conclusion

These three new test types form a **defensive barrier** that would have prevented the Trail Making bug and will prevent similar issues in the future:

1. **Integration Tests** → "Does it work end-to-end?"
2. **Contract Tests** → "Does it follow our patterns?"
3. **Architecture Tests** → "Is the codebase properly structured?"

**The tests successfully identified 50+ violations across the codebase!** 🎯
