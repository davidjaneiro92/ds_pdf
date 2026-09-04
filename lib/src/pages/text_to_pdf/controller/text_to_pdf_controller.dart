import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart' as qpdf;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import '../../../components/custom_toast.dart';
import '../../../components/loading/controller/loading_controller.dart';
import '../../../enum/pages_routes.dart';
import '../../../enum/pdf_font_option.dart';
import '../../../repositories/pdf_documents_repository.dart';
import '../abstract/text_to_pdf_controller_abstract.dart';

/// Tipo do embed customizado usado como quebra de página manual (botão
/// "Nova página" da barra de formatação — ver `especificacao/
/// replanejamento/`, seção 6.1). Cada ocorrência divide o documento em um
/// segmento próprio na geração do PDF (ver [_dividirEmSegmentos]), então a
/// quebra manual é sempre 1:1 com o PDF final — diferente da contagem de
/// páginas do rodapé, que é uma estimativa (ver [_recalcularContadores]).
const String tipoEmbedQuebraDePagina = 'page_break';

class TextToPdfController extends GetxController
    implements TextToPdfControllerAbstract {
  late final QuillController quillController;
  final cabecalhoController = TextEditingController();
  final rodapeController = TextEditingController();

  final Rx<PdfFontOption> fonte = PdfFontOption.helvetica.obs;
  final RxInt tamanhoFonte = 12.obs;
  final RxInt paginaCountEstimado = 1.obs;
  final RxInt palavraCount = 0.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    quillController = QuillController.basic();
    quillController.document.changes.listen((_) => _agendarRecalculo());
  }

  @override
  void inserirQuebraDePagina() {
    final index = quillController.selection.baseOffset;
    quillController.replaceText(
      index,
      0,
      const BlockEmbed(tipoEmbedQuebraDePagina, 'quebra'),
      TextSelection.collapsed(offset: index + 1),
    );
  }

  void _agendarRecalculo() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _recalcularContadores);
  }

  /// Contagem de páginas do rodapé ("2 páginas / A4 · 318 palavras") é uma
  /// **estimativa** por número de caracteres — não a paginação real que o
  /// `flutter_quill_to_pdf` vai calcular ao gerar o PDF. Medir com precisão
  /// pixel-a-pixel exigiria reimplementar o layout multi-estilo do editor a
  /// cada tecla digitada, com risco real de bugs de cursor/seleção; a
  /// estimativa por caracteres avisa o usuário do crescimento do documento
  /// sem esse risco. As quebras de página **manuais** (botão "Nova
  /// página"), por outro lado, são exatas — contam 1 segmento a mais cada.
  void _recalcularContadores() {
    final texto = quillController.document.toPlainText();
    final semEspacos = texto.trim();
    palavraCount.value =
        semEspacos.isEmpty ? 0 : semEspacos.split(RegExp(r'\s+')).length;

    const capacidadeEm12pt = 2800;
    final fatorTamanho = (12 / tamanhoFonte.value) * (12 / tamanhoFonte.value);
    final capacidadePorSegmento =
        (capacidadeEm12pt * fatorTamanho).round().clamp(200, 20000);

    final segmentos = dividirEmSegmentos();
    var totalEstimado = 0;
    for (final segmento in segmentos) {
      final tamanho = segmento.toList().fold<int>(
            0,
            (soma, op) => soma + (op.data is String ? (op.data as String).length : 0),
          );
      totalEstimado += (tamanho / capacidadePorSegmento).ceil().clamp(1, 999999);
    }
    paginaCountEstimado.value = totalEstimado.clamp(1, 999999);
  }

  /// Divide o Delta do documento em sub-Deltas nos pontos de quebra de
  /// página manual, removendo o embed da quebra em si. Usado tanto para a
  /// contagem estimada quanto para a geração real do PDF (cada segmento
  /// vira um `pw.MultiPage` próprio, forçando início de página nova).
  List<Delta> dividirEmSegmentos() {
    final segmentos = <Delta>[];
    var atual = Delta();
    for (final op in quillController.document.toDelta().toList()) {
      if (op.isInsert &&
          op.data is Map &&
          (op.data as Map).containsKey(tipoEmbedQuebraDePagina)) {
        segmentos.add(atual);
        atual = Delta();
        continue;
      }
      atual.push(op);
    }
    segmentos.add(atual);
    return segmentos;
  }

  /// Texto plano de um segmento (ver [dividirEmSegmentos]) — usado como
  /// pré-visualização na tela "Páginas".
  String previewSegmento(Delta segmento) => Document.fromDelta(segmento).toPlainText();

  @override
  Future<void> gerarPDF() async {
    final temConteudo = quillController.document.toPlainText().trim().isNotEmpty;
    if (!temConteudo) {
      CustomToast().showToasts(
        messagem: 'Digite algum texto antes de gerar o PDF.',
        status: status.warner,
      );
      return;
    }

    final loadingController = Get.find<LoadingController>();
    loadingController.showLoading(mensagem: 'Gerando PDF');

    try {
      final segmentos = dividirEmSegmentos();
      final formato = qpdf.PDFPageFormat.a4;
      final documentoFinal = sf.PdfDocument();
      final margensSemBorda = sf.PdfMargins()..all = 0;
      final cabecalho = cabecalhoController.text.trim();
      final rodape = rodapeController.text.trim();
      final fonteCabecalhoRodape = sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 9);
      final pincel = sf.PdfSolidBrush(sf.PdfColor(0, 0, 0));

      for (final segmento in segmentos) {
        if (segmento.isEmpty) continue;
        // API mais antiga do flutter_quill_to_pdf (presa em 1.2.2 por
        // compatibilidade com Flutter 3.24.5 — ver comentário no
        // pubspec.yaml) pede um Future<pw.Font> por combinação de
        // negrito/itálico em vez de um único callback unificado. Cada
        // segmento vira seu próprio `pw.Document`, depois suas páginas são
        // copiadas (via Syncfusion, mesmo padrão do Editor de PDF) para o
        // documento final — garante que a quebra manual sempre inicia
        // página nova, já que cada `pw.Document` sempre começa do zero.
        final converter = qpdf.PDFConverter(
          document: segmento,
          frontMatterDelta: null,
          backMatterDelta: null,
          customConverters: const [],
          params: formato,
          fallbacks: const [],
          onRequestFont: (_) async => _resolverFonte(negrito: false, italico: false),
          onRequestBoldFont: (_) async => _resolverFonte(negrito: true, italico: false),
          onRequestItalicFont: (_) async => _resolverFonte(negrito: false, italico: true),
          onRequestBoldItalicFont: (_) async => _resolverFonte(negrito: true, italico: true),
          onRequestFallbackFont: null,
        );
        final doc = await converter.createDocument();
        if (doc == null) continue;
        final bytesSegmento = await doc.save();
        if (bytesSegmento.isEmpty) continue;

        final origem = sf.PdfDocument(inputBytes: bytesSegmento);
        for (var i = 0; i < origem.pages.count; i++) {
          final template = origem.pages[i].createTemplate();
          final novaPagina = documentoFinal.pages
              .insert(documentoFinal.pages.count, template.size, margensSemBorda);
          novaPagina.graphics.drawPdfTemplate(template, const Offset(0, 0));
          if (cabecalho.isNotEmpty) {
            novaPagina.graphics.drawString(
              cabecalho,
              fonteCabecalhoRodape,
              brush: pincel,
              bounds: const Rect.fromLTWH(0, 8, double.maxFinite, 20),
            );
          }
          if (rodape.isNotEmpty) {
            novaPagina.graphics.drawString(
              rodape,
              fonteCabecalhoRodape,
              brush: pincel,
              bounds: Rect.fromLTWH(
                0,
                novaPagina.graphics.size.height - 24,
                double.maxFinite,
                20,
              ),
            );
          }
        }
        origem.dispose();
      }

      if (documentoFinal.pages.count == 0) {
        documentoFinal.dispose();
        throw Exception('Nenhuma página foi gerada.');
      }

      final totalPaginas = documentoFinal.pages.count;
      final bytesFinais = Uint8List.fromList(await documentoFinal.save());
      documentoFinal.dispose();

      final dir = await getApplicationDocumentsDirectory();
      final filename = 'ds_pdf_texto_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File("${dir.path}/$filename");
      await file.writeAsBytes(bytesFinais);

      await Get.find<PdfDocumentsRepository>().registrarDocumento(
        fileName: filename,
        path: file.path,
        createdAt: DateTime.now(),
        pageCount: totalPaginas,
      );

      loadingController.mostrarSucesso(
        nomeArquivo: filename,
        aoCompartilhar: () => Printing.sharePdf(bytes: bytesFinais, filename: filename),
        aoVerEmMeusArquivos: () => Get.toNamed(PagesRoutes.myFilesView.path),
      );
    } catch (e) {
      debugPrint('TextToPdfController.gerarPDF falhou: $e');
      loadingController.mostrarErro(
        causa: 'Verifique se há espaço de armazenamento disponível no '
            'aparelho e tente novamente.',
        aoTentarNovamente: gerarPDF,
      );
    }
  }

  pw.Font _resolverFonte({required bool negrito, required bool italico}) {
    switch (fonte.value) {
      case PdfFontOption.times:
        if (negrito && italico) return pw.Font.timesBoldItalic();
        if (negrito) return pw.Font.timesBold();
        if (italico) return pw.Font.timesItalic();
        return pw.Font.times();
      case PdfFontOption.courier:
        if (negrito && italico) return pw.Font.courierBoldOblique();
        if (negrito) return pw.Font.courierBold();
        if (italico) return pw.Font.courierOblique();
        return pw.Font.courier();
      case PdfFontOption.helvetica:
        if (negrito && italico) return pw.Font.helveticaBoldOblique();
        if (negrito) return pw.Font.helveticaBold();
        if (italico) return pw.Font.helveticaOblique();
        return pw.Font.helvetica();
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    cabecalhoController.dispose();
    rodapeController.dispose();
    quillController.dispose();
    super.onClose();
  }
}
