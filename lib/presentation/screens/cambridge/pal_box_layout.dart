/// Box layout types for different PAL stages
enum BoxLayout {
  horizontal,  // Stage 1 (2 patterns): boxes arranged horizontally
  grid,        // Stage 2 (4 patterns): 2x2 grid arrangement
  circle,      // Stages 3-7 (5-8 patterns): circular arrangement
}
