import 'package:flutter/material.dart';

/// Network Console logosu: koyu kutuda altin nabiz cizgisi. Tema ne olursa
/// olsun ayni renkler - marka isareti. Geometri tools/make_icon.py ile ayni
/// (150x150 kutu); biri degisirse digeri de.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: const CustomPaint(painter: _LogoPainter()));
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  static const _bg = Color(0xFF17140C);
  static const _border = Color(0xFF4A3A18);
  static const _glow = Color(0xFF6B5221);
  static const _line = Color(0xFFF2C14E);
  static const _pulse = [
    Offset(22, 78), Offset(52, 78), Offset(64, 52), Offset(80, 108),
    Offset(94, 62), Offset(104, 78), Offset(128, 78),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 150;
    final rect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(34 * s));
    canvas.drawRRect(rect, Paint()..color = _bg);
    canvas.drawRRect(
      rect.deflate(s),
      Paint()
        ..color = _border
        ..style = PaintingStyle.stroke
        ..strokeWidth = (2 * s).clamp(.6, 4),
    );
    final path = Path()..moveTo(_pulse.first.dx * s, _pulse.first.dy * s);
    for (final p in _pulse.skip(1)) {
      path.lineTo(p.dx * s, p.dy * s);
    }
    // Kucuk boyutlarda (title bar) cizgi kaybolmasin.
    final lineW = (6 * s).clamp(1.5, double.infinity);
    for (final (w, color) in [(lineW * 2, _glow), (lineW, _line)]) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
