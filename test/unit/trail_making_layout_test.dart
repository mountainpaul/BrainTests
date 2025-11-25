import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

// Copy of the logic classes needed for testing
class CircleData {
  CircleData({
    required this.value,
    required this.x,
    required this.y,
  });
  final String value;
  final double x;
  final double y;
}

void main() {
  group('Trail Making Layout Calculations', () {
    // Constants from the implementation
    const double canvasSize = 800.0;
    const double circleDiameter = 75.0; // Proposed new size (was 93.5)
    
    List<CircleData> generateLayout(int itemCount, double margin, int gridSize, double jitterFactor) {
      final random = math.Random(12345); // Fixed seed for reproducibility
      final List<CircleData> circles = [];
      
      final availableWidth = canvasSize - (2 * margin);
      final availableHeight = canvasSize - (2 * margin);
      final cellWidth = availableWidth / gridSize;
      final cellHeight = availableHeight / gridSize;

      final List<Map<String, int>> gridPositions = [];
      for (int row = 0; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
          gridPositions.add({'row': row, 'col': col});
        }
      }
      gridPositions.shuffle(random);

      for (int i = 0; i < itemCount; i++) {
        final gridPos = gridPositions[i];
        final row = gridPos['row']!;
        final col = gridPos['col']!;

        final centerX = margin + (col * cellWidth) + (cellWidth / 2);
        final centerY = margin + (row * cellHeight) + (cellHeight / 2);

        final maxOffset = math.min(cellWidth, cellHeight) * jitterFactor;
        final offsetX = (random.nextDouble() - 0.5) * maxOffset;
        final offsetY = (random.nextDouble() - 0.5) * maxOffset;

        final finalX = (centerX + offsetX).clamp(margin, canvasSize - margin);
        final finalY = (centerY + offsetY).clamp(margin, canvasSize - margin);

        circles.add(CircleData(value: '$i', x: finalX, y: finalY));
      }
      return circles;
    }

    test('Layout should not have overlaps with proposed parameters', () {
      // Parameters I plan to use:
      // Margin: 20 (reduced from 40)
      // Grid: 6 (for 25 items)
      // Jitter: 0.15 (reduced from 0.25)
      // Circle Diameter: 75.0
      
      final circles = generateLayout(25, 20.0, 6, 0.15);
      
      int overlapCount = 0;
      double minDistance = double.infinity;

      for (int i = 0; i < circles.length; i++) {
        for (int j = i + 1; j < circles.length; j++) {
          final c1 = circles[i];
          final c2 = circles[j];
          final dx = c1.x - c2.x;
          final dy = c1.y - c2.y;
          final distance = math.sqrt(dx*dx + dy*dy);
          
          if (distance < minDistance) minDistance = distance;

          // Check for overlap (distance < sum of radii)
          // Radius = diameter / 2
          // Distance < diameter means overlap
          if (distance < circleDiameter) {
            overlapCount++;
            print('Overlap between ${c1.value} and ${c2.value}: Dist=$distance, Req=$circleDiameter');
          }
        }
      }

      print('Minimum Distance Found: $minDistance');
      print('Required Distance: $circleDiameter');
      
      expect(overlapCount, 0, reason: 'Found $overlapCount overlaps in layout');
      expect(minDistance, greaterThanOrEqualTo(circleDiameter));
    });

    test('Legacy broken layout should fail (validating the test)', () {
      // My previous "Fix" parameters which caused overlaps:
      // Margin: 40
      // Grid: 7
      // Jitter: 0.25
      // Circle Diameter: 93.5 (Old size)
      
      final circles = generateLayout(25, 40.0, 7, 0.25);
      
      int overlapCount = 0;
      const oldDiameter = 93.5;

      for (int i = 0; i < circles.length; i++) {
        for (int j = i + 1; j < circles.length; j++) {
          final c1 = circles[i];
          final c2 = circles[j];
          final distance = math.sqrt(math.pow(c1.x - c2.x, 2) + math.pow(c1.y - c2.y, 2));
          if (distance < oldDiameter) {
            overlapCount++;
          }
        }
      }
      
      print('Legacy Layout Overlaps: $overlapCount');
      expect(overlapCount, greaterThan(0));
    });
  });
}
