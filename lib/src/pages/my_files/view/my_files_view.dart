import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../components/blueprint_frame.dart';
import '../../../components/custom_alert.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_list_tile.dart';
import '../../../enum/pages_routes.dart';
import '../../../models/pdf_document_model.dart';
import '../../../utils/formatters.dart';
import '../../select_PDF_type/abstract/select_PDF_type_contoller_abstract.dart';
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
              decoration: const InputDecoration(
                hintText: 'Pesquisar por nome',
                prefixIcon: Icon(LucideIcons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
          _buildFiltros(context),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.documentos.isEmpty) {
                return controller.totalDocumentos == 0
                    ? _buildEstadoVazio(context)
                    : const Center(
                        child: Text('Nenhum arquivo encontrado.'),
                      );
              }
              return ListView.builder(
                itemCount: controller.documentos.length,
                itemBuilder: (context, index) {
                  final documento = controller.documentos[index];
                  return CustomListTile(
                    icon: LucideIcons.fileText,
                    title: documento.displayName,
                    subtitle: Formatters.metadadosDocumento(
                      pageCount: documento.pageCount,
                      path: documento.path,
                      createdAt: documento.createdAt,
                    ),
                    onTap: () => controller.compartilhar(documento),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            LucideIcons.star,
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

  /// Ver `especificacao/replanejamento/`, tela R8: explica o que a tela
  /// faz e já oferece a próxima ação, em vez de só constatar que está
  /// vazia.
  Widget _buildEstadoVazio(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlueprintFrame(
            child: SizedBox(
              width: 132,
              height: 168,
              child: Icon(LucideIcons.fileText,
                  size: 40,
                  color: theme.colorScheme.onSurface.withOpacity(0.3)),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Nada salvo ainda',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Todo PDF que você gerar aparece aqui, com pesquisa, pastas e '
            'favoritos. Comece escaneando um documento.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(PagesRoutes.scannerView.path),
              icon: const Icon(LucideIcons.scanText),
              label: const Text('Escanear documento'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  Get.find<SelectPdfTypeContollerAbstract>().selecionarImagens(),
              child: const Text('Escolher da galeria'),
            ),
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
              label: 'Todos · ${controller.totalDocumentos}',
              selecionado: !controller.somenteFavoritos.value &&
                  controller.pastaSelecionadaId.value == null,
              onTap: () {
                controller.somenteFavoritos.value = false;
                controller.selecionarPasta(null);
              },
            ),
            _chip(
              label: 'Favoritos · ${controller.totalFavoritos}',
              selecionado: controller.somenteFavoritos.value,
              onTap: controller.alternarSomenteFavoritos,
            ),
            for (final pasta in controller.pastas)
              _chip(
                label:
                    '${pasta.name} · ${controller.contagemPasta(pasta.id)}',
                selecionado: controller.pastaSelecionadaId.value == pasta.id,
                onTap: () => controller.selecionarPasta(
                  controller.pastaSelecionadaId.value == pasta.id
                      ? null
                      : pasta.id,
                ),
                onLongPress: () => _confirmarExcluirPasta(context, pasta.id),
              ),
            ActionChip(
              avatar: const Icon(LucideIcons.plus, size: 18),
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
