import 'package:pdf/widgets.dart' as pw;

enum PdfFontOption {
  helvetica('Helvetica'),
  times('Times'),
  courier('Courier');

  final String label;
  const PdfFontOption(this.label);

  pw.Font get font {
    switch (this) {
      case PdfFontOption.helvetica:
        return pw.Font.helvetica();
      case PdfFontOption.times:
        return pw.Font.times();
      case PdfFontOption.courier:
        return pw.Font.courier();
    }
  }
}
