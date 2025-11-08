import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

/// Represents a 3D block configuration for mental rotation tasks
class Block3DShape {

  Block3DShape({
    required this.id,
    required this.name,
    required this.blocks,
    required this.difficulty,
  });
  final String id;
  final String name;
  final List<Vector3> blocks; // Position of each unit cube
  final DifficultyLevel difficulty;

  /// Create a rotated version of this shape
  Block3DShape rotate(double angleX, double angleY, double angleZ) {
    final rotationMatrix = Matrix4.identity()
      ..rotateX(angleX)
      ..rotateY(angleY)
      ..rotateZ(angleZ);

    final rotatedBlocks = blocks.map((block) {
      final transformed = rotationMatrix.transform3(block);
      // Round to nearest 0.1 for better precision while maintaining comparability
      return Vector3(
        (transformed.x * 10).roundToDouble() / 10,
        (transformed.y * 10).roundToDouble() / 10,
        (transformed.z * 10).roundToDouble() / 10,
      );
    }).toList();

    return Block3DShape(
      id: '${id}_rot_${angleX.toStringAsFixed(2)}_${angleY.toStringAsFixed(2)}_${angleZ.toStringAsFixed(2)}',
      name: '$name (rotated)',
      blocks: rotatedBlocks,
      difficulty: difficulty,
    );
  }

  /// Create a mirror image (reflection) of this shape
  Block3DShape mirror(Axis axis) {
    final mirroredBlocks = blocks.map((block) {
      switch (axis) {
        case Axis.x:
          return Vector3(-block.x, block.y, block.z);
        case Axis.y:
          return Vector3(block.x, -block.y, block.z);
        case Axis.z:
          return Vector3(block.x, block.y, -block.z);
      }
    }).toList();

    return Block3DShape(
      id: '${id}_mirror_$axis',
      name: '$name (mirrored)',
      blocks: mirroredBlocks,
      difficulty: difficulty,
    );
  }

  /// Check if this shape is equivalent to another (accounting for floating point errors)
  bool isEquivalentTo(Block3DShape other) {
    if (blocks.length != other.blocks.length) return false;

    // Normalize both shapes to origin for comparison
    final thisNormalized = _normalizeToOrigin(blocks);
    final otherNormalized = _normalizeToOrigin(other.blocks);

    // Sort blocks by position for comparison
    final sortedBlocks = [...thisNormalized]..sort(_compareVectors);
    final sortedOtherBlocks = [...otherNormalized]..sort(_compareVectors);

    // Check if all blocks match within tolerance
    for (int i = 0; i < sortedBlocks.length; i++) {
      final diff = (sortedBlocks[i] - sortedOtherBlocks[i]).length;
      if (diff > 0.25) return false; // Tolerance for rotation rounding errors
    }

    return true;
  }

  /// Normalize shape to origin by centering it
  List<Vector3> _normalizeToOrigin(List<Vector3> blocks) {
    if (blocks.isEmpty) return blocks;

    // Find center
    Vector3 sum = Vector3.zero();
    for (final block in blocks) {
      sum += block;
    }
    final center = sum / blocks.length.toDouble();

    // Translate to origin
    return blocks.map((b) => b - center).toList();
  }

  /// Compare vectors for sorting
  static int _compareVectors(Vector3 a, Vector3 b) {
    const tolerance = 0.2;
    if ((a.x - b.x).abs() > tolerance) return a.x.compareTo(b.x);
    if ((a.y - b.y).abs() > tolerance) return a.y.compareTo(b.y);
    return a.z.compareTo(b.z);
  }

  /// Get bounding box for rendering
  Vector3 get minBounds {
    double minX = double.infinity, minY = double.infinity, minZ = double.infinity;
    for (final block in blocks) {
      minX = math.min(minX, block.x);
      minY = math.min(minY, block.y);
      minZ = math.min(minZ, block.z);
    }
    return Vector3(minX, minY, minZ);
  }

  Vector3 get maxBounds {
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity, maxZ = double.negativeInfinity;
    for (final block in blocks) {
      maxX = math.max(maxX, block.x);
      maxY = math.max(maxY, block.y);
      maxZ = math.max(maxZ, block.z);
    }
    return Vector3(maxX, maxY, maxZ);
  }

  Vector3 get center {
    final min = minBounds;
    final max = maxBounds;
    return (min + max) / 2;
  }
}

enum Axis { x, y, z }

enum DifficultyLevel { easy, medium, hard }

/// Predefined 3D shapes for mental rotation tasks
class Block3DShapes {
  /// Easy: 2-3 block L-shape (classic)
  static Block3DShape get easyLShape => Block3DShape(
    id: 'easy_l',
    name: 'L-Shape',
    blocks: [
      Vector3(0, 0, 0),
      Vector3(1, 0, 0),
      Vector3(0, 1, 0),
    ],
    difficulty: DifficultyLevel.easy,
  );

