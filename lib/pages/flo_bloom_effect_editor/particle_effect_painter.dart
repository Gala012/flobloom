import 'dart:math' as math;
import 'package:flutter/material.dart';

class Particle {
  final double s1;
  final double s2;
  final double s3;
  final double s4;
  const Particle(this.s1, this.s2, this.s3, this.s4);
}

class ParticleEffectPainter extends CustomPainter {
  final String effectType;
  final double animValue;
  final double density;
  final double speed;
  final double opacity;
  final List<Particle> particles;
  const ParticleEffectPainter({
    required this.effectType,
    required this.animValue,
    required this.density,
    required this.speed,
    required this.opacity,
    required this.particles,
  });
  @override
  void paint(Canvas canvas, Size size) {
    if (effectType == 'None' || particles.isEmpty) return;
    if (size.width <= 0 || size.height <= 0 || !size.isFinite) return;
    final count = (particles.length * density / 100).ceil().clamp(
      1,
      particles.length,
    );
    final speedMult = (speed / 50).clamp(0.2, 3.0);
    final opacityMult = (opacity / 100).clamp(0.0, 1.0);
    for (var i = 0; i < count; i++) {
      final p = particles[i];
      final t = (animValue * speedMult + p.s1) % 1.0;
      try {
        switch (effectType) {
          case 'Petals':
            _drawPetal(canvas, size, p, t, opacityMult);
            break;
          case 'Firefly':
            _drawFirefly(canvas, size, p, t, opacityMult);
            break;
          case 'Stars':
            _drawStar(canvas, size, p, t, opacityMult);
            break;
          case 'Hearts':
            _drawHeart(canvas, size, p, t, opacityMult);
            break;
          case 'Glow':
            _drawGlow(canvas, size, p, t, opacityMult);
            break;
        }
      } catch (e) {
        continue;
      }
    }
  }

  void _drawPetal(Canvas canvas, Size size, Particle p, double t, double om) {
    final x =
        (p.s2 + math.sin(t * math.pi * 4 + p.s3 * math.pi) * 0.08) * size.width;
    final y = t * size.height * 1.1 - size.height * 0.05;
    final alpha = math.sin(t * math.pi).clamp(0.0, 1.0) * om;
    if (alpha <= 0.01) return;
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(t * math.pi * 3 + p.s4 * math.pi);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 7 + p.s3 * 6,
        height: 12 + p.s4 * 6,
      ),
      Paint()
        ..color = Color.fromRGBO(230, 110, 170, alpha)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  void _drawFirefly(Canvas canvas, Size size, Particle p, double t, double om) {
    final cx = p.s2 * size.width;
    final cy = p.s3 * size.height;
    final r = 28.0 + p.s4 * 22;
    final x = cx + math.cos(t * math.pi * 2 + p.s4 * math.pi) * r;
    final y = cy + math.sin(t * math.pi * 3 + p.s3 * math.pi) * r * 0.6;
    final glow = (math.sin(t * math.pi * 6 + p.s2 * math.pi) + 1) / 2;
    canvas.drawCircle(
      Offset(x, y),
      14,
      Paint()
        ..color = Color.fromRGBO(170, 255, 170, glow * 0.28 * om)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawCircle(
      Offset(x, y),
      2.5,
      Paint()..color = Color.fromRGBO(200, 255, 200, glow * om),
    );
  }

  void _drawStar(Canvas canvas, Size size, Particle p, double t, double om) {
    final x = p.s2 * size.width;
    final y = p.s3 * size.height;
    final alpha = ((math.sin(t * math.pi * 5 + p.s4 * math.pi) + 1) / 2) * om;
    if (alpha <= 0.01) return;
    final radius = 1.5 + p.s4 * 2.5;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()..color = Color.fromRGBO(255, 245, 200, alpha),
    );
    final len = radius * 2.8;
    canvas.drawLine(
      Offset(x - len, y),
      Offset(x + len, y),
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, alpha * 0.6)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(x, y - len),
      Offset(x, y + len),
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, alpha * 0.6)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawHeart(Canvas canvas, Size size, Particle p, double t, double om) {
    final x = (p.s2 * 0.8 + 0.1) * size.width;
    final y = size.height * (1.05 - t) - 10;
    final alpha = math.sin(t * math.pi).clamp(0.0, 1.0) * om;
    if (alpha <= 0.01) return;
    final s = 5.0 + p.s3 * 5;
    _drawHeartShape(
      canvas,
      Offset(x, y),
      s,
      Color.fromRGBO(240, 90, 130, alpha),
    );
  }

  void _drawHeartShape(Canvas canvas, Offset c, double s, Color color) {
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.4)
      ..cubicTo(
        c.dx - s,
        c.dy - s * 0.2,
        c.dx - s,
        c.dy - s * 0.8,
        c.dx,
        c.dy - s * 0.4,
      )
      ..cubicTo(
        c.dx + s,
        c.dy - s * 0.8,
        c.dx + s,
        c.dy - s * 0.2,
        c.dx,
        c.dy + s * 0.4,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawGlow(Canvas canvas, Size size, Particle p, double t, double om) {
    final x = p.s2 * size.width;
    final y = p.s3 * size.height;
    final alpha =
        ((math.sin(t * math.pi * 2 + p.s4 * math.pi) + 1) / 2) * om * 0.55;
    final radius = 35.0 + p.s4 * 45;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()
        ..color = Color.fromRGBO(245, 205, 235, alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.75),
    );
  }

  @override
  bool shouldRepaint(ParticleEffectPainter old) => true;
}
