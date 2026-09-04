import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

import '../../../components/custom_toast.dart';
import '../../../components/loading/controller/loading_controller.dart';
import '../../../enum/pages_routes.dart';
import '../../../repositories/pdf_documents_repository.dart';
import '../../../services/content_uri_reader.dart';
import '../abstract/scanner_controller_abstract.dart';

class ScannerController extends GetxController
    implements ScannerControllerAbstract {
  final RxList<String> paginas = <String>[].obs;
  final _scanner = FlutterDocScanner();

  @override
  Future<void> escanearDocumento() async {
    await Permission.camera.request();

    try {
      final resultado = await _scanner.getScannedDocumentAsImages(page: 20);
      debugPrint('ScannerController: resultado do scan = $resultado');
      if (resultado != null && resultado.images.isNotEmpty) {
        paginas.addAll(resultado.images);
      } else {
        // O usuário cancelou o scanner, ou o scanner nativo (Google Play
        // Services) falhou internamente sem lançar exceção — acontece em
        // alguns aparelhos ao escanear mais de uma vez na mesma sessão do
        // app (bug conhecido do play-services-mlkit-document-scanner, fora
        // do nosso controle). Avisamos o usuário em vez de falhar em
        // silêncio, para não parecer que o app travou.
        CustomToast().showToasts(
          messagem: 'A página não foi escaneada. Tente novamente.',
          status: status.warner,
        );
      }
    } catch (e) {
      CustomToast().showToasts(
        messagem: 'Não foi possível escanear o documento.',
        status: status.error,
      );
    }
  }

  @override
  Future<void> gerarPDF() async {
    if (paginas.isEmpty) return;

    final loadingController = Get.find<LoadingController>();
    loadingController.showLoading(mensagem: 'Gerando PDF', cancelavel: true);

    try {
      final pdf = pw.Document();
      final total = paginas.length;

      for (var i = 0; i < total; i++) {
        if (loadingController.foiCancelado) {
          throw GeracaoCanceladaException();
        }
        loadingController.atualizarProgresso(i + 1, total);

        final bytes = await ContentUriReader.readBytes(paginas[i]);
        final image = pw.MemoryImage(bytes);

        pdf.addPage(
          pw.Page(
            build: (ctx) => pw.Center(
              child: pw.Image(image),
            ),
          ),
        );
      }

      final dir = await getApplicationDocumentsDirectory();
      final filename = 'ds_pdf_scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File("${dir.path}/$filename");

      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      await Get.find<PdfDocumentsRepository>().registrarDocumento(
        fileName: filename,
        path: file.path,
        createdAt: DateTime.now(),
        pageCount: paginas.length,
      );

      limparPaginas();

      loadingController.mostrarSucesso(
        nomeArquivo: filename,
        aoCompartilhar: () => Printing.sharePdf(bytes: bytes, filename: filename),
        aoVerEmMeusArquivos: () => Get.toNamed(PagesRoutes.myFilesView.path),
      );
    } on GeracaoCanceladaException {
      loadingController.hideLoading();
      CustomToast().showToasts(
        messagem: 'Geração de PDF cancelada.',
        status: status.warner,
      );
    } catch (e) {
      debugPrint('ScannerController.gerarPDF falhou: $e');
      loadingController.mostrarErro(
        causa: 'Verifique se há espaço de armazenamento disponível no '
            'aparelho e tente novamente.',
        aoTentarNovamente: gerarPDF,
      );
    }
  }

  @override
  void limparPaginas() {
    paginas.clear();
  }
}
