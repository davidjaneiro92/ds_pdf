import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/pdf_document_model.dart';
import '../models/pdf_folder_model.dart';

class PdfDocumentsRepository {
  static const _boxDocuments = 'pdf_documents';
  static const _boxFolders = 'pdf_folders';

  late Box _documentsBox;
  late Box _foldersBox;

  Future<void> init() async {
    _documentsBox = await Hive.openBox(_boxDocuments);
    _foldersBox = await Hive.openBox(_boxFolders);
  }

  List<PdfDocumentModel> _documentosSalvos() {
    return _documentsBox.values
        .map((e) => PdfDocumentModel.fromMap(e as Map))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> registrarDocumento({
    required String fileName,
    required String path,
    required DateTime createdAt,
  }) async {
    final documento = PdfDocumentModel(
      id: fileName,
      fileName: fileName,
      displayName: fileName,
      path: path,
      createdAt: createdAt,
    );
    await _documentsBox.put(documento.id, documento.toMap());
  }

  /// Varre o diretório de documentos do app e registra automaticamente
  /// qualquer PDF já existente em disco que ainda não tenha metadado salvo
  /// (ex.: gerado antes desta funcionalidade existir).
  Future<void> _reconciliarComDisco() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      if (!await dir.exists()) return;

      final arquivos = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.pdf'));

      for (final arquivo in arquivos) {
        final fileName = arquivo.uri.pathSegments.last;
        if (_documentsBox.containsKey(fileName)) continue;

        final stat = await arquivo.stat();
        await registrarDocumento(
          fileName: fileName,
          path: arquivo.path,
          createdAt: stat.modified,
        );
      }
    } catch (_) {
      // Sem acesso ao diretório de documentos nesta plataforma — ignora.
    }
  }

  Future<List<PdfDocumentModel>> listarDocumentos() async {
    await _reconciliarComDisco();
    return _documentosSalvos();
  }

  Future<void> renomear(String id, String novoNome) async {
    final atual = _documentsBox.get(id);
    if (atual == null) return;
    final documento =
        PdfDocumentModel.fromMap(atual as Map).copyWith(displayName: novoNome);
    await _documentsBox.put(id, documento.toMap());
  }

  Future<void> alternarFavorito(String id) async {
    final atual = _documentsBox.get(id);
    if (atual == null) return;
    final documento = PdfDocumentModel.fromMap(atual as Map);
    await _documentsBox.put(
      id,
      documento.copyWith(isFavorite: !documento.isFavorite).toMap(),
    );
  }

  Future<void> moverParaPasta(String id, String? folderId) async {
    final atual = _documentsBox.get(id);
    if (atual == null) return;
    final documento = PdfDocumentModel.fromMap(atual as Map);
    await _documentsBox.put(
      id,
      documento
          .copyWith(folderId: folderId, clearFolderId: folderId == null)
          .toMap(),
    );
  }

  Future<void> excluir(String id) async {
    final atual = _documentsBox.get(id);
    if (atual != null) {
      final documento = PdfDocumentModel.fromMap(atual as Map);
      final arquivo = File(documento.path);
      if (await arquivo.exists()) {
        await arquivo.delete();
      }
    }
    await _documentsBox.delete(id);
  }

  // Pastas

  List<PdfFolderModel> listarPastas() {
    return _foldersBox.values
        .map((e) => PdfFolderModel.fromMap(e as Map))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<PdfFolderModel> criarPasta(String nome) async {
    final pasta = PdfFolderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nome,
      createdAt: DateTime.now(),
    );
    await _foldersBox.put(pasta.id, pasta.toMap());
    return pasta;
  }

  Future<void> renomearPasta(String id, String novoNome) async {
    final atual = _foldersBox.get(id);
    if (atual == null) return;
    final pasta = PdfFolderModel.fromMap(atual as Map).copyWith(name: novoNome);
    await _foldersBox.put(id, pasta.toMap());
  }

  Future<void> excluirPasta(String id) async {
    for (final documento in _documentosSalvos()) {
      if (documento.folderId == id) {
        await moverParaPasta(documento.id, null);
      }
    }
    await _foldersBox.delete(id);
  }
}
