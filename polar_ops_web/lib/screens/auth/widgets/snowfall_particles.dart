import 'dart:math';
import 'package:flutter/material.dart';

class SnowfallParticles extends StatefulWidget {
  final int numberOfSnowflakes;
  const SnowfallParticles({
    super.key,
    this.numberOfSnowflakes = 40,
  });

  @override
  State<SnowfallParticles> createState() => _SnowfallParticlesState();
}

class _SnowfallParticlesState extends State<SnowfallParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Snowflake> _snowflakes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _snowflakes = List.generate(
      widget.numberOfSnowflakes,
      (_) => _Snowflake.random(_random),
    );
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
          size: Size.infinite,
          painter: _SnowfallPainter(
            snowflakes: _snowflakes,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Snowflake {
  double x;
  double y;
  double radius;
  double speed;
  double swayFrequency;
  double swayAmplitude;
  double opacity;

  _Snowflake({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.swayFrequency,
    required this.swayAmplitude,
    required this.opacity,
  });

  factory _Snowflake.random(Random random) {
    return _Snowflake(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: random.nextDouble() * 2.2 + 1.0,
      speed: random.nextDouble() * 0.12 + 0.04,
      swayFrequency: random.nextDouble() * 3.0 + 1.0,
      swayAmplitude: random.nextDouble() * 0.015 + 0.005,
      opacity: random.nextDouble() * 0.55 + 0.25,
    );
  }
}

class _SnowfallPainter extends CustomPainter {
  final List<_Snowflake> snowflakes;
  final double progress;

  _SnowfallPainter({
    required this.snowflakes,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final flake in snowflakes) {
      final currentY = (flake.y + progress * flake.speed * 8.0) % 1.0;
      final sway =
          sin((progress * 2 * pi * flake.swayFrequency) + flake.y * 10) *
              flake.swayAmplitude;
      final currentX = (flake.x + sway) % 1.0;

      final dx = currentX * size.width;
      final dy = currentY * size.height;

      paint.color = Colors.white.withValues(alpha: flake.opacity);
      canvas.drawCircle(Offset(dx, dy), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowfallPainter oldDelegate) => true;
}
