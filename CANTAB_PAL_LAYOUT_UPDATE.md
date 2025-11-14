# CANTAB PAL Layout Update - Implementation Plan

## Current Status
✅ Configuration updated in `cantab_pal_config.dart`:
- Stages: 8 → 7 (now: 2, 4, 5, 6, 7, 8 patterns)
- Max failed attempts: 4 → 3
- Created `BoxLayout` enum (horizontal, grid, circle)
- Added `getLayoutForStage()` method

## Required Changes

### 1. Update Box Positioning Logic (cantab_pal_test_screen.dart line ~766)

**Current:** All stages use circular arrangement

**Required:**
- **Stage 1 (2 patterns):** Horizontal layout
  - Position boxes left and right of center
  - Example: [Box] -------- [Box]

- **Stage 2 (4 patterns):** Grid layout
  - 2x2 grid arrangement
  - Example:
    ```
    [Box] [Box]
    [Box] [Box]
    ```

- **Stages 3-7 (5-8 patterns):** Circle arrangement
  - Keep current circular positioning
  - Already implemented correctly

### 2. Implementation Steps

1. Add layout detection:
```dart
final layout = CANTABPALConfig.getLayoutForStage(_currentStageIndex);
```

2. Generate positions based on layout:
```dart
List<Offset> _generateBoxPositions(BoxLayout layout, int patternCount, Size screenSize) {
  switch (layout) {
    case BoxLayout.horizontal:
      return _generateHorizontalLayout(screenSize);
    case BoxLayout.grid:
      return _generateGridLayout(screenSize);
    case BoxLayout.circle:
      return _generateCircleLayout(patternCount, screenSize);
  }
}
```

3. Horizontal layout (2 boxes):
```dart
List<Offset> _generateHorizontalLayout(Size screenSize) {
  final centerY = screenSize.height * 0.5;
  final spacing = screenSize.width * 0.6;
  final centerX = screenSize.width * 0.5;

  return [
    Offset(centerX - spacing/2, centerY), // Left box
    Offset(centerX + spacing/2, centerY), // Right box
  ];
}
```

4. Grid layout (4 boxes):
```dart
List<Offset> _generateGridLayout(Size screenSize) {
  final centerX = screenSize.width * 0.5;
  final centerY = screenSize.height * 0.5;
  final spacing = 80.0;

  return [
    Offset(centerX - spacing, centerY - spacing), // Top-left
    Offset(centerX + spacing, centerY - spacing), // Top-right
    Offset(centerX - spacing, centerY + spacing), // Bottom-left
    Offset(centerX + spacing, centerY + spacing), // Bottom-right
  ];
}
```

### 3. Testing

Create integration test verifying:
- Stage 1 uses horizontal layout ✓
- Stage 2 uses grid layout ✓
- Stages 3-7 use circle layout ✓
- Test stops after 3 failed attempts ✓
- All 7 stages progress correctly ✓

### 4. Files to Modify

- ✅ `lib/presentation/screens/cambridge/cantab_pal_config.dart` - Configuration updated
- ✅ `lib/presentation/screens/cambridge/pal_box_layout.dart` - Enum created
- ⏳ `lib/presentation/screens/cambridge/cantab_pal_test_screen.dart` - Layout logic (line ~766)

## Benefits

Following official CANTAB PAL protocol:
- ✅ Matches clinical research standards
- ✅ Proper difficulty progression (2→4→5→6→7→8)
- ✅ Appropriate layouts per stage
- ✅ Accurate normative comparisons
- ✅ Better user experience (easier stages more intuitive)

## Estimated Time
- Layout positioning implementation: ~1 hour
- Testing and refinement: ~30 mins
- Total: ~1.5 hours
