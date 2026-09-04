import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../components/blueprint_frame.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/dotted_border_box.dart';
import '../../../config/custom_colors.dart';
import '../../../services/content_uri_reader.dart';
import '../../../utils/formatters.dart';
import '../controller/scanner_controller.dart';

/// Tela do scanner replanejada (ver `especificacao/replanejamento/`, tela
/// R3): contagem de páginas visível na barra, grade com miniatura numerada
/// + um item tracejado "Adicionar" (leva direto à câmera sem precisar dos
/// botões do rodapé), e o destino do arquivo declarado antes de gerar.
class ScannerView extends StatelessWidget {
  final ScannerController controller = Get.find();

  ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        tela: 'Escanear',
        golBack: true,
        trailing: Obx(() {
          final n = controller.paginas.length;
          if (n == 0) return const SizedBox.shrink();
          return _Tag(texto: n == 1 ? '1 página' : '$n páginas');
        }),
      ),
      body: Obx(() {
        final paginas = controller.paginas;

        if (paginas.isEmpty) {
          return _buildEstadoVazio(context);
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.75,
                ),
                itemCount: paginas.length + 1,
                itemBuilder: (context, index) {
                  if (index == paginas.length) {
                    return _TileAdicionar(
                      onTap: () => controller.escanearDocumento(),
                    );
                  }
                  return _PaginaThumbnail(uri: paginas[index], numero: index + 1);
                },
              ),
            ),
            _buildRodape(context),
          ],
        );
      }),
    );
  }

  Widget _buildRodape(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Será salvo em Meus Arquivos como '
            '${Formatters.sugestaoNomeArquivo('scan')}.pdf',
            style: CustomColors.monoTextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.58),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.escanearDocumento(),
                  icon: const Icon(LucideIcons.camera),
                  label: const Text('Escanear mais'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => controller.gerarPDF(),
                  icon: const Icon(LucideIcons.fileText),
                  label: const Text('Gerar PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlueprintFrame(
              child: SizedBox(
                width: 140,
                height: 140,
                child: Icon(LucideIcons.scanText,
                    size: 56,
                    color: theme.colorScheme.onSurface.withOpacity(0.35)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhuma página escaneada',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'O scanner detecta as bordas do documento e corrige a '
              'perspectiva automaticamente a cada foto.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.escanearDocumento(),
                icon: const Icon(LucideIcons.camera),
                label: const Text('Escanear documento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de contagem usado na `CustomAppBar` (`.tag-accent` no documento de
/// referência).
class _Tag extends StatelessWidget {
  final String texto;
  const _Tag({required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? CustomColors.tagBgDark : CustomColors.tagBgLight,
      ),
      child: Text(
        texto,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isDark ? CustomColors.tagTextDark : CustomColors.tagTextLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TileAdicionar extends StatelessWidget {
  final VoidCallback onTap;
  const _TileAdicionar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: DottedBorderBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.plus, size: 30, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                'Adicionar',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginaThumbnail extends StatelessWidget {
  final String uri;
  final int numero;

  const _PaginaThumbnail({required this.uri, required this.numero});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlueprintFrame(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: theme.colorScheme.surface),
          FutureBuilder<Uint8List>(
            future: ContentUriReader.readBytes(uri),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Icon(LucideIcons.imageOff,
                      color: theme.colorScheme.error),
                );
              }
              if (snapshot.connectionState != ConnectionState.done ||
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Image.memory(snapshot.data!, fit: BoxFit.cover);
            },
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              color: theme.colorScheme.primary,
              child: Text(
                '$numero',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
