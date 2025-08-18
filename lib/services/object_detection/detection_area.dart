import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final double imageWidth;
  final double imageHeight;

  TrianglePainter({required this.imageWidth, required this.imageHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red.withOpacity(0.3) // Red semi-transparent overlay
      ..style = PaintingStyle.fill;

    // Define the triangle points
    final Offset topPoint = Offset(imageWidth/2.4, imageHeight*0.3); // Apex (bottom center)
    final Offset bottomLeft = Offset(imageWidth*0.1, imageHeight*0.60); // Bottom-left corner
    final Offset bottomRight = Offset(imageWidth*0.75, imageHeight*0.60); // Bottom-right corner

    final Path path = Path()
      ..moveTo(topPoint.dx, topPoint.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}