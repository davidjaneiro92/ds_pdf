import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../components/custom_alert.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_list_tile.dart';
import '../../../config/custom_colors.dart';
import '../../../enum/pages_routes.dart';
import '../../../models/pdf_document_model.dart';
import '../controller/my_files_controller.dart';

class MyFilesView extends StatelessWidget {
  final MyFilesController controller = Get.find();

  MyFilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(tela: 'Meus Arquivos', golBack: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: controller.pesquisar,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          _buildFiltros(context),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.documentos.isEmpty) {
                return const Center(
                  child: Text('Nenhum arquivo encontrado.'),
                );
              }
              return ListView.builder(
                itemCount: controller.documentos.length,
                itemBuilder: (context, index) {
                  final documento = controller.documentos[index];
                  return CustomListTile(
                    icon: Icons.picture_as_pdf_outlined,
                    title: documento.displayName,
                    subtitle: DateFormat('dd/MM/yyyy HH:mm')
                        .format(documento.createdAt),
                    onTap: () => controller.compartilhar(documento),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            documento.isFavorite
                                ? Icons.star
                                : Icons.star_border,
                            color: documento.isFavorite
                                ? Colors.amber
                                : Colors.grey,
                          ),
                          onPressed: () =>
                              controller.alternarFavorito(documento),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (opcao) =>
                              _executarAcao(context, opcao, documento),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: 'compartilhar',
                                child: Text('Compartilhar')),
                            PopupMenuItem(
                                value: 'editar', child: Text('Editar')),
                            PopupMenuItem(
                                value: 'renomear', child: Text('Renomear')),
                            PopupMenuItem(
                                value: 'mover',
                                child: Text('Mover para pasta')),
                            PopupMenuItem(
                                value: 'excluir', child: Text('Excluir')),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Obx(() {
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            _chip(
              label: 'Todos',
              selecionado: !controller.somenteFavoritos.value &&
                  controller.pastaSelecionadaId.value == null,
              onTap: () {
                controller.somenteFavoritos.value = false;
                controller.selecionarPasta(null);
              },
            ),
            _chip(
              label: 'Favoritos',
              selecionado: controller.somenteFavoritos.value,
              onTap: controller.alternarSomenteFavoritos,
            ),
            for (final pasta in controller.pastas)
              _chip(
                label: pasta.name,
                selecionado: controller.pastaSelecionadaId.value == pasta.id,
                onTap: () => controller.selecionarPasta(
                  controller.pastaSelecionadaId.value == pasta.id
                      ? null
                      : pasta.id,
                ),
                onLongPress: () => _confirmarExcluirPasta(context, pasta.id),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Nova pasta'),
              onPressed: () => _abrirDialogoNovaPasta(context),
            ),
          ],
        );
      }),
    );
  }

  Widget _chip({
    required String label,
    required bool selecionado,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: ChoiceChip(
          label: Text(label),
          selected: selecionado,
          selectedColor: CustomColors.blue.shade100,
          onSelected: (_) => onTap(),
        ),
      ),
    );
  }

  void _executarAcao(
      BuildContext context, String opcao, PdfDocumentModel documento) {
    switch (opcao) {
      case 'compartilhar':
        controller.compartilhar(documento);
        break;
      case 'editar':
        _abrirEditor(documento);
        break;
      case 'renomear':
        _abrirDialogoRenomear(context, documento);
        break;
      case 'mover':
        _abrirDialogoMoverPasta(context, documento);
        break;
      case 'excluir':
        _confirmarExcluirDocumento(context, documento);
        break;
    }
  }

  Future<void> _abrirEditor(PdfDocumentModel documento) async {
    await Get.toNamed(PagesRoutes.pdfEditorView.path, arguments: documento);
    // O editor salva o resultado como um novo documento; recarrega a lista
    // para ele aparecer assim que o usuário voltar para Meus Arquivos.
    controller.carregar();
  }

  void _confirmarExcluirDocumento(
      BuildContext context, PdfDocumentModel documento) {
    customAalertQuestion(
      context: context,
      title: 'Excluir arquivo',
      message: 'Deseja excluir "${documento.displayName}"? Essa ação não pode ser desfeita.',
      onPressedYes: () => controller.excluir(documento),
    );
  }

  void _confirmarExcluirPasta(BuildContext context, String folderId) {
    customAalertQuestion(
      context: context,
      title: 'Excluir pasta',
      message: 'Os arquivos dessa pasta não serão apagados, só deixarão de estar organizados nela. Continuar?',
      onPressedYes: () => controller.excluirPasta(folderId),
    );
  }

  void _abrirDialogoNovaPasta(BuildContext context) {
    final nomeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova pasta'),
        content: TextField(
          controller: nomeController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nome da pasta'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.criarPasta(nomeController.text);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _abrirDialogoRenomear(
      BuildContext context, PdfDocumentModel documento) {
    final nomeController = TextEditingController(text: documento.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renomear arquivo'),
        content: TextField(
          controller: nomeController,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.renomear(documento, nomeController.text);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _abrirDialogoMoverPasta(
      BuildContext context, PdfDocumentModel documento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mover para pasta'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: const Text('Sem pasta'),
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.moverParaPasta(documento, null);
                    },
                  ),
                  for (final pasta in controller.pastas)
                    ListTile(
                      title: Text(pasta.name),
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.moverParaPasta(documento, pasta.id);
                      },
                    ),
                ],
              )),
        ),
      ),
    );
  }
}
