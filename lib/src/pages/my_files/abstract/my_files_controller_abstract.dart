import '../../../models/pdf_document_model.dart';

abstract class MyFilesControllerAbstract {
  /// Total de documentos, para o chip "Todos · N" (ver R5 do replanejamento).
  int get totalDocumentos;

  /// Total de favoritos, para o chip "Favoritos · N".
  int get totalFavoritos;

  /// Total de documentos numa pasta, para o chip "<pasta> · N".
  int contagemPasta(String folderId);

  Future<void> carregar();
  Future<void> renomear(PdfDocumentModel documento, String novoNome);
  Future<void> excluir(PdfDocumentModel documento);
  Future<void> compartilhar(PdfDocumentModel documento);
  Future<void> alternarFavorito(PdfDocumentModel documento);
  Future<void> criarPasta(String nome);
  Future<void> moverParaPasta(PdfDocumentModel documento, String? folderId);
  Future<void> excluirPasta(String folderId);
}
