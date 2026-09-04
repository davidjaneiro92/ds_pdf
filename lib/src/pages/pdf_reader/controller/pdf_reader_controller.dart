import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../components/custom_toast.dart';
import '../../../models/pdf_document_model.dart';
import '../../../repositories/pdf_documents_repository.dart';
import '../abstract/pdf_reader_controller_abstract.dart';

/// Argumento da rota do leitor. Um PDF pode chegar de três lugares:
///
/// - de Meus Arquivos / Recentes — aí [documento] vem preenchido e o arquivo
///   já está no diretório do app;
/// - do botão "Abrir PDF" (seletor de arquivos do sistema);
/// - de outro app, por "Abrir com" (ver `IncomingPdf`).
///
/// Nos dois últimos casos [documento] é `null`: o arquivo é externo, pode
/// estar num cache temporário, e o leitor oferece "Salvar em Meus Arquivos".
class PdfReaderArgs {
  final String path;
  final String titulo;
  final PdfDocumentModel? documento;

  const PdfReaderArgs({
    required this.path,
    required this.titulo,
    this.documento,
  });
}

class PdfReaderController extends GetxController
    implements PdfReaderControllerAbstract {
  final PdfReaderArgs args;

  PdfReaderController(this.args);

  final _repository = Get.find<PdfDocumentsRepository>();

  @override
  final PdfViewerController viewerController = PdfViewerController();

  @override
  final RxInt paginaAtual = 1.obs;

  @override
  final RxInt totalPaginas = 0.obs;

  @override
  final RxnString erro = RxnString();

  @override
  late final RxBool podeSalvar = (args.documento == null).obs;

  /// Busca de texto no documento. `null` enquanto ninguém pesquisou nada.
  final Rxn<PdfTextSearchResult> resultadoBusca = Rxn<PdfTextSearchResult>();
  final RxBool modoBusca = false.obs;
  final RxString termoBusca = ''.obs;

  File get arquivo => File(args.path);

  // Ciclo de vida do documento -------------------------------------------

  void aoCarregar(PdfDocumentLoadedDetails detalhes) {
    totalPaginas.value = detalhes.document.pages.count;
    erro.value = null;
  }

  void aoFalhar(PdfDocumentLoadFailedDetails detalhes) {
    // O visualizador já mostra um aviso próprio para senha/corrompido; aqui
    // guardamos a causa para o rodapé poder sumir em vez de mostrar
    // "página 1 de 0".
    erro.value = detalhes.description.isNotEmpty
        ? detalhes.description
        : detalhes.error;
  }

  void aoMudarPagina(PdfPageChangedDetails detalhes) {
    paginaAtual.value = detalhes.newPageNumber;
  }

  // Navegação -------------------------------------------------------------

  @override
  void irParaPagina(int pagina) {
    if (pagina < 1 || pagina > totalPaginas.value) return;
    viewerController.jumpToPage(pagina);
  }

  @override
  void paginaAnterior() => irParaPagina(paginaAtual.value - 1);

  @override
  void proximaPagina() => irParaPagina(paginaAtual.value + 1);

  // Busca -----------------------------------------------------------------

  void alternarBusca() {
    modoBusca.value = !modoBusca.value;
    if (!modoBusca.value) limparBusca();
  }

  void pesquisar(String termo) {
    termoBusca.value = termo;
    resultadoBusca.value?.clear();
    if (termo.trim().isEmpty) {
      resultadoBusca.value = null;
      return;
    }
    resultadoBusca.value = viewerController.searchText(termo.trim());
  }

  void ocorrenciaAnterior() => resultadoBusca.value?.previousInstance();

  void proximaOcorrencia() => resultadoBusca.value?.nextInstance();

  void limparBusca() {
    resultadoBusca.value?.clear();
    resultadoBusca.value = null;
    termoBusca.value = '';
  }

  // Ações -----------------------------------------------------------------

  @override
  Future<void> compartilhar() async {
    try {
      final bytes = await arquivo.readAsBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: arquivo.uri.pathSegments.last,
      );
    } catch (e) {
      debugPrint('PdfReaderController.compartilhar falhou: $e');
      CustomToast().showToasts(
        messagem: 'Não foi possível compartilhar este PDF.',
        status: status.error,
      );
    }
  }

  @override
  Future<void> salvarEmMeusArquivos() async {
    if (!podeSalvar.value) return;
    try {
      final destinoDir = await getApplicationDocumentsDirectory();
      final nomeOriginal = arquivo.uri.pathSegments.last;
      // Prefixo com timestamp garante nome único mesmo abrindo duas vezes o
      // mesmo arquivo — o id do documento no Hive é o nome do arquivo.
      final nomeArquivo =
          'ds_pdf_${DateTime.now().millisecondsSinceEpoch}_$nomeOriginal';
      final destino = File('${destinoDir.path}/$nomeArquivo');
      await destino.writeAsBytes(await arquivo.readAsBytes());

      await _repository.registrarDocumento(
        fileName: nomeArquivo,
        path: destino.path,
        createdAt: DateTime.now(),
        pageCount: totalPaginas.value,
      );

      podeSalvar.value = false;
      CustomToast().showToasts(
        messagem: 'Salvo em Meus Arquivos.',
        status: status.success,
      );
    } catch (e) {
      debugPrint('PdfReaderController.salvarEmMeusArquivos falhou: $e');
      CustomToast().showToasts(
        messagem: 'Não foi possível salvar o arquivo.',
        status: status.error,
      );
    }
  }

  @override
  void onClose() {
    resultadoBusca.value?.clear();
    viewerController.dispose();
    super.onClose();
  }
}
