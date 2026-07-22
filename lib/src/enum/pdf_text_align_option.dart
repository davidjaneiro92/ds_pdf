import 'package:pdf/widgets.dart' as pw;

enum PdfTextAlignOption {
  esquerda('Esquerda'),
  centro('Centro'),
  direita('Direita'),
  justificado('Justificado');

  final String label;
  const PdfTextAlignOption(this.label);

  pw.TextAlign get align {
    switch (this) {
      case PdfTextAlignOption.esquerda:
        return pw.TextAlign.left;
      case PdfTextAlignOption.centro:
        return pw.TextAlign.center;
      case PdfTextAlignOption.direita:
        return pw.TextAlign.right;
      case PdfTextAlignOption.justificado:
        return pw.TextAlign.justify;
    }
  }
}
