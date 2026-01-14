import 'dart:io';

import 'package:ds_pdf/src/pages/select_PDF_type/abstract/select_PDF_type_contoller_abstract.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

import '../../../components/loading/controller/loading_controller.dart';


class SelectPdfTypeContoller extends GetxController
    implements SelectPdfTypeContollerAbstract {
  final ImagePicker _picker = ImagePicker();
  List<XFile> imagens = [];

  Future<void> selecionarImagens() async {
    final loadingController = Get.find<LoadingController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadingController.showLoading();
    });
    // Pedir permissão
    await Permission.photos.request();
    await Permission.storage.request();

    final List<XFile>? selecionadas = await _picker.pickMultiImage();

    if (selecionadas != null) {

        imagens = selecionadas;
       await gerarPDF();


    }
        loadingController.hideLoading();
  }

  Future<void> gerarPDF() async {
    if (imagens.isEmpty) return;

    final pdf = pw.Document();

    for (var img in imagens) {
      final bytes = await img.readAsBytes();
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
    final file = File("${dir.path}/gerado.pdf");

    await file.writeAsBytes(await pdf.save());

    // Compartilhar
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'gerado.pdf');
  }

}