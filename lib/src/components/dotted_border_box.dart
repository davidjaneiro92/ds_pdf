import 'package:flutter/material.dart';

/// Moldura tracejada (sem depender de pacote externo), desenhada com
/// `CustomPaint`. Usada nas células "Adicionar" do Scanner e "Nova página"
/// da tela Páginas de Texto→PDF — o documento de referência pede célula
/// tracejada para a ação de acrescentar item numa grade.
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color? color;

  const DottedBorderBox({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    final cor = color ?? Theme.of(context).colorScheme.primary.withOpacity(0.5);
    return CustomPaint(
      painter: _DashedRectPainter(color: cor),
      child: child,
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;

  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    // Cantos retos em todo o app (ver CustomColors.radiusZero), então o
    // tracejado segue um retângulo simples, sem raio.
    final path = Path()..addRect(Offset.zero & size);
    for (final metric in path.computeMetrics()) {
      const dashWidth = 5.0;
      const gapWidth = 4.0;
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color;
}
