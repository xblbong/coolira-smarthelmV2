import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Widget gauge score melingkar dengan custom painter
/// Menampilkan skor berkendara (0-100) dalam bentuk arc gauge
class GaugeScoreWidget extends StatelessWidget {
  final int score;
  final double size;
  final String label;

  const GaugeScoreWidget({
    super.key,
    required this.score,
    this.size = 160,
    this.label = 'Skor Berkendara',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _GaugePainter(
              score: score,
              backgroundColor: AppColors.lightGrey,
              activeColor: AppColors.deepBlue,
              activeGradient: AppColors.accentGrad,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: size * 0.25,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '/ 100',
                    style: TextStyle(
                      fontSize: size * 0.075,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int score;
  final Color backgroundColor;
  final Color activeColor;
  final LinearGradient activeGradient;

  _GaugePainter({
    required this.score,
    required this.backgroundColor,
    required this.activeColor,
    required this.activeGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 12;
    const strokeWidth = 14.0;
    const startAngle = 3 * pi / 4; // 135 derajat
    const sweepAngle = 3 * pi / 2; // 270 derajat (3/4 lingkaran)

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Active arc dengan gradient
    final progress = score / 100;
    final activeSweep = sweepAngle * progress;

    final gradientShader = activeGradient.createShader(
      Rect.fromCircle(center: center, radius: radius),
    );

    final activePaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep,
      false,
      activePaint,
    );

    // Titik indicator di ujung arc
    final dotAngle = startAngle + activeSweep;
    final dotX = center.dx + radius * cos(dotAngle);
    final dotY = center.dy + radius * sin(dotAngle);

    final dotPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    // Outer glow
    canvas.drawCircle(
      Offset(dotX, dotY),
      8,
      Paint()
        ..color = activeColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );

    // Dot
    canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);

    // Tick marks kecil di sepanjang arc
    final tickPaint = Paint()
      ..color = AppColors.darkGrey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= 10; i++) {
      final tickAngle = startAngle + (sweepAngle / 10) * i;
      final outerR = radius + strokeWidth / 2 + 2;
      final innerR = radius + strokeWidth / 2 + 6;
      final x1 = center.dx + outerR * cos(tickAngle);
      final y1 = center.dy + outerR * sin(tickAngle);
      final x2 = center.dx + innerR * cos(tickAngle);
      final y2 = center.dy + innerR * sin(tickAngle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
