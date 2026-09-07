import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import '../../../components/custom_toast.dart';
import '../../../components/loading/controller/loading_controller.dart';
import '../../../models/pdf_document_model.dart';
import '../../../repositories/pdf_documents_repository.dart';
import '../abstract/pdf_editor_controller_abstract.dart';

class PdfEditorController extends GetxController
    implements PdfEditorControllerAbstract {
  PdfEditorController(this.documentoOriginal);

  final PdfDocumentModel documentoOriginal;

  final RxBool carregando = true.obs;

  /// Índices das páginas originais, na ordem/seleção atual do editor.
  final RxList<int> ordemPaginas = <int>[].obs;

  /// Miniaturas indexadas pelo índice da página original (não muda com reordenação).
  final RxList<Uint8List> miniaturas = <Uint8List>[].obs;

  final Rx<Uint8List?> assinatura = Rx<Uint8List?>(null);

  /// Índice dentro de [ordemPaginas] que vai receber a assinatura.
  final RxInt paginaDaAssinatura = 0.obs;

  Uint8List? _bytesOriginais;

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  @override
  Future<void> carregar() async {
    carregando.value = true;
    try {
      _bytesOriginais = await File(documentoOriginal.path).readAsBytes();

      final novasMiniaturas = <Uint8List>[];
      await for (final pagina in Printing.raster(_bytesOriginais!, dpi: 72)) {
        novasMiniaturas.add(await pagina.toPng());
      }

      miniaturas.assignAll(novasMiniaturas);
      ordemPaginas.assignAll(List.generate(novasMiniaturas.length, (i) => i));
      paginaDaAssinatura.value =
          ordemPaginas.isEmpty ? 0 : ordemPaginas.length - 1;
    } catch (e) {
      CustomToast().showToasts(
        messagem: 'Não foi possível abrir o PDF para edição.',
        status: status.error,
      );
    } finally {
      carregando.value = false;
    }
  }

  @override
  void reordenarPagina(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final pagina = ordemPaginas.removeAt(oldIndex);
    ordemPaginas.insert(newIndex, pagina);
  }

  @override
  void excluirPagina(int index) {
    if (ordemPaginas.length <= 1) {
      CustomToast().showToasts(
        messagem: 'O PDF precisa ter ao menos uma página.',
        status: status.warner,
      );
      return;
    }
    ordemPaginas.removeAt(index);
    if (paginaDaAssinatura.value >= ordemPaginas.length) {
      paginaDaAssinatura.value = ordemPaginas.length - 1;
    }
  }

  @override
  void definirAssinatura(List<int> pngBytes) {
    assinatura.value = Uint8List.fromList(pngBytes);
  }

  @override
  void definirPaginaDaAssinatura(int index) {
    paginaDaAssinatura.value = index;
  }

  @override
  Future<void> salvar() async {
    if (ordemPaginas.isEmpty || _bytesOriginais == null) return;

    final loadingController = Get.find<LoadingController>();
    loadingController.showLoading();

    sf.PdfDocument? original;
    sf.PdfDocument? novo;
    try {
      original = sf.PdfDocument(inputBytes: _bytesOriginais!);
      novo = sf.PdfDocument();
      // `pages.insert(indice, tamanho, margens)` lança "Null check
      // operator used on a null value" em qualquer chamada, no Syncfusion
      // 27.2.5 e 29.1.38 (ver specs/CHANGELOG.md, 2026-09-05). O caminho
      // que funciona é `pageSettings` + `pages.add()`.
      novo.pageSettings.margins.all = 0;

      for (final indiceOriginal in ordemPaginas) {
        final template = original.pages[indiceOriginal].createTemplate();
        novo.pageSettings.size = template.size;
        final novaPagina = novo.pages.add();
        novaPagina.graphics.drawPdfTemplate(template, Offset.zero);
      }

      final assinaturaBytes = assinatura.value;
      if (assinaturaBytes != null) {
        final paginaAlvo = novo.pages[paginaDaAssinatura.value];
        final tamanho = paginaAlvo.graphics.size;
        const largura = 150.0;
        const altura = 60.0;
        const margem = 24.0;
        paginaAlvo.graphics.drawImage(
          sf.PdfBitmap(assinaturaBytes),
          Rect.fromLTWH(
            tamanho.width - largura - margem,
            tamanho.height - altura - margem,
            largura,
            altura,
          ),
        );
      }

      final bytesFinais = await novo.save();

      final dir = await getApplicationDocumentsDirectory();
      final nomeBase = documentoOriginal.fileName.replaceAll('.pdf', '');
      final filename =
          '${nomeBase}_editado_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final arquivo = File("${dir.path}/$filename");
      await arquivo.writeAsBytes(bytesFinais);

      await Get.find<PdfDocumentsRepository>().registrarDocumento(
        fileName: filename,
        path: arquivo.path,
        createdAt: DateTime.now(),
      );

      CustomToast().showToasts(
        messagem: 'PDF editado salvo com sucesso.',
        status: status.success,
      );
      Get.back();
    } catch (e) {
      CustomToast().showToasts(
        messagem: 'Não foi possível salvar o PDF editado.',
        status: status.error,
      );
    } finally {
      novo?.dispose();
      original?.dispose();
      loadingController.hideLoading();
    }
  }
}
