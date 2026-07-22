abstract class ScannerControllerAbstract {
  Future<void> escanearDocumento();
  Future<void> gerarPDF();
  void limparPaginas();
}
