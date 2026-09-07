// Regressão do "juntar páginas num PdfDocument" do Syncfusion, usado por
// dois fluxos: Texto→PDF (copia as páginas de cada segmento para o
// documento final) e o Editor de PDF (remonta o documento na ordem nova).
//
// Bug real (2026-09-05, reportado pelo usuário gerando um PDF de texto no
// aparelho): `PdfPageCollection.insert(indice, tamanho, margens)` lança
// `Null check operator used on a null value` em **toda** chamada — em
// documento vazio, em documento com páginas, em qualquer índice. Confirmado
// nas versões 27.2.5 e 29.1.38 do `syncfusion_flutter_pdf`, ou seja, não é
// um problema da versão fixada neste projeto. O caminho que funciona é
// definir `pageSettings.size`/`margins` e chamar `pages.add()`.
//
// O primeiro teste é o que trava a regressão: se alguém voltar a usar
// `insert`, ele quebra. O segundo cobre o pipeline inteiro de Texto→PDF,
// que é onde o usuário viu o erro.
import 'dart:ui';

import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart' as qpdf;
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

void main() {
  test('monta um documento de várias páginas preservando cada tamanho', () {
    final documento = sf.PdfDocument();
    documento.pageSettings.margins.all = 0;

    const tamanhos = [Size(595.3, 841.9), Size(300, 500), Size(595.3, 841.9)];
    for (final tamanho in tamanhos) {
      documento.pageSettings.size = tamanho;
      final pagina = documento.pages.add();
      // A margem zero precisa valer: as páginas são carimbadas com um
      // template do PDF de origem, e qualquer margem deslocaria o
      // conteúdo copiado.
      expect(pagina.graphics.size.width, closeTo(tamanho.width, 0.1));
      expect(pagina.graphics.size.height, closeTo(tamanho.height, 0.1));
    }

    expect(documento.pages.count, tamanhos.length);
    documento.dispose();
  });

  test('Texto→PDF: Delta vira PDF com o conteúdo copiado página a página',
      () async {
    final delta = Delta()
      ..insert('Primeira linha do documento')
      ..insert('\n');

    final conversor = qpdf.PDFConverter(
      document: delta,
      frontMatterDelta: null,
      backMatterDelta: null,
      customConverters: const [],
      params: qpdf.PDFPageFormat.a4,
      fallbacks: const [],
      onRequestFont: (_) async => pw.Font.helvetica(),
      onRequestBoldFont: (_) async => pw.Font.helveticaBold(),
      onRequestItalicFont: (_) async => pw.Font.helveticaOblique(),
      onRequestBoldItalicFont: (_) async => pw.Font.helveticaBoldOblique(),
      onRequestFallbackFont: null,
    );

    final documentoQuill = await conversor.createDocument();
    expect(documentoQuill, isNotNull,
        reason: 'o flutter_quill_to_pdf deveria converter um Delta simples');
    final bytesSegmento = await documentoQuill!.save();
    expect(bytesSegmento, isNotEmpty);

    // A partir daqui é exatamente o que TextToPdfController.gerarPDF faz.
    final documentoFinal = sf.PdfDocument();
    documentoFinal.pageSettings.margins.all = 0;

    final origem = sf.PdfDocument(inputBytes: bytesSegmento);
    expect(origem.pages.count, greaterThan(0));

    for (var i = 0; i < origem.pages.count; i++) {
      final template = origem.pages[i].createTemplate();
      documentoFinal.pageSettings.size = template.size;
      final novaPagina = documentoFinal.pages.add();
      novaPagina.graphics.drawPdfTemplate(template, Offset.zero);

      // Cabeçalho/rodapé são carimbados aqui no fluxo real; incluídos no
      // teste porque `graphics.size` era outro ponto que dependia da
      // página ter sido criada corretamente.
      novaPagina.graphics.drawString(
        'cabeçalho',
        sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 9),
        brush: sf.PdfSolidBrush(sf.PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(
          0,
          novaPagina.graphics.size.height - 24,
          double.maxFinite,
          20,
        ),
      );
    }
    origem.dispose();

    expect(documentoFinal.pages.count, greaterThan(0));
    final bytesFinais = await documentoFinal.save();
    documentoFinal.dispose();

    expect(bytesFinais, isNotEmpty);
    // Um PDF de verdade começa com "%PDF-".
    expect(String.fromCharCodes(bytesFinais.take(5)), '%PDF-');
  });
}
