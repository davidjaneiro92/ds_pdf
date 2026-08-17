import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/custom_app_bar.dart';
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.58),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.escanearDocumento(),
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Escanear mais'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => controller.gerarPDF(),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
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
            Icon(Icons.document_scanner_outlined,
                size: 96, color: theme.colorScheme.onSurface.withOpacity(0.35)),
            const SizedBox(height: 16),
            Text(
              'Nenhuma página escaneada ainda',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.escanearDocumento(),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Escanear documento'),
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
        borderRadius: BorderRadius.circular(CustomColors.radiusSm),
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
        borderRadius: BorderRadius.circular(CustomColors.radiusLg),
        onTap: onTap,
        child: DottedBorderBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 30, color: theme.colorScheme.primary),
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

/// Moldura tracejada simples (sem depender de pacote externo) para o item
/// "Adicionar" da grade — desenhada com `CustomPaint`.
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary.withOpacity(0.5);
    return CustomPaint(
      painter: _DashedRectPainter(color: cor, radius: CustomColors.radiusLg),
      child: child,
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      const dashWidth = 5.0;
      const gapWidth = 4.0;
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _PaginaThumbnail extends StatelessWidget {
  final String uri;
  final int numero;

  const _PaginaThumbnail({required this.uri, required this.numero});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(CustomColors.radiusLg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: theme.colorScheme.surface),
          FutureBuilder<Uint8List>(
            future: ContentUriReader.readBytes(uri),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Icon(Icons.broken_image_outlined,
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
            child: CircleAvatar(
              radius: 13,
              backgroundColor: theme.colorScheme.primary,
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
