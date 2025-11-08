import 'dart:math' as math;

import 'package:brain_plan/domain/models/block_3d_shape.dart';
import 'package:flutter/material.dart' as material show Colors;
import 'package:flutter/material.dart' hide Colors;
import 'package:vector_math/vector_math_64.dart';

/// Custom painter for rendering 3D block shapes in isometric view
class Block3DPainter extends CustomPainter {

  Block3DPainter({
    required this.shape,
    this.blockColor = const Color(0xFF64B5F6), // Light blue
    this.edgeColor = const Color(0xFF1976D2), // Dark blue
    this.blockSize = 30.0,
    this.showShadow = true,
  });
  final Block3DShape shape;
  final Color blockColor;
  final Color edgeColor;
  final double blockSize;
  final bool showShadow;

  @override
  void paint(Canvas canvas, Size size) {
    // Center the shape
    final center = Offset(size.width / 2, size.height / 2);
    final shapeCenter = shape.center;

    // Isometric projection matrix (30° angle)
    const isoAngle = math.pi / 6; // 30 degrees
    final cosAngle = math.cos(isoAngle);
    final sinAngle = math.sin(isoAngle);

    // Sort blocks by depth (back to front) for proper rendering
    final sortedBlocks = [...shape.blocks];
    sortedBlocks.sort((a, b) {
      // Sort by distance from camera (simple depth sort)
      final depthA = -a.x + a.y - a.z;
      final depthB = -b.x + b.y - b.z;
      return depthA.compareTo(depthB);
    });

    // Draw shadow first if enabled
    if (showShadow) {
      _drawShadow(canvas, sortedBlocks, center, shapeCenter, blockSize, cosAngle, sinAngle);
    }

    // Draw each block
    for (final block in sortedBlocks) {
      _drawBlock(canvas, block, center, shapeCenter, blockSize, cosAngle, sinAngle);
    }
  }

  void _drawShadow(Canvas canvas, List<Vector3> blocks, Offset center, Vector3 shapeCenter,
      double blockSize, double cosAngle, double sinAngle) {
    final shadowPaint = Paint()
      ..color = material.Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (final block in blocks) {
      final adjusted = block - shapeCenter;
      final x = center.dx + (adjusted.x - adjusted.z) * blockSize * cosAngle;
      final y = center.dy + (adjusted.x + adjusted.z) * blockSize * sinAngle + blockSize * 2;

      // Draw simple shadow ellipse
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: blockSize * 1.5,
          height: blockSize * 0.5,
        ),
        shadowPaint,
      );
    }
  }

  void _drawBlock(Canvas canvas, Vector3 block, Offset center, Vector3 shapeCenter,
      double blockSize, double cosAngle, double sinAngle) {
    // Adjust block position relative to shape center
    final adjusted = block - shapeCenter;

    // Project 3D coordinates to 2D isometric view
    final x = center.dx + (adjusted.x - adjusted.z) * blockSize * cosAngle;
    final y = center.dy + (adjusted.x + adjusted.z) * blockSize * sinAngle - adjusted.y * blockSize;

    // Define the 3D cube vertices in isometric projection
    final vertices = _getCubeVertices(x, y, blockSize, cosAngle, sinAngle);

    // Draw faces with different shades for depth perception
    _drawFaces(canvas, vertices);
  }

  List<Offset> _getCubeVertices(double x, double y, double size, double cosAngle, double sinAngle) {
    // Isometric cube vertices
    final halfSize = size / 2;

    return [
      // Top face vertices (0-3)
      Offset(x, y - halfSize),                                    // 0: top center
      Offset(x + halfSize * cosAngle, y - halfSize + halfSize * sinAngle),  // 1: top right
      Offset(x, y),                                               // 2: center
      Offset(x - halfSize * cosAngle, y - halfSize + halfSize * sinAngle),  // 3: top left

      // Bottom face vertices (4-7)
      Offset(x, y + halfSize),                                    // 4: bottom center
      Offset(x + halfSize * cosAngle, y + halfSize + halfSize * sinAngle),  // 5: bottom right
      Offset(x, y + size),                                        // 6: bottom center-bottom
      Offset(x - halfSize * cosAngle, y + halfSize + halfSize * sinAngle),  // 7: bottom left
    ];
  }

  void _drawFaces(Canvas canvas, List<Offset> vertices) {
    // Top face (lightest)
    final topPaint = Paint()
      ..color = blockColor.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    final topPath = Path()
      ..moveTo(vertices[0].dx, vertices[0].dy)
      ..lineTo(vertices[1].dx, vertices[1].dy)
      ..lineTo(vertices[2].dx, vertices[2].dy)
      ..lineTo(vertices[3].dx, vertices[3].dy)
      ..close();
    canvas.drawPath(topPath, topPaint);

    // Right face (medium shade)
    final rightPaint = Paint()
      ..color = blockColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final rightPath = Path()
      ..moveTo(vertices[1].dx, vertices[1].dy)
      ..lineTo(vertices[2].dx, vertices[2].dy)
      ..lineTo(vertices[4].dx, vertices[4].dy)
      ..lineTo(vertices[5].dx, vertices[5].dy)
      ..close();
    canvas.drawPath(rightPath, rightPaint);

    // Left face (darkest)
    final leftPaint = Paint()
      ..color = blockColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final leftPath = Path()
      ..moveTo(vertices[3].dx, vertices[3].dy)
      ..lineTo(vertices[2].dx, vertices[2].dy)
      ..lineTo(vertices[4].dx, vertices[4].dy)
      ..lineTo(vertices[7].dx, vertices[7].dy)
      ..close();
    canvas.drawPath(leftPath, leftPaint);

    // Draw edges for definition
    final edgePaint = Paint()
      ..color = edgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw all edges
    canvas.drawPath(topPath, edgePaint);
    canvas.drawPath(rightPath, edgePaint);
    canvas.drawPath(leftPath, edgePaint);
  }

  @override
  bool shouldRepaint(Block3DPainter oldDelegate) {
    return oldDelegate.shape.id != shape.id ||
           oldDelegate.blockSize != blockSize;
  }
}

