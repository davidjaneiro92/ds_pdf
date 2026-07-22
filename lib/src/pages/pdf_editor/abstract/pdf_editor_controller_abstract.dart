abstract class PdfEditorControllerAbstract {
  Future<void> carregar();
  void reordenarPagina(int oldIndex, int newIndex);
  void excluirPagina(int index);
  void definirAssinatura(List<int> pngBytes);
  void definirPaginaDaAssinatura(int index);
  Future<void> salvar();
}