  /// Easy: Simple T-shape
  static Block3DShape get easyTShape => Block3DShape(
    id: 'easy_t',
    name: 'T-Shape',
    blocks: [
      Vector3(0, 0, 0),
      Vector3(-1, 0, 0),
      Vector3(1, 0, 0),
      Vector3(0, 1, 0),
    ],
    difficulty: DifficultyLevel.easy,
  );

  /// Medium: 4-block zigzag
  static Block3DShape get mediumZigzag => Block3DShape(
    id: 'medium_zigzag',
    name: 'Zigzag',
    blocks: [
      Vector3(0, 0, 0),
      Vector3(1, 0, 0),
      Vector3(1, 1, 0),
      Vector3(2, 1, 0),
    ],
    difficulty: DifficultyLevel.medium,
  );

  /// Medium: 5-block plus shape
  static Block3DShape get mediumPlus => Block3DShape(
    id: 'medium_plus',
    name: 'Plus',
    blocks: [
      Vector3(0, 0, 0),
      Vector3(1, 0, 0),
      Vector3(-1, 0, 0),
      Vector3(0, 1, 0),
      Vector3(0, -1, 0),
    ],
    difficulty: DifficultyLevel.medium,
  );

  /// Medium: 3D L with depth
  static Block3DShape get mediumL3D => Block3DShape(
    id: 'medium_l3d',
    name: '3D L-Shape',
    blocks: [
      Vector3(0, 0, 0),
      Vector3(1, 0, 0),
      Vector3(0, 1, 0),
      Vector3(0, 0, 1),
    ],
    difficulty: DifficultyLevel.medium,
  );

  /// Hard: 6-block complex shape
  static Block3DShape get hardComplex => Block3DShape(
    id: 'hard_complex',
    name: 'Complex Shape',
    blocks: [
      Vector3(0, 0, 0),
      Vector3(1, 0, 0),
      Vector3(1, 1, 0),
      Vector3(0, 1, 1),
      Vector3(1, 0, 1),
      Vector3(0, 0, 1),
    ],
    difficulty: DifficultyLevel.hard,
  );

  /// Hard: 7-block staircase
  static Block3DShape get hardStaircase => Block3DShape(
    id: 'hard_staircase',
    name: 'Staircase',
    blocks: [
      Vector3(0, 0, 0),
      Vector3(1, 0, 0),
      Vector3(1, 1, 0),
      Vector3(2, 1, 0),
      Vector3(2, 2, 0),
      Vector3(2, 2, 1),
      Vector3(3, 2, 1),
    ],
    difficulty: DifficultyLevel.hard,
  );

  /// Hard: 3D cross
  static Block3DShape get hard3DCross => Block3DShape(
    id: 'hard_3d_cross',
    name: '3D Cross',
    blocks: [
      Vector3(0, 0, 0),
      Vector3(1, 0, 0),
      Vector3(-1, 0, 0),
      Vector3(0, 1, 0),
      Vector3(0, -1, 0),
      Vector3(0, 0, 1),
      Vector3(0, 0, -1),
    ],
    difficulty: DifficultyLevel.hard,
  );

  /// Get all shapes for a difficulty level
  static List<Block3DShape> getShapesForDifficulty(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return [easyLShape, easyTShape];
      case DifficultyLevel.medium:
        return [mediumZigzag, mediumPlus, mediumL3D];
      case DifficultyLevel.hard:
        return [hardComplex, hardStaircase, hard3DCross];
    }
  }
}

/// Common rotation angles for mental rotation tasks
class RotationAngles {
  // Easy rotations (90 degree increments)
  static const easy = [
    [0.0, math.pi / 2, 0.0],  // 90° around Y
    [0.0, math.pi, 0.0],      // 180° around Y
    [0.0, -math.pi / 2, 0.0], // -90° around Y
    [math.pi / 2, 0.0, 0.0],  // 90° around X
  ];

  // Medium rotations (45 degree and multi-axis)
  static const medium = [
    [0.0, math.pi / 4, 0.0],        // 45° around Y
    [math.pi / 4, math.pi / 4, 0.0], // 45° around X and Y
    [0.0, 3 * math.pi / 4, 0.0],    // 135° around Y
    [math.pi / 2, math.pi / 2, 0.0], // 90° around X and Y
  ];

  // Hard rotations (complex multi-axis)
  static const hard = [
    [math.pi / 3, math.pi / 4, math.pi / 6],  // 60°, 45°, 30°
    [math.pi / 4, math.pi / 3, math.pi / 4],  // 45°, 60°, 45°
    [math.pi / 6, 2 * math.pi / 3, math.pi / 4], // 30°, 120°, 45°
    [math.pi / 2, math.pi / 4, math.pi / 3],  // 90°, 45°, 60°
  ];

  static List<List<double>> getRotationsForDifficulty(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return easy;
      case DifficultyLevel.medium:
        return medium;
      case DifficultyLevel.hard:
        return hard;
    }
  }
}
