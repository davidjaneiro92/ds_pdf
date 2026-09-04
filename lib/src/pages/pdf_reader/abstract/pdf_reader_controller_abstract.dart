import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Contrato da tela de leitura de PDF (mesmo padrão abstract/controller/view
/// das demais features).
abstract class PdfReaderControllerAbstract extends GetxController {
  PdfViewerController get viewerController;

  RxInt get paginaAtual;
  RxInt get totalPaginas;
  RxnString get erro;

  /// `true` enquanto o arquivo aberto ainda não existe em Meus Arquivos
  /// (PDF externo, aberto pelo botão "Abrir PDF" ou por "Abrir com").
  RxBool get podeSalvar;

  void irParaPagina(int pagina);
  void paginaAnterior();
  void proximaPagina();

  Future<void> compartilhar();
  Future<void> salvarEmMeusArquivos();
}
