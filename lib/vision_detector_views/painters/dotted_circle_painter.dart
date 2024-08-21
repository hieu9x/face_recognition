import 'dart:math';

import 'package:flutter/material.dart';

class DottedCirclePainter extends CustomPainter {
  final double radius;
  final double angle;

  DottedCirclePainter({required this.radius, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0;

    double dashWidth = 1.6;
    double dashSpace = 1.8;
    Path circlePath = Path();

    for (double i = -90; i < 270; i += dashSpace + dashWidth) {
      circlePath.addArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius),
        i * pi / 180,
        dashWidth * pi / 180,
      );
    }

    Paint donePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0;

    Path yellowPath = Path();
    for (double i = -90; i < angle; i += dashSpace + dashWidth) {
      yellowPath.addArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius),
        i * pi / 180,
        dashWidth * pi / 180,
      );
    }

    canvas.drawPath(circlePath, paint);
    canvas.drawPath(yellowPath, donePaint);
  }

  @override
  bool shouldRepaint(DottedCirclePainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
