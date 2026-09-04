import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../components/custom_app_bar.dart';
import '../../../config/custom_colors.dart';
import '../../../enum/pages_routes.dart';
import '../../../utils/formatters.dart';
import '../controller/pdf_reader_controller.dart';

/// Leitor de PDF — a função "padrão" do app: abrir e ler um PDF que já
/// existe, em vez de gerar um novo. Chega aqui um documento de Meus
/// Arquivos/Recentes, um PDF escolhido pelo botão "Abrir PDF" da Início, ou
/// um arquivo aberto por outro app via "Abrir com".
///
/// Segue a linguagem visual das demais telas (ver `specs/04-componentes.md`):
/// barra superior sem faixa colorida, metadados em fonte monoespaçada,
/// cantos retos e rodapé fixo com as ações — sem FAB flutuando sobre o
/// conteúdo, que aqui atrapalharia a leitura.
class PdfReaderView extends StatelessWidget {
  final PdfReaderController controller = Get.find();

  PdfReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        tela: controller.args.titulo,
        golBack: true,
        subtitle: Formatters.tamanhoArquivoDoPath(controller.args.path),
        trailing: Obx(() => IconButton(
              icon: Icon(
                controller.modoBusca.value ? LucideIcons.x : LucideIcons.search,
              ),
              tooltip: controller.modoBusca.value
                  ? 'Fechar pesquisa'
                  : 'Pesquisar no documento',
              onPressed: controller.alternarBusca,
            )),
      ),
      body: Column(
        children: [
          Obx(() => controller.modoBusca.value
              ? _BarraDeBusca(controller: controller)
              : const SizedBox.shrink()),
          Expanded(
            child: SfPdfViewer.file(
              controller.arquivo,
              controller: controller.viewerController,
              onDocumentLoaded: controller.aoCarregar,
              onDocumentLoadFailed: controller.aoFalhar,
              onPageChanged: controller.aoMudarPagina,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableTextSelection: true,
              pageSpacing: 6,
            ),
          ),
          _buildRodape(context),
        ],
      ),
    );
  }

  Widget _buildRodape(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (controller.erro.value != null) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: Text(
            'Não foi possível abrir este PDF: ${controller.erro.value}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavegacaoPaginas(context),
            const SizedBox(height: 6),
            _buildAcoes(context),
          ],
        ),
      );
    });
  }

  Widget _buildNavegacaoPaginas(BuildContext context) {
    final theme = Theme.of(context);
    final total = controller.totalPaginas.value;
    final atual = controller.paginaAtual.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          tooltip: 'Página anterior',
          onPressed: atual > 1 ? controller.paginaAnterior : null,
        ),
        GestureDetector(
          onTap: total > 1 ? () => _abrirDialogoIrParaPagina(context) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              total == 0 ? 'carregando...' : 'página $atual de $total',
              style: CustomColors.monoTextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(LucideIcons.chevronRight),
          tooltip: 'Próxima página',
          onPressed: atual < total ? controller.proximaPagina : null,
        ),
      ],
    );
  }

  Widget _buildAcoes(BuildContext context) {
    final documento = controller.args.documento;
    return Row(
      children: [
        Expanded(
          child: _BotaoAcao(
            icon: LucideIcons.share2,
            rotulo: 'Compartilhar',
            onTap: controller.compartilhar,
          ),
        ),
        if (controller.podeSalvar.value)
          Expanded(
            child: _BotaoAcao(
              icon: LucideIcons.download,
              rotulo: 'Salvar',
              onTap: controller.salvarEmMeusArquivos,
            ),
          ),
        if (documento != null)
          Expanded(
            child: _BotaoAcao(
              icon: LucideIcons.pencil,
              rotulo: 'Editar',
              onTap: () => Get.toNamed(
                PagesRoutes.pdfEditorView.path,
                arguments: documento,
              ),
            ),
          ),
      ],
    );
  }

  void _abrirDialogoIrParaPagina(BuildContext context) {
    final campo = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ir para página'),
        content: TextField(
          controller: campo,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '1 - ${controller.totalPaginas.value}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final pagina = int.tryParse(campo.text.trim());
              if (pagina != null) controller.irParaPagina(pagina);
            },
            child: const Text('Ir'),
          ),
        ],
      ),
    );
  }
}

/// Faixa de pesquisa dentro do documento, aberta pela lupa da barra
/// superior. Mostra "n/N" enquanto há resultado, com as setas para percorrer
/// as ocorrências.
class _BarraDeBusca extends StatelessWidget {
  final PdfReaderController controller;
  const _BarraDeBusca({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: controller.pesquisar,
              decoration: const InputDecoration(
                hintText: 'Pesquisar no documento',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),
          Obx(() {
            final resultado = controller.resultadoBusca.value;
            if (resultado == null) return const SizedBox(width: 8);
            return AnimatedBuilder(
              animation: resultado,
              builder: (context, _) {
                if (!resultado.hasResult) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 12),
                    child: Text(
                      resultado.isSearchCompleted ? 'nada' : '...',
                      style: CustomColors.monoTextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      '${resultado.currentInstanceIndex}/'
                      '${resultado.totalInstanceCount}',
                      style: CustomColors.monoTextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.chevronUp),
                      tooltip: 'Ocorrência anterior',
                      onPressed: controller.ocorrenciaAnterior,
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.chevronDown),
                      tooltip: 'Próxima ocorrência',
                      onPressed: controller.proximaOcorrencia,
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

/// Botão do rodapé: ícone sobre rótulo, mesmo formato da barra de
/// ferramentas do Editor de PDF.
class _BotaoAcao extends StatelessWidget {
  final IconData icon;
  final String rotulo;
  final VoidCallback onTap;

  const _BotaoAcao({
    required this.icon,
    required this.rotulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: theme.colorScheme.primary),
              const SizedBox(height: 3),
              Text(
                rotulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
