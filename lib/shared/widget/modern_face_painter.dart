import 'package:flutter/material.dart';

class ModernFacePainter extends CustomPainter {
  final Color color;
  final double laserPos;

  ModernFacePainter({required this.color, required this.laserPos});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    final radius = size.width * 0.35;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addOval(rect)
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black.withOpacity(0.75),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    double dy = center.dy + (((laserPos * 2) - 1) * radius * 0.8);
    canvas.drawLine(
      Offset(center.dx - (radius * 0.7), dy),
      Offset(center.dx + (radius * 0.7), dy),
      Paint()
        ..color = color.withOpacity(0.6)
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    final cp = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    double len = 30;
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + len)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.left + len, rect.top),
      cp,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - len, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.top + len),
      cp,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.right, rect.bottom - len)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.right - len, rect.bottom),
      cp,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.left + len, rect.bottom)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.bottom - len),
      cp,
    );
  }

  @override
  bool shouldRepaint(covariant ModernFacePainter oldDelegate) => true;
}