import 'package:flutter/material.dart';
import 'dart:math' as math;

class M3LoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  const M3LoadingIndicator({super.key, this.size = 48.0, this.color});

  @override
  State<M3LoadingIndicator> createState() => _M3LoadingIndicatorState();
}

class _M3LoadingIndicatorState extends State<M3LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 3000,
      ), // Slower for better visibility
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _M3ExpressiveLoadingPainter(
              animationValue: _controller.value,
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class _M3ExpressiveLoadingPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _M3ExpressiveLoadingPainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Shape Definitions based on User Request
    // Types: 0=Circle, 1=Oval, 2=Polygon (Cookie), 3=Clover
    final shapes = [
      _ShapeDef(type: 0), // Circle
      _ShapeDef(type: 1), // Oval
      _ShapeDef(type: 2, points: 5), // Pentagon
      _ShapeDef(type: 2, points: 4), // 4-sided cookie
      _ShapeDef(type: 2, points: 6), // 6-sided cookie
      _ShapeDef(type: 2, points: 7), // 7-sided cookie
      _ShapeDef(type: 2, points: 9), // 9-sided cookie
      _ShapeDef(type: 3, points: 4), // 4-leaf clover
      _ShapeDef(type: 3, points: 8), // 8-leaf clover
    ];

    final segmentCount = shapes.length;
    // We want a continuous loop.
    final totalProgress = animationValue * segmentCount;
    final stage = totalProgress.floor() % segmentCount;
    final nextStage = (stage + 1) % segmentCount;
    final localT = totalProgress - totalProgress.floor();

    final currentShape = shapes[stage];
    final nextShape = shapes[nextStage];

    // Morph the path
    final path = _createMorphedPath(size, currentShape, nextShape, localT);

    // Draw the "Track" circle enclosing the shapes
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4; // Thickness of the enclosing circle

    // Draw track
    canvas.drawCircle(center, radius - 2, trackPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Expressive rotation
    final rotation = animationValue * 2 * math.pi;
    canvas.rotate(rotation);

    // Breathing scale for "enclosed in circle" feel
    // Morphing shape is smaller (0.65) to fit inside the track (1.0) without touching
    final scale = 0.65 + 0.10 * math.sin(animationValue * 4 * math.pi);
    canvas.scale(scale);

    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  Path _createMorphedPath(
    Size size,
    _ShapeDef shapeA,
    _ShapeDef shapeB,
    double t,
  ) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();
    const int resolution = 360; // High res for smooth curves

    final morphT = Curves.easeInOutCubic.transform(t);

    for (int i = 0; i <= resolution; i++) {
      final angle = (i / resolution) * 2 * math.pi;

      final rA = _getRadiusForShape(angle, shapeA, radius);
      final rB = _getRadiusForShape(angle, shapeB, radius);

      final r = rA * (1 - morphT) + rB * morphT;

      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  double _getRadiusForShape(double angle, _ShapeDef shape, double maxRadius) {
    switch (shape.type) {
      case 0: // Circle
        return maxRadius;
      case 1: // Oval
        // Ellipse with 0.75 aspect ratio
        final a = maxRadius;
        final b = maxRadius * 0.75;
        return (a * b) /
            math.sqrt(
              math.pow(b * math.cos(angle), 2) +
                  math.pow(a * math.sin(angle), 2),
            );
      case 2: // Polygon (Cookie)
        return _getRoundedPolygonRadius(angle, shape.points, maxRadius);
      case 3: // Clover (Star)
        return _getCloverRadius(angle, shape.points, maxRadius);
      default:
        return maxRadius;
    }
  }

  double _getRoundedPolygonRadius(double angle, int sides, double baseRadius) {
    // Standard polygon radius
    final section = (2 * math.pi) / sides;
    final theta = angle % section;
    final rSharp =
        baseRadius *
        math.cos(math.pi / sides) /
        math.cos(theta - math.pi / sides);

    // High smoothing for "Cookie" look (Squircle-ish)
    // User specifically requested rounded corners.
    // 0.7 guarantees very soft corners.
    const smoothing = 0.7;
    return rSharp * (1 - smoothing) + baseRadius * smoothing;
  }

  double _getCloverRadius(double angle, int leaves, double baseRadius) {
    // Clover logic:
    // r = R * (base + amp * cos(n * theta))
    // We align the leaves. Using cosine creates smooth, round lobes automatically.
    return baseRadius * (0.8 + 0.2 * math.cos(leaves * angle));
  }

  @override
  bool shouldRepaint(_M3ExpressiveLoadingPainter oldDelegate) => true;
}

class _ShapeDef {
  final int type; // 0=Circle, 1=Oval, 2=Polygon, 3=Clover
  final int points;

  _ShapeDef({required this.type, this.points = 0});
}
