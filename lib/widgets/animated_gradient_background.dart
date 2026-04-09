import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _GradientPainter extends CustomPainter {
  final double progress;

  _GradientPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = math.sin(progress * 2 * math.pi);

    // Orb 1 — purple
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6C63FF).withOpacity(0.18 + pulse * 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.15, size.height * 0.25),
        radius: 320,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.25),
      320,
      paint1,
    );

    // Orb 2 — cyan
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.12 - pulse * 0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.6),
        radius: 280,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.6),
      280,
      paint2,
    );

    // Orb 3 — violet (bottom left)
    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFB044FF).withOpacity(0.10 + pulse * 0.02),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.4, size.height * 0.85),
        radius: 250,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.85),
      250,
      paint3,
    );
  }

  @override
  bool shouldRepaint(_GradientPainter old) => old.progress != progress;
}
