import 'dart:math' as math;

import 'package:brain_plan/domain/models/block_3d_shape.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('Block3DShape', () {
    test('should consider identical shapes as equivalent', () {
      // Arrange
      final shape1 = Block3DShape(
        id: 'test1',
        name: 'Test',
        blocks: [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0)],
        difficulty: DifficultyLevel.easy,
      );
      final shape2 = Block3DShape(
        id: 'test2',
        name: 'Test',
        blocks: [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0)],
        difficulty: DifficultyLevel.easy,
      );

      // Assert
      expect(shape1.isEquivalentTo(shape2), isTrue);
    });

    test('should create rotated shapes', () {
      // Arrange
      final originalShape = Block3DShapes.easyLShape;

      // Act - Just verify rotation doesn't throw
      final rotatedShape = originalShape.rotate(0.0, math.pi / 2, 0.0);

      // Assert - Verify we get a valid shape back
      expect(rotatedShape.blocks.length, equals(originalShape.blocks.length));
      expect(rotatedShape.id, contains('rot'));
    });

    test('should handle rotation operations', () {
      // Arrange
      final shape = Block3DShapes.easyLShape;

      // Act - Verify various rotations work
      final rotatedX = shape.rotate(math.pi / 4, 0.0, 0.0);
      final rotatedY = shape.rotate(0.0, math.pi / 4, 0.0);
      final rotatedZ = shape.rotate(0.0, 0.0, math.pi / 4);

      // Assert - All rotations produce valid shapes
      expect(rotatedX.blocks.length, equals(shape.blocks.length));
      expect(rotatedY.blocks.length, equals(shape.blocks.length));
      expect(rotatedZ.blocks.length, equals(shape.blocks.length));
    });
  });
}
