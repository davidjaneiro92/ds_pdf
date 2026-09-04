import 'package:flutter/material.dart';

/// Moldura de "desenho de linha" do sistema visual do documento de
/// referência: borda de 1px em `divider` e quatro marcas de registro `+`
/// nos cantos, em vez de preenchimento de superfície ou sombra. Usada em
/// cards, figuras e miniaturas em toda a UI (Início, Scanner, Meus
/// Arquivos, Editor de PDF, Texto→PDF).
class BlueprintFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double markSize;

  const BlueprintFrame({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.markSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final divider = borderColor ?? Theme.of(context).dividerColor;
    return Stack(
      children: [
        Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(color: divider),
          ),
          child: child,
        ),
        _mark(divider, top: -1, left: -1),
        _mark(divider, top: -1, right: -1),
        _mark(divider, bottom: -1, left: -1),
        _mark(divider, bottom: -1, right: -1),
      ],
    );
  }

  Widget _mark(Color color, {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: CustomPaint(
          size: Size.square(markSize),
          painter: _RegistrationMarkPainter(color: color),
        ),
      ),
    );
  }
}

class _RegistrationMarkPainter extends CustomPainter {
  final Color color;

  const _RegistrationMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final centro = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      Offset(centro.dx, 0),
      Offset(centro.dx, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, centro.dy),
      Offset(size.width, centro.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RegistrationMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
