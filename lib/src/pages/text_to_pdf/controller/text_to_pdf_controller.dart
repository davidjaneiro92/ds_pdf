import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../components/custom_toast.dart';
import '../../../components/loading/controller/loading_controller.dart';
import '../../../enum/pdf_font_option.dart';
import '../../../enum/pdf_text_align_option.dart';
import '../../../repositories/pdf_documents_repository.dart';
import '../abstract/text_to_pdf_controller_abstract.dart';

class TextToPdfController extends GetxController
    implements TextToPdfControllerAbstract {
  final corpoController = TextEditingController();
  final cabecalhoController = TextEditingController();
  final rodapeController = TextEditingController();

  final Rx<PdfFontOption> fonte = PdfFontOption.helvetica.obs;
  final Rx<PdfTextAlignOption> alinhamento = PdfTextAlignOption.esquerda.obs;

  @override
  Future<void> gerarPDF() async {
    final corpo = corpoController.text.trim();
    if (corpo.isEmpty) {
      CustomToast().showToasts(
        messagem: 'Digite algum texto antes de gerar o PDF.',
        status: status.warner,
      );
      return;
    }

    final loadingController = Get.find<LoadingController>();
    loadingController.showLoading();

    try {
      final cabecalho = cabecalhoController.text.trim();
      final rodape = rodapeController.text.trim();
      final estilo = pw.TextStyle(font: fonte.value.font, fontSize: 12);

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: cabecalho.isEmpty
              ? null
              : (context) => pw.Text(cabecalho, style: estilo),
          footer: rodape.isEmpty
              ? null
              : (context) => pw.Text(rodape, style: estilo),
          build: (context) => [
            pw.Text(
              corpo,
              style: estilo,
              textAlign: alinhamento.value.align,
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final filename = 'ds_pdf_texto_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File("${dir.path}/$filename");

      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      await Get.find<PdfDocumentsRepository>().registrarDocumento(
        fileName: filename,
        path: file.path,
        createdAt: DateTime.now(),
      );

      await Printing.sharePdf(bytes: bytes, filename: filename);
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
  void onClose() {
    corpoController.dispose();
    cabecalhoController.dispose();
    rodapeController.dispose();
    super.onClose();
  }
}
