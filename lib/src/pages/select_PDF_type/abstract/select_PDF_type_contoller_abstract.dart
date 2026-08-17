import 'package:get/get.dart';

import '../../../models/pdf_document_model.dart';

abstract class SelectPdfTypeContollerAbstract {
  /// Últimos PDFs gerados, para a seção "Recentes" da tela inicial.
  RxList<PdfDocumentModel> get recentes;

  Future<void> selecionarImagens();
  Future<void> gerarPDF();
  Future<void> carregarRecentes();
}