/// Widget for displaying a 3D block shape
class Block3DWidget extends StatelessWidget {

  const Block3DWidget({
    super.key,
    required this.shape,
    this.size = 150.0,
    this.blockColor = const Color(0xFF64B5F6),
    this.edgeColor = const Color(0xFF1976D2),
    this.showShadow = true,
    this.decoration,
  });
  final Block3DShape shape;
  final double size;
  final Color blockColor;
  final Color edgeColor;
  final bool showShadow;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: decoration ?? BoxDecoration(
        color: material.Colors.white,
        border: Border.all(color: material.Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: material.Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: Block3DPainter(
          shape: shape,
          blockColor: blockColor,
          edgeColor: edgeColor,
          blockSize: _calculateBlockSize(size, shape),
          showShadow: showShadow,
        ),
      ),
    );
  }

  double _calculateBlockSize(double containerSize, Block3DShape shape) {
    // Calculate appropriate block size based on shape bounds
    final bounds = shape.maxBounds - shape.minBounds;
    final maxDimension = math.max(
      math.max(bounds.x.abs(), bounds.y.abs()),
      bounds.z.abs(),
    );

    // Scale to fit in container with some padding
    return (containerSize * 0.7) / (maxDimension + 2);
  }
}

/// Widget for displaying a mental rotation task with reference and options
class MentalRotationTaskWidget extends StatelessWidget {

  const MentalRotationTaskWidget({
    super.key,
    required this.referenceShape,
    required this.options,
    required this.onOptionSelected,
    this.selectedIndex,
    this.instructions = 'Which shape is the same as the reference (just rotated)?',
  });
  final Block3DShape referenceShape;
  final List<Block3DShape> options;
  final int? selectedIndex;
  final Function(int) onOptionSelected;
  final String instructions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Instructions
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            instructions,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: material.Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Reference shape
        const SizedBox(height: 8),
        const Text(
          'Reference Shape:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: material.Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Block3DWidget(
          shape: referenceShape,
          size: 180,
          blockColor: const Color(0xFF64B5F6), // Light blue
          edgeColor: const Color(0xFF1976D2),
        ),

        const SizedBox(height: 24),
        const Text(
          'Which one matches?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: material.Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Options grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => onOptionSelected(index),
                child: Block3DWidget(
                  shape: options[index],
                  size: 140,
                  blockColor: isSelected
                      ? const Color(0xFF4CAF50) // Green when selected
                      : const Color(0xFF64B5F6), // Light blue
                  edgeColor: isSelected
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF1976D2),
                  decoration: BoxDecoration(
                    color: material.Colors.white,
                    border: Border.all(
                      color: isSelected ? material.Colors.green : material.Colors.grey.shade300,
                      width: isSelected ? 3 : 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? material.Colors.green.withOpacity(0.3)
                            : material.Colors.black.withOpacity(0.1),
                        blurRadius: isSelected ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
