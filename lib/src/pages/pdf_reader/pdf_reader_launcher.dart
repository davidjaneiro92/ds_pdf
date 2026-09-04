import 'dart:io';

import 'package:get/get.dart';

import '../../components/custom_toast.dart';
import '../../enum/pages_routes.dart';
import '../../models/pdf_document_model.dart';
import '../../services/pdf_file_picker.dart';
import 'controller/pdf_reader_controller.dart';

/// Pontos de entrada do leitor de PDF, num só lugar porque três telas
/// diferentes abrem a mesma rota: Início ("Abrir PDF" e "Recentes"), Meus
/// Arquivos (toque num item) e o próprio sistema ("Abrir com", ver
/// `IncomingPdf`).
abstract class PdfReaderLauncher {
  /// Abre um documento que já está registrado em Meus Arquivos.
  static Future<void> abrirDocumento(PdfDocumentModel documento) {
    return Get.toNamed(
          PagesRoutes.pdfReaderView.path,
          arguments: PdfReaderArgs(
            path: documento.path,
            titulo: documento.displayName,
            documento: documento,
          ),
        ) ??
        Future.value();
  }

  /// Abre um PDF avulso do aparelho (ainda não está em Meus Arquivos).
  /// Devolve `false` se o arquivo não existir mais no caminho informado.
  static Future<bool> abrirArquivo(String caminho) async {
    if (!await File(caminho).exists()) {
      CustomToast().showToasts(
        messagem: 'O arquivo não foi encontrado.',
        status: status.error,
      );
      return false;
    }
    await Get.toNamed(
      PagesRoutes.pdfReaderView.path,
      arguments: PdfReaderArgs(
        path: caminho,
        titulo: Uri.file(caminho).pathSegments.last,
      ),
    );
    return true;
  }

  /// Abre o seletor de arquivos do sistema e, se o usuário escolher um PDF,
  /// abre o leitor. Cancelar não mostra nada — não é erro.
  static Future<void> escolherEAbrir() async {
    final caminho = await PdfFilePicker.escolher();
    if (caminho == null) return;
    await abrirArquivo(caminho);
  }
}
