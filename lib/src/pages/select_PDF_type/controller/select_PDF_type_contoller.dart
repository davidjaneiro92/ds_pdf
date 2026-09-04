import 'dart:io';

import 'package:ds_pdf/src/pages/select_PDF_type/abstract/select_PDF_type_contoller_abstract.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

import '../../../components/custom_toast.dart';
import '../../../components/loading/controller/loading_controller.dart';
import '../../../enum/pages_routes.dart';
import '../../../models/pdf_document_model.dart';
import '../../../repositories/pdf_documents_repository.dart';


class SelectPdfTypeContoller extends GetxController
    implements SelectPdfTypeContollerAbstract {
  final ImagePicker _picker = ImagePicker();
  List<XFile> imagens = [];

  @override
  final RxList<PdfDocumentModel> recentes = <PdfDocumentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    carregarRecentes();
  }

  @override
  Future<void> carregarRecentes() async {
    final todos = await Get.find<PdfDocumentsRepository>().listarDocumentos();
    recentes.assignAll(todos.take(3));
  }

  @override
  Future<void> selecionarImagens() async {
    // Pedir permissão
    await Permission.photos.request();
    await Permission.storage.request();

    final List<XFile>? selecionadas = await _picker.pickMultiImage();

    if (selecionadas != null && selecionadas.isNotEmpty) {
      imagens = selecionadas;
      await gerarPDF();
    }
  }

  @override
  Future<void> gerarPDF() async {
    if (imagens.isEmpty) return;

    final loadingController = Get.find<LoadingController>();
    loadingController.showLoading(mensagem: 'Gerando PDF', cancelavel: true);

    try {
      final pdf = pw.Document();
      final total = imagens.length;

      for (var i = 0; i < total; i++) {
        if (loadingController.foiCancelado) {
          throw GeracaoCanceladaException();
        }
        loadingController.atualizarProgresso(i + 1, total);

        final bytes = await imagens[i].readAsBytes();
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
      final filename = 'ds_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File("${dir.path}/$filename");

      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      await Get.find<PdfDocumentsRepository>().registrarDocumento(
        fileName: filename,
        path: file.path,
        createdAt: DateTime.now(),
        pageCount: imagens.length,
      );

      imagens = [];
      await carregarRecentes();

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
      loadingController.mostrarErro(
        causa: 'Verifique se há espaço de armazenamento disponível no '
            'aparelho e tente novamente.',
        aoTentarNovamente: gerarPDF,
      );
    }
  }
}