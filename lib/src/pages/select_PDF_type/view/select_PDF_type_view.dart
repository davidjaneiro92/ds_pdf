import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../components/blueprint_frame.dart';
import '../../../config/custom_colors.dart';
import '../../../config/theme_controller.dart';
import '../../../enum/pages_routes.dart';
import '../../../models/pdf_document_model.dart';
import '../../../utils/formatters.dart';
import '../../pdf_reader/pdf_reader_launcher.dart';
import '../abstract/select_PDF_type_contoller_abstract.dart';

/// Tela inicial (ver `especificacao/replanejamento/`, telas R1 claro/escuro).
///
/// Desde 2026-09-04 a tela é dividida em duas seções: **Ler PDF**, com a
/// ação primária "Abrir PDF" no topo — ler passou a ser a função padrão do
/// app —, e **Criar PDF**, com Escanear/Galeria/Texto. A lista de
/// "Recentes" fecha a tela e agora abre cada item direto no leitor, em vez
/// de só levar a Meus Arquivos.
class SelectPdfTypeView extends StatelessWidget {
  final SelectPdfTypeContollerAbstract controller = Get.find();

  SelectPdfTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildCabecalho(context, themeController),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ler PDF', style: _rotuloSecao(theme)),
                    const SizedBox(height: 12),
                    _cardPrimario(context),
                    const SizedBox(height: 28),
                    Text('Criar PDF', style: _rotuloSecao(theme)),
                    const SizedBox(height: 12),
                    _cardEscanear(context),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _cardSecundario(
                            context,
                            icon: LucideIcons.images,
                            titulo: 'Galeria',
                            subtitulo: 'Fotos já salvas',
                            onTap: () async {
                              await controller.selecionarImagens();
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _cardSecundario(
                            context,
                            icon: LucideIcons.fileText,
                            titulo: 'Texto',
                            subtitulo: 'Digitar e paginar',
                            onTap: () async {
                              await Get.toNamed(PagesRoutes.textToPdfView.path);
                              controller.carregarRecentes();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildRecentes(context, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabecalho(BuildContext context, ThemeController themeController) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 20, right: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'DS PDF',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.search),
            tooltip: 'Pesquisar',
            onPressed: () => Get.toNamed(PagesRoutes.myFilesView.path),
          ),
          Obx(() => IconButton(
                icon: Icon(
                  themeController.isDark ? LucideIcons.sun : LucideIcons.moon,
                ),
                tooltip: themeController.isDark ? 'Tema claro' : 'Tema escuro',
                onPressed: themeController.alternar,
              )),
        ],
      ),
    );
  }

  TextStyle? _rotuloSecao(ThemeData theme) => theme.textTheme.titleSmall
      ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6));

  /// Ação primária da tela: **abrir** um PDF que já existe no aparelho. Era
  /// o "Escanear documento" até 2026-09-04, quando o app passou a ser
  /// também um leitor de PDF e a leitura virou a função padrão — escanear
  /// desceu para a seção "Criar PDF" (ver `specs/CHANGELOG.md`).
  Widget _cardPrimario(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
      child: InkWell(
        onTap: () async {
          await PdfReaderLauncher.escolherEAbrir();
          controller.carregarRecentes();
        },
        child: BlueprintFrame(
          borderColor: theme.colorScheme.onPrimary.withOpacity(0.4),
          child: Container(
            height: 128,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(LucideIcons.bookOpen,
                    size: 40, color: theme.colorScheme.onPrimary),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Abrir PDF',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Ler, pesquisar e navegar por um arquivo do aparelho',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onPrimary.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Escanear em formato largo (ícone à esquerda, texto à direita): continua
  /// sendo a principal forma de *criar* um PDF, mas já não disputa o topo da
  /// tela com a leitura.
  Widget _cardEscanear(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Get.toNamed(PagesRoutes.scannerView.path);
          controller.carregarRecentes();
        },
        child: BlueprintFrame(
          child: Container(
            height: 84,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(LucideIcons.scanText,
                    size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Escanear documento',
                          style: theme.textTheme.titleMedium),
                      Text(
                        'Detecta as bordas e corrige a perspectiva',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardSecundario(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: BlueprintFrame(
          child: Container(
            height: 104,
            padding: const EdgeInsets.all(14),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 26, color: theme.colorScheme.primary),
                const SizedBox(height: 6),
                Text(titulo, style: theme.textTheme.titleMedium),
                Text(
                  subtitulo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentes(BuildContext context, ThemeData theme) {
    return Obx(() {
      final recentes = controller.recentes;
      if (recentes.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Recentes', style: _rotuloSecao(theme))),
              GestureDetector(
                onTap: () => Get.toNamed(PagesRoutes.myFilesView.path),
                child: Text(
                  'Ver todos',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          for (final documento in recentes) _itemRecente(context, documento),
        ],
      );
    });
  }

  Widget _itemRecente(BuildContext context, PdfDocumentModel documento) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => PdfReaderLauncher.abrirDocumento(documento),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.fileText,
                size: 22, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documento.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    Formatters.metadadosDocumento(
                      pageCount: documento.pageCount,
                      path: documento.path,
                      createdAt: documento.createdAt,
                    ),
                    style: CustomColors.monoTextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.58),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
