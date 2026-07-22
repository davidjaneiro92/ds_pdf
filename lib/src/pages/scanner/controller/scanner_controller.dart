import 'dart:io';

import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:uri_to_file/uri_to_file.dart';

import '../../../components/custom_toast.dart';
import '../../../components/loading/controller/loading_controller.dart';
import '../../../repositories/pdf_documents_repository.dart';
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
      if (resultado != null && resultado.images.isNotEmpty) {
        paginas.assignAll(resultado.images);
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
    loadingController.showLoading();

    try {
      final pdf = pw.Document();

      for (final uri in paginas) {
        final arquivo = await toFile(uri);
        final bytes = await arquivo.readAsBytes();
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
      );

      await Printing.sharePdf(bytes: bytes, filename: filename);

      limparPaginas();
    } catch (e) {
      CustomToast().showToasts(
        messagem: 'Não foi possível gerar o PDF.',
        status: status.error,
      );
    } finally {
      loadingController.hideLoading();
    }
  }

  @override
  void limparPaginas() {
    paginas.clear();
  }
}
