import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common.dart';

/// Ilustração vetorial decorativa, desenhada no próprio Flutter.
class AtlasGlobe extends StatelessWidget {
  const AtlasGlobe({super.key});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 290,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _GlobePainter())),
          _flag('br', const Alignment(-0.78, -0.58), -0.15),
          _flag('jp', const Alignment(0.85, -0.26), 0.14),
          _flag('fr', const Alignment(-0.55, 0.84), 0.1),
          const Align(
            alignment: Alignment(0.88, 0.78),
            child: Tag(
              text: '195 destinos',
              icon: Icons.explore_outlined,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _flag(String code, Alignment alignment, double angle) => Align(
    alignment: alignment,
    child: Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.text,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            'assets/flags/$code.png',
            width: 57,
            height: 37,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
  );
}

class _GlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius + 18,
      Paint()..color = AppColors.lime.withValues(alpha: 0.035),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF35504D), Color(0xFF203337)],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    final grid = Paint()
      ..color = AppColors.lime.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final fraction in [0.35, 0.7, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2 * fraction,
          height: radius * 2,
        ),
        grid,
      );
    }
    for (final offset in [-0.55, 0.0, 0.55]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(0, radius * offset),
          width: radius * 2,
          height: radius * 0.38,
        ),
        grid,
      );
    }
    void land(List<Offset> points) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final p = center + points[i] * radius;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()..color = AppColors.lime.withValues(alpha: 0.7),
      );
    }

    land(const [
      Offset(-0.95, -0.52),
      Offset(-0.61, -0.8),
      Offset(-0.24, -0.7),
      Offset(-0.31, -0.42),
      Offset(-0.53, -0.2),
      Offset(-0.42, 0.06),
      Offset(-0.6, 0.03),
      Offset(-0.73, -0.14),
    ]);
    land(const [
      Offset(-0.47, 0.08),
      Offset(-0.17, 0.19),
      Offset(-0.12, 0.37),
      Offset(-0.3, 0.68),
      Offset(-0.4, 0.88),
      Offset(-0.5, 0.47),
      Offset(-0.62, 0.17),
    ]);
    land(const [
      Offset(0.07, -0.22),
      Offset(0.35, -0.28),
      Offset(0.51, -0.02),
      Offset(0.37, 0.4),
      Offset(0.2, 0.61),
      Offset(0.06, 0.25),
      Offset(-0.08, 0.07),
    ]);
    land(const [
      Offset(0.04, -0.41),
      Offset(0.22, -0.69),
      Offset(0.51, -0.73),
      Offset(0.92, -0.53),
      Offset(0.96, -0.22),
      Offset(0.66, -0.02),
      Offset(0.49, -0.11),
      Offset(0.33, -0.42),
      Offset(0.18, -0.31),
    ]);
    land(const [
      Offset(0.66, 0.44),
      Offset(0.9, 0.39),
      Offset(1.03, 0.61),
      Offset(0.83, 0.73),
      Offset(0.63, 0.63),
    ]);
    canvas.restore();
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.lime.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final orbit = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.42);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2.7,
        height: radius * 0.85,
      ),
      0.12,
      math.pi * 0.95,
      false,
      orbit,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
