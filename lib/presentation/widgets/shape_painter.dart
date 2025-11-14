import 'package:flutter/material.dart';

/// Custom painter for drawing rotated shapes accurately
/// Used in spatial awareness exercises to avoid Unicode character inconsistencies
class ShapePainter extends CustomPainter {
  final String shapeType;
  final int rotation;
  final Color color;

  ShapePainter({
    required this.shapeType,
    required this.rotation,
    this.color = Colors.black87,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    // Save canvas state before rotating
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 3.14159 / 180); // Convert degrees to radians
    canvas.translate(-center.dx, -center.dy);

    switch (shapeType) {
      case 'L':
        _drawLShape(canvas, size, paint);
        break;
      case 'wedge':
      case 'triangle-right':
        _drawRightTriangle(canvas, size, paint);
        break;
      case 'triangle':
        _drawEquilateralTriangle(canvas, size, paint);
        break;
      case 'rectangle':
        _drawRectangle(canvas, size, paint);
        break;
      case 'cube':
        _drawCube(canvas, size, paint);
        break;
      default:
        _drawLShape(canvas, size, paint);
    }

    canvas.restore();
  }

  void _drawLShape(Canvas canvas, Size size, Paint paint) {
    // Draw L-shape with corner at bottom-left
    // Vertical part: 2/3 height
    // Horizontal part: 2/3 width
    final path = Path();

    final w = size.width * 0.6;
    final h = size.height * 0.6;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final thickness = w / 3;

    // Start at bottom-left corner
    path.moveTo(centerX - w/2, centerY + h/2);
    // Up the vertical part
    path.lineTo(centerX - w/2, centerY - h/2);
    // Right along the top of vertical
    path.lineTo(centerX - w/2 + thickness, centerY - h/2);
    // Down to where horizontal starts
    path.lineTo(centerX - w/2 + thickness, centerY + h/2 - thickness);
    // Right along horizontal part
    path.lineTo(centerX + w/2, centerY + h/2 - thickness);
    // Down to bottom
    path.lineTo(centerX + w/2, centerY + h/2);
    // Back to start
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawRightTriangle(Canvas canvas, Size size, Paint paint) {
    // Draw right triangle with right angle at bottom-left
    final path = Path();

    final w = size.width * 0.6;
    final h = size.height * 0.6;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Right angle at bottom-left
    path.moveTo(centerX - w/2, centerY + h/2); // Bottom-left (right angle)
    path.lineTo(centerX - w/2, centerY - h/2); // Top-left
    path.lineTo(centerX + w/2, centerY + h/2); // Bottom-right
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawEquilateralTriangle(Canvas canvas, Size size, Paint paint) {
    // Draw equilateral triangle pointing up
    final path = Path();

    final w = size.width * 0.6;
    final h = size.height * 0.6;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Top point
    path.moveTo(centerX, centerY - h/2);
    // Bottom-right
    path.lineTo(centerX + w/2, centerY + h/2);
    // Bottom-left
    path.lineTo(centerX - w/2, centerY + h/2);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawRectangle(Canvas canvas, Size size, Paint paint) {
    // Draw rectangle (wider than tall for 0° and 180°)
    final w = size.width * 0.7;
    final h = size.height * 0.4;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: w,
      height: h,
    );

    canvas.drawRect(rect, paint);
  }

  void _drawCube(Canvas canvas, Size size, Paint paint) {
    // Draw isometric cube
    final w = size.width * 0.4;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final path = Path();

    // Front face (center square)
    path.moveTo(centerX - w/2, centerY - w/4);
    path.lineTo(centerX + w/2, centerY - w/4);
    path.lineTo(centerX + w/2, centerY + w/4);
    path.lineTo(centerX - w/2, centerY + w/4);
    path.close();

    // Top face
    path.moveTo(centerX - w/2, centerY - w/4);
    path.lineTo(centerX, centerY - w/2);
    path.lineTo(centerX + w, centerY - w/2);
    path.lineTo(centerX + w/2, centerY - w/4);

    // Right face
    path.moveTo(centerX + w/2, centerY - w/4);
    path.lineTo(centerX + w, centerY - w/2);
    path.lineTo(centerX + w, centerY);
    path.lineTo(centerX + w/2, centerY + w/4);

    canvas.drawPath(path, paint);

    // Draw edges for depth
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) {
    return oldDelegate.shapeType != shapeType ||
        oldDelegate.rotation != rotation ||
        oldDelegate.color != color;
  }
}

/// Widget wrapper for ShapePainter
class ShapeWidget extends StatelessWidget {
  final String shapeType;
  final int rotation;
  final double size;
  final Color color;

  const ShapeWidget({
    super.key,
    required this.shapeType,
    required this.rotation,
    this.size = 80,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ShapePainter(
          shapeType: shapeType,
          rotation: rotation,
          color: color,
        ),
      ),
    );
  }
}
