import 'dart:io';

import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../../../components/custom_toast.dart';
import '../../../models/pdf_document_model.dart';
import '../../../models/pdf_folder_model.dart';
import '../../../repositories/pdf_documents_repository.dart';
import '../abstract/my_files_controller_abstract.dart';

class MyFilesController extends GetxController
    implements MyFilesControllerAbstract {
  final _repository = Get.find<PdfDocumentsRepository>();

  final RxList<PdfDocumentModel> documentos = <PdfDocumentModel>[].obs;
  final RxList<PdfFolderModel> pastas = <PdfFolderModel>[].obs;

  final RxString termoPesquisa = ''.obs;
  final Rx<String?> pastaSelecionadaId = Rx<String?>(null);
  final RxBool somenteFavoritos = false.obs;

  List<PdfDocumentModel> _todos = [];

  @override
  int get totalDocumentos => _todos.length;

  @override
  int get totalFavoritos => _todos.where((d) => d.isFavorite).length;

  @override
  int contagemPasta(String folderId) =>
      _todos.where((d) => d.folderId == folderId).length;

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  @override
  Future<void> carregar() async {
    _todos = await _repository.listarDocumentos();
    pastas.assignAll(_repository.listarPastas());
    _aplicarFiltros();
  }

  void pesquisar(String termo) {
    termoPesquisa.value = termo;
    _aplicarFiltros();
  }

  void selecionarPasta(String? folderId) {
    pastaSelecionadaId.value = folderId;
    _aplicarFiltros();
  }

  void alternarSomenteFavoritos() {
    somenteFavoritos.value = !somenteFavoritos.value;
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    final termo = termoPesquisa.value.trim().toLowerCase();

    final filtrados = _todos.where((documento) {
      if (termo.isNotEmpty &&
          !documento.displayName.toLowerCase().contains(termo)) {
        return false;
      }
      if (somenteFavoritos.value && !documento.isFavorite) {
        return false;
      }
      if (pastaSelecionadaId.value != null &&
          documento.folderId != pastaSelecionadaId.value) {
        return false;
      }
      return true;
    }).toList();

    documentos.assignAll(filtrados);
  }

  @override
  Future<void> renomear(PdfDocumentModel documento, String novoNome) async {
    if (novoNome.trim().isEmpty) return;
    await _repository.renomear(documento.id, novoNome.trim());
    await carregar();
  }

  @override
  Future<void> excluir(PdfDocumentModel documento) async {
    await _repository.excluir(documento.id);
    await carregar();
  }

  @override
  Future<void> compartilhar(PdfDocumentModel documento) async {
    try {
      final arquivo = File(documento.path);
      final bytes = await arquivo.readAsBytes();
      await Printing.sharePdf(bytes: bytes, filename: documento.fileName);
    } catch (e) {
      CustomToast().showToasts(
        messagem: 'Não foi possível compartilhar o arquivo.',
        status: status.error,
      );
    }
  }

  @override
  Future<void> alternarFavorito(PdfDocumentModel documento) async {
    await _repository.alternarFavorito(documento.id);
    await carregar();
  }

  @override
  Future<void> criarPasta(String nome) async {
    if (nome.trim().isEmpty) return;
    await _repository.criarPasta(nome.trim());
    await carregar();
  }

  @override
  Future<void> moverParaPasta(
      PdfDocumentModel documento, String? folderId) async {
    await _repository.moverParaPasta(documento.id, folderId);
    await carregar();
  }

  @override
  Future<void> excluirPasta(String folderId) async {
    await _repository.excluirPasta(folderId);
    if (pastaSelecionadaId.value == folderId) {
      pastaSelecionadaId.value = null;
    }
    await carregar();
  }
}
