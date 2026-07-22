import '../../../models/pdf_document_model.dart';

abstract class MyFilesControllerAbstract {
  Future<void> carregar();
  Future<void> renomear(PdfDocumentModel documento, String novoNome);
  Future<void> excluir(PdfDocumentModel documento);
  Future<void> compartilhar(PdfDocumentModel documento);
  Future<void> alternarFavorito(PdfDocumentModel documento);
  Future<void> criarPasta(String nome);
  Future<void> moverParaPasta(PdfDocumentModel documento, String? folderId);
  Future<void> excluirPasta(String folderId);
}